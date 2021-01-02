;; begin the game in your car
(defparameter *location* 'bedroom)
(defparameter *player* "Stella")
(defparameter *nearby-person* nil)
(defparameter *current-event* nil)
(defparameter *stats-moves* 0)

(defparameter *nodes* 
  '((bedroom (You are in your bedroom within your house.))
    (closet (You are in your closet. There are lots of things in here.))
    (front-yard (You are in the front yard. You are near the front door of your house.))
    (front-door (You standing at the front door of your house.))
    (side-yard (Here in your side yard you can see all around.))
    (side-yard2 (Still in your side yard you can a fence surrounding the yard.))
    (living-room (You are in your living room.))
    (foyer (You now standing in your homes foyer.))
    (dining-room (You in your dining room. Theres a large table and several chairs.))
    (doorstep (You at the front door of your house.))
    (hall (You are in the hall in your house. ))
    (hall2 (You are in the hall in your house. ))
    (hall3 (You are in the hall in your house. ))
    (hall4 (You are in the hall in your house. ))
    (laundry-room (You are in the laundry room. ))
    (back-porch (You are on the back porch. ))
    (kitchen (You are in the kitchen. ))
))

(defparameter *all-nodes* (mapcar #'car *nodes*))
 
(defparameter *edges* 
  '((bedroom (hall north door) (closet east "closet door") (side-yard west window))
    (hall (bedroom south bedroom) (living-room east "living room") (foyer north "the foyer"))
    (hall2 (living-room south "living room") (bathroom east bathroom) (foyer west foyer) (hall3 north hall))
    (hall3 (hall2 south "a hall") (dining-room west "dining room") (hall4 north hall))
    (hall4 (kitchen west "kitchen") (hall3 south hall) (laundry-room east "laundry room"))
    (living-room (hall west "hall") (hall2 north "hall"))
    (closet (bedroom west "closet door"))
    (test (test2 north door))
    (laundry-room (back-porch east "back porch") (hall4 west hall))
    (doorstep (foyer east "front door") (front-yard south "front yard"))
    (kitchen (dining-room south "the dining room") (hall4 east "the hall"))
    (dining-room (foyer south "the foyer") (kitchen north "the kitchen") (hall3 east "a hall"))
    (foyer (doorstep west doorstep)(hall2 east "a hallway") (dining-room north "dining room") (hall south "another hall"))
    (front-yard (side-yard3 east grass) (doorstep north sidewalk) (side-yard south grass))
    (side-yard (bedroom east window) (side-yard2 west grass) (front-yard north grass) )
    (side-yard2 (side-yard east grass) )
    (side-yard3 (front-yard west grass) )
    (bathroom (hall2 west hall) )
    (back-porch (laundry-room west "laundry room") )
    (front-door (main-path south path))))

(defparameter *objects* '(lunch raincoat boots flashlight))

(defparameter *object-locations* '((badge car "the passenger seat.") 
                                   (lunch kitchen "the counter.") 
                                   (raincoat bedroom "the floor.")
                                   (flashlight closet "a shelf.")
                                   (boots closet "the floor.")))

;; flag certain text as 'bye' text, meaning after they say it they leave
;; also have a default if theres no key word hits
;; SPECIAL keys:
;; allowed-locations: where can this character be seen?
;; sighting: what is said when char is seen
;; hello
;; bye
;; default
(defparameter *people*
  `((auntem
      (allowed-locations (living-room kitchen))
      (sighting-msg (You see your Aunt.))
      (hello (hi there ,*player*))
      (help  (im never that much help with anything.))
      (bye ("See you later honey, she says."))
      (default  (Thats great honey!))
    )
    (unclehenry
      (allowed-locations ,*all-nodes*)
      (sighting-msg (You see "your uncle."))
      (hello (Hey there ,*player*))
      (help  (I dont know about that.))
      (default  (Well whatever youd like!))
      (bye  (Uncle puts his pipe back in his mouth and picks up his book.))
    )
    (zeke
      (allowed-locations ,*all-nodes*)
      (sighting-msg (Here comes Zeke.))
      (hello (Hello ,*player*))
      (help  (Sure Id love to help.))
      (default  (Just busy doing my work here on the farm.))
    )
    (hunk
      (allowed-locations ,*all-nodes*)
      (sighting-msg (Ah you see your friend Hunk.))
      (hello (Hi ,*player*))
      (help  (I think I can help but what with?))
      (default  (Well I gotta do me some thinkin on that.))
    )
    (hickory
      (allowed-locations ,*all-nodes*)
      (sighting-msg (Theres old Hickory.))
      (hello (Hello ,*player*))
      (help  (Sure Id love to help.))
      (default  (I dont know what to feel about that.))
    )
  ))

(defparameter *total-encounters* 9)
;; delete greetings and fix random-enc function
(defparameter *encounters* 
  '((0 (auntem))
    (1 (unclehenry))
    (2 (hunk))
    (3 (zeke))
    (4 (hickory)         )
    (5 ())
    (6 ())
    (7 ())
    (8 ())))

(defparameter *events-at-moves* 
  '((10 (tornado-approaching))
    (15 (tornado-closer))
    (20 (tornado-struck))
    (80 ())))

(defun reset-locale ()
  (load "laboratory.lisp")
  ;; change edges
  ;; change nodes
  ;; change people
  ;; change objects
  ;; can I basically (load "oz.lisp") to overwrite the variables?
)
;; events occur after a certain number of moves
;; moves is my crude time keeping technique at the moment
;; after each move, in the look function, it will check for 
;; an event based on # moves and location
;; Events can change the look of a place by adding new description
;; to nodes (how) just push like when you pick up an object
;; and its still at the place you found it but your "body" 
;; location is more recent in the list

;; another idea: dinner-
;; changes the description of a node: dining-room
;; AND adds a bunch of people to that place
;; AND objects
(defparameter *events*
  `(
    (tornado-approaching
      (sighting-msg (A tornado is approaching you can see it in the distance))
      (allowed-locations ,*all-nodes*)
      (action nil))
    (tornado-closer
      (sighting-msg (The tornado is closer its getting really windy outside the windows are rattling.))
      (allowed-locations ,*all-nodes*)
      (action nil))
    (tornado-struck
      (sighting-msg (The tornado has struck!))
      (allowed-locations ,*all-nodes*)
      (action reset-locale))
))



;; will want to create a way for people to join you
;; just like the object functions, you can join someone
;; and they get attached to you and leave the random encounter
;; somehow...
