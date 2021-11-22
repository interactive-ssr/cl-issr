(in-package #:issr)

(defun server-uuid ()
  (let ((filename
          (merge-pathnames
           "issr/uuid.txt"
           (or (uiop:getenvp "XDG_DATA_HOME")
               "~/.local/share/"))))
    (unless (uiop:directory-exists-p (pathname-directory filename))
      (ensure-directories-exist filename))
    (if (uiop:file-exists-p filename)
        (uiop:read-file-string filename)
        (with-open-file (out filename
                             :direction :output
                             :if-does-not-exist :create)
          (let ((uuid (princ-to-string (uuid:make-v4-uuid))))
            (write-sequence uuid out))))))

(defun destination-parts (destination)
  (typecase destination
    (integer
     (values "localhost" destination))
    (string
     (let ((parts (str:split ":" destination :omit-nulls t)))
       (values (first parts)
               (parse-integer (second parts)))))))

(defun issr-keys (main-key &rest keys)
  (->> keys
    (map 'list (compose 'str:downcase 'princ-to-string))
    (cons (str:concat "issr-" (princ-to-string main-key)))
    (str:join ":")))


(defvar *redis-destination* "localhost:6379")

(defvar *redis-password* nil)

(defmacro with-redis-connection (&body body)
  `(multiple-value-bind (redis-host redis-port)
       (destination-parts *redis-destination*)
     (redis:with-connection (:host redis-host :port redis-port :auth *redis-password*)
       ,@body)))
