(def location 'living-room)

(def nodes  
  '((living-room (you are in the living-room.  a wizard is snoring loudly on the couch.))
  (garden (you are in a beautiful garden. there is a well in front of you.))
  (attic (you are in the attic.  there is a giant welding torch in the corner.))))

(def edges  
  '((living-room (garden west door) (attic upstairs ladder))
  (garden (living-room east door))
  (attic (living-room downstairs ladder))))

(def objects '(whiskey bucket frog chain))

(def ^:dynamic *object-locations*
  '((whiskey living-room) 
    (bucket living-room)
    (chain garden)
    (frog garden)))

(defn car [lst]
  (first lst))

(defn cdr [lst]
  (rest lst))

(defn cadr [lst]
  (first (rest lst)))

(defn caddr [lst]
  (first (rest (rest lst))))

(defn assoc-cl [thing alist]
   (if (nil? alist)
       false
       (if (= (car (car alist)) thing)
           (car alist)
           (assoc-cl thing (cdr alist)))))

(defn describe-location [location nodes]
  (cadr (assoc-cl location nodes)))

; fixes this problem
; my-namespace=> `(a b c)
; (my-namespace/a my-namespace/b my-namespace/c)
; my-namespace=> (map symbol (map name *1))
; (a b c)
(defn getsym [quoted-string]
  (symbol (name quoted-string)))

(defn describe-path [edge]
  (map getsym `(there is a ~(caddr edge) going ~(cadr edge) from here.)))

;(defn describe-paths [location edges]
;  (apply append (map describe-path (cdr (assoc-cl location *edges*)))))

