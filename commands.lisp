(in-package #:issr)

(defun rr (id &optional args)
  (with-redis-connection
    (red:publish "issr-rr"
                 (jojo:to-json (list (server-uuid) id args)
                               :from :alist))))

(defun get-from-redis (id key subkey)
  (with-redis-connection
    (let ((result (red:hget (issr-keys id key) subkey)))
      (when result
        (jojo:parse result)))))

(defun header (id header)
  (get-from-redis id :headers header))

(defun cookie (id cookie)
  (get-from-redis id :cookies-in cookie))

(defun query (id query)
  (get-from-redis id :query-arguments query))
