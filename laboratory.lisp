;; begin the game in your car
(defparameter *location* 'your-car)
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)
(defparameter *current-event* nil)

(defparameter *nodes* 
  '((parking-lot (You are in the parking lot just south of the "Laboratories" for "Sciences" "Department."))
    (your-car (You are in your car in the parking lot of the "Laboratories" for "Sciences" "Department." ))
    (main-path (You are on the path to the door to the "LSD" building. You see a bench.))
    (forest-path (You are on the forest path. You see a stream and a log laying across the stream.))
    (forest (You are in the forest. Dont you have to go to work at some point?))
    (stream (You have crossed the stream on the log! You are now having fun.))
    (front-door (You are at the front door to the "LSD" building. You see an id card reader.))
    ;; why does a period after Staff not compile here but the ones above are fine?
    (chief-of-staff-office (You are in the office of the "Chief of Staff." There is a bowl of candy.))
    (entry-room (You have just entered the "LSD" building. You can go anywhere!))
    (hallway1 (You are in a hallway. You can go anywhere!))
    (inner-main-door (You are entering the "LSD" lab facility. Inside you will find the offices of "yourself," your coworkers and labs filled with wondrous mechanical "gizmos, beakers" and vials.))
    (lobby (you are in the lobby of the "LSD" building. ))
    (hallway2 (You are in a "hallway," one of many.))
    (greeting-area (This is the greeting area. Coffee "tables," team awards on the walls and a couple of skylights above let some light into an otherwise windowless area.))
    (west-hallway1 (You have entered the west "hallway," the home of the fabled "Chemical Engineering Research Team," or CERT Team for short.))
    (west-hallway2 (You are in the west hallway. There should be an office you know somewhere.))
    (west-hallway3 (You are in the west hallway.))
    (west-hallway4 (You are in the west hallway.))
    (west-hallway5 (You are in the west hallway.))
))

(defparameter *all-nodes* (mapcar #'car *nodes*))
 
;; unlocking the door adds
(defparameter *edges* 
  '((parking-lot (main-path north path) (forest-path east path) (your-car west car))
    (main-path (front-door north path) (parking-lot south path))
    (your-car (parking-lot east door))
    (forest-path (stream east log) (parking-lot west path))
    (stream (forest east path) (forest-path west path))
    (forest (stream west path))
    ;(lobby (inner-main-door east door))
    (lobby (inner-main-door east door) (front-door south door))
    (inner-main-door (entry-room east hallway) (lobby west door))
    (hallway1 (entry-room south hallway) (chief-of-staff-office north doorway) (hallway2 west hallway) (greeting-area east hallway))
    (entry-room (hallway1 north hallway) (inner-main-door west hallway))
    (chief-of-staff-office (hallway1 south doorway))
    (front-door (lobby north door) (main-path south path))
    (greeting-area (hallway1 west hallway))
    (hallway2 (hallway1 east hallway) (west-hallway1 west hallway))
    (west-hallway1 (west-hallway2 north hallway) (hallway2 east hallway))
    (west-hallway2 (west-hallway3 north hallway) (west-hallway1 south hallway))
    (west-hallway3 (west-hallway4 north hallway) (west-hallway2 south hallway))
    (west-hallway4 (west-hallway5 north hallway) (west-hallway3 south hallway))
    (west-hallway5 (west-hallway4 south hallway))
    ;(front-door (main-path south path))
))

(defparameter *objects* '(badge lunch raincoat paper pumpkin candy lemon-tree))
(defparameter *object-descriptions* 
 '((badge (the green colored badge has a picture of your wonderful face))
   (lunch (it is an obviously reused paper bag containing a warm greek yogurt and brown banana))
   (paper (on this crumbled piece of paper you see the word inventory))))


(defparameter *object-locations* '((badge your-car "the passenger seat.") 
                                   (lunch your-car "the passenger seat.") 
                                   (raincoat your-car "the back seat.")
                                   (paper your-car "the floor.") 
                                   (pumpkin main-path "the ground.")
                                   (candy chief-of-staff-office "a bowl.")
                                   (lemon-tree lobby "the left side.")))

(defparameter *total-encounters* 9)
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

(defparameter *events-at-moves*
  '((10 (nine-oclock))
    (15 (ten-oclock))
    (20 (eleven-oclock))
    (8 ())))

;; need to put marks around event messages so they
;; are distinguished from text if you are talking to someone
(defparameter *events*
  `(
    (nine-oclock
      (sighting-msg (It is now nine oclock time for work!))
      (allowed-locations ,*all-nodes*)
      (action nil))
    (ten-oclock
      (sighting-msg (It is now ten oclock.))
      (allowed-locations ,*all-nodes*)
      (action nil))
    (eleven-oclock
      (sighting-msg (It is now eleven oclock.))
      (allowed-locations ,*all-nodes*)
      (action nil))
))
