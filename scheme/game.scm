(define *location* 'living-room)

(define *nodes* 
  '((living-room (you are in the living-room.  a wizard is snoring loudly on the couch.))
  (garden (you are in a beautiful garden. there is a well in front of you.))
  (attic (you are in the attic.  there is a giant welding torch in the corner.))))

(define *edges* 
  '((living-room (garden west door) (attic upstairs ladder))
  (garden (living-room east door))
  (attic (living-room downstairs ladder))))

(define *objects* '(whiskey bucket frog chain))

(define *object-locations* 
  '((whiskey living-room) 
    (bucket living-room)
    (chain garden)
    (frog garden)))

(define (describe-location location *nodes*)
  (cadr (assoc location *nodes*)))

(define (describe-path edge)
  `(there is a ,(caddr edge) going ,(cadr edge) from here.))

(define (describe-paths location *edges*)
  (apply append (map describe-path (cdr (assoc location *edges*)))))

;; needed to define filter for following function to work
(define (filter pred lst)
  (cond 
    ((null? lst) '())
    ((pred (car lst))
     (cons (car lst) (filter pred (cdr lst))))
    (else (filter pred (cdr lst)))))

; ported "labels" to "letrec"
; replaced "remove-if-not" with my own "filter", above
(define (objects-at location objects object-locations)
  (letrec 
    ((at-loc-p (lambda (object)
      (eq? (cadr (assoc object object-locations)) location))))
    (filter at-loc-p objects)))
  
; ported apply line to be more scheme-like
(define (describe-objects location objects object-locations) 
  (letrec 
    ((describe-obj (lambda (object)
      `(you see a ,object on the floor.))))
    (apply append (map describe-obj (objects-at location objects object-locations)))))


;; helper function for find
(define (find-item sym lst)
  (cond
    ((not (equal? (member sym lst) #f)) lst)
    (else #f)))

;; finds a value within a list of lists
;; not for any other use
;; ts> (find 'north '((yard west window) (door east path) (road north bridge)))
;; (road north bridge)
(define (find sym lst)
  (cond
    ((null? lst) '())
    ((find-item sym (car lst)))
    (else (find sym (cdr lst)))))

; ported progn to begin, setf to set!
; had to create my own "find", see above
(define (walk direction)
  (let ((next (find direction (cdr (assoc *location* *edges*)))))
    (if next
      (begin
        (set! *location* (car next))
        (look))
      '(you cannot go that way.))))

(define (inventory)
  (cons 'items- (objects-at 'body *objects* *object-locations*)))

; ported "push" to (set! ... (cons ...)
(define (pickup object)
  (cond 
    ((member object (objects-at *location* *objects* *object-locations*))
    (set! *object-locations* (cons (list object 'body) *object-locations*))
    `(you are now carrying the ,object))
        (t '(you cannot get that.))))

;; Calls GLOBAL variables here
(define (look)
  (append 
    (describe-location *location* *nodes*)
    (describe-paths *location* *edges*)
    (describe-objects *location* *objects* *object-locations*)))
