
(defparameter *high* 6)
(defparameter *low* -1)
(defparameter *player* 'chris)
(load "g2-util.lisp")
(load "g2-lab.lisp")
(defparameter *stats-moves* 0)
(defparameter *current-event* nil)

(load "g2-places.lisp")
(load "g2-people.lisp")
(defparameter *nearby-person* 'claude)
(defparameter *current-place* *outside-lab-front*)
(defparameter *current-grid* *map1*)
(defparameter *location* '(5 5))

(defparameter *doors* 
  ;; XXX should remove direction from this list, should come from map
  ;; (PLACE-NAME (PLACE-DESC) DIR-TO-ENTER MAP-TO-CHANGE-TO high-map-num(LOCATION-ON-NEW-MAP))
  ;;
  ;; Need to add LOCKED and what item unlocks?
  `(
    (front-door 
      (locked badge)
      (You see a door with an id card reader to the north.) 
      north ,*map2* ,*lab-lobby* 4 (3 1))
    (entrance 
      (unlocked)
      (You see the entrance to the building to the south. This will take you back outside.) 
      south ,*map1* ,*outside-lab-front* 6 (5 2))
    (inner-entryway 
      (unlocked)
      (You see the way into the lab to the east. This is the place to go.) 
      east ,*map3* ,*lab-floor1* 10 (9 0))
    (en 
      (unlocked)
      (You see the door to the lobby to the west.) 
      west ,*map2* ,*lab-lobby* 4 (2 3))
    (side-patio 
      (unlocked)
      (You see a door that may be unlocked.))
))

(defun thing-check (enc thing1 thing2 thing3)
  (set thing1 nil)
  (let ((tmp (caadr (assoc enc thing2))))
    (if (and (not (eq tmp nil))
             (member (grid-loc *location*) (cadr (assoc 'allowed-locations (cdr (assoc tmp thing3))))))
      (set thing1 (caadr (assoc enc thing2))))
    (cadr (assoc 'sighting-msg (cdr (assoc (symbol-value thing1) thing3))))
))

(defun random-encounter (enc)
  (thing-check enc '*nearby-person* *encounters* *people*)
)

(defun event-check (enc)
  (thing-check enc '*current-event* *events-at-moves* *events*)
)

;; input: '(0 0)
;; output: YOUR-CAR
(defun grid-loc (point-pair)
  (aref *current-grid* (car point-pair) (cadr point-pair)))
  
(defun grid-loc2 (x y)
  (aref *current-grid* x y))
  
;; description of location that you are in
;; connects x,y location on grid to list of text 
(defun describe-location (loc places)
  (caddr (assoc (grid-loc loc) places))
)

;; what location looks like from outside
;(defun see-location (loc grid places)
;  (cadr (assoc (aref grid (car loc) (cadr loc)) places))
;)


;; if y value of pt is > curent, it is to the EAST
;; if y value of pt is < current, it is to the WEST
;; if x value of pt is > current, it is to the SOUTH
;; if x value of pt is < current, it is to the NORTH
;;
;; (adj-cells 0 0)
;; returns 
;; ((NORTH -1 0) (WEST 0 -1) (EAST 0 1) (SOUTH 1 0))
(defun adj-cells (x y)
  (list 
    (list 'north (- x 1) y)
    (list 'west x (- y 1))
    (list 'east x (+ y 1))
    (list 'south (+ x 1) y )))
 
;; remove points that contain something out of bounds
(defun prune (low high lst)
  (remove-if #'(lambda (pt) (or (member low pt) (member high pt))) lst))

(defun prune-walls (lst) 
  (remove-if #'(lambda (pt) (eq (grid-loc (cdr pt)) 'wall)) lst))

  
(defun grid-see (point-pair)
  (cadr (assoc (grid-loc point-pair) *current-place*)))

;; dir-place = (EAST 0 1)
(defun see-direction (dir-place)
  `(to the ,(car dir-place) you see ,(grid-see (cdr dir-place))))

(defun see-around2 (x y)
  (flatten (mapcar #'see-direction (prune *low* *high* (adj-cells x y)))))

(defun see-special (place)
  (caddr (assoc place *doors*)))

;; Items
;; (objects-at *location* *objects* *object-locations*)
;; returns
;; (BADGE LUNCH RAINCOAT PAPER)
(defun objects-at (loc objs obj-locs)
  (labels ((at-loc-p (obj)
    (eq (cadr (assoc obj obj-locs)) loc)))
    (remove-if-not #'at-loc-p objs)))

(defun describe-objects (loc objs obj-loc)
  (labels ((describe-obj (obj)
           (let ((ol (caddr (assoc obj obj-loc))))
            `(you see a ,obj on ,ol))))
    (apply #'append (mapcar #'describe-obj (objects-at loc objs obj-loc)))))
;; Items

(defun stats ()
  `(you have made ,*stats-moves* moves.))

;; special
(defun location ()
  (append
  `(grid location ,*location* )
  `(grid ,*current-grid* )))

(defun look ()
  (append 
    (describe-location *location* *current-place*)
    (see-around2 (car *location*) (cadr *location*))
    (see-special (grid-loc *location*))
    (describe-objects (grid-loc *location*) *objects* *object-locations*)
    (random-encounter (random *total-encounters*))))

;; XXX do we really need this function?
(defun openthing (&optional thing &rest thing-more)
  (let ((d (find thing (valid-dirs *location*) :key #'cadddr)))
    ;;((next (find dir (valid-dirs *location* ) :key #'car)))
    (cond
      ((eq thing nil) '(open what?))
      ((eq d nil) `(there is no ,thing nearby.))
      (t `(you opened the ,(concatenate 'string (string thing) ".")))
)))
;;
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
;;

;(defun describe-paths (loc grid places)
;(apply (function append) (mapcar #'describe-path (cdr (assoc location edges)))))

;(defun describe-around (x y)
;  (let 
;    (adj-list (prune *low* *high* (adj-cells x y)))
;    
;  ((cadr (assoc (aref *map1* x y) *places*)))))

;`(there is a ,(caddr edge) to the ,(concat

;(defun see-around (x y)
;  (let 
;    ((adj-list (prune *low* *high* (adj-cells x y))))
;    (mapcar #'see-direction adj-list)))
  
;(defun describe-paths (loc grid)
;; create list of adjacent cells

(defun have-item (item)
  (if (member item (objects-at 'body *objects* *object-locations*)) t))

(defun whats-the-key ()
  (cadr (second (assoc (grid-loc *location*) *doors*))))

(defun can-open-door ()
  ;; what does door need to open
  ;; (cadr (second (assoc (grid-loc '(5 2)) *doors*)))
  ;; do you have it?
  (cond
    ((eq 'unlocked (car (second (assoc (grid-loc *location*) *doors*)))) t)
    ((have-item (whats-the-key)) t)
  ))

(defun go-thru-door ()
  (progn
    (let ((orig-location (grid-loc *location*)) (key (whats-the-key)))
  ;; check if door is open or locked
  ;; XXX idea: maybe just having the badge will open the door
  ;; makes it a little simpler to process, since user doesnt
  ;; have to _do_ anything to open it, it just says something like
  ;; "you use your badge to open the door"
  ;; if locked has player done the necessary thing
  ;; or carrying the necessary item to unlock
  ;; if so, set current-grid to the new grid for door
  ;; set location
    ;;(format t "~% ~A ~%" "go-thru-door-1" )
    (setq *current-grid* (car (cddddr (assoc orig-location *doors*))))
    (setq *current-place* (cadr (cddddr (assoc orig-location *doors*))))
    (setq *high* (caddr (cddddr (assoc orig-location *doors*))))
    ;(format t "~% ~A ~%" "go-thru-door-2" )
    (setq *location* (car (last (assoc orig-location *doors*))))
    ;(format t "~% ~A ~%" "go-thru-door-3" )
    `(you use your ,key to go thru the door with ease.)
  ) ;; let
  )
)

;; this could be good, hide the complexity from walk function,
;; just return a list of valid directions and the points they'll
;; send you to if you go there.
;; (valid-dirs '(0 0))
;;((EAST 0 1) (SOUTH 1 0))
;; (valid-dirs '(3 3))
;;((NORTH 2 3) (WEST 3 2) (EAST 3 4) (SOUTH 4 3))
;; DOOR is special
;; XXX Maybe Im over complicating the door thing.
;; Q: what if insted of 'door, we just tack on the *map2* you're moving to?
;; A: I think we need 'door b/c in some cases you have to get thru the door
;;    and its not automatic
;; (valid-dirs '(5 2))
;;((NORTH 4 2) (WEST 5 1) (EAST 5 3) (SOUTH 0 0 DOOR))
;;
(defun valid-dirs2 (x y))
(defun valid-dirs (point-pair)
  (append
    ;; get simple grid-based directions
    (prune-walls (prune *low* *high* (adj-cells (car point-pair) (cadr point-pair))))
    ;; NEED TO PRUNE WALLS
    ;; (prune-walls (prune ... <above call> ))
    ;; get special directions, eg doors
    ;; THIS IS PROBABLY NOT NECESSARY, need to fix. DIRECTION should come from map
    (let ((s (fourth (assoc (grid-loc point-pair) *doors*))))
      (if s
        (list (list s 0 0 'door))))))
;; above is hard-coded to put door and starting point at 0 0, need to connect the new map here 
;; and decide if all doors put you into (0 0) of the new map
;; UPDATE: the 0 0 above doesnt matter, we never use it

;; Make Location contain the MAP var
;;
;; need to modify this to check adj-cells, then *doors* to see if near an open door
(defun walk (dir)
  (let
    ((next (find dir (valid-dirs *location* ) :key #'car)))
    (cond 
      ((eq next nil) '(not a way to go dude))
      ((eq 'door (cadddr next))
          (if (can-open-door)
            (go-thru-door) 
            `(The door is locked. Looks like you need a ,(whats-the-key) to open it.)))
          ;; only do this if its not a door
      (t (progn (setf *location* (cdr next)) (look) )))))

;;broken, needs to use cond
(defun walk2 (dir)
  (let
    ;; hey dude why doesnt valid-dirs just take a pair of numbers like grid-loc?
    ((next (find dir (valid-dirs *location* ) :key #'car)))
    ;; if (valid-dirs 5 2), and dir SOUTH, next will be (SOUTH 0 0 DOOR)
    ;;
    ;; if (last next) 'DOOR, then also change map, but to this ...
    ;; (car (last (assoc (grid-loc *location*) *doors*))) == *map2*
    (if next
      (progn
        ;; if the next move contains a door, need to change the map
        ;; XXX how do we use things to get thru doors?
        (if (eq 'door (cadddr next))
          (if (can-open-door)
            (go-thru-door)
            (format t "~% ~A ~%" "The door is locked, maybe you need your badge?" )
          )
          ;; only do this if its not a door
          (setf *location* (cdr next)))
        (look))
       (progn
          '(not a way to go person.))
      )))
;; need to add an else here for when they cant go in the direction they typed
;; also, what to do when its a door --> change maps!

(defun use (a))

;; need to sanitize object
;; putting semicolon causes crash
(defun pickup (&optional object &rest obj-more)
  (cond
    ;; Is the object I want to pickup in the location that I am?
    ((member object (objects-at (grid-loc *location*) *objects* *object-locations*))
       ;; if so, change the object-location to "body" and return 'carrying' text
       (push (list object 'body) *object-locations*)
      `(you are now carrying the ,object))
     (t '(you cannot get that.))))

;; nf
(defun items ()
  (cons 'items- (objects-at 'body *objects* *object-locations*)))

(defun examine (&optional item)
  (cond
    ((eq item nil)  '(Examine what?))
    ((not (member item (objects-at 'body *objects* *object-locations*))) '(you dont have that!))
    ((member item (objects-at 'body *objects* *object-locations*)) (cadr (assoc item *object-descriptions*)))))

;; talking functions
(defun respond (text person)
    (let ((r (cadr (assoc text (cdr (assoc person *people*))))))
      ;;(format t "~% ~A ~A ~%" "respond text:" r)
      (if (eq text 'bye) (setq *nearby-person* nil))
      (if (not r)
      (cadr (assoc 'default (cdr (assoc person *people*))))
      r))
)

(defun talk-read (words)
  (car (read-from-string
    (concatenate 'string "(" words ")"))))

(defun talk (&optional blah)
  (talk-repl)
)

(defun talk-repl ()
  ;;(format t "~% ~A" "?")
  ;;(princ ">")
  (format *query-io* "~a " "?")
  (force-output *query-io*)
  (let ((say (talk-read (read-line *query-io*))))
    ;;(format t "~% ~A ~A ~%" "talk-repl say:" say)
    ;;(game-print (respond say *nearby-person*))
    (game-print (cons '? (respond say *nearby-person*)))
    (unless (eq say 'bye)
      (talk-repl))))
;; end talking functions

    

;(defun event-check (enc)
;  (setf *current-event* nil)
;  (let ((event (caadr (assoc enc *events-at-moves*))))
;    (if (and (not (eq event nil))
;             (member (grid-loc *location*) (cadr (assoc 'allowed-locations (cdr (assoc event *events*))))))
;      (setf *current-event* (caadr (assoc enc *events-at-moves*))))
;    (let ((action (cadr (assoc 'action (cdr (assoc event *events*))))))
;      ;(format t "~% ~A ~%" action)
;      ;; BUG: if there's an action, we never see the sighting-msg
;      (if (not (eq action nil))
;        (eval (list action))))
;    (cadr (assoc 'sighting-msg (cdr (assoc *current-event* *events*))))
;))

(defparameter *synonym-pickup* '(pickup grab get take))
(defparameter *synonym-walk* '(walk go move run cd))
(defparameter *synonym-look* '(look ls))
(defparameter *synonym-talk* '(talk say speak shout whisper respond ask))
(defparameter *synonym-open* '(open unlock openthing))
(defparameter *allowed-commands* (append '(look items stats use examine location) *synonym-pickup* *synonym-walk* *synonym-look* *synonym-talk* *synonym-open*))

(defun game-read (rcmd)
  (ignore-errors
  ;(if (member rcmd *illegal-chars*)
  ;(if (not (alpha-char-p rcmd))
    ;(format t "~% ~A ~A ~%" "game-read" rcmd)
  (let ((cmd (read-from-string
    (concatenate 'string "(" rcmd ")"))))
    ;(format t "~% ~A ~A ~%" "game-read 2" cmd)
    (flet ((quote-it (x) (list 'quote x)))
      (cons (car cmd) (mapcar #'quote-it (cdr cmd)))))))

;; what if I keep track of things they try to do but arent allowed?
;; nf
;; TODO turn this into macros instead of evals
(defun game-eval (sexp)
  (progn
    ;(format t "~% ~A ~A ~%" "game-eval" sexp)
    ;(format t "~% ~A ~A ~%" "game-eval" sexp)
  (if (member (car sexp) *allowed-commands*)
    (cond
      ;; TODO why cant i just send cadr of sexp to eval, to drop extra args??
      ;; More Impt TODO: add nil check for these funcs to prevent crash
      ((member (car sexp) *synonym-pickup*) (eval (cons 'pickup (cdr sexp))))
      ((member (car sexp) *synonym-walk*) (eval (cons 'walk (cdr sexp))))
      ((member (car sexp) *synonym-talk*) (eval (cons 'talk (cdr sexp))))
      ((member (car sexp) *synonym-open*) (eval (cons 'openthing (cdr sexp))))
      ; gave look an arg so it is now a synonym for examine
      ((member (car sexp) *synonym-look*) (eval (cons 'look (cdr sexp))))
      ; I do this to prevent crash if user passes args to these funcs
      ((equal (car sexp) 'items) (eval '(items)))
      ((equal (car sexp) 'stats) (eval '(stats)))
      ((equal (car sexp) 'location) (eval '(location)))
      ;((equal (car sexp) 'look) (eval '(look)))
      ((equal (car sexp) 'use) (eval (cons 'use (cdr sexp))))
      ((equal (car sexp) 'examine) (eval (cons 'examine (cdr sexp))))
      ;; should get away from this for safety reasons-- to easy to crash
      ;(t (eval sexp))
  )
  '(?SYNTAX ERROR))))
  ;;'(i do not know that command.)))

;; added if not eq nil to accomodate use of event-check in game-repl
(defun game-print (lst)
  (if (not (eq nil lst))
  (princ
    (coerce
      (tweak-text (coerce (string-trim "() " (prin1-to-string lst)) 'list) t nil)
      'string)))
  (fresh-line))

; temp file 
; (concatenate 'string "textgame_" (write-to-string (get-internal-real-time)) ".log")
(defun loggit (fun msg)
  (with-open-file
    (my-stream "/tmp/test.log" :direction :output :if-does-not-exist :create :if-exists :append)
      (format my-stream "~% {~A} [~A] ~A ~%" *player* fun msg)))

;; TODO Sanitize input, semicolons crash!!!
(defun game-repl ()
  (format *query-io* "~a " "-->")
  (force-output *query-io*)
  (let ((cmd (game-read (read-line *query-io*))))
    (print cmd)
    (loggit "game-repl: cmd" cmd)
    ;;(if (and (> *used-badge* 0) (= (+ 2 *used-badge*) *stats-moves*))
     ;; (progn
      ;;  (setq *edges* (cdr *edges*))
       ;; (setq *used-badge* 0)))
    (if (not (eq (car cmd) 'stats))
      (progn
        (setq *stats-moves* (+ *stats-moves* 1))    ;; incr total moves
        (game-print (event-check *stats-moves*))
      ))  ;; is there an event at this move number?
    (unless (eq (car cmd) 'quit)
      (game-print (game-eval cmd))
      (game-repl))))

