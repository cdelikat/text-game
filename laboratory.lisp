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

(defparameter *all-nodes* (mapcar #'car *nodes*))
 
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
  `((claude 
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

