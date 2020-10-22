;; begin the game in your car
(defparameter *location* 'your-house-bedroom)
(defparameter *nearby-person* nil)
(defparameter *stats-moves* 0)

(defparameter *nodes* 
  '((your-house-bedroom (You are in your bedroom within your house.))
    (your-house-hall (You are in the hall in your house. ))))

(defparameter *all-nodes* (mapcar #'car *nodes*))
 
(defparameter *edges* 
  '((your-house-bedroom (your-house-hall north door) (your-closet east "closet door") (your-window west window))
    (your-house-hall (your-house-bedroom south door))
    (your-closet (your-house-bedroom west door))
    (your-window (your-house-bedroom east door) (your-yard west grass) (your-front-yard north grass) (your-back-yard south grass))
    (front-door (main-path south path))))

(defparameter *objects* '(lunch raincoat boots flashlight))

(defparameter *object-locations* '((badge your-car "the passenger seat.") 
                                   (lunch your-house-kitchen "the counter.") 
                                   (raincoat your-house-bedroom "the floor.")
                                   (flashlight your-closet "a shelf.")
                                   (boots your-closet "the floor.")))

;; flag certain text as 'bye' text, meaning after they say it they leave
;; also have a default if theres no key word hits
;; SPECIAL keys:
;; allowed-locations: where can this character be seen?
;; sighting: what is said when char is seen
(defparameter *people*
  `((auntem
      (allowed-locations ,*all-nodes*)
      (sighting-msg (You see Claude))
      (hello (hi friend its me claude.))
      (help  (im never that much help with anything.))
      (inventory (im working on finding my things right now.))
      (things (you items i use for my science experiments and so forth.))
      (barcode (i havent seen that one lately))
      (lately (lately? i meant ever. i have never seen that barcode))
      (never (never is hard to really quantify i mean who knows i may have ))
      (ever (ever? well i hate to be so definitive who knows? am i right?))
      (default (one of those days already how about you?))
      (bye (Claude continues talking as you turn and move away.))
    )
    (thedirector
      (allowed-locations ,*all-nodes*)
      (sighting-msg (You see "The Director."))
      (hello (Greetings good worker.))
      (help  (Come find me later I have to greet some visitors.))
      (default  (Busy busy gotta go!))
      (bye  (The Director waves.))
    )
    (chiefofstaff
      (allowed-locations ,*all-nodes*)
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
      (allowed-locations ,*all-nodes*)
      (sighting-msg (You see Moe the inventory specialist.))
      (hello (Hi there.))
      (help  (Sure Id love to help.))
      (barcode  (Ahhh I have not found that one yet.))
      (barcode-12345  (Ahhh I have not found that one yet either.))
      (barcode-2345  (Ahhh I really need that one.))
      (inventory  (Thats what I do best. What barcode are you looking for?))
      (default  (I dont know... maybe))
    )
    (tate
      (allowed-locations (lobby))
      (sighting-msg (Uh-oh here comes Tate.))
      (hello (Yo bro whaddya know on the down low?))
      (help  (Help yourself duuuude.))
      (bye  (Later hater.))
      (default  (Whats the matter man?))
    )
  ))

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

