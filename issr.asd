(in-package #:asdf-user)

(defsystem issr
  :depends-on
  (#:alexandria
   #:binding-arrows
   #:cl-redis
   #:jonathan
   #:uuid
   #:str
   #:trivia)
  :serial t
  :components
  ((:file "package")
   (:file "utils")
   (:file "commands")
   (:file "hooks")))
