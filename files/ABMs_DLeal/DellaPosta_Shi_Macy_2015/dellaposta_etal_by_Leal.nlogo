extensions [ nw ] ;; importing NetLogo's network extension

globals
[
 number-of-caves  ;; number of caves in the context of the "connected caveman" graph model (see p. 24)
 ego1             ;; first agent in the first pair randomly selected to be rewired (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
 alter1           ;; second agent in the first pair randomly selected to be rewired (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
 ego2             ;; first agent in the second pair randomly selected to be rewired (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
 alter2           ;; second agent in the first pair randomly selected to be rewired (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
 #-links          ;; this variables keeps track of the total number of ties/links.
 link-list1       ;; this variable keeps track of the original link between ego1 and alter 1. This link MUST dissapear after rewiring (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
 link-list2       ;; this variable keeps track of the original link between ego2 and alter 2. This link MUST dissapear after rewiring (see "Maslov-Sneppen" procedure in p. 24, see also Maslov and Sneppen 2002)
]


turtles-own
[
 cave                                 ;; this variable gives an unique id number to ONE foundational agent per "number-of-caves". After creating the desired number of foundational agents, all new agents are created next to one of them (i.e. the new agents will be connected to one of the "foundational" agents, thus allowing for the emergence of the so-called caves)
 dynamic-traits                       ;; list containing the dynamic traits of a given agent. The acual length of the list, that is, the number of items in the list is determined by the global variable "number-dynamic-traits", represented by a slider in the interface
 dynamic-trait                        ;; each one of the traits in "dynamic-traits". This variable is used to fill in the list dynamic-traits
 static-traits                        ;; list containing the static traits of a given agent. The acual length of the list, that is, the number of items in the list is determined by the global variable "number-static-traits", represented by a slider in the interface
 static-trait                         ;; each one of the traits in "static-traits". This variable is used to fill in the list static-traits
 my-neighbors                         ;; list contaning the id numbers ("who" numbers in NetLogo's jargon) of the neighbors of a given agent. The size of this list (i.e. the number of neighbors of a given agent) is equal to k - 1, where k represents the number of nodes per cave. K is a global variable represented by a slider in the interface
 neighbor-id                          ;; specific id number of each one of the neighbors of a given turtle. This variable is used to "loop through" my-neighbors in order to calculate the distance (for dynamic and static traits) between neighbors
 difference-dynamic-trait             ;; this variables keeps track of the SQUARED DIFFERENCE between an agents' opinion regarding a given trait (e.g. item 2 in "dynamic-traits") and the same opinion of one of its neighbors (e.g. item 2 in the neighbor's "dynamic-traits").  See the first substraction in equation 2 in the paper.
 dynamic-differences-list             ;; list of all "difference-dynamic-trait". In other words, this list contains ALL the squared differences between an agents' opinions and ONE of its neighbor's opinions. See the first substraction in equation 2 in the paper.
 sum-dynamic-differences              ;; this variable sums up the numbers in "dynamic-differences-list". See the first summation in equation 2 in the paper.
 sum-dynamic-differences-list         ;; this is a list containig all the "sum-dynamic-differences" between a given agent ALL of its neighbors
 difference-static-trait              ;; this variables keeps track of the SQUARED DIFFERENCE between an agents' sociodemographic trait (e.g. item 2 in "static-traits") and the same sociodemographic trait of one its neighbors (e.g. item 2 in the neighbor's "static-traits").  See the second substraction in equation 2 in the paper.
 static-differences-list              ;; list of all "difference-static-trait". In other words, this list contains ALL the squared differences between an agents' sociodemographic traits and ONE of its neighbor's sociodemographic traits. See the second substraction in equation 2 in the paper.
 sum-static-differences               ;; this variable sums up the numbers in "static-differences-list". See the second summation in equation 2 in the paper.
 sum-static-differences-list          ;; this is a list containig all the "sum-static-differences" between a given agent ALL of its neighbors
 expected-distance                    ;; this variable keeps track of the expected distance between an agent an one of its neighbors. In other words, it equals the SQUARE ROOT of sum-static-differences-list + sum-dynamic-differences. see equation 2.
 expected-distances-list              ;; this is a list containing all the expected distances (i.e. all "expected-distance") between an agent and each one of its neighbors
 current-dynamic-differences-list     ;; list of all "difference-dynamic-trait" at time ("ticks") > 0. In other words, this list contains ALL the squared differences between an agents' opinions and ONE of its neighbor's opinions after time 0. See the first substraction in equation 2 in the paper.
 current-sum-dynamic-differences-list ;; this is a list containig all the "sum-dynamic-differences" between a given agent ALL of its neighbors at time ("ticks") > 0
 current-difference-dynamic-trait     ;; this variables keeps track of the SQUARED DIFFERENCE between an agents' opinion regarding a given trait (e.g. item 2 in "dynamic-traits") and the same opinion of one of its neighbors (e.g. item 2 in the neighbor's "dynamic-traits") at time ("ticks") 0.  See the first substraction in equation 2 in the paper.
 current-sum-dynamic-differences      ;; this variable sums up the numbers in "dynamic-differences-list" at time ("ticks") > 0. See the first summation in equation 2 in the paper.
 current-distance                     ;; this variable keeps track of the CURRENT (i.e. at the present time step, where time ("ticks") > 0) distance between an agent an one of its neighbors. In other words, it equals the SQUARE ROOT of sum-static-differences-list + sum-dynamic-differences. see equation 2.
 current-distances-list               ;; this is a list containing all the CURRENT (i.e. at the present time step, where time ("ticks") > 0) distances (i.e. all "current-distance") between an agent and each one of its neighbors
 expected-minus-current               ;; difference between expected distance and current distance between a given turtle an one of its neighbors. See equaton 3 in the paper.
 weight                               ;; list of ALL differences between the expected distance and the current distance between a given turtle an EACH ONE of its neighbors. See equaton 3 in the paper.
 weight-absolute                      ;; list of ALL the asbolute values of the differences between the expected distance and the current distance between a given turtle an EACH ONE of its neighbors. See equaton 3 in the paper.absolute value of difference between expected distance and current distance between a given turtle an one of its neighbors. See equaton 3 in the paper.
 weight-absolute-copy                 ;; this is a copy of the list "weight-absolute". It is used to calculate the probability of adopting an opinion. More precisely, it is used to calculate the denominator in equation 4 because to compute that numner (the dominator), one needs to exclude the (asbolute value of the) weight of the neighbor been compared to ego.
 selected-trait                       ;; at each iteration a randomly selected agent is choosen. After that, on of its traits is seclected at random. The urn will be fill based on this trait
 probability-of-adoption              ;; this is the probability of adopting a neighbors opinion. According to the authors "Each neighbor of a given agent places its opinion in the agent's urn with a probability given by the absolute value of the weight of the tie to that neighbor divided by the sum over the absolute values of the weights to all other neighbors." (p. 25) see equation 4.
 urn                                  ;; this is a list containing all the selected opinions  of a given agent's neighbors.
 opinion-adopted                      ;; this variable keeps track of the opinion dopted by a given agent. According to the authors: "Once the urn is filled, an opinion is randomly chosen and assigned to the focal agent" (p.25)
 selected-neighbor                    ;; specific id number of each one of the neighbors of a given turtle. This variable is used to "loop through" my-neighbors in order to fill in the urn.
]
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; initial-conditions ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
 clear-all                      ;; clear everything
 reset-timer
 generate-small-world           ;; execute the generate-small-world procedure based on a connected caveman graph (see p. 23; see also Watts 1999).
 generate-static-traits         ;; execute the generate-static-traits procedure
 generate-dynamic-traits        ;; execute the generate-dynamic-traits procedure
 identify-my-neighbors          ;; execute the identify-my-neighbors procedure
 calculate-expected-distances   ;; execute the calculate-expected-distances
 reset-ticks                    ;; set time ("ticks") to 0
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; go: run the simulation ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go-once
 calculate-current-distances      ;; execute the calculate-current-distances procedure. Remember that the difference between this procedure and the procedure "calculate-expected-distances" is that the latter calculates the expected distance, understood as the "distance at t=0 when all traits are randomly distributed" (p. 25)
 calculate-weight                 ;; execute the calculate-weight procedure
 filling-urns                     ;; execute the filling-urns-procedure
 show [dynamic-traits] of turtles ;; show dynamic traits of turtles
 tick                             ;; advance time
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; IMPORTANT:
;;;;;;;;; network topology and visulization ;;;;;;;;;;;; THIS PROCEDURE GENERATES THE NETWORK AND SOME OTHER VISUALIZATION STUFF. GIVEN THAT THIS PROCEDURE IS NOT RELATED TO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TO THE ACTUAL DYNAMICS OF THE MODEL, IT IS NOT IMPORTANT TO STUDY/UNDERSTAND THESE LINES OF CODE. THAT IS THE REASON WHY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; THESE LINES OF CODE ARE NOTE COMMENTED


to generate-small-world
 set-default-shape turtles "circle"
 set number-of-caves round (n / (k + 1))
 let z 0
 while [z < number-of-caves]
 [
  create-ordered-turtles 1
  [
   set cave z
   set color red
   ifelse (n <= 300) and (k <= 10)
   [
    display
    relocate
   ]
   [no-display]
  ]
  set z z + 1
 ]

 let j 0
 while [j < number-of-caves]
 [
  create-ordered-turtles k
  [
   set color red
   setxy ([xcor] of turtle j) ([ycor] of turtle j)
   fd 5
   create-link-with turtle j
   set cave j
  ]
  set j j + 1
 ]

 ask turtles
 [
  if (who >= number-of-caves)
  [
   ask other turtles
   [
    if ([cave] of self = [cave] of myself) and ([who] of self >= number-of-caves)
    [
     create-link-with myself
    ]
   ]
  ]
 ]

 set #-links count links
 rewire
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; THE FOLLOWING SET OF PROCEDURES ARE RELATED TO THE GENERATION OF THE NETWORK TOPOLOGY, SEE MASLOV & SNEPPEN (2002) FOR DETAILS.
;;; THESE PROCEDURES ARE MORE RELATED TO FORM THAN SUBSTANCE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to rewire
 repeat round (theta * #-links)
 [
  find-first-pair
  find-second-pair
  do-rewire
  ask link item 0 link-list1 item 1 link-list1 [die]
  ask link item 0 link-list2 item 1 link-list2 [die]
 ]
 check-number-of-ties
end

to find-first-pair
 set ego1 [who] of one-of turtles
 set alter1 [who] of [one-of link-neighbors] of turtle ego1
 check-first-pair
 set link-list1 []
 set link-list1 fput (ego1) link-list1
 set link-list1 fput (alter1) link-list1
 set link-list1 sort link-list1
end

to find-second-pair
 set ego2 [who] of one-of turtles
 set alter2 [who] of [one-of link-neighbors] of turtle ego2
 check-second-pair
 set link-list2 []
 set link-list2 fput (ego2) link-list2
 set link-list2 fput (alter2) link-list2
 set link-list2 sort link-list2
end


to do-rewire
 ask turtle ego1
 [
  create-link-with turtle ego2
 ]

 ask turtle alter1
 [
  create-link-with turtle alter2
  check-do-rewire
 ]
end

to relocate
  setxy random-pxcor random-pycor
   if ((count (turtles in-radius 12 with [distance myself < 12])) > 1) [
    relocate
                               ]
end


to check-first-pair
 if [cave] of turtle ego1 != [cave] of turtle alter1
  [find-first-pair]
end

to check-second-pair
  if [cave] of turtle ego2 != [cave] of turtle alter2 or [cave] of turtle ego1 = [cave] of turtle ego2
  [find-second-pair]
end

to check-do-rewire
 if link ego1 ego2 = link alter1 alter2
  [do-rewire]
end

to check-number-of-ties
  if count links != #-links
  [setup]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; generate dynamic and static traits ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to generate-static-traits
 ask turtles
 [
  set static-traits []                                 ;; generate the list "static-traits", make it an empty list
  repeat number-static-traits                          ;; repeat this loop as many times as the global variable "number-static-traits" indicates
  [
   set static-trait random 2                           ;; randomly generate either a 0 or 1
   set static-traits fput (static-trait) static-traits ;; put the randomly generated number in the list "static-traits"
  ]
 ]
end

to generate-dynamic-traits
 ask turtles
 [
  set dynamic-traits []                                   ;; generate the list "dynamic-traits", make it an empty list
  repeat number-dynamic-traits                            ;; repeat this loop as many times as the global variable "number-dynamic-traits" indicates
  [
   set dynamic-trait random 2                             ;; randomly generate either a 0 or 1
   set dynamic-traits fput (dynamic-trait) dynamic-traits ;; put the randomly generated number in the list "dynamic-traits"
  ]
 ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; calculate expected distances between a given agent and its neighbors ;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to identify-my-neighbors
 ask turtles
 [
  set my-neighbors []                                 ;; generate the list "my-neighbors", make it an empty list
  set my-neighbors [who] of turtle-set link-neighbors ;; put the id number ("who" number in netLogo's jargon) of each neighbor in the list "my-neighbors"
 ]
end

to calculate-expected-distances
 ask turtles
 [
  set dynamic-differences-list []              ;; generate the list "dynamic-differences-list", make it an empty list
  set sum-dynamic-differences-list []          ;; generate the list "sum-dynamic-differences-list", make it an empty list
  let j 0                                      ;; set the local variable j to 0
  while [j < k ]                               ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
  [
   let z 0                                     ;; set the local variable z to 0
   while [z < length dynamic-traits]           ;; go through this loop once per dynamic trait
   [
    set neighbor-id item j my-neighbors                                                                                  ;; retrieve the Jth neighbor's id number
    set difference-dynamic-trait ([item z dynamic-traits] of self - [item z dynamic-traits] of turtle neighbor-id) ^ 2   ;; take the square of the difference between the focal agent Zth dynamic trait and the Zth dynamic trait of its neighbor
    set dynamic-differences-list lput (difference-dynamic-trait) dynamic-differences-list                                ;; put each "difference-dynamic-trait" in the list called "dynamic-differences-list"
    set z z + 1                                                                                                          ;; go to the next trait in the "dynamic-traits" list
   ]
   set sum-dynamic-differences sum dynamic-differences-list                                     ;; sum up all the items in dynamic-differences-list.
   set sum-dynamic-differences-list lput (sum-dynamic-differences) sum-dynamic-differences-list ;; put the sum of all the "sum-dynamic-differences" (i.e. the distances between the focal agent and each one of tis neighbors) in he list "sum-dynamic-differences-list".
   set dynamic-differences-list []                                                              ;; set the list "dynamic-differences-list" as en empty list in order to do all the calculations again for the next neighbor.
   set j j + 1                                                                                  ;; go to the next neighbor
  ]
 ]


 ask turtles
 [
  set static-differences-list []               ;; generate the list "static-differences-list", make it an empty list
  set sum-static-differences-list []           ;; generate the list "sum-static-differences-list", make it an empty list
  let j 0                                      ;; set the local variable j to 0
  while [j < k ]                               ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
  [
   let z 0                                     ;; set the local variable z to 0
   while [z < length static-traits]            ;; go trough this loop once per static trait
   [
    set neighbor-id item j my-neighbors                                                                               ;; retrieve the Jth neighbor's id number
    set difference-static-trait ([item z static-traits] of self - [item z static-traits] of turtle neighbor-id) ^ 2   ;; take the square of the difference between the focal agent Zth static trait and the Zth static trait of its neighbor
    set static-differences-list lput (difference-static-trait) static-differences-list                                ;; put each "difference-static-trait" in the list called "static-differences-list"
    set z z + 1                                                                                                       ;; go to the next trait in the "static-traits" list
   ]
   set sum-static-differences sum static-differences-list                                     ;; sum up all the items in static-differences-list.
   set sum-static-differences-list lput (sum-static-differences) sum-static-differences-list  ;; put the sum of all the "sum-static"-differences (i.e. the distances between the focal agent and each one of tis neighbors) in he list "static-differences-list".
   set static-differences-list []                                                             ;; set the list "static-differences-list" as en empty list in order to do all the calculations again for the next neighbor.
   set j j + 1                                                                                ;; go to the next neighbor
  ]
 ]

 ask turtles
 [
  set expected-distances-list []                                                                         ;; generate the list "expected-distances-list", make it an empty list
  let z 0                                                                                                ;; set the local variable z to 0
  while [z < k]                                                                                          ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
  [
   set expected-distance sqrt (item z sum-static-differences-list + item z sum-dynamic-differences-list) ;; calculate the expected distance between the focal agent and its Zth neighbor. see equation 2.
   set expected-distances-list lput (expected-distance) expected-distances-list                          ;; keep track of all the expected distances by making a list of all the expected distances between the focal agent and each one of its neighbors
   set z z + 1                                                                                           ;; go to the the next neighbor
  ]
 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; calculate current distances between a given agent and its neighbors ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-current-distances
 if ticks >= 0
 [
  ask turtles
  [
   set current-dynamic-differences-list []     ;; generate the list "current-dynamic-differences-list", make it an empty list
   set current-sum-dynamic-differences-list [] ;; generate the list "current-sum-dynamic-differences-list", make it an empty list
   let j 0                                     ;; set the local variable j to 0
   while [j < k ]                              ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
   [
    let z 0                                    ;; set the local variable z to 0
    while [z < length dynamic-traits]          ;; go trough this loop once per dynamic trait
    [
     set neighbor-id item j my-neighbors                                                                                        ;; retrieve the Jth neighbor's id numb
     set current-difference-dynamic-trait ([item z dynamic-traits] of self - [item z dynamic-traits] of turtle neighbor-id) ^ 2 ;; take the square of the difference between the focal agent Zth dynamic trait and the Zth dynamic trait of its neighbor
     set current-dynamic-differences-list lput (current-difference-dynamic-trait) current-dynamic-differences-list              ;; put each "current-difference-dynamic-trait" in the list called "current-dynamic-differences-list "
     set z z + 1                                                                                                                ;; go to the next trait in the "dynamic-traits" list
    ]
    set current-sum-dynamic-differences sum current-dynamic-differences-list                                                    ;; sum up all the items in dynamic-differences-list.
    set current-sum-dynamic-differences-list lput (current-sum-dynamic-differences) current-sum-dynamic-differences-list        ;; put the sum of all the "sum-dynamic-differences" (i.e. the distances between the focal agent and each one of tis neighbors) in he list "sum-dynamic-differences-list".
    set current-dynamic-differences-list []                                                                                     ;; set the list "dynamic-differences-list" as en empty list in order to do all the calculations again for the next neighbor.
    set j j + 1                                                                                                                 ;; go to the next neighbor
   ]
  ]

  ask turtles
  [
   set current-distances-list []                                                                                  ;; generate the list "current-distances-list" , make it an empty list
   let z 0                                                                                                        ;; set the local variable z to 0
   while [z < length my-neighbors]                                                                                ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
   [
    set current-distance sqrt (item z sum-static-differences-list + item z current-sum-dynamic-differences-list)  ;; calculate the current distance between the focal agent and its Zth neighbor. see equation 2.
    set current-distances-list lput (current-distance) current-distances-list                                     ;; keep track of all the current distances by making a list of all the current distances between the focal agent and each one of its neighbors
    set z z + 1                                                                                                   ;; go to the the next neighbor
   ]
  ]
 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; calculate the weigh of a given tie ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to calculate-weight
  ask turtles
  [
   ifelse (ticks < 1)
   [
    set weight []                               ;; generate the list "weight" , make it an empty list
    set weight-absolute []                      ;; generate the list "weight-absolute" , make it an empty list
    set weight expected-distances-list          ;; make "weight" exactly the same as the distances at time = 0 (expected-distances-list), when all traits are randomly distributed (see p. 25 and equation 3)
    set weight-absolute expected-distances-list ;; make "weight-absolute" exactly the same as the absolute value distances at time = 0 (expected-distances-list) , when all traits are randomly distributed (see p. 25 and equation 3)
   ]

   [
    set weight []                                                                                ;; generate the list "weight" , make it an empty list
    set weight-absolute []                                                                       ;; generate the list "weight" , make it an empty list
    let z 0                                                                                      ;; set the local variable z to 0
    while [z < length my-neighbors]                                                              ;; go through this loop once per neighbor, remember that "k" is the number of neighbors (degree) of a given turtle
    [
     set expected-minus-current (item z expected-distances-list - item z current-distances-list) ;; calculate the weight of each one of the focal agent's ties. That is, compute the difference between the expected distance and the current distance between the focal agent and its Zth neighbor. see equation 3
     set weight-absolute lput (abs expected-minus-current) weight-absolute                       ;; keep track of the absolute value of the weight of each tie by putting the weight of each tie in the list "weight-absolute"
     set weight lput (expected-minus-current) weight                                             ;; keep track of the value of the weight of each tie by putting the weight of each tie in the list "weight"
     set z z + 1
    ]
   ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;
;;; filling the urns ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to filling-urns

 ask one-of turtles                                                                  ;; just to make the comments clearer, its important to emphasize that in all procedures, the "focal agent" is the turtle that is executing the commands
 [
  set selected-trait random  length dynamic-traits                                   ;; this variable indexes/indentifies the (dynamic) trait undergoing change
  set urn []                                                                         ;; generate the list "urn", make it an empty list
  let z 0                                                                            ;; set the local variable z to 0. This local variable indexes/identifies the focal agent's neighbor
  while [z < length my-neighbors]                                                    ;; go through this loop once per neighbor
  [
   set weight-absolute-copy weight-absolute                                          ;; creates a copy of the list  that contains the absolute values of the weights (i.e. "weight-absolute") between the focal agent and its neighbors
   set weight-absolute-copy remove-item z weight-absolute-copy                       ;; remove the weight of the tie between the focal agent and its Zth neighbor (this is the denominator in equation 4)
   ifelse sum weight-absolute-copy != 0                                              ;; if expected distances and current distances are different:
   [
    set probability-of-adoption (abs (item z weight) / (sum weight-absolute-copy))   ;; calculate the probability of adopting the Zth neighbor's opinion (see equation 4)
    ifelse (random-float 1 < probability-of-adoption)                                ;; if that probability IS large enough when compared to a randomly generated number between 0 and 1 AND
    [
     ifelse item z weight < 0                                                        ;; weight is NEGATIVE (see equation 3):
     [
      if random-float 1 <= 0.1                                                       ;; then, only 10% of the time:
      [
       set selected-neighbor item z my-neighbors                                     ;; keep track of the focal agent's Zth neighbor id number
       ifelse [item selected-trait dynamic-traits] of turtle selected-neighbor = 1   ;; if the opinion of the (negatively weighted) Zth neighbor regarding the selected trait is 1
       [
        set urn lput (0) urn                                                         ;; put a 0 in the focal agent's urn
        set z z + 1                                                                  ;; go the the next neighbor of the focal agent
       ]
       [                                                                             ;; if the opinion of the (negatively weighted) Zth neighbor regarding the selected is not 1 (i.e. if it is 0)
        set urn lput (1) urn                                                         ;; put a 0 in the focal agent's urn
        set z z + 1                                                                  ;; go the the next neighbor of the focal agent
       ]
      ]
     ]
     [                                                                                      ;; if the probability (probability-of-adoption) is large enough AND the weight is POSITIVE:
       set selected-neighbor item z my-neighbors                                            ;; store the id number of the focal agent's Zth neighbor
       set urn lput ([item selected-trait dynamic-traits] of turtle selected-neighbor) urn  ;; put the Zth neighbor's opinion about the selected trait dynamic trait in the focal agent's urn, which is the urn related to the selected trait
       set z z + 1                                                                          ;; go tho the next neighbor
     ]
    ]
    [                                                                                ;; if that probability (probability-of-adoption) of adopting the Zth neighbor's opinion IS NOT large enough:
     set z z + 1                                                                     ;; go to the next neighbor
    ]
   ]                                                                                 ;; if ALL the expected distances and current distances are the same:
   [
        set z length my-neighbors                                                    ;; exit the while loop because the denominator of equation 4 will be 0.
   ]
  ]                                                                                  ;; while loop is finished, which means that the focal agent went through all its neighbors
  if not empty? urn
  [                                                                                  ;; if the urn is not empty
   set opinion-adopted one-of urn                                                    ;; randomly select an opinion that is in the urn
   set dynamic-traits replace-item selected-trait dynamic-traits opinion-adopted     ;; replace the focal agent's opinion related to the selected trait by the opinion it selected in the line above
  ]
 ]
end

;; Why Do Liberals Drink Lattes?
;; Code for the model in Dellaposta, Shi, and Macy (2015)
;; Diego F. Leal, University of Massachusetts (www.diegoleal.info)
;; Last updated: August 2016
;; This code is a beta version
@#$#@#$#@
GRAPHICS-WINDOW
203
105
590
493
-1
-1
5.34
1
10
1
1
1
0
1
1
1
-35
35
-35
35
0
0
1
ticks
30.0

SLIDER
13
120
185
153
n
n
100
250
177.0
1
1
NIL
HORIZONTAL

SLIDER
14
171
186
204
k
k
8
10
10.0
1
1
NIL
HORIZONTAL

BUTTON
324
504
379
537
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
13
404
143
457
number of caves
number-of-caves
17
1
13

SLIDER
13
222
185
255
theta
theta
0
0.1
0.1
0.001
1
NIL
HORIZONTAL

MONITOR
13
349
146
402
clustering coefficient
mean [ nw:clustering-coefficient ] of turtles
3
1
13

MONITOR
13
459
142
512
mean path length
nw:mean-path-length
3
1
13

TEXTBOX
89
103
194
121
number of nodes
13
0.0
1

TEXTBOX
38
155
195
174
number of nodes per cave
13
0.0
1

TEXTBOX
49
205
188
223
proportion links rewired
13
0.0
1

SLIDER
13
262
186
295
number-static-traits
number-static-traits
1
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
14
307
186
340
number-dynamic-traits
number-dynamic-traits
1
20
5.0
1
1
NIL
HORIZONTAL

BUTTON
387
504
443
537
go-once
go-once\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
29
10
488
88
Why Do Liberals Drink Lattes? \nDellaPosta et al., AJS 2015.\nReplication by Diego F. Leal (www.diegoleal.info)
20
0.0
1

TEXTBOX
447
508
597
536
show all agents' dynamic traits after 1 run
11
0.0
1

TEXTBOX
207
514
331
532
set up initial conditions
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="_N3000_K99" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>[dynamic-traits] of turtles</metric>
    <enumeratedValueSet variable="k">
      <value value="99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-static-traits">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-dynamic-traits">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="?">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="_N500_K30_100000" repetitions="24" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100000"/>
    <metric>[dynamic-traits] of turtles</metric>
    <enumeratedValueSet variable="k">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-static-traits">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-dynamic-traits">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="?">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="_N3000_K30_100000" repetitions="24" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100000"/>
    <metric>[dynamic-traits] of turtles</metric>
    <enumeratedValueSet variable="k">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n">
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-static-traits">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-dynamic-traits">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="?">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
