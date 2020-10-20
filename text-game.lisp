;; loading lol

(load "socket.lisp")

;; begin the game in your car
(defparameter *location* 'your-car)
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)

(defparameter *nodes* 
  '((parking-lot (You are in the parking lot just south of the "Laboratories" for "Sciences" "Department."))
    (your-car (You are in your car in the parking lot of the "Laboratories" for "Sciences" "Department." ))
    (main-path (You are on the path to the door to the "LSD" building. You see a bench.))
    (forest-path (You are on the forest path. You see a stream and a log laying across the stream.))
    (forest (You are in the forest. Dont you have to go to work at some point?))
    (stream (You have crossed the stream on the log! This is fun.))
    (front-door (You are at the front door to the "LSD building." You see an id card reader.))
    ;; why does a period after Staff not compile here but the ones above are fine?
    (chief-of-staff-office (You are in the office of the "Chief of Staff." There is a bowl of candy.))
    (entry-room (You have just entered the "LSD" building. You can go anywhere!))
    (hallway1 (You are in a hallway. You can go anywhere!))
    (inner-main-door (You are entering the "LSD" lab facility. Inside you will find the offices of "yourself," your coworkers and labs filled with wondrous mechanical "gizmos, beakers" and vials.))
    (lobby (you are in the lobby of the "LSD" building. ))))

(defparameter *edges* 
  '((parking-lot (main-path north path) (forest-path east path) (your-car west car))
    (main-path (front-door north path) (parking-lot south path))
    (your-car (parking-lot east door))
    (forest-path (stream east log) (parking-lot west path))
    (stream (forest east path) (forest-path west path))
    (forest (stream west path))
    (lobby (inner-main-door east door))
    (inner-main-door (entry-room east hallway) (lobby west door))
    (hallway1 (chief-of-staff-office north doorway) (hallway2 west hallway) (greeting-area east hallway))
    (entry-room (hallway1 north hallway) (greeting-area east hall) (inner-main-door west hallway))
    (chief-of-staff-office (entry-room south doorway))
    (front-door (main-path south path))))

(defparameter *objects* '(badge lunch raincoat paper pumpkin lemon-tree))

(defparameter *object-locations* '((badge your-car "the passenger seat.") 
                                   (lunch your-car "the passenger seat.") 
                                   (raincoat your-car "the back seat.")
                                   (paper your-car "the floor.") 
                                   (pumpkin main-path "the ground.")
                                   (lemon-tree lobby "the left side.")))

;; flag certain text as 'bye' text, meaning after they say it they leave
;; also have a default if theres no key word hits
;; SPECIAL keys:
;; allowed-locations: where can this character be seen?
;; sighting: what is said when char is seen
(defparameter *people*
  '((claude 
      (allowed-locations (parking-lot main-path lobby))
      (sighting-msg (You see Claude))
      (hello (hi friend its me claude.))
      (help  (im never that much help with anything.))
      (inventory (im working on finding my things right now.))
      (things (you items i use for my science experiments and so forth.))
      (barcode (i havent seen that one lately))
      (lately (lately? i meant ever. i have never seen that barcode))
      (default (one of those days already how about you?))
      (bye (Claude continues talking as you turn and move away.))
    )
    (thedirector
      (allowed-locations (parking-lot main-path lobby))
      (sighting-msg (You see "The Director."))
      (hello (Greetings good worker.))
      (help  (Come find me later I have to greet some visitors.))
      (default  (Busy busy gotta go!))
      (bye  (The Director waves.))
    )
    (chiefofstaff
      (allowed-locations (parking-lot main-path lobby))
      (sighting-msg (You see the "Chief of Staff."))
      (hello (Greetings good worker.))
      (help  (Come find me later I have to greet some visitors.))
      (inventory  (Talk to the inventory specialist.))
      (specialist  (Dont mess with me you know who it is.))
      (who  (Just do it!))
      (default  (Have you finished your inventory?))
      (bye  (Later))
    )
    (joe
      (hello (Hey man.))
      (help  (Sure Id love to help.))
      (default  (Wrong "Joe."))
    )
    (franciscorouter
      (hello (Helo sir.))
      (help  (Im glad you asked. Im trying to get this code to compile.))
      (default  (Wrong "Joe."))
    )
    (mushroombroker
      (allowed-locations (parking-lot main-path lobby))
      (sighting-msg (You see a mushroom broker.))
      (hello (I see many fine mushrooms around this building.))
      (help  (I need some help carrying all these mushrooms.))
      (mushroom  (Mushrooms have many many uses. For example eating.))
      (default  (Im not bothering anybody.))
    )
    (moe
      (hello (Hi there.))
      (help  (Sure Id love to help.))
      (barcode  (Ahhh I have not found that one yet.))
      (barcode-12345  (Ahhh I have not found that one yet either.))
      (barcode-2345  (Ahhh I really need that one.))
      (inventory  (Thats what I do best. What barcode are you looking for?))
      (default  (I dont know... maybe))
    )
    (tate
      (hello (Yo bro whaddya know on the down low?))
      (help  (Help yourself duuuude.))
      (bye  (Later hater.))
      (default  (Whats the matter man?))
    )
  ))

;; delete greetings and fix random-enc function
(defparameter *encounters* 
  '((0 (chiefofstaff))
    (1 (TheDirector))
    (2 (suspicious))
    (3 (mushroombroker))
    (4 (claude)         )
    (5 ())
    (6 ())
    (7 ())
    (8 ())))


;; thsi would work but seems tedious,
;; looks like itd be simpler to add the insde/outside as the second symbol to the node
;; and simply change the describe to caddr rather than cadr to get the descrip
;; (defparameter *location-inside* (assoc 'inside (sppool thru nodes?))
(defparameter *location-inside* '(hallway1 entry-room)) 
(defparameter *person-inside* '(chiefofstaff thedirector)) 
(defparameter *location-outside* '(your-car parking-lot)) 
(defparameter *person-outside* '(mushroom-broker suspicious-person chiefofstaff thedirector)) 

;; really need to figure out how to do this by location-
;; after random number, figure out if the person can be where the player is
(defun random-encounter2 (enc)
 ; based on where you are, you may encounter a coworker 
    (setf *nearby-person* (caaddr (assoc enc *encounters*)))
    (cadr (assoc enc *encounters*)))

(defun random-encounter (enc)
 ; based on where you are, you may encounter a coworker 
  (let ((tmp (caadr (assoc enc *encounters*))))
    ;(setf *nearby-person* (caaddr (assoc enc *encounters*)))
    (if (and (not (eq tmp nil)) 
             (member *location* (cadr (assoc 'allowed-locations (cdr (assoc tmp *people*))))))
      (setf *nearby-person* (caadr (assoc enc *encounters*))))
    (cadr (assoc 'sighting-msg (cdr (assoc *nearby-person* *people*))))))

(defun describe-location (location nodes)
  (cadr (assoc location nodes)))

(defun describe-path (edge)
  `(there is a ,(caddr edge) going ,(cadr edge) from here.))

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
    (random-encounter (random 9))))

(defun wait () 
)

(defun openthing (thing)
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

(defun walk (direction)
  (let ((next 
          (find direction (cdr (assoc *location* *edges*)) :key #'cadr)))
    (if next
      (progn 
        (setf *location* (car next))
        (look))
      '(you cannot go that way.))))
 
;; not sure if I want to bother with the
;; full sentence parsing thing
;; might be simpler just to have player key
;; off certain words said by NPC ala Ultima
;(defun talk (text &rest text2)
(defun talk (text)
  (if (not (equal *nearby-person* nil))
    (respond text *nearby-person*)
   '(theres nobody to talk to near by.)))
  
(defun pickup (object)
  (cond 
    ;; Is the object I want to pickup in the location that I am?
    ((member object (objects-at *location* *objects* *object-locations*)) 
       ;; if so, change the object-location to "body" and return 'carrying' text
       (push (list object 'body) *object-locations*) 
      `(you are now carrying the ,object)) 
     (t '(you cannot get that.))))      

;; nf
(defun inventory ()
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
  (if (member (car sexp) *allowed-commands*)
    (cond
      ((member (car sexp) *synonym-pickup*) (eval (cons 'pickup (cdr sexp))))
      ((member (car sexp) *synonym-walk*) (eval (cons 'walk (cdr sexp))))
      ((member (car sexp) *synonym-talk*) (eval (cons 'talk (cdr sexp))))
      ((member (car sexp) *synonym-open*) (eval (cons 'openthing (cdr sexp))))
      ;((equal (car sexp) 'stats) (eval '(stats)))
      (t (eval sexp)))
  '(i do not know that command.)))

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
(defun game-print (lst)
  (princ 
    (coerce 
      (tweak-text (coerce (string-trim "() " (prin1-to-string lst)) 'list) t nil) 
      'string))
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
      (setq *stats-moves* (+ *stats-moves* 1)))
    (unless (eq (car cmd) 'quit) 
      (game-print (game-eval cmd))
      (game-repl))))

(defun main ()
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
