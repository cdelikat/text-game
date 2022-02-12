;; utility functions the may be used anywhere 
;; in the code, including people and places files

;; flattens list
;; (pt ((TO THE EAST YOU SEE (PARKING LOT.)) (TO THE SOUTH YOU SEE (PARKING LOT.))))
;; returns
;; (TO THE EAST YOU SEE PARKING LOT. TO THE SOUTH YOU SEE PARKING LOT.) 
(defun flatten (lst)
  (cond
    ((eq lst nil) '())
    ((atom (car lst)) (cons (car lst) (flatten (cdr lst))))
    (t (append (flatten (car lst)) (flatten (cdr lst)))))
)
