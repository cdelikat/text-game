(defun opp-dir (direction)
  (let ((dirs '((north south) (south north) (east west) (west east))))
    (cadr (assoc direction dirs))))

;; verify every item in edges is positioned correctly from every other item
;; according to their respective direction lists
(defun checker ()
  (dolist (lista *edges*)
    (format t "~%lista =  ~A ~%" lista)
    (let ((main-loc-name (car lista))(main-dir-list (cdr lista)))
      (dolist (listb main-dir-list)
        (let ((next-loc-name (car listb))(next-loc-dir (cadr listb)))
          (if (not (eq (opp-dir next-loc-dir) 
                  (cadr (assoc main-loc-name (cdr (assoc next-loc-name *edges*))))))
              ;;(format t "~% ~A is ~A of ~A~%" next-loc-name next-loc-dir main-loc-name)
              (cond
                ((eq nil (assoc next-loc-name *edges*)) (format t "~% NO ~A in *edges* ~%" next-loc-name))
                (t (format t "~% ~A is NOT ~A of ~A~%" next-loc-name next-loc-dir main-loc-name)))
          ))
        )
      )))

;; verify that every location name in edges exists in nodes
(defun noder (e other)
  (cond
    ((eq e nil) t)
    (t  (progn
          (if (not (assoc (caar e) other))
            (format t "~% MISSING from *nodes*: ~A ~%" (caar e))
            (print "YUP"))
        (noder (cdr e) other)
        )
)))
