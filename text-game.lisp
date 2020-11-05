;; loading lol

(load "socket.lisp")
(load "kansas.lisp")
;(load "laboratory.lisp")

;; really need to figure out how to do this by location-
;; after random number, figure out if the person can be where the player is
(defun random-encounter-bad (enc)
 ; based on where you are, you may encounter a coworker 
    (setf *nearby-person* (caaddr (assoc enc *encounters*)))
    (cadr (assoc enc *encounters*)))

(defun random-encounter (enc)
 ; based on where you are, you may encounter a coworker 
  (setf *nearby-person* nil)
  (let ((tmp (caadr (assoc enc *encounters*))))
    ;(setf *nearby-person* (caaddr (assoc enc *encounters*)))
    (if (and (not (eq tmp nil)) 
             (member *location* (cadr (assoc 'allowed-locations (cdr (assoc tmp *people*))))))
      (setf *nearby-person* (caadr (assoc enc *encounters*))))
    (cadr (assoc 'sighting-msg (cdr (assoc *nearby-person* *people*))))))

(defun event-check (enc)
  (setf *current-event* nil)
  (let ((event (caadr (assoc enc *events-at-moves*))))
    (if (and (not (eq event nil)) 
             (member *location* (cadr (assoc 'allowed-locations (cdr (assoc event *events*))))))
      (setf *current-event* (caadr (assoc enc *events-at-moves*))))
    (let ((action (cadr (assoc 'action (cdr (assoc event *events*))))))
      ;(format t "~% ~A ~%" action)
      (if (not (eq action nil))
        (eval (list action))))
    (cadr (assoc 'sighting-msg (cdr (assoc *current-event* *events*))))
))

(defun thing-check (enc thing1 thing2 thing3)
  (set thing1 nil)
  (let ((tmp (caadr (assoc enc thing2))))
    (if (and (not (eq tmp nil)) 
             (member *location* (cadr (assoc 'allowed-locations (cdr (assoc tmp thing3))))))
      (set thing1 (caadr (assoc enc thing2))))
    (cadr (assoc 'sighting-msg (cdr (assoc (symbol-value thing1) thing3))))
))

;(defun event-action ()
(defun event-check2 (enc)
  (thing-check enc '*current-event* *events-at-moves* *events*)
)
(defun random-encounter2 (enc)
  (thing-check enc '*nearby-person* *encounters* *people*)
)

(defun describe-location (location nodes)
  (cadr (assoc location nodes)))

;; wanted to change sentence from:
;; you see a path going north from here.
;; to
;; you see a path to the north.
;; but had a problem smushing the period to the cadr edge 
;; so see what i had to do to make it work
;; SIDE-EFFECT: (cadr edge) remains in all caps, but i like that
(defun describe-path (edge)
  `(there is a ,(caddr edge) to the ,(concatenate 'string (string (cadr edge)) "." )))
  ;`(there is a ,(caddr edge) to the ,(cadr edge)"."))
  ;`(there is a ,(caddr edge) going ,(cadr edge) from here.))

;; I wrote this but it functions much like the built-in (assoc)
;; couple problems, main one is an unknown location puts it in loop
(defun show-paths (location edges)
  (if (equal (car (car edges)) location) 
    (cdr (car edges))
    (show-paths location (cdr edges))))

(defun describe-paths (location edges)
  (apply (function append) (mapcar #'describe-path (cdr (assoc location edges)))))

;; (objects-at *location* *objects* *object-locations*)
;; returns
;; (BADGE LUNCH RAINCOAT PAPER)
(defun objects-at (loc objs obj-locs) 
  (labels ((at-loc-p (obj)
    (eq (cadr (assoc obj obj-locs)) loc))) 
    (remove-if-not #'at-loc-p objs)))

(defun describe-objects2 (loc objs obj-loc) 
  (labels ((describe-obj (obj)
    `(you see a ,obj on the floor.)))
(apply #'append (mapcar #'describe-obj (objects-at loc objs obj-loc)))))

(defun describe-objects (loc objs obj-loc) 
  (labels ((describe-obj (obj)
           (let ((ol (caddr (assoc obj obj-loc)))) 
            `(you see a ,obj on ,ol))))
    (apply #'append (mapcar #'describe-obj (objects-at loc objs obj-loc)))))

;;;;;;;;;;;;;;;;;;;;
;; player commands

;; laboratory specific code 
(defun use-badge ()
  (push (list 'front-door '(lobby north door)) *edges*) 
  '(you used your badge to open the front door.)
)

(defun use (item)
  (cond
    ((not (member item (objects-at 'body *objects* *object-locations*))) '(you dont have that!))
    ;; to use the badge, you must 
    ;; 1) have the badge
    ;; 2) be near a keypad
    ((and 
        (eq item 'badge) 
        (member 'badge (objects-at 'body *objects* *object-locations*))
        (eq *location* 'front-door))
      (use-badge))
      ;; to make badge actually do something, we'll append a path onto the edges structure
      ;; in the direction of the door. note we'll ahve to remove it and put the description 
      ;; of the locked door in the nodes
    (t '(you cant use that here.))))

(defun stats ()
  `(you have made ,*stats-moves* moves.))

(defun look ()
  (append 
    (describe-location *location* *nodes*)
    (describe-paths *location* *edges*)
    (describe-objects *location* *objects* *object-locations*)
    (random-encounter2 (random *total-encounters*))
    ;;(event-check *stats-moves*)
))

(defun wait () 
)

(defun openthing (thing &rest thing-more)
  (let ((d (find thing (cdr (assoc *location* *edges*)) :key #'caddr)))
    (if (eq d nil) 
      `(there is no ,thing nearby.)
      `(you opened the ,thing"."))))
  
;; Player should be able to say bye
;; NPC should also say bye at some point
;; finds keyword in person's response list
;; need to deal with nil
;; also need to deal with player typing in a sentence
;; we should pass each word into this function to
;; see if any key off the npc
(defun respond (text person)
    (let ((r (cdr (assoc text (cdr (assoc person *people*))))))
      (if (eq text 'bye) (setq *nearby-person* nil))
      (if (not r)
      (cdr (assoc 'default (cdr (assoc person *people*))))
      r))
    ;(setf *nearby-person* nil)
    ;`(,person runs away.))
)

;; adding code so this handles multiple args better
;; it used to just crash the program
;; what if they could say "go living room"
(defun walk (direction &rest dir-more)
  (let ((next 
          (find direction (cdr (assoc *location* *edges*)) :key #'cadr)))
    (if next
      (progn 
        (setf *location* (car next))
        (look))
      (progn
        (if dir-more
          '(please try "go direction" for example "go north")
          '(you cannot go that way.))))))
 
;; not sure if I want to bother with the
;; full sentence parsing thing
;; might be simpler just to have player key
;; off certain words said by NPC ala Ultima
;(defun talk (text &rest text2)
(defun talk (text &rest text-more)
  (if (not (equal *nearby-person* nil))
    (respond text *nearby-person*)
   '(theres nobody to talk to near by.)))
  
(defun pickup (object &rest obj-more)
  (cond 
    ;; Is the object I want to pickup in the location that I am?
    ((member object (objects-at *location* *objects* *object-locations*)) 
       ;; if so, change the object-location to "body" and return 'carrying' text
       (push (list object 'body) *object-locations*) 
      `(you are now carrying the ,object)) 
     (t '(you cannot get that.))))      

;; nf
(defun inventory (a &rest b)
  (cons 'items- (objects-at 'body *objects* *object-locations*)))

(defparameter *synonym-pickup* '(grab get take))
(defparameter *synonym-walk* '(go move run))
(defparameter *synonym-talk* '(say speak shout whisper respond ask))
(defparameter *synonym-open* '(open unlock openthing))
(defparameter *allowed-commands* (append '(look walk talk pickup inventory stats use) *synonym-pickup* *synonym-walk* *synonym-talk* *synonym-open*))

;;;;;;;;;;;;;;;;;;;;;;;
;; Core game functions
;; nf
(defun game-read (rcmd)
  (let ((cmd (read-from-string
    (concatenate 'string "(" rcmd ")"))))
    (flet ((quote-it (x) (list 'quote x)))
      (cons (car cmd) (mapcar #'quote-it (cdr cmd))))))

;; what if I keep track of things they try to do but arent allowed?
;; nf
(defun game-eval (sexp)
  (progn
    ;(format t "~% ~A ~%" sexp)
  (if (member (car sexp) *allowed-commands*)
    (cond
      ((member (car sexp) *synonym-pickup*) (eval (cons 'pickup (cdr sexp))))
      ((member (car sexp) *synonym-walk*) (eval (cons 'walk (cdr sexp))))
      ((member (car sexp) *synonym-talk*) (eval (cons 'talk (cdr sexp))))
      ((member (car sexp) *synonym-open*) (eval (cons 'openthing (cdr sexp))))
      ;((equal (car sexp) 'stats) (eval '(stats)))
      (t (eval sexp)))
  '(?SYNTAX ERROR))))
  ;;'(i do not know that command.)))

;; my temporary game-print, the real one is really complicated...
;(defun game-print (x)
;  (format t "~% ~A ~%" x))

;; yf
(defun tweak-text (lst caps lit) 
  (when lst 
    (let ((item (car lst)) (rest (cdr lst))) 
      (cond 
        ((eq item #\space) (cons item (tweak-text rest caps lit))) 
        ((member item '(#\! #\? #\.)) (cons item (tweak-text rest t lit))) 
        ((eq item #\") (tweak-text rest caps (not lit)))
        (lit (cons item (tweak-text rest nil lit)))
        ((or caps lit) (cons (char-upcase item) (tweak-text rest nil lit))) 
        (t (cons (char-downcase item) (tweak-text rest nil nil)))))))

;; nf
;; added if not eq nil to accomodate use of event-check in game-repl
(defun game-print (lst)
  (if (not (eq nil lst))
  (princ 
    (coerce 
      (tweak-text (coerce (string-trim "() " (prin1-to-string lst)) 'list) t nil) 
      'string)))
  (fresh-line))

;; nf
(defun game-repl-sock (s)
  (let ((cmd (game-read (read-line s)))(*standard-output* s))
    (if (not (eq (car cmd) 'stats))
      (setq *stats-moves* (+ *stats-moves* 1)))
    (unless (eq (car cmd) 'quit) 
      (game-print (game-eval cmd))
      (force-output s)
      (game-repl-sock s))))

(defun game-repl ()
  (let ((cmd (game-read (read-line))))
    (if (not (eq (car cmd) 'stats))
      (progn
        (setq *stats-moves* (+ *stats-moves* 1))
        (game-print (event-check *stats-moves*))
      )
    )
    (unless (eq (car cmd) 'quit) 
      (game-print (game-eval cmd))
      (game-repl))))

(defun start-server ()
  (let ((c (socket-accept (socket-listen 8080))))
    (unwind-protect
      ;(sb-bsd-sockets:socket-send c *data* (length *data*) :external-format :utf-8)
    ;(let ((stream (sb-bsd-sockets:socket-make-stream c :output t :input t)))
    (with-open-stream (stream (sb-bsd-sockets:socket-make-stream c :output t :input t))
      ;(defparameter *standard-output* stream)
      (game-repl-sock stream))
    (sb-bsd-sockets:socket-close c))))

;; Stuff Ive added:
;; random encounters
;; talking engine
;; synonyms for commands
;; use objects in certain locations
;; stats with move counter
;; more descriptive object locations
;; events
