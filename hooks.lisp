(in-package #:issr)

(defvar *hook-listener-name* "issr-hook-listener")

(defvar *connect-hooks* (list))

(defvar *disconnect-hooks* (list))

(defvar *file-upload-hook*
  (lambda (uuid path filename filetype)
    (declare (ignore uuid))
    (jojo:to-json (list :|file| path :|name| filename :|content-type| filetype))))

(defun start-hook-listener ()
  (bt:make-thread
   (lambda ()
     (block exit
       (loop
         (block continue
           (handler-case 
               (with-redis-connection
                 (red:subscribe (str:concat "issr-" (server-uuid)))
                 (loop 
                   (let ((message (redis:expect :anything)))
                     (bt:make-thread
                      (lambda ()
                        (with-redis-connection
                          (match (jojo:parse (third message))
                            ((list "issr-connect" uuid)
                             (loop for function in *connect-hooks* do
                               (funcall function uuid)))
                            ((list "issr-disconnect" uuid)
                             (loop for function in *disconnect-hooks* do
                               (funcall function uuid)
                               (red:publish (str:concat "issr-" uuid "-disconnect-done") "")))
                            ((list "issr-file-upload" uuid
                                   (plist :|file| file :|name| name :|content-type| content-type))
                             (red:publish (str:concat "issr-" uuid "-file-upload-done")
                                          (funcall *file-upload-hook* uuid file name content-type))))))))))
             (usocket:connection-refused-error ()
               (sleep 2)
               (format *debug-io* "Trying to connect to redis.~%")
               (return-from continue))
             (redis:redis-bad-reply () (return-from continue))
             (end-of-file () (return-from continue)))))))
   :name *hook-listener-name*))

(defun stop-hook-listener ()
  (let ((hook-listeners
          (remove *hook-listener-name*
                  (bt:all-threads)
                  :key 'bt:thread-name
                  :test-not 'string=)))
    (when hook-listeners
      (mapc 'bt:destroy-thread hook-listeners))))
