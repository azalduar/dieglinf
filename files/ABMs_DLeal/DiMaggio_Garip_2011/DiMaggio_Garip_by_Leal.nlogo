globals[
 internet-price-history ;; list containing the history/records of internet price over time
 internet-price         ;; internet price at time t
 overall-adopters-now   ;; agents with internet at time t
       ]

turtles-own[
 race                                 ;; ego's race, from GSS
 income                               ;; ego's income, from GSS
 incomeNorm                           ;; ego's normalized income to a range of [0,1] (see DiMaggio and Garip appendix page 3)
 educ                                 ;; ego's education, from GSS
 educNorm                             ;; ego's normalized education to a range of [0,1] (see DiMaggio and Garip appendix page)
 target-number-of-relations           ;; ego's number of friends to discuss personal issues or other problems, "numprobs" variable from GSS
 social-distance-to-alter             ;; ego's social distance to a given alter
 social-distances-to-all-alters       ;; list of social distances between ego and every alter (i.e. list of all "social-distance-to-alter")
 social-distance-to-similar-alter     ;; social distance between ego and a given in-group alter
 social-distance-to-dissimilar-alter  ;; social distance between ego and a given alter in the out-group
 dissimilar-turtles                   ;; list of all alters' IDs in ego's out-group.
 alters-id-number                     ;; alter's ID number (i.e. "who" number in NetLogo's jargon)
 in-group-size                        ;; size of the in-group (i.e. number of alters similar to ego in terms of the social distance metric)
 max-in-group-distance                ;; value of the social distance to the least socially similar alter in ego's in-group
 all-alters                           ;; list of all ID numbers excluding ego's ID number. This variable is used to generate the random network
 reservation-price                    ;; reservation price
 k                                    ;; multiplicative constant fot the income effect
 gamma                                ;; exponential constant for the income effect
 delta                                ;; multiplicative constant for network effect
 alpha                                ;; exponential constant for network effect
 weight_income                        ;; weight of income
 weight_educ                          ;; weight of education
 weight_race                          ;; weight of race
 random-perturbation                  ;; this is a "normally distributed random perturbation with a mean of 0 introduced in the ﬁrst period". (see DiMaggio and Garip appendix p. 1). This distribution is not truncated.
 proportion-similar                   ;; proportion of socially similar alters in ego's network (i.e. degree/level of homophily in ego's network)
 alters-id                            ;; ID number of a possible neighbor. This variable is used to evaluate the possibility of generating a tie between a given alter an ego
 my-friends                           ;; possible similar neighbor. This variable is used to evaluate the possibility of generating a tie between ego an a given alter in the in-group
 my-friends2                          ;; possible dissimilar neighbor. This variable is used to evaluate the possibility of generating a tie between ego and a given alter in the out-group
 adopters-in-ego-network              ;; proportion of neighbors that have adopted internet
 homophily-score                      ;; this variable is used to assign the degree of homophily selected by the user
         ]

to setup
  clear-all
  set-default-shape turtles "person" ;; make all turtles look like a person
  generate-realistic-agents          ;; this procedure imports the GSS data and assigns the variables' values to the corresponding agent
  ask turtles [setup-turtles]        ;; extra setup for turtles (location in the world, colors, etc.)
  setup-internet-price-history       ;; this procedure creates the internet-price-history list
  if (Type-Network-Effects = "Specific-Network-Effects") or (Type-Network-Effects = "Specific-Random-Network")[  ;; if a network needs to be modeled:
   compute-social-distance           ;; execute the compute-social-distance procedure
   find-alters-id-number             ;; execute the find-alters-id-number
   generate-ties                     ;; execute the generate-ties procedure
                                                                                                              ]


  reset-ticks                        ;; reset the tick counter
end

to setup-in-group-size
;"Under conditions of homophily, networks are generated as follows: each agent i establishes a random tie with
;an individual j who is among the n agents closest to the individual i in terms of the social distance metric. We
;refer to this set of agents as i’s “in-group.” In our application, n is arbitrarily chosen to be three times the target
;number of relations for that person." (see DiMaggio and Garip Appendix p. 3)
  set in-group-size (n * target-number-of-relations)  ;; the in-group size of each agent is n * the GSS self-reported number of friends
end

to setup-turtles
   assign-constants               ;; execute the procedure assign-constants
   generate-random-perturbation   ;; execute the procedure generate-random-perturbation
   assign-homophily               ;; execute the procedure assign-homophily
   setup-in-group-size            ;; execute the procedure setup-ingroup-size
   set color pink                 ;; let agents be pink
   setxy random-xcor random-ycor  ;; let agents find a random location in the world
end

to assign-homophily
  set homophily-score homophily   ;; assign the value/degree of "homophily" selected by the user
end

to assign-constants
  set k (0.1)                                           ;; multiplicative constant of the pure income effect (see DiMaggio and Garip equation A6 in the appendix)
  set gamma (0.5)                                       ;; exponent of network size (see DiMaggio and Garip equation A4 in the appendix)
  set alpha (0.5)                                       ;; exponent of income (see DiMaggio and Garip equation A4 in the appendix)
   ifelse (Type-Network-Effects = "No-Network-Effects") ;; if the user selects no network effects:
    [set delta (0.0)]                                   ;; no network effect on reservation prices (see DiMaggio and Garip equation A7  in the appendix)
    [set delta (0.1)]                                   ;; otherwise, use network effect on reservation prices  (see DiMaggio and Garip equation A7 in the appendix)
  set weight_income (0.53)                              ;; assigning the weight of the income variable (see DiMaggio and Garip equation A15 in the appendix)
  set weight_educ (0.53)                                ;; assigning the weight of the education variable (see DiMaggio and Garip equation A15 in the appendix)
  set weight_race (0.83)                                ;; assigning the weight of the education variable (see DiMaggio and Garip equation A16 in the appendix)
end

to generate-random-perturbation
  set random-perturbation ((random-normal 0 1) * 12.5) ;; "a normally distributed random perturbation with a mean of 0 [is] introduced in the ﬁrst period" (see DiMaggio and Garip p.1 in the appendix)
end

to setup-internet-price-history
 set internet-price-history [60.00] ;; the initial internet price is setup to $60.00 (see DiMaggio and Garip equation A11 in the appendix)
end

to compute-changes-in-prices-and-adoption
 ask-concurrent turtles[
  calculate-reservation-price ;; execute the calculate-reservation-price procedure
  change-color                ;; execute the change-color procedure
                         ]
 if (Type-Network-Effects = "Specific-Network-Effects") or (Type-Network-Effects = "Specific-Random-Network")[ ;; if specific network externalities are selected by the user
  ask-concurrent turtles[
    calculate-adopters-in-ego-network ;; execute the calculate-adopters-in-ego-network procedure
                        ]
                                                                                                              ]
    calculate-overall-adopters-now ;;execute the calculate-overall-adopters-now procedure
    calculate-internet-price       ;;execute the calculate-internet-price procedure
end

to calculate-overall-adopters-now
  set overall-adopters-now (((count turtles with [color = blue])) / count turtles) ;; calculate the overall proportion of adopters
end

to calculate-adopters-in-ego-network
  ifelse (count my-links > 0)[
   set adopters-in-ego-network (((count link-neighbors with [color = blue])) / count link-neighbors) ;; ego calculates the proportion of adopters in its network
                             ]

   [
   set adopters-in-ego-network 0 ;; if ego is an isolate, by definition it cannot by tied to an agent.
   ]
end

to calculate-reservation-price
  if (Type-Network-Effects = "General-Network-Effects") or (Type-Network-Effects = "No-Network-Effects")[                                  ;; if no network externalities or general externalities are selected by the user:
   set reservation-price ((k * (income ^ gamma)) + ((income ^ gamma) * delta * (overall-adopters-now ^ gamma)) + (random-perturbation))    ;; set reservation price using this formula, see DiMaggio and Garip equation A12 in the apendix
                                                                                                        ]

  if (Type-Network-Effects = "Specific-Network-Effects") or (Type-Network-Effects = "Specific-Random-Network")[                            ;; if specific network externalities are selected by the user:
   set reservation-price ((k * (income ^ gamma)) + ((income ^ gamma) * delta * (adopters-in-ego-network ^ gamma)) + (random-perturbation)) ;; set reservation price using this formula, see DiMaggio and Garip equation A12 in the appendix
                                                                                                              ]
end

to calculate-internet-price
  set internet-price (((3.34 / 12) * overall-adopters-now * (28.74 - (item 0 internet-price-history))) + (item 0 internet-price-history))  ;; compute internet price, see DiMaggio and Garip equation A13 in the appendix
end

to register-internet-price
  set internet-price-history fput (internet-price) internet-price-history ;; the historic record of internet prices over time are stored in this list
end

to change-color
  if (reservation-price >= item 0 internet-price-history) ;; ego compares the current internet price to its threshold (i.e. to its reservation-price)
   [set color blue]                                       ;; if ego's threshold is >= than the internet price, then it turns blue (i.e. it purchases internet service) (see DiMaggio and Garip p. 1901)
end

to go
  compute-changes-in-prices-and-adoption ;; calculate internet price and proportion of adopters over time
  register-internet-price                ;; keep track of internet prices over time
                                    ;; advance the tick (i.e. time) counter by one
  if timeLimit? [                        ;; if timeLimit? is on
  if ticks > 99 [
    stop                   ;; the model stops at 100 ticks
                ]
  ]
 tick
end

to compute-social-distance
if (Type-Network-Effects = "Specific-Network-Effects") or (Type-Network-Effects = "Specific-Random-Network")[ ;; if the user selects specific network or random network effects:
 ask turtles[
  set social-distances-to-all-alters [] ;; agents generate the list social-distances-to-all-alters, initially it is an empty list
             ]

  let i 0                        ;; declare the variable i as a local variable
  let j 0                        ;; declare the variable j as a local variable
  let node1 0                    ;; declare the variable node1 as a local variable
  let node2 0                    ;; declare the variable node2 as a local variable
  let node-count count turtles   ;; declare the variable node-count as a local variable, make it equal to the overall number of agents

  while [i < node-count]         ;; while i is less than node-count.
  [
    set j 0                      ;; set the local variable j to 0
    while [j < node-count]       ;; while j is less than node-count.
    [
      set node1 turtle i         ;; the variable j represents ego's ID number. Ego's ID number starts at 0
      set node2 turtle j         ;; the variable j represents alter's ID number. Alter's ID number starts at 0
      if i != j                  ;; if alter is different from ego
      [
          ask node1 [            ;; ask ego
            set social-distance-to-alter sqrt (((weight_income * ([income] of node1 - [income] of node2))^ 2) + ((weight_educ *([educ] of node1 - [educ] of node2))^ 2) + ((weight_race * ([race] of node1 - [race] of node2))^ 2)) ;; calculate social distance to current alter (see equation A14 in the appendix)
             if ([target-number-of-relations] of node2 != 0)[                                                         ;; if alter is not an isolate:
              set social-distances-to-all-alters fput (social-distance-to-alter) social-distances-to-all-alters       ;; put social distance to current alter in the list social-distances-to-all-alters
              set social-distances-to-all-alters sort social-distances-to-all-alters                                  ;; sort the list social-distances-to-all-alters in ascending order, from more similar to more dissimilar alters
                                                            ]
                    ]
      ]
      set j j + 1                ;; go to the next alter
    ]
    set i i + 1                  ;; go to the next ego
  ]
                                                                                                              ]
end


to find-alters-id-number

if (Type-Network-Effects = "Specific-Random-Network")[  ;; if the user selects specific random network effects
 ask-concurrent turtles [                               ;; ask agents to:
  set alters-id-number []                               ;; generate the list alters-id-number, make it an empty list
                        ]

  let i 0                        ;; declare the variable i as a local variable
  let j 0                        ;; declare the variable j as a local variable
  let node1 0                    ;; declare the variable node1 as a local variable
  let node2 0                    ;; declare the variable node2 as a local variable
  let node-count count turtles   ;; declare the variable node-count as a local variable, make it equal to the overall number of agents

  while [i < node-count]         ;; while j is less than node-count.
  [
    set j 0                      ;; set the local variable j to 0
    while [j < node-count]       ;; while j is less than node-count.
    [
      set node1 turtle i         ;; the variable i represents ego's ID number. Ego's ID number starts at 0
      set node2 turtle j         ;; the variable j represents alter's ID number. Alter's ID number starts at 0

      if i != j                  ;; if alter is different from ego
      [
          ask node1 [            ;; ask ego
            if ([target-number-of-relations] of node2 != 0)[             ;; if alter is not an isolate:
            set alters-id-number lput ([who] of node2) alters-id-number  ;; put the current alter's ID number in ego's list "alters-id-number"
                                                           ]
                    ]
      ]
      set j j + 1                ;; go to the next alter
    ]
    set i i + 1                  ;; go to the next ego
  ]


                                                        ]

if (Type-Network-Effects = "Specific-Network-Effects")[   ;; if the user selects specific network effects
 ask-concurrent turtles[                                  ;; ask agents to:
  set alters-id-number []                                 ;; generate the list alters-id-number, make it an empty list
  set dissimilar-turtles []                               ;; generate the list dissimilar-turtles, make it an empty list
                       ]

 ask-concurrent turtles[ ;; ask agents to:
    ;; report a subset of the list "social-distances-to-all-alters." The size of the new subsetted list is equal to ego's in-group size.
    ;; Remember that the list "social-distances-to-all-alters" is already sorted in ascending order, meaning alters are already sorted
    ;; from more to less socially similar to ego. Therefore, this new subsetted list containts all alters in ego's in-group. Given that
    ;; the command "sublist" does not report (excludes) the last position (see NetLogo dictionary), then 1 must be added to the last position.
    ;; If the network size is too small to generate a given agent's in-group, a runtime error occurs and the message "network size is
    ;; too small for an in-group of this size, use full data set" is shown in the command center. This runtime error occurs when the full
    ;; data set is not used and the variable n is set by the user to a number greater than 5.
   carefully [set social-distances-to-all-alters sublist social-distances-to-all-alters 0 (in-group-size + 1)] [print "network size is too small for an in-group of this size, use the full data set or set the slider *n* to 5"]
    ifelse (in-group-size = 0)                                               ;; if ego is an isolate:
     [set max-in-group-distance 0]                                           ;; set max-in-group-distace to 0
     [set max-in-group-distance max social-distances-to-all-alters]          ;; otherwise, set max-in-group-distance to the maximum value (i.e. max social distance) in ego's in-group
                       ]
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;; ego generates a list with the IDs of all socially similar alters ;
 ;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;;;

  let i 0                        ;; declare the variable i as a local variable
  let j 0                        ;; declare the variable j as a local variable
  let node1 0                    ;; declare the variable node1 as a local variable
  let node2 0                    ;; declare the variable node2 as a local variable
  let node-count count turtles   ;; declare the variable node-count as a local variable, make it equal to the overall number of agents

  while [i < node-count]         ;; while i is less than node-count.
  [
    set j 0                      ;; set the local variable j to 0
    while [j < node-count]       ;; while j is less than node-count
    [
      set node1 turtle i         ;; the variable i represents ego's ID number. Ego's ID number starts at 0
      set node2 turtle j         ;; the variable j represents alter's ID number. Alter's ID number starts at 0

      if i != j                  ;; if alter is different from ego
      [
          ask node1 [            ;; ask ego
            set social-distance-to-similar-alter sqrt (((weight_income * ([income] of node1 - [income] of node2))^ 2) + ((weight_educ *([educ] of node1 - [educ] of node2))^ 2) + ((weight_race * ([race] of node1 - [race] of node2))^ 2))  ;; calculate social distance to current alter (see equation A14 in the appendix)
             if ((social-distance-to-similar-alter <= max-in-group-distance) and ([target-number-of-relations] of node2 != 0)) [        ;; if social distance to alter is less than or equal to the max distance in the in-group and alter is not an isolate
              set alters-id-number lput ([who] of node2) alters-id-number                                                               ;; put alter's ID numberin the list alters-id-number
                                                                                                                               ]
                    ]
      ]
      set j j + 1                ;; go to the next alter
    ]
    set i i + 1                  ;; go to the next ego
  ]


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;; ego generates a list with the IDs of all socially dissimilar alters ;
 ;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::;;;;;;

  let a 0                        ;; declare the variable a as a local variable
  let b 0                        ;; declare the variable b as a local variable
  let ego one-of turtles         ;; declare the variable ego as a local variabl
  let alter one-of turtles       ;; declare the variable alter as a local variable

  while [a < node-count]         ;; while a is less than node-count.
  [
    set b 0                      ;; set the local variable b to 0
    while [b < node-count]       ;; while b is less than node-count
    [
      set ego turtle a           ;; the variable ego represents ego's ID number. Ego's ID number starts at 0
      set alter turtle b         ;; the variable alter represents alter's ID number. Alter's ID number starts at 0

      if a != b                  ;; if alter is different from ego
      [
          ask ego [
            set social-distance-to-dissimilar-alter sqrt (((weight_income * ([income] of ego - [income] of alter))^ 2) + ((weight_educ *([educ] of ego - [educ] of alter))^ 2) + ((weight_race * ([race] of ego - [race] of alter))^ 2)) ;; calculate social distance to current alter (see equation A14 in the appendix)
            if (((social-distance-to-dissimilar-alter > max-in-group-distance) and ([target-number-of-relations] of alter != 0)) and (target-number-of-relations > 0))[    ;; if social distance to alter is greater than the max distance in the in-group and alter is not an isolate
            set dissimilar-turtles lput ([who] of alter) dissimilar-turtles                                                                                                ;; put alter's ID numberin the list alters-id-number
                                                                                                                                                                      ]
                  ]
      ]
      set b b + 1               ;; go to next alter
    ]
    set a a + 1                 ;; go to next ego
  ]
                                                 ]
end

to generate-ties

if Type-Network-Effects = "Specific-Random-Network"[                                                                     ;; if the user selects specific random network effects:
  ask turtles[                                                                                                           ;; ask agents:
    let z 0                                                                                                              ;; declare the variable z as a local variable
    set all-alters []                                                                                                    ;; generate the list all-alters, make it an empty list
    set all-alters shuffle alters-id-number                                                                              ;; set the list all-alters as a shuffled (i.e. random) version of the list "alters-id-number." In the context of random network effects, "alters-id-number" constains all other turtles (i.e. there is no in-group and out-group distinction)
    if ((target-number-of-relations > 0) and (not empty? all-alters) and (count my-links < target-number-of-relations))[ ;; if ego is not an isolate and ego's current number of neighbors is less than the number of friends ego reported to have according to GSS data
     loop[                                                                                                               ;; begin a loop:
      set alters-id item z all-alters                                                                                    ;; select the Zth alter from the list "all-alters"
      if ([count my-links] of turtle alters-id < [target-number-of-relations] of turtle alters-id)[                      ;; if the Zth alter can still have one more neighbor
       create-link-with turtle alters-id                                                                                 ;; create a tie with the Zth alter
                                                                                                  ]
       set z z + 1                                                                                  ;; go to the next alter in the list "all-alters"
       if ((z = length all-alters) or (count my-links >= target-number-of-relations))               ;; if ego exhausted the list "all-alters" or ego already has the number of neighbors it reported to have according to GSS data:
        [stop]                                                                                      ;; stop the loop
         ]
                                                                                                                       ]
             ]
                                                     ]


  if (Type-Network-Effects = "Specific-Network-Effects")[                                           ;; if the user selects specific network effects:
   ask turtles [                                                                                    ;; ask agents:
     set proportion-similar round (homophily * target-number-of-relations)                          ;; set proportion similar in ego-network to the homophily level selected by the user * the number of ties reported by the agent according to GSS data
               ]

   ask turtles[                                                                                     ;; ask agents:
    let z 0                                                                                         ;; declare the variable z as a local variable
    set my-friends []                                                                               ;; generate the list "my-friends", make it an empty list
    set my-friends shuffle alters-id-number                                                         ;; set the list "my-friends" as a shuffled (i.e. random) version of the list "alters-id-number." In the context of specific network effects, "alters-id-number" only contains alters in the in-group
    if (target-number-of-relations > 0)[                                                            ;; if ego is not an isolate
     loop[                                                                                          ;; begin this loop:
      set alters-id item z my-friends                                                               ;; select the Zth alter from the list "my-friends"
      if ([count my-links] of turtle alters-id < [proportion-similar] of turtle alters-id)[         ;; if the Zth alter can still have one more neighbor in its in-group
       create-link-with turtle alters-id                                                            ;; create a tie with the Zth alter
                                                                                          ]
        set z z + 1                                                                                 ;; go to the next alter in the list "my-friends"
        if ((z = length my-friends) or (count my-links >= proportion-similar))                      ;; if ego exhausted the list "my-friends" or ego already has the number of neighbors/ties it reported to have according to GSS data:
         [stop]                                                                                     ;; stop the loop
          ]
                                       ]

              ]

   ask turtles[                                                                                                           ;; ask agents:
    let z 0                                                                                                               ;; declare the variable z as a local variable
    set my-friends2 []                                                                                                    ;; generate the list "my-friends2", make it an empty list
    set my-friends2 shuffle dissimilar-turtles                                                                            ;; set the list "my-friends2" as a shuffled (i.e. random) version of the list "dissimilar-turtles." Dissimilar-turtles only contains alters in the out-group
    if ((target-number-of-relations > 0) and (not empty? my-friends2) and (count my-links < target-number-of-relations))[ ;; if ego is not an isolate and ego still has room for more neighbors
     loop[                                                                                                                ;; begin this loop:
      set alters-id item z my-friends2                                                                                    ;; select the Zth alter from the list "my-friends2"
      if ([count my-links] of turtle alters-id < [target-number-of-relations] of turtle alters-id)[                       ;; if the Zth alter can still have more neighbors
       create-link-with turtle alters-id                                                                                  ;; create a tie with the Zth alter
                                                                                                  ]
       set z z + 1                                                                                                        ;; go to the next alter in the list "my-friends2"
       if ((z = length my-friends2) or (count my-links >= target-number-of-relations))                                    ;; if ego exhausted the list "my-friends2" or ego already has the number of neighbors/ties it reported to have according to GSS data:
        [stop]                                                                                                            ;; stop the loop
         ]
                                                                                                                        ]

             ]

                                                         ]


  ask links [
    let rnd random-float 1
    if 0.4 < rnd [ hide-link ]
            ]

  repeat 5
  [
   layout-spring turtles links 1 (world-width * 2 / (sqrt count turtles)) 4
  ]
end


;;;;; this procedure was developed to import gss data
to generate-realistic-agents
 carefully [
  ifelse fullDataSet?                          ;; if the switch "fullDataSet?" is on:
   [file-open "GSS_full_dataset_N_2241.txt"  ;; use the full data set (N = 2241)
    no-display                                 ;; do not show the agents or the ties between them
   ]
   [ display                                   ;; do not show the agents or the ties between them
     file-open "GSS_subsample_N_500.txt"]      ;; otherwise, use a random sample with N = 500
      while [not file-at-end?][                ;; read the entire file
        let agent-features read-from-string (word"[" file-read-line "]") ;; read line by line, each line has info regarding a given agents' trait (e.g. educatio
           create-ordered-turtles 1[                                     ;; create one agent
            set race item 0 agent-features                               ;; assing "race" to the recetly created agent
            set educ item 1 agent-features                               ;; assign "educ" (education) to the recetly created agent
            set target-number-of-relations item 2 agent-features         ;; assign "target-number-of-relations" to to the recetly created agent
            set income item 3 agent-features                             ;; assign "income" to the recetly created agent
            set incomeNorm item 4 agent-features                         ;; assign "incomeNorm" (normalized income) to the recetly created agent
            set educNorm item 5 agent-features                           ;; assign "educNorm" (normalized education) to the recetly created agent
                                   ]
                              ]
   file-close
         ]                                                               ;; close the external file
 [
   print "NEED TO IMPORT DATA TO START A SIMULATION. CHECK IF DATA ARE SAVED IN WORKING DIRECTORY"
 ]
end


;; Simulating Internet Adoption
;; Code for the model in DiMaggio and Garip 2011
;; Code Written by Diego F. Leal, University of Massachusetts (www.diegoleal.info)
;; Last updated: August 2016
@#$#@#$#@
GRAPHICS-WINDOW
250
99
627
477
-1
-1
11.2
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
354
508
433
541
Setup
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
905
448
1034
501
number of agents
count turtles
17
1
13

MONITOR
649
446
788
499
proportion of adopters
overall-adopters-now
2
1
13

MONITOR
799
446
887
499
internet price
internet-price
2
1
13

PLOT
649
105
1027
439
Internet adoption over time
Time
Proportion of adopters
0.0
100.0
0.0
1.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -13345367 true "" "plot overall-adopters-now"

CHOOSER
17
474
186
519
Type-Network-Effects
Type-Network-Effects
"No-Network-Effects" "General-Network-Effects" "Specific-Network-Effects" "Specific-Random-Network"
2

SLIDER
17
434
188
467
homophily
homophily
0.25
1
0.25
0.25
1
NIL
HORIZONTAL

TEXTBOX
19
374
241
422
n determines the size of the in-group, that is, the set of agents socially similar to ego.
13
0.0
1

SLIDER
16
338
154
371
n
n
5
20
5.0
1
1
NIL
HORIZONTAL

BUTTON
451
509
536
542
Go/Stop
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

SWITCH
16
97
151
130
fullDataSet?
fullDataSet?
1
1
-1000

TEXTBOX
18
137
246
202
if fullDataSet? is on, the original GSS data set is used (N = 2241). Otherwise, a random sample (N = 500) taken from the original GSS data set is used.
13
0.0
1

SWITCH
19
212
154
245
timeLimit?
timeLimit?
0
1
-1000

TEXTBOX
17
248
241
329
if timeLimit? is on, the model runs for 100 ticks (time periods) as reported in the original article (DiMaggio and Garip: 2011: 1902). Otherwise, the model runs until the user stops it.
13
0.0
1

TEXTBOX
20
10
689
110
How Network Externalities Can Exacerbate Intergroup Inequality? \nDiMaggio and Garip, AJS 2011.\nReplication by Diego F. Leal (www.diegoleal.info)
20
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is a replication of the agent-based model in DiMaggio and Garip (2011), see references below. More precisely, this is a difussion model that investigates the emergence of intergroup inequality in the adoption of internet. The model examines the interplay of two causal mechanisms: positive network externalities and homophily.

## HOW IT WORKS

There are three main variations to this model.

In the first variation, specific network effects are modeled using 2002 GSS data. These
data allow the user to generate networks with different levels of homophily or a
random network.

In the second variation, general network effects are modeled using a complete graph.

In the third variation, no network effects are modeled, thus the difussion of internet
depends only on agents' income.

The construction of this model, and the logic behind the aforementioned variations, are described in DiMaggio and Garip (2011), see references below.

## HOW TO USE IT

If the switch "fullDataSet?" is on, the original 2002 GSS data set is used (N = 2241). Otherwise, a random subsample (N = 500) taken from the original 2002 GSS data set is used.

If the switch "timeLimit?" is on, the model runs for 100 ticks (time periods) as reported in DiMaggio and Garip (2011). Otherwise, the model runs until the user actively stops it.

The slider "n" determines the size of the in-group, that is, the length of the set of agents socially similar to ego.

The slider "homophily" allows the user to control the degree to which social similarity (i.e. homophily) is build into the social network.

The chooser "type-network-effects" allows the user to select the type of network effects to be modeled: specific, general, random or inexistent (i.e. no network effects). See DiMaggio and Garip (2011) for more details.

Notes:

- In order to run the model, the user must import the GSS data used in DiMaggio and Garip (2011). A copy of the clean data set can be provided by the author of this replication upon request. If the data are not imported, the error message "IMPORT DATA TO START A SIMULATION" will be printed in the command window. This error prevents the simulation to start.

- When the small data set (N= 500) is used, ego-networks of agents with a large in-group size are not possible to generate if the slider "n" is set to a number >= 6. In that context, a runtime error will occur and the message "network size is too small for an in-group of this size, use full data set or set the slider *n* to 5" will be printed in the command window. This error does not prevent the simulation to run.

- In the original article, DiMaggio and Garip (2011) set *n* to 20.

- A simulation that uses the full data set takes substantially more time to finish the setup procedure compared to a simulaton that uses the small data set. Both data sets produce similar results.

## CREDITS

This replication was developed by Diego Leal, University of Massachusetts - Amherst. To inquire about the functioning of the model, please contact Diego Leal (www.diegoleal.info).

This code was developed for the class "Modeling Emergence: Social Simulation," taught by Professor James Kitts in the Fall semester of 2014 at UMass - Amherst.

The author gratefully acknowledges the support of James Kitts and Filiz Garip in the development of this replication.

## REFERENCES

DiMaggio, Paul and Filiz Garip (2011). "How Network can Exacerbate Intergroup Inequality." American Journal of Sociology, 116 (6): 1887-1933.

DiMagio, Paul and Filiz Garip (2011). "Appendix from DiMAggio and Garip." American Journal of Sociology, 116 (6), p. 000.
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
  <experiment name="No-Network-Effects_full" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;No-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="General-Network-Effects_full" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;General-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Specific-NE-H_25_full" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="homophily">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;Specific-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Specific-NE-H_50" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="homophily">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;Specific-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Specific-NE-H_75" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="homophily">
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;Specific-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Specific-NE-H_100" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="homophily">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;Specific-Network-Effects&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="NE-Random" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>overall-adopters-now</metric>
    <enumeratedValueSet variable="Type-Network-Effects">
      <value value="&quot;Specific-Random-Network&quot;"/>
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
