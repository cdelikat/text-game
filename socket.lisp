(require 'sb-bsd-sockets)

(defparameter socket-any-address '(0 0 0 0))

(defun socket-listen (port)
  (let ((socket (make-instance 'sb-bsd-sockets:inet-socket
			       :type :stream :protocol :tcp)))
    (setf (sb-bsd-sockets:sockopt-reuse-address socket) t)
    (sb-bsd-sockets:socket-bind socket socket-any-address port)
    (sb-bsd-sockets:socket-listen socket 1)
    (setf (sb-bsd-sockets:sockopt-reuse-address socket) 1)
    socket))

;; returns a stream
(defun socket-accept-stream (s)
  (sb-bsd-sockets:socket-make-stream (sb-bsd-sockets:socket-accept s)
				     :output t
				     :input t))

(defun socket-accept (s)
  (sb-bsd-sockets:socket-accept s))

(defun socket-server-close (s)
  (sb-bsd-sockets:socket-close s))

(defparameter *data* (format nil "deli~%"))

(defun srepl (s)
  (let ((inp (read-line s)))
    (format s "~A~&" inp)
    (force-output s)
    (srepl s)))

(defun main ()
  (let ((c (socket-accept (socket-listen 8080))))
    (unwind-protect
      ;(sb-bsd-sockets:socket-send c *data* (length *data*) :external-format :utf-8)
    (let ((stream (sb-bsd-sockets:socket-make-stream c :output t :input t)))
     ;;(format stream "test~&"))
      (srepl stream))
    (sb-bsd-sockets:socket-close c))))

;; bind
;; listen
;; accept
;; loop
;;  read
;;    process
;;  send
