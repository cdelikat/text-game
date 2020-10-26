;; begin the game in your car
(defparameter *location* 'house-bedroom)
(defparameter *player* "Stella")
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)

(defparameter *nodes* 
  '((house-bedroom (You are in your bedroom within your house.))
    (closet (You are in your closet. There are lots of things in here.))
    (side-yard (Here in your side yard you can see all around.))
    (living-room (You are in your living room.))
    (house-hall (You are in the hall in your house. ))))

(defparameter *all-nodes* (mapcar #'car *nodes*))
 
(defparameter *edges* 
  '((house-bedroom (house-hall north door) (closet east "closet door") (side-yard west window))
    (house-hall (house-bedroom south bedroom) (living-room east "living room"))
    (house-hall2 (living-room south "living room") (bathroom east bathroom) (foyer west foyer) (house-hall3 north hall))
    (living-room (house-hall west hall) (house-hall2 north "another hall"))
    (closet (house-bedroom west door))
    (side-yard (house-bedroom east window) (side-yard2 west grass) (front-yard north grass) (back-yard south grass))
    (front-door (main-path south path))))

(defparameter *objects* '(lunch raincoat boots flashlight))

(defparameter *object-locations* '((badge car "the passenger seat.") 
                                   (lunch house-kitchen "the counter.") 
                                   (raincoat house-bedroom "the floor.")
                                   (flashlight closet "a shelf.")
                                   (boots closet "the floor.")))

;; flag certain text as 'bye' text, meaning after they say it they leave
;; also have a default if theres no key word hits
;; SPECIAL keys:
;; allowed-locations: where can this character be seen?
;; sighting: what is said when char is seen
(defparameter *people*
  `((auntem
      (allowed-locations (living-room kitchen))
      (sighting-msg (You see your Aunt.))
      (hello (hi there ,*player* how are you?))
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
      (hello (Hello ,*player* how are you today?))
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
      (hello (Hello ,*player* I hope you are felling well.))
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

