extensions
[
 ;; UNCOMMENT IF WANT TO USE PROFILER
 ;profiler
 nw
]

globals
[
 ;; KEY GLOBAL VARIABLES TO CARRY OUT THE SIMULATION
 all-agents-primary-G-list               ;; list of all agents' group membership in the primary boundary. For instance, if G = 2 (e.g. black and white society), it means that each agent would either have G=0 or G=1 (i.e. black or white)
 all-agents-all-G-list                   ;; list of all agents' group membership across all boundaries. This is a super list in which the ith sublist has the group membership of all agents in the ith boundary. For instance, if the total number of boundaries is 3 (i.e. B=2 + the primary boundary), then there will be three sublists in "all-agents-all-G-list". See the agent-level variable "my-all-G-list" for more info in terms of the content of each sublist
 corr-between-traits-list                ;; list of all pair-wise correlation coefficients between agents' traits (i.e. between all the lists/traits in all-agents-all-G-list)
 group1                                  ;; if G-even-split? = FALSE, number of agents that are members of group 1 in the primary boundary
 group2                                  ;; if G-even-split? = FALSE, number of agents that are members of group 2 in the primary boundary
 group3                                  ;; if G-even-split? = FALSE, number of agents that are members of group 3 in the primary boundary
 group4                                  ;; if G-even-split? = FALSE, number of agents that are members of group 4 in the primary boundary
 group5                                  ;; if G-even-split? = FALSE, number of agents that are members of group 4 in the primary boundary
 C-outside-target-range?                 ;; false if C - F <= C <= C + F. That is, this variable is true as long as the target/user-defined level of correlation between boundaries (i.e. C) is outside the acceptable margin of error (i.e. C +/- F)
 unique-G-list                           ;; list with the actual values of the group memerships. So, if G=5, then this list will contain 5 numbers [0,1,2,3,4]
 mean-corr                               ;; average correlation between boundaries
 all-agents-deg-list                     ;; list with the IDs of all agents ordered by their degree, from highest to lowest
 all-agents-brokerage-list               ;; list with the IDs of all agents ordered by their intercultural capacity for brokerage, from highest to lowest
 all-agents-betw-list                    ;; list with the IDs of all agents ordered by their betweenness centrality, from highest to lowest
 seed                                    ;; original/early/seed adopter. If, for instance, innovators = "degree", this would be the agent with the highest degree.

 ;; SEGREGATION MEASURES
 E-I                                     ;; value of the E-I index of segregation
 GSI                                     ;; value of Moody's (2001) gross segregation index (GSI)
 avg-prop-same-G                         ;; average proportion of neighbors that have the same group membership in the primary boundary exhibited by ego. This is a basic measure of segregation
 modularity

 ;; DESCRIPTIVE GRAPH-LEVEL INDICES:
 transitivity                            ;; networks' transitivity
 clustering                              ;; networks' clustering
 avg-path-length                         ;; networks' avergae path length
 density                                 ;; networks' density
 isolates                                ;; number of isolates in the network
 overall-adoption                        ;; overall nuber of adopters
 in-group-adoption
 out-group-adoption


 ;; These variables are used to calculate the Pearson correlation coefficient between boundaries. These variables act mostly as local variables/place holders. For more details see the "compute-correlations" procedure
 X
 Y
 r
 t
 u
]

turtles-own
[
 ;; KEY AGENT-LEVEL VARIABLES TO CARRY OUT THE SIMULATION
 my-primary-G                            ;; ego's group membership in the primary boundary. For instance, if G=2 (e.g. black and white society), then ego would either have my-primary-G = 0 (e.g. black) or my-primary-G = 1 (white)
 my-all-G-list                           ;; list of all ego's group membership in all boundaries. For instance, if G=2 and B=1, ego will exhibit a list of length 2 (primary boundary + one secondary boundary [i.e. B=1]). Each item in the list will be either a 1 (e.g. black) or a 0 (white) since G=2 (e.g. black and white society)
 my-similarity-to-alter                  ;; ego's social similarity to the ith alter in the context of a given pair of traits
 my-raw-similarity-to-all-alters-list    ;; list of ego's raw social similarity (i.e similarity before making it range between 0 and 1) to each and every other alter
 my-similarity-to-all-alters-list        ;; list of ego's social similarity to each and every other alter

 Ai                                      ;; Ai = 1 if agent 1 adopted the innonvation, 0 otherwise
 Ti                                      ;; Agent i's adoption treshold
 my-brokerage-w                          ;; Agent i's intercultural capacity for brokerage
 my-neighbors                            ;; Agent i's (inmediate) neighbors
 my-degr                                 ;; Agent i's degree
 my-betw                                 ;; Agent i's betweenness centrality
]

to setup

clear-all
reset-ticks

;; UNCOMMENT IF WANT TO USE PROFILER
; profiler:start

if random-net?
[
 set C 0
 set H 1 / G
]

initilize-globals
populate-world
assign-primary-G
generate-secondary-Bs
compute-correlations
compute-final-corrs
generate-ties
c-isolates
check-isolates
segregation-measures
c-transitivity
c-avg-path-length
c-mean-corr
c-clustering
c-avg-prop-same-G
c-density
sociogram
compute-similarity
if innovators = "brokerage"
[
 compute-brokerage
]
order-potential-innovators
activate-seed-neighborhood
assign-adoption-threshold

;; UNCOMMENT IF WANT TO USE PROFILER

; profiler:stop
; print profiler:report
; profiler:reset
end

to go

social-diffusion

ask turtle seed
[
 set overall-adoption   ((count other turtles with    [Ai = 1 and shape = "default"]) / (count other turtles with [shape = "default"]))  ;; overall proportion of adopters. Note that only agents outside the seed neighborhoos (i.e. those with a default shape) are included here.
 set in-group-adoption  ((count other turtles with    [Ai = 1 and shape = "default" and my-primary-G = [my-primary-G] of turtle seed]) / (count other turtles with [my-primary-G = [my-primary-G] of turtle seed and shape = "default"]))       ;; proportion of in-group adopters of seed agent. Note that only agents outside the seed neighborhoos (i.e. those with a default shape) are included here.
 set out-group-adoption ((count other turtles with    [Ai = 1 and shape = "default" and my-primary-G != [my-primary-G] of turtle seed]) / (count other turtles with [my-primary-G != [my-primary-G] of turtle seed and shape = "default"]))     ;; proportion of out-group adopters of seed agent. Note that only agents outside the seed neighborhoos (i.e. those with a default shape) are included here.
]

if ticks > Q - 1
[
 stop                   ;; the model stops at Q - 1 ticks
]

tick ;; advance the tick (i.e. time) counter by one
end

to assign-adoption-threshold

ask turtles
[
 set Ti random-normal Tmean Tsd  ;; each turtle generates a random number (ej) drawn from a normal distribution with mean = mean-2 and standard deviation = std-deviation-2
 if (Ti < Tmean - 2 * Tsd)       ;; cap lower bound of learning rate (ej) at 2 standard deviations
 [
  set Ti (Tmean - 2 * Tsd)
 ]
 if (Ti > Tmean + 2 * Tsd)
 [
  set Ti (Tmean + 2 * Tsd)      ;; cap upper bound of learning rate (ej) at 2 standard deviations
 ]
]
end

to social-diffusion

if any? turtles with [Ai = 0 and shape = "default"]           ;; if there is any non-adopter
[
 ask one-of turtles with [Ai = 0 and shape = "default"]       ;; randomly select any of the non-adopters
 [
  let ego [who] of self                                       ;; call the (randomly) selected agent "ego"
  if any? link-neighbors with [Ai = 1]                        ;; if ego has any adopter in her neighborhood
  [
   ask one-of link-neighbors                                  ;; randomly ask one of ego's neighbors
   [
    if Ai = 1                                                 ;; if the randmly picked neighbor is an adopter
    [
     let alter [who] of self                                  ;; call the (randomly) selected agent "alter"

     ;; IF AGENTS CAN MAKE MISTAKES
     ifelse M > 0
     [
      ifelse random-float 1 < M    ;; with probability M
      [
       ask turtle alter            ;; ask ALTER (yes, not ego) to become a non-adopter
       [
        set Ai 0
        set size 1
       ]
      ]
      [                           ;; with probability 1 - M
       if [item alter my-similarity-to-all-alters-list] of turtle ego >= Ti
       [
        ask turtle ego
        [
         set Ai 1
         set size 1.5
        ]
       ]
      ]
     ]

     ;; IF AGENTS CANNOT MAKE MISTAKES
     [
      if [item alter my-similarity-to-all-alters-list] of turtle ego >= Ti
      [
       ask turtle ego
       [
        set Ai 1
        set size 1.5
       ]
      ]
     ]
    ]
   ]
  ]
 ]
]
end

to compute-similarity

let i 0                                          ;; declare the variable i as a local variable
let j 0                                          ;; declare the variable j as a local variable
let ego 0                                        ;; declare the variable ego as a local variable
let alter 0                                      ;; declare the variable alter as a local variable
while [i < N]                                    ;; while i is less than N
[
 set j 0                                         ;; set the local variable j to 0
 while [j < N]                                   ;; while j is less than group size, these nested loops allow agents to compare themselves with each of one of the other agents
 [
  set ego turtle i                               ;; the variable j represents ego's ID number. Ego's ID number starts at 0
  set alter turtle j                             ;; the variable j represents alter's ID number. Alter's ID number starts at 0
  ask ego                                        ;; ask ego:
  [
   let k 0                                       ;;  set the flag variable k to 0
   set my-raw-similarity-to-all-alters-list []   ;;  initially, have the local list my-raw-similarity-to-all-alters-list be an empty list
   while [k < length my-all-G-list ]             ;;  loop through all its (ego's) traits:
   [

    ifelse i = j                                                                                                                  ;; if ego is comparing to itself
    [
     set my-similarity-to-all-alters-list lput 9999 my-similarity-to-all-alters-list                                              ;; set social-distance to itself = to 9999.
    ]

    [

     if distance-measure = "smc"                                                                                                   ;; IF SIMPLE MATCHING COEFFICIENT IS USED:
     [
      ifelse [item k my-all-G-list ] of ego = [item k my-all-G-list ] of alter                                                     ;; if ego and alter have the same value on the kth boundary
      [
       set my-similarity-to-alter 1                                                                                                ;;  set similarity to alter (my-similarity-to-alter) = 1
      ]
      [
       set my-similarity-to-alter 0                                                                                                ;;  else (i.e. if ego and alter do not have the same value in the kth boundary), then set social distance to alter (my-similarity-to-alter) = 0
      ]

      let my-raw-my-similarity-to-alter my-similarity-to-alter
      set my-raw-similarity-to-all-alters-list lput (my-raw-my-similarity-to-alter) my-raw-similarity-to-all-alters-list           ;; make a list with the pair-wise "raw" similarity between ego and her alters

      if k = (length my-all-G-list ) - 1                                                                                           ;; once the comparison across all boundaries has been carried out:
      [
       set my-similarity-to-all-alters-list lput (((sum my-raw-similarity-to-all-alters-list) / length my-all-G-list )) my-similarity-to-all-alters-list ;; calculate the simple matching coefficient. See Šulc (2014) https://msed.vse.cz/msed_2014/article/275-Sulc-Zdenek-paper.pdf or Boriah et a. (???) http://www-users.cs.umn.edu/~sboriah/PDFs/BoriahBCK2008.pdf
      ]
     ]
    ]
    set k k + 1              ;; go to the next boundary
   ]
  ]
  set j j + 1                ;; go to the next alter
 ]
 set i i + 1                 ;; go to the next ego
]

repeat B                    ;; make sure the list my-similarity-to-all-alters-list (i.e. the socimatrix of all similarity scores) is an N X N matrix
[
 ask turtles
 [
  set my-similarity-to-all-alters-list remove-item  who  my-similarity-to-all-alters-list
 ]
]
end

to activate-seed-neighborhood

;; activate the seed agent and her inmmediate neighbors based on the user-defined innovator type (degree, brokerage, random)

if innovators = "degree"
[
 set seed item 0 all-agents-deg-list
 ask turtle seed
 [
  set Ai 1
  set shape "circle"
  ask link-neighbors
  [
   set Ai 1
   set shape "circle"
  ]
 ]
]

if innovators = "brokerage"
[
 set seed item 0 all-agents-brokerage-list
 ask turtle seed
 [
  set Ai 1
  set shape "circle"
  ask link-neighbors
  [
   set Ai 1
   set shape "circle"
  ]
 ]
]

if innovators = "random"
[
 set seed random (N)
 ask turtle seed
 [
  set Ai 1
  set shape "circle"
  ask link-neighbors
  [
   set Ai 1
   set shape "circle"
  ]
 ]
]

if innovators = "betweenness"
[
 set seed item 0 all-agents-betw-list
 ask turtle seed
 [
  set Ai 1
  set shape "circle"
  ask link-neighbors
  [
   set Ai 1
   set shape "circle"
  ]
 ]
]
end

to populate-world

;; create agents

ask patches
[
 set pcolor black
]

;; if group membership is to be evenly split  (e.g. if G-even-split? = TRUE and G = 2, then 50% of agents will be randomly assigned to group 1 (i.e. blacks) and 50% will be assigned to group 2 (e.g. whites)
ifelse G-even-split?
[
 let initial-seed (G * (round (N / G)))
 let extra-agents N - initial-seed

 ifelse extra-agents < 0
 [
  set initial-seed (initial-seed - abs (extra-agents))
  crt initial-seed
 ]
 [
  ifelse extra-agents > 0
  [
   set initial-seed (initial-seed + abs (extra-agents))
   crt initial-seed
  ]
  [
   crt initial-seed
  ]
 ]
]

;; if group membership is NOT to be evenly split
[
 ifelse PG1 + PG2 + PG3 + PG4 + PG5 = 1
 [
  set group1 round N * PG1
  set group2 round N * PG2
  set group3 round N * PG3
  set group4 round N * PG4
  set group5 round N * PG5
  crt (group1 + group2 + group3 + group4 + group5)
 ]
 [
  print "SIMULATION CANNOT START. THE GROUP PROPORTIONS (PG) MUST SUM UP TO 1"
  stop
 ]
]
end

to initilize-globals

set all-agents-primary-G-list []
set all-agents-all-G-list []
set all-agents-all-G-list []
set corr-between-traits-list []
set corr-between-traits-list []
set C-outside-target-range? true
set F 0.001
end

to assign-primary-G

;; assign agents to groups in the primary boundary G and assign colors to them too

ask turtles
[
 set color black
 set size 0.75
 set my-all-G-list []
 set my-similarity-to-all-alters-list []
 setxy random-xcor random-ycor
]

;; if group membership is to be evenly split

ifelse G-even-split?
[
 let initial-seed (G * (round (N / G)))
 let extra-agents N - initial-seed
 let agents-per-group floor (N / G)

 let i 0
 let agent-color 5
 while [i < G]
 [
  ask n-of agents-per-group turtles with [color = black]
  [
   set color agent-color
   set my-primary-G i
  ]
  set agent-color agent-color + 10
  set i i + 1
 ]

 if count turtles with [color = 0] > 0
 [
  repeat abs extra-agents
  [
   ask one-of turtles with [color = black]
   [
    set my-primary-G random G
    set color ((my-primary-G * 10) + 5)
   ]
  ]
 ]

 set group1 0
 set group2 0
 set group3 0
 set group4 0
 set group5 0
]

;; if group membership is to be evenly split
[
 ask n-of group1 turtles with [color = black]
 [
  set color 55
  set my-primary-G 0
 ]

 ask n-of group2 turtles with [color = black]
 [
  set color 15
  set my-primary-G 1
 ]

 ask n-of group3 turtles with [color = black]
 [
  set color 25
  set my-primary-G 2
 ]

 ask n-of group4 turtles with [color = black]
 [
  set color 35
  set my-primary-G 3
 ]

 ask turtles with [color = black]
 [
  set color 45
  set my-primary-G 4
 ]
]

let k 0
 while [k < N]
 [
  ask turtle k
  [
   set all-agents-primary-G-list lput ([my-primary-G] of self) all-agents-primary-G-list
  ]
  set k k + 1
 ]


set unique-G-list remove-duplicates all-agents-primary-G-list


set all-agents-primary-G-list []
set unique-G-list []

let l 0
while [l < N]
[
 ask turtle l
 [
  set all-agents-primary-G-list lput ([my-primary-G] of self) all-agents-primary-G-list
 ]
 set l l + 1
]

set unique-G-list remove-duplicates all-agents-primary-G-list
end

to generate-secondary-Bs

repeat B                                                                                       ;; repeat this loop B times
[
 let all-agents-new-trait-list all-agents-primary-G-list                                       ;; initially, have all-agents-new-trait-list be a copy of all-agents-primary-G-list

 let items-to-change 0                                                                         ;; initially, set the local variable items-to-change to 0
 if C >= 0                                                                                     ;; if the user-defined level of consolidation (C) is >= 0
 [
  set items-to-change round ((N * ((1 - C) * 100)) / 100)                                      ;; given the user-defined level of consolidation (C), compute the number of agents that need to change the value of their new trait in order to achieve the desired level of consolidation
 ]

 let a 0
 while [a < items-to-change]                                                                   ;; repeat this loop items-to-change times
 [
  let ego random N                                                                                                  ;; select an agent's ID at random, call the ID variable ego
  let alter random N                                                                                                ;; select an agent's ID at random, call the ID vaiable alter
  set all-agents-new-trait-list replace-item alter all-agents-new-trait-list (item ego all-agents-primary-G-list)   ;; swap ego's value with alter's value, the values are taken from the list all-agents-new-trait-list
  set all-agents-new-trait-list replace-item ego all-agents-new-trait-list (item alter all-agents-primary-G-list)   ;; swap alter's value with egos's value, the values are taken from the list all-agents-new-trait-list
  set a a + 1
 ]

 set all-agents-all-G-list lput (all-agents-new-trait-list) all-agents-all-G-list               ;; once the loop is executed items-to-change times, put all-agents-new-trait-list in the (super) list all-agents-all-G-list
]

set all-agents-all-G-list fput (all-agents-primary-G-list) all-agents-all-G-list                ;; have the list with agents' primary boundary group membership (i.e. all-agents-primary-G-list) be the first element in the (super)list all-agents-all-G-list
end

to compute-correlations

 set corr-between-traits-list []                                   ;; have the corr-between-traits-list be an empty list

 set t 0                                                           ;; set the flag variable t to 0
 set u 0                                                           ;; set the flag variable u to 0
 while [t < length all-agents-all-G-list]                          ;; this nested while loops go through all agents's traits in order to compute pair-wise correlations between them.
 [
  set u 0
  while [u < length all-agents-all-G-list]
  [
   if u > t                                                        ;; this condition makes the nested while loops compute pair-wise correlation for the lower triangle of the matrix since corr (trait u , trait t) = corr (trait t , trait u)
   [
    set X item t all-agents-all-G-list                             ;; set X to be the same as trait t in the context of the list of all agents' traits (i.e. all-agents-all-G-list)
    set Y item u all-agents-all-G-list                             ;; set Y to be the same as trait u in the context of the list of all agents' traits (i.e. all-agents-all-G-list)
    let XY []                                                      ;; have XY be an empty list
    let Xsqrd []                                                   ;; have Xsqrd be an empty list
    let Ysqrd []                                                   ;; have Ysqrd be an empty list
    let i 0                                                        ;; set the flag variable i to 0
    while [i < length X]                                           ;; go through all the elements of the target list / trait (either X or Y)
    [
     set XY lput ((item i X) * (item i Y)) XY                      ;; create a list with all the (element-wise) multiplications of the ith elements of lists / traits X and Y
     set Xsqrd lput ((item i X) ^ 2) Xsqrd                         ;; create a list with all the squared values of the ith elements of list / trait X
     set Ysqrd lput ((item i Y) ^ 2) Ysqrd                         ;; create a list with all the squared values of the ith elements of list / trait Y
     set i i + 1
    ]

    set r  (((length X * (sum (XY)))) - ((sum (X) * sum (Y)))) / ((sqrt ((length X * (sum Xsqrd)) - ((sum X) ^ 2))) * (sqrt ((length Y * (sum Ysqrd)) - ((sum Y) ^ 2))))  ;; compute the Pearson correlation coefficient (r) between trait X and trait Y, see https://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient
    set corr-between-traits-list lput (r) corr-between-traits-list ;; store correlation coefficient (r) between traits X and Y in the list corr-between-traits-list

    if C-outside-target-range?                                     ;; if the consolidation procedure has not been executed yet
    [
     get-desired-correlation                                       ;; run the consolidation procedure
    ]
   ]
   set u u + 1
  ]
  set t t + 1
 ]
end

to get-desired-correlation

let items-to-change round ((N * ((abs (C - (precision (r) 1))) * 100)) / 100)     ;; given the difference between the correlation (r) between two given agents' traits (here called X and Y) and the user-defined level of consolidation, compute the number of agents that need to change the value of their traits in order to achieve the desired level of consolidation

if (r <= C - F)                                                                   ;; if correlation (r) is too low, meaning, if the level of correlation (r) between traits X and Y is <= the user-defined level of consolidaton (i.e. C) - margin-of-error-corr (i.e. F)
[
 let a 0
 while [a < items-to-change]                                                      ;; repeat this loop items-to-change times:
 [
  let ego random N                                                                ;; select an agent (i.e. ego) at random
  if item ego X != item ego Y                                                     ;; if ego's value of trait X is different from ego's value of trait Y
  [
   set all-agents-all-G-list (replace-item u all-agents-all-G-list (replace-item ego (item u all-agents-all-G-list) item ego all-agents-primary-G-list)) ;; make ego's value of trait Y equal to ego's group membership in the primary boundary, this line of code is somewhat complex because it replaces a value in the context of a nested list. Here, the target nested list is identified using the "u" flag variable used in the context of the compute-correlations procedure
   set a a + 1                                                                    ;; go to next item to change
  ]
 ]
]

if (r > C + F)                                                                    ;; if correlation (r) is too high, meaning, if the level of correlation (r) between traits X and Y is > the user-defined level of consolidaton (i.e. C) + margin-of-error-corr (i.e. F)
[
 let a 0
 while [a < items-to-change]                                                      ;; repeat this loop items-to-change times:
 [
  let ego random N                                                                ;; select an agent (i.e. ego) at random
  let different-G one-of unique-G-list                                            ;; select a group membership in the primary boundary at random
  if (item ego X = item ego Y) and (item ego X != different-G)                    ;; if ego's value of trait X is equal to ego's value of trait Y AND ego's value of trait X is different from the number "different-G"
  [
   set all-agents-all-G-list (replace-item u all-agents-all-G-list (replace-item ego (item u all-agents-all-G-list) different-G))                ;; make ego's value of trait Y different from the number that identifies its group membership in the primary boundary, this line of code is somewhat complex because it replaces a value in the context of a nested list. Here, the target nested list is identified using the "u" flag variable used in the context of the compute-correlations procedure
   set a a + 1                                                                    ;; go to next item to change
  ]
 ]
]
end

to compute-final-corrs

set C-outside-target-range? false                                                  ;; given that the get-desired-correlations was already executed, have the variable not-yet-consolidated set to false
compute-correlations                                                               ;; given that the get-desired-correlations was already executed, compute (final) correlations between all traits

let i 0
while [i < length all-agents-all-G-list]                                           ;; loop through all the elements of the (super) list all-agents-all-G-list
[
 ask turtles                                                                       ;; ask each agents to
 [
  set my-all-G-list lput (item who (item i all-agents-all-G-list)) my-all-G-list   ;; create its own private list of traits based on the globally available info found in the ith trait / list located in the (super) list all-agents-all-G-list
 ]
 set i i + 1                                                                       ;; go to next trait
]
end

to generate-ties

let seed-ego random N
let prob random-float 1

ask turtle seed-ego                               ;; ask a randomly selected agent to randomly select a boundary and store in memory her group membership in that boundary
[
 let ego-trait length my-all-G-list
 let rnd-trait random ego-trait
 let ego-my-trait item rnd-trait my-all-G-list

;; WITH PROBABILITY H
 ifelse (prob  <= H )
 [
  let alter-id [who] of one-of other turtles with [item rnd-trait my-all-G-list = ego-my-trait] ;; select as an associate an alter that has the same group membership in boundary she selected in the previous ask loop
  create-link-with turtle alter-id
 ]
;; WITH PROBABILITY  1- H
 [
  let alter-id [who] of one-of other turtles with [item rnd-trait my-all-G-list != ego-my-trait] ;; select as an associate an alter that does not have the same group membership in boundary she selected in the previous ask loop
  create-link-with turtle alter-id
 ]
]

ifelse count links >= ((N * Z) / 2) * 0.97                           ;; to reduce execution time, only check if the number of existing ties is 97% of what it should be given the user-defined Z
[
 if mean-degree <= Z - (F * 10) or mean-degree >= Z + (F * 10)       ;; if current mean-degree is <= or >= than Z [i.e. user-defined mean degree] +/- a margin of error [F * 10], then do one more round. Note that the margin of error for Z is 10 times less strict than the margin of error for the target level of C [i.e. F]. So, for instance, if F = 0.001, the margin of error for Z is 0.01
 [
  generate-ties                                                      ;; generate a new tie
 ]
]
[
 generate-ties
]

;; change some colors to make things looks prettier
ask links [set color 109]
ask patches [set pcolor white]
ask turtles [set my-degr count link-neighbors]
ask turtles [set my-betw nw:betweenness-centrality]
end

to check-isolates

if isolates > 0             ;; if there are isolates, run the model again
[
 ask links [die]
 initilize-globals
 assign-primary-G
 generate-secondary-Bs
 compute-correlations
 compute-final-corrs
 generate-ties
 c-isolates
 check-isolates
]
end

to sociogram                  ;; draw plots

;; code to do plots

ifelse do-plots?
[
 update-plots
 display
 if C-outside-target-range? = false
 [
  repeat 750
  [
   layout-spring turtles links 0.2 1 1.5
  ]
 ]
]
[
 no-display
]
end

to c-mean-corr                ;; compute the mean corrwelation between boundaries

 set mean-corr mean corr-between-traits-list
end

to-report mean-degree         ;; compute mean degree
 report (sum [count my-links] of turtles) / N
end

to c-avg-prop-same-G          ;; compute the average proportion of in-group ties along the primary boundary

let all-agents-prop-same-G-list []
ask turtles
[
 ask other turtles
 [
  if count [link-neighbors] of self > 0
  [
   let my-prop-same-G (count (link-neighbors with [[my-primary-G] of myself = [my-primary-G] of self])) / (count [link-neighbors] of self)
   set all-agents-prop-same-G-list  lput (my-prop-same-G) all-agents-prop-same-G-list
  ]
 ]
]

set avg-prop-same-G mean all-agents-prop-same-G-list
end

to c-transitivity             ;; calculate transitiviy

 let closed-triplets sum [nw:clustering-coefficient * count my-links * (count my-links - 1)] of turtles
 let triplets sum [count my-links * (count my-links - 1)] of turtles
 set transitivity closed-triplets / triplets
end

to c-clustering               ;; calculate clustering

 set clustering mean [nw:clustering-coefficient] of turtles
end

to c-avg-path-length          ;; calculate average path length

 set avg-path-length nw:mean-path-length
end

to c-density                  ;; calculate graph density
 set density count links / ((N * (N - 1)) / 2)
end

to c-isolates                 ;; clculate number of isolates

set isolates count turtles with [not any? link-neighbors = true]
end

to segregation-measures       ;; compute Moody's (2001) gross friendship segregation (GSI)

let AA 0
let BB 0
let CC 0
let DD 0


let i 0                                     ;; declare the variable i as a local variable
let j 0                                     ;; declare the variable j as a local variable
let ego 0                                   ;; declare the variable ego as a local variable
let alter 0                                 ;; declare the variable alter as a local variable
while [i < N]                      ;; while i is less than group-size.
[
 set j 0                                    ;; set the local variable j to 0
 while [j < N]                     ;; while j is less than group-size, these nested while loops allow each agent (ego) to compare to all other agents (alter)
 [
  set ego [who] of turtle i                 ;; the variable i represents ego's ID number. Ego's ID number starts at 0
  set alter [who] of turtle j               ;; the variable j represents alter's ID number. Alter's ID number starts at 0
  if ego != alter and j > i
  [
   ask turtle ego
   [
    if ([my-primary-G] of turtle alter = [my-primary-G] of turtle ego) and (link-neighbor? turtle alter)
    [set AA AA + 1]
    if ([my-primary-G] of turtle alter != [my-primary-G] of turtle ego) and (link-neighbor? turtle alter)
    [set BB BB + 1]
    if ([my-primary-G] of turtle alter = [my-primary-G] of turtle ego) and (not link-neighbor? turtle alter)
    [set CC CC + 1]
    if ([my-primary-G] of turtle alter != [my-primary-G] of turtle ego) and (not link-neighbor? turtle alter)
    [set DD DD + 1]
   ]
  ]
  set j j + 1                               ;; go to the next alter
 ]
 set i i + 1                                ;; go to the next ego
]

set E-I -1 * ((BB - AA) / count links)

ifelse BB != 0 and CC != 0 and AA != 0 and DD != 0
[
 set GSI ln ((AA * DD) / (BB * CC))  ;; result is the same as the one reported in Bojanowski & Corten 2014
]
[
 set GSI "infinity"
]

;"Alpha is substantively
;interpretable as the odds ratio of a friendship between members
;of a same-race dyad relative to friendship in a cross-race dyad. When
;alpha = 1, then the odds of a same-race friendship equal the odds of a crossrace
;friendship, and the setting is perfectly integrated. As alpha increases, the
;relative odds of a same-race friendship increase by a factor of alpha. Since a
;is scaled from 0 to indfinity, I use ln (a), which ranges from - infinity to infinity" Moody (2001: 692)



;; E-I index (Krackhardt and Stern 1988). We mutiply the original measure by -1 so that this measure takes the value -1 if all ties
;; in the network are between groups, and + 1 if all ties are within groups.


set modularity  nw:modularity
(
 list (turtles with [ my-primary-G = 0 ]) (turtles with [ my-primary-G = 1 ])  (turtles with [ my-primary-G = 2 ]) (turtles with [ my-primary-G = 3 ]) (turtles with [ my-primary-G = 4 ])
 (turtles with [ my-primary-G = 5 ]) (turtles with [ my-primary-G = 6 ])  (turtles with [ my-primary-G = 7 ]) (turtles with [ my-primary-G = 8 ]) (turtles with [ my-primary-G = 9 ])
)
end

to compute-brokerage          ;; compute intercultural capacity for brokerage (IB)

ask turtles
[
 set my-brokerage-w 0
 set my-neighbors []
 set my-neighbors (sort [who] of link-neighbors)
]

let i 0
let j 0
let k 0
while [i < N]
[
 set j 0
 while [j < N]
 [
  set k 0
  while [k < N]
  [
   if i != k and i != j and j != k and i < k  ;; loop through all triads
   [
    ask turtle i
    [
     if (not link-neighbor? turtle k) and ([my-primary-G] of turtle i != [my-primary-G] of turtle k) ;; make sure i<-/->k and that i and k are from different groups (i.e. group membeship in the primary boundary)
     [
      ask turtle j
      [
       if link-neighbor? turtle i and link-neighbor? turtle k     ;; make sure i<->j<->k
       [

        let AA 0
        let redundancy 0
        while [AA < length [my-neighbors] of turtle k]            ;; loop through the end-point's (i.e. agent k's) neighbors
        [
         let alter-2 item AA [my-neighbors] of turtle k
         if [link-neighbor? turtle alter-2] of myself             ;; if any of k's neighbors, including j, is connected to the initial-point (i.e. agent i):
         [
          set redundancy redundancy + 1                           ;; increase redundancy by one. This, therefore, is a count of number of two-paths that connect agents i and k
         ]
         set AA AA + 1
        ]

        set my-brokerage-w my-brokerage-w + 1 / redundancy            ;; weight j's role as a broker in the context of the i<->j<->k triad by the number of other brokers (e.g. i<->l<->k)
       ]
      ]
     ]
    ]
   ]
   set k k + 1
  ]
  set j j + 1
 ]
 set i i + 1
]
end

to order-potential-innovators ;; order agents by desired properties (i.e. degree of IB)

set all-agents-deg-list     []
set all-agents-brokerage-list []
set all-agents-betw-list []


if innovators = "degree"
[
 foreach sort-on [(- my-degr)] turtles                            ;; make a list with the CAPi values of the agents with X hightest degree
 [ ?1 ->
  ask ?1
  [
   set all-agents-deg-list lput ([who] of self) all-agents-deg-list]
  ]
]

if innovators = "brokerage"
[
 foreach sort-on [(- my-brokerage-w)] turtles                      ;; make a list with the CAPi values of the agents with X highest racial brokerage scores
 [ ?1 ->
  ask ?1
   [
    set all-agents-brokerage-list lput ([who] of self) all-agents-brokerage-list
   ]
 ]
]

if innovators = "betweenness"
[
 foreach sort-on [(- my-betw)] turtles                      ;; make a list with the CAPi values of the agents with X highest racial brokerage scores
 [ ?1 ->
  ask ?1
   [
    set all-agents-betw-list lput ([who] of self) all-agents-betw-list
   ]
 ]
]
end


;; Code written by Diego F. Leal (www.diegoleqal.info)
;; Project: Three Essays on Network Dynamics and Liminality, Ph.D. dissertation
;; Sociology department, UMass-Amherst
;; All rights reserved
;; Last updated 2/19/18
@#$#@#$#@
GRAPHICS-WINDOW
343
10
844
512
-1
-1
10.96
1
10
1
1
1
0
0
0
1
-22
22
-22
22
1
1
1
ticks
30.0

SLIDER
4
10
139
43
C
C
0
1
0.6
0.01
1
NIL
HORIZONTAL

SLIDER
163
13
302
46
H
H
0
1
1.0
0.01
1
NIL
HORIZONTAL

BUTTON
524
579
587
612
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

BUTTON
604
581
667
614
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
166
70
304
103
B
B
1
25
9.0
1
1
NIL
HORIZONTAL

SLIDER
5
141
143
174
N
N
100
500
300.0
10
1
NIL
HORIZONTAL

SLIDER
5
106
143
139
Z
Z
4
8
5.0
1
1
NIL
HORIZONTAL

SWITCH
8
388
163
421
do-plots?
do-plots?
1
1
-1000

MONITOR
223
588
321
633
consolidation coef
mean-corr
4
1
11

MONITOR
223
453
321
498
NIL
mean-degree
4
1
11

MONITOR
223
496
321
541
density
density
3
1
11

SLIDER
166
106
302
139
G
G
2
8
5.0
1
1
NIL
HORIZONTAL

MONITOR
222
362
322
407
path length
avg-path-length
4
1
11

MONITOR
222
408
321
453
clustering coeff
clustering
4
1
11

SWITCH
4
431
174
464
G-even-split?
G-even-split?
0
1
-1000

SLIDER
3
467
175
500
PG1
PG1
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
3
500
175
533
PG2
PG2
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
3
531
175
564
PG3
PG3
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
2
565
175
598
PG4
PG4
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
1
600
175
633
PG5
PG5
0
1
0.0
0.001
1
NIL
HORIZONTAL

MONITOR
432
520
511
565
ln (GSI)
GSI
4
1
11

MONITOR
516
519
579
564
E-I index
E-I
4
1
11

MONITOR
1079
361
1199
406
overall adoption
overall-adoption
3
1
11

CHOOSER
5
264
164
309
innovators
innovators
"random" "degree" "brokerage" "betweenness"
1

PLOT
855
10
1171
252
Adoption over time
Time
Proportion adopters
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot overall-adoption"
"pen-1" 1.0 0 -13840069 true "" "plot in-group-adoption"
"pen-2" 1.0 0 -2674135 true "" "plot out-group-adoption"

MONITOR
582
519
653
564
NIL
modularity
3
1
11

MONITOR
223
541
321
586
transitivity
transitivity
3
1
11

SWITCH
5
354
164
387
random-net?
random-net?
1
1
-1000

MONITOR
658
519
767
564
avg prop same race
avg-prop-same-G
3
1
11

TEXTBOX
855
265
1078
315
OUT-GROUP ADOPTION
20
15.0
1

TEXTBOX
855
367
1050
393
OVERALL-ADOPTION
20
0.0
1

TEXTBOX
854
319
1100
347
IN-GROUP-ADOPTION
20
65.0
1

MONITOR
1078
255
1198
300
out-group adoption
out-group-adoption
3
1
11

MONITOR
1078
309
1198
354
in-group adoption
in-group-adoption
3
1
11

CHOOSER
5
309
164
354
distance-measure
distance-measure
"smc"
0

SLIDER
5
175
144
208
Q
Q
10000
50000
10000.0
500
1
NIL
HORIZONTAL

SLIDER
5
71
143
104
M
M
0
0.1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
166
140
304
173
F
F
0.001
0.0025
0.001
0.0001
1
NIL
HORIZONTAL

SLIDER
165
174
303
207
Tmean
Tmean
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
5
210
145
243
Tsd
Tsd
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

PLOT
169
214
342
360
Threshold Distribution
NIL
NIL
0.0
1.05
0.0
300.0
true
false
"histogram [Ti] of turtles" ""
PENS
"default" 0.05 1 -16777216 true "" "histogram [Ti] of turtles"

TEXTBOX
853
403
1415
711
C: \t\tConsolidation\nH: \t\tHomophily\nM: \t\tNoise\nB: \t\tNumber of secondary boundaries\nZ: \t\tMean degree\nG: \t\tNumber of groups\nN: \t\tNumber of agents\nF: \t\tMargin of error for C\nQ: \t\tNumber of iterations\nTmean: \t\tAdoption threshold mean\nTsd: \t\tAdoption threshold standard deviation\nInovators: \tSelect seed agent\nG-even-plit?: \tShould each group be of equal size?\nPG1-PG5: \tIf groups are are not of equal size, specify the proportion of agents in each group\n\nFor a detailed explanation of the code: http://diegoleal.info/files/Dissertation_ABM_Dleal/\nDiego F. Leal (www.diegoleal.info)
11
105.0
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
  <experiment name="ID_1_experiment_base_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_2_Tmean_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.4"/>
      <value value="0.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_3_Tmean2_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.3"/>
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_4_Tsd_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.01"/>
      <value value="0.015"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_5_G_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="3"/>
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_6_B_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="4"/>
      <value value="14"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_7_Z_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="7"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_8_Tsd_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.1"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_9_Q_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="50000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_10_M_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_11_M_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="ID_12_M_100" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>mean-corr</metric>
    <metric>GSI</metric>
    <metric>E-I</metric>
    <metric>modularity</metric>
    <metric>transitivity</metric>
    <metric>clustering</metric>
    <metric>avg-prop-same-G</metric>
    <metric>avg-path-length</metric>
    <metric>in-group-adoption</metric>
    <metric>out-group-adoption</metric>
    <metric>overall-adoption</metric>
    <enumeratedValueSet variable="PG1">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG4">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PG5">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G-even-split?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-net?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="do-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-measure">
      <value value="&quot;smc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="innovators">
      <value value="&quot;degree&quot;"/>
      <value value="&quot;brokerage&quot;"/>
      <value value="&quot;random&quot;"/>
      <value value="&quot;betweenness&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="F">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0.01"/>
      <value value="0.025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Q">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tmean">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tsd">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Z">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="B">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="G">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="C" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="H" first="0" step="0.1" last="1"/>
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
