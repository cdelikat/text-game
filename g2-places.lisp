
;; XXX change this to only hold places for your current-place
; (PLACE-NAME (VIEW OF PLACE FROM OUTSIDE) (DESCR OF PLACE WHEN INSIDE))

(defparameter *outside-lab-front*
'(
  (your-car (your automobile.) 
    (You are in your car in the parking lot of the "Laboratories" for "Sciences" "Department." ))
  (parking-lot1 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot2 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot3 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot4 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot5 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot6 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
  (parking-lot7 (parking lot.) 
    (You are in the parking lot just north of the "Laboratories" for "Sciences" "Department."))
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
  (side-patio ( patio on the side.) 
    (You are on the side patio of the "LSD" building. There is a picnic table.))
  (side-path2 ( path around the side.) (You are on a sidewalk along the side of the "LSD" building.))
  (side-path1 ( path around the side.) (You are on a sidewalk along the side of the "LSD" building.))
  (entrance (you see the entrance to the lsd building.) (You are in the entrance area of the "LSD" building.))
))

(defparameter *map1-list*
'(
;; NORTH
;; 0          1             2             3             4             5
(grass5       grass6       front-door   side-path1    side-path2    picnic-table)
(grass3       grass4       path3        grass11       grass12       side-patio)
(grass1       grass2       path2        grass9        grass10       dumpster)
(parking-lot6 parking-lot7 path1        grass7        grass8        parking-lot8)   ;; EAST
(forest1      forest2      forest3      parking-lot3  parking-lot4  parking-lot5 )
(forest-path1 forest-path2 parking-lot0 parking-lot1  parking-lot2  your-car)
;; SOUTH
))

;; outside-lab-front
(defparameter *map1* (make-array '(6 6)
:initial-contents *map1-list*
))


(defparameter *lab-lobby*
'(
  (entrance (you see the exit from the lsd building.) (You are in the entrance area of the "LSD" building.))
  (wall (you see a wall.) (You cant go this way.))
  (lobby1 (you see the lobby. ) (You are in the lobby.))
  (lobby2 (you see more lobby. ) (You are still in the lobby.))
  (waiting-area1 (you see chairs and small tables. ) (You are still in the waiting area.))
  (waiting-area2 (you see chairs and small tables. ) (You are still in the waiting area.))
  (waiting-area3 (you see chairs and small tables. ) (You are still in the waiting area.))
))

(defparameter *map2-list*
'(
(auditorium     lobby1        waiting-area1   waiting-area4)
(wall         lobby2        waiting-area2   waiting-area5)
(inner-hall   inner-door    waiting-area3   inner-entryway)
(office1      entrance    wall        waiting-area7)
))

(defparameter *map2* (make-array '(4 4)
 :initial-contents *map2-list*
))

(defparameter *lab-floor1*
'(
  (en (you have just entered the lsd building.) (You are finally inside "LSD" building.))
  (w (you see a wall.) (You cant go this way.))
  (h (you see a hallway. ) (You are in a hallway.))
  (pr (you see a printer room. ) (You are now inside the printer room.))
  (odp (you see the office of the deputy. ) (You are in the deputy's office.))
  (odir (you see the office of the director. ) (You are in the directors office.))
  (otd (you see the tds office. ) (You are in the tds office.))
))

(defparameter *map3-list*
'(
(w  h w w h  h  h h   h     h )
(w  h o w h  h  h h   h     h )
(w  h w w h  h  h h   h     h )
(w  h o w h  h  h h   h     h )
(w  h w w h  h  h h   h     h )
(w  h o w h  h  h h   h     h )
(w  h w w h  h  h h   h     h )
(w  h o w h  h  h h   h     h )
(w  h w w h  h  h h   h     h )
(en h w w pr h  w odp odir  otd )
))

(defparameter *map3* (make-array '(10 10)
 :initial-contents *map3-list*
))
