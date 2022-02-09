;; begin the game in your car
(defparameter *location* 'your-car)
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)
(defparameter *current-event* nil)

;; objects
(defparameter *objects* '(badge lunch raincoat paper pumpkin candy lemon-tree))
(defparameter *object-descriptions* 
 '((badge (the green colored badge has a picture of your wonderful face))
   (lunch (it is an obviously reused paper bag containing a warm greek yogurt and brown banana))
   (paper (on this crumbled piece of paper you see the words items use  ))))

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
    (5 (monster))
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
      (allowed-locations (your-car))
      (action nil))
    (ten-oclock
      (sighting-msg (It is now ten oclock.))
      (allowed-locations (your-car))
      (action nil))
    (eleven-oclock
      (sighting-msg (It is now eleven oclock.))
      (allowed-locations (your-car))
      (action nil))
))
