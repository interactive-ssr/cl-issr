(in-package #:asdf-user)

(defsystem issr
  :description "Software Development Kit for working with Interactive Server
Side Rendering (ISSR) for Common Lisp (obviously). It provides an interface to
define hooks for connect, disconnect, and file-upload. It also has functions for
geting information like headers and cookies about a given client."
  :version "1.0"
  :author "Charles Jackson <charles.b.jackson@protonmail.com>"
  :licence "LLGPL"
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
