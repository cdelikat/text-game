
(defparameter *high* 6)
(defparameter *low* -1)
(load "laboratory.lisp")
(defparameter *player* 'chris)
(defparameter *used-badge* 0)
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)
(defparameter *current-event* nil)

(defparameter *map1*
#2A(
;; NORTH
;; 0          1             2             3             4             5
(your-car     parking-lot1 parking-lot2 forest-path1  forest-path2 forest-bridge)
(parking-lot3 parking-lot4 parking-lot5 forest1       forest2       forest3)
(parking-lot6 parking-lot7 path1        grass7        grass8        parking-lot8)   ;; EAST
(grass1       grass2       path2        grass9        grass10       dumpster)
(grass3       grass4       path3        grass11       grass12       side-patio)
(grass5       grass6       front-door   side-path1    side-path2    picnic-table)
;; SOUTH
))

(defparameter *map2*
#2A(
(entrance     lobby1        waiting-area1)
(wall         lobby2        waiting-area2)
(inner-hall   inner-door    waiting-area3)
(office1      inner-entryway    wall)
))

(defparameter *current-grid* *map1*)
(defparameter *location* '(0 0))

; (PLACE-NAME (VIEW OF PLACE FROM OUTSIDE) (DESCR OF PLACE WHEN INSIDE))
(defparameter *places*
'(
  (your-car (your automobile.) (You are in your car in the parking lot of the "Laboratories" for "Sciences" "Department." ))
  (parking-lot1 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot2 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot3 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot4 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot5 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot6 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot7 (parking lot.) (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (grass1 (some grass in front of the building.) (You are on the grass.))
  (grass2 (some grass in front of the building.) (You are on the grass.))
  (grass3 (some grass in front of the building.) (You are on the grass.))
  (grass4 (some grass in front of the building.) (You are on the grass.))
  (grass5 (some grass in front of the building.) (You are on the grass.))
  (grass6 (some grass in front of the building.) (You are on the grass.))
  (grass7 (some grass in front of the building.) (You are on the grass.))
  (grass8 (some grass in front of the building.) (You are on the grass.))
  (grass9 (some grass in front of the building.) (You are on the grass.))
  (grass10 (some grass in front of the building.) (You are on the grass.))
  (grass11 (some grass in front of the building.) (You are on the grass.))
  (grass12 (some grass in front of the building.) (You are on the grass.))
  (forest1 (a forest of green trees.) (You stand among the trees.))
  (forest2 (a forest of green trees.) (You stand among the trees.))
  (forest3 (a forest of green trees.) (You stand among the trees.))
  (front-door (the front door of the building.) (You are in front of the main door.))
  (forest-path1 (a path into the forest.) (You are on a path into the forest.))
  (path1 (a paved winding path.) (You are on the path to the door to the "LSD" building. You see a bench.))
  (path2 (a paved winding path.) (You are on the path to the door to the "LSD" building.))
  (path3 (a paved path.) (You are on the path to the door to the "LSD" building.))
  (side-patio ( patio on the side.) (You are on the side patio of the "LSD" building. There is a picnic table.))
  (side-path2 ( path around the side.) (You are on a sidewalk along the side of the "LSD" building.))
  (side-path1 ( path around the side.) (You are on a sidewalk along the side of the "LSD" building.))
  (entrance (you see the entrance to the lsd building.) (You are in the entrance area of the "LSD" building.))
  (wall (you see a wall.) (You cant go this way.))
  (lobby1 (you see the lobby. ) (You are in the lobby.))
  (lobby2 (you see more lobby. ) (You are still in the lobby.))
))

(defparameter *doors* 
  ;; XXX should remove direction from this list, should come from map
  ;; (PLACE-NAME (PLACE-DESC) DIR-TO-ENTER MAP-TO-CHANGE-TO (LOCATION-ON-NEW-MAP))
  ;;
  ;; Need to add LOCKED and what item unlocks?
  `(
    (front-door 
      (locked badge)
      (You see a door with an id card reader.) 
      south ,*map2* (0 0))
    (entrance 
      (unlocked)
      (You see the entrance to the building to the west. This will take you back outside.) 
      west ,*map1* (5 2))
    (side-patio 
      (unlocked)
      (You see a door that may be unlocked.))
))

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
  
(defun grid-see (point-pair)
  (cadr (assoc (grid-loc point-pair) *places*)))

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
    (describe-location *location* *places*)
    (see-around2 (car *location*) (cadr *location*))
    (see-special (grid-loc *location*))
    (describe-objects (grid-loc *location*) *objects* *object-locations*)))

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

(defun can-open-door ()
  ;; what does door need to open
  ;; (cadr (second (assoc (grid-loc '(5 2)) *doors*)))
  ;; do you have it?
  (if (eq 'unlocked (car (second (assoc (grid-loc *location*) *doors*)))) 
    t
  (let ((key (cadr (second (assoc (grid-loc *location*) *doors*)))))
    (if (have-item key) t))))

(defun go-thru-door ()
  (progn
    (let ((orig-location (grid-loc *location*)))
  ;; check if door is open or locked
  ;; XXX idea: maybe just having the badge will open the door
  ;; makes it a little simpler to process, since user doesnt
  ;; have to _do_ anything to open it, it just says something like
  ;; "you use your badge to open the door"
  ;; if locked has player done the necessary thing
  ;; or carrying the necessary item to unlock
  ;; if so, set current-grid to the new grid for door
  ;; set location
    (format t "~% ~A ~%" "go-thru-door-1" )
    (setq *current-grid* (car (cddddr (assoc orig-location *doors*))))
    (format t "~% ~A ~%" "go-thru-door-2" )
    (setq *location* (car (last (assoc orig-location *doors*))))
    (format t "~% ~A ~%" "go-thru-door-3" )
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
            '(The door is locked forget your badge?)))
          ;; only do this if its not a door
      (t (progn (setf *location* (cdr next)) (look) )))))

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

(defun event-check (enc)
  (setf *current-event* nil)
  (let ((event (caadr (assoc enc *events-at-moves*))))
    (if (and (not (eq event nil))
             (member *location* (cadr (assoc 'allowed-locations (cdr (assoc event *events*))))))
      (setf *current-event* (caadr (assoc enc *events-at-moves*))))
    (let ((action (cadr (assoc 'action (cdr (assoc event *events*))))))
      ;(format t "~% ~A ~%" action)
      ;; BUG: if there's an action, we never see the sighting-msg
      (if (not (eq action nil))
        (eval (list action))))
    (cadr (assoc 'sighting-msg (cdr (assoc *current-event* *events*))))
))

(defparameter *synonym-pickup* '(pickup grab get take))
(defparameter *synonym-walk* '(walk go move run))
(defparameter *synonym-talk* '(talk say speak shout whisper respond ask))
(defparameter *synonym-open* '(open unlock openthing))
(defparameter *allowed-commands* (append '(look items stats use examine location) *synonym-pickup* *synonym-walk* *synonym-talk* *synonym-open*))

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
      ((equal (car sexp) 'look) (eval (cons 'look (cdr sexp))))
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
  (let ((cmd (game-read (read-line))))
    (print cmd)
    (loggit "game-repl: cmd" cmd)
    (if (and (> *used-badge* 0) (= (+ 2 *used-badge*) *stats-moves*))
      (progn
        (setq *edges* (cdr *edges*))
        (setq *used-badge* 0)))
    (if (not (eq (car cmd) 'stats))
      (progn
        (setq *stats-moves* (+ *stats-moves* 1))    ;; incr total moves
        (game-print (event-check *stats-moves*))))  ;; is there an event at this move number?
    (unless (eq (car cmd) 'quit)
      (game-print (game-eval cmd))
      (game-repl))))

