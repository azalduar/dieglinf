globals
[
 all-turtles-profit-list                    ;; list of all agents' profit in a given generation
 mean-profit-all-turtles                    ;; mean profit of all agents in a given generation
 sd-profit-all-turtles                      ;; standard deviation of all agents in a given generation
 lower-bound-profit-all-turtles             ;; mean profit of all agents in a given generation - standard deviation of all agents in a given generation
 upper-bound-profit-all-turtles             ;; mean profit of all agents in a given generation + standard deviation of all agents in a given generation
 offsprings-list                            ;; list of all agents that will populate the world in the new generation
 more-turtles                               ;; number of extra offspring needed to make group size constant
 less-turtles                               ;; number of offspring needed to make group size constant
 trials                                     ;; total number of trials
 mean-giving                                ;; mean value of agents' giving genes in the current generation
 mean-tolerance                             ;; mean value of agents' tolerance genes in the current generation
 generation-number                          ;; total number of generations
]

turtles-own
[
 my-giving-gene                              ;; ego's giving gene. The giving gene determines how much an actor gives to its my-recipient [0,10]. 0 means ego gives nothing, 10 means ego gives everything.
 my-tolerance-gene                           ;; ego's tolerance gene.
 fairness-criterion                          ;; ego's giving gene X ego's tolerance gene.
 my-trials-kept-points-list                  ;; "the amount of the resources that each actor saves in each trial is added to his total profit in the generation." (p. 1118)
 my-trials-received-points-list              ;; the amount of resources ego received in a generation disciminated by trial
 my-sum-profit-this-generation               ;; sum of profit ego accumulated in the present generation
 my-sum-profit-all-generations               ;; sum of profit ego accumulated in all generations
 giving-points                               ;; number of points an agent could potentially give in a given trial
 my-giver                                    ;; ego's giver
 my-recipient                                ;; ego's recipient
 my-good-neighbors-list                      ;; ego's list of alters' IDs whose giving gene is >= than its (ego's) giving gene
 my-bad-neighbors-list                       ;; ego's list of alters IDs whose giving gene is < than its (ego's) giving gene
 my-bad-neighbors-agentset                   ;; ego's list of alters whose giving gene is < than its (ego's) giving gene
 my-second-best-neighbors-list               ;; ego's list of the top alters whose giving gene is < than its (ego's) giving gene
 giving?                                     ;; has ego exchanged points in this trial? yes = 1, no = 1
 duplicated?                                 ;; has ego left offsrping in this trial? yes = 1, no = 1
 duplicate?                                  ;; is ego an offsrping? yes = 1, no = 1
]

to setup

 clear-all
 crt group-size                                                ;; create the number of agents determined by the user

 set trials 0                                                  ;; start at trial 0
 set generation-number 0                                       ;; start at generation 0
 set all-turtles-profit-list []                                ;; initialize the all-turtles-profit-list list

 ask turtles                                                   ;; initialize agent-level variables
 [
  set color red
  set size 1.5
  set my-trials-received-points-list []
  set my-sum-profit-this-generation []
  set my-sum-profit-all-generations []
  set duplicate? 0
  set duplicated? 0
  set my-giving-gene random max-giving                         ;; make my-giving-gene a random integer between 0 and the user-determined "max-giving"
  set my-tolerance-gene ((random-float max-tolerance) + 0.1)   ;; make my-giving-gene a random floating-point number between 0.1 and the user-determined "max-tolerance"
]

layout-circle turtles 15                                       ;; agents are positioned in a circle
reset-ticks                                                    ;; reset time
end

to go

 if ticks >= max-#-generations                                 ;; stop simulation at "max-#-generations"
 [
  stop
 ]

 set generation-number (generation-number + 1)                 ;; increase the count of the number of generations by 1

 ask turtles
 [
  setup-turtles                                                ;; agents run the setup-turtles procedure
 ]

 repeat trials-per-generation                                  ;; repeat this steps "trials-per-generation" number of times per generation
 [

  ask links                                                    ;; delete any links
  [
   die
  ]
  set trials trials + 1                                        ;; increase the count of the number of trials by 1

  ask turtles
  [
   select-my-possible-partners                                 ;; agents run the select-my-possible-partners procedure
   create-link-good-neighbors                                  ;; agents run the create-link-good-neighbors procedure
   create-link-bad-neighbors                                   ;; agents run th create-link-bad-neighbors procedure
  ]

  ask turtles
  [
   if any? in-link-neighbors                                   ;; if ego exchanged resources:
   [
    set my-giver item 0 [who] of in-link-neighbors              ;; set ego's "my-giver" = to the ID of its (ego's) sending alter
   ]
  ]

  ask turtles
  [
   exchange                                                    ;; agents run the exchange procedure
  ]
 ]

 fitness                                                       ;; run the fitness procedure
 dv                                                            ;; compute the devependent variables
 new-generation                                                ;; run the new-generation procedure
tick                                                           ;; advance time
end

to setup-turtles

 set label my-giving-gene                                      ;; make agents' giving-gene visible on the interface
 set fairness-criterion (my-giving-gene * my-tolerance-gene)   ;; calculate the fairness criterion
 set my-trials-kept-points-list []                             ;; initialize the my-trials-kept-points-list list
 set my-trials-received-points-list []                         ;; initialize the my-trials-received-points-list list
 set my-sum-profit-this-generation []                          ;; initialize the my-sum-profit-this-generation list
end


to select-my-possible-partners

 set my-good-neighbors-list []                                 ;; initialize the my-good-neighbors-list list
 set giving? 0                                                 ;; set giving = 0
 set my-recipient [who] of self                                ;; Initially, set my-recipient = ID of ego. This will change if ego exchanges resources
 set my-giver [who] of self                                    ;; Initially, set my-giver = ID of ego. This will change if ego exchanges resources

 let j 0
 while [j < group-size]                                                                    ;; loop through all turtles
 [
  if j != [who] of self and [my-giving-gene] of turtle j >= [my-giving-gene] of self
  [
  set my-good-neighbors-list lput ([who] of turtle j)  my-good-neighbors-list               ;; make a list with the IDs of all the alters whose giving gene is >= than ego's giving gene
  ]
  set j j + 1
 ]

 set my-good-neighbors-list shuffle my-good-neighbors-list                                                        ;; randomize my-good-neighbors-list
 set my-bad-neighbors-agentset []                                                                                 ;; initialize the my-bad-neighbors-agentset list
 set my-bad-neighbors-list []                                                                                     ;; initialize the my-bad-neighbors-agentset list
 set my-bad-neighbors-agentset sort-on [(- my-giving-gene)] other turtles                                         ;; initially, make the my-bad-neighbors-agentset a sorted list of all alters based on their giving-genes, from higher values to lower values
 set my-bad-neighbors-agentset sublist my-bad-neighbors-agentset (length my-good-neighbors-list) (group-size - 1) ;; exclude from my-bad-neighbors-agentset all agents already included in my-good-neighbors-list

 let l 0
 while [l < length my-bad-neighbors-agentset]                                                          ;; loop through all agents in my-bad-neighbors-agentset
 [
  set my-bad-neighbors-list lput ([who] of (item l my-bad-neighbors-agentset)) my-bad-neighbors-list   ;; make a list (my-bad-neighbors-list) with the IDs of all agents in my-bad-neighbors-agentset
  set l l + 1
 ]
end

to create-link-good-neighbors

 let k 0
 if length my-good-neighbors-list > 0 and my-recipient = [who] of self                                 ;; if ego has good neighbors (i.e. alters whose giving genes are >= than that of ego) and it (ego) has not given resources to any of them
 [
  while [k < length my-good-neighbors-list]                                                             ;; ego loops through the list of good neighbors in order to:
  [
   if not any? [my-in-links]  of turtle (item k my-good-neighbors-list) and [giving?] of self = 0         ;; select an alter to give resources to it
   [
     create-link-to turtle (item k my-good-neighbors-list)                                                 ;; create a link to it
     ask my-out-links
     [
      set color green                                                                                       ;; make the link green
      set thickness 0.25                                                                                    ;; change the link's thickness
     ]
     set my-recipient [who] of turtle (item k my-good-neighbors-list)                                      ;; set "my-recipient" = the partner's ID
     set giving? 1                                                                                         ;; set giving? = 1
     set k length my-good-neighbors-list
   ]
   set k k + 1
  ]
 ]
end

to create-link-bad-neighbors

 set my-second-best-neighbors-list []                                                                                  ;; initialize the my-second-best-neighbors-list list

 if length my-bad-neighbors-agentset > 0                                                                               ;; if ego has bad neighbors (i.e. alters whose giving genes are < than that of ego)
 [
  set my-second-best-neighbors-list lput ([who] of item 0 my-bad-neighbors-agentset) my-second-best-neighbors-list     ;; put the bad neighbor's ID with the highest giving gene in the list my-second-best-neighbors-list

  let r 1
  while [r < length my-bad-neighbors-agentset]                                                                         ;; loop through the my-bad-neighbors-agentset list (remember, the my-bad-neighbors-agentset list is sorted by the value of alters' giving genes)
  [
   if [my-giving-gene] of (item 0 my-bad-neighbors-agentset) = [my-giving-gene] of (item r my-bad-neighbors-agentset)  ;; put the next bad neighbor's ID in the list my-second-best-neighbors-list if and only if it has the same value of the giving gene as the one of the bad neighbors already in the list
   [
    set my-second-best-neighbors-list lput ([who] of (item r my-bad-neighbors-agentset)) my-second-best-neighbors-list
   ]
  set r r + 1
  ]
 ]

 set my-second-best-neighbors-list shuffle my-second-best-neighbors-list                                               ;; randomize the my-second-best-neighbors-list list

 let u 0
 if length my-second-best-neighbors-list > 0 and my-recipient = [who] of self                                          ;; if ego has bad neighbors and it did not exchange resources with a good neighbor, then ego:
 [
  while [u < length my-second-best-neighbors-list]                                                                     ;; loops through my-second-best-neighbors-list list
  [
    if not any? [my-in-links]  of turtle (item u my-second-best-neighbors-list) and [giving?] of self = 0
   [
     create-link-to turtle (item u my-second-best-neighbors-list)                                                      ;; creates a link with one of the alters in my-second-best-neighbors-list
     ask my-out-links
     [
      set color green                                                                                                 ;; make the link red
      set thickness 0.25                                                                                               ;; change the link's thickness
     ]
     set my-recipient [who] of turtle (item u my-second-best-neighbors-list)                                           ;; set "my-recipient" = the partner's ID
     set giving? 1                                                                                                     ;; set giving? = 1
     set u length my-second-best-neighbors-list
   ]
   set u u + 1
  ]
 ]
end

to exchange

 set giving-points new-points-per-trial                                                                                             ;; set giving-points = to the user-defined new-points-per-trial

 ifelse my-giving-gene = 0                                                                                                          ;; if ego is NOT willing to give
 [
  set my-trials-kept-points-list fput (giving-points) my-trials-kept-points-list                                                    ;; then, ego authomatically acumulates the points it gets at the beginning of each trial
 ]
 [
  set my-trials-kept-points-list fput (giving-points - my-giving-gene) my-trials-kept-points-list                                   ;; otherwise, ego looses the points it gives to its recipient (i.e. my-recipient)
 ]

 ifelse my-giver != [who] of self                                                                                                   ;; if ego is selected by an alter (i.e. my-giver)
 [
  set my-trials-received-points-list fput ([my-giving-gene] of turtle my-giver * multiplying-factor) my-trials-received-points-list ;; then, it gets twice as much of the points granted by the alter (i.e. my-giver), note that the multiplying factor is fixed to 2 in the article
 ]
 [
  set my-trials-received-points-list fput (0) my-trials-received-points-list                                                        ;; otherwise, ego gets 0
 ]

 if length my-trials-kept-points-list = trials-per-generation                                                                                    ;; at the end of each generation:
 [
  set my-sum-profit-this-generation lput ((sum my-trials-received-points-list) + (sum my-trials-kept-points-list)) my-sum-profit-this-generation ;; ego sum up the points it got in each trial
  set my-sum-profit-all-generations lput (sum my-sum-profit-this-generation) my-sum-profit-all-generations                                       ;; ego keeps the history of the total payoff it got in each generation
 ]
end



to fitness

 ask turtles
 [
  set duplicated? 0                                                                                              ;; ego sets duplicted? to 0
  set duplicate? 0                                                                                               ;; ego sets duplicate? to 0
 ]

 set all-turtles-profit-list []                                                                                  ;; initialize the all-turtles-profit-list list

 let j 0                                                                                                         ;; loop through all agents
 while [j < group-size]
 [
  set all-turtles-profit-list lput ([item 0 my-sum-profit-this-generation] of turtle j) all-turtles-profit-list  ;; put each agent's total profit in a given generation in the list all-turtles-profit-list
  set j j + 1
 ]

 set mean-profit-all-turtles mean all-turtles-profit-list                                                        ;; compute the mean of all-turtles-profit-list
 set sd-profit-all-turtles standard-deviation all-turtles-profit-list                                            ;; compute the standard deviation of all-turtles-profit-list
 set lower-bound-profit-all-turtles (mean-profit-all-turtles - sd-profit-all-turtles)                            ;; compute the lower bound of (mean - sd) of the turtles profit in a given generation
 set upper-bound-profit-all-turtles (mean-profit-all-turtles + sd-profit-all-turtles)                            ;; compute the upper bound of (mean + sd) of the turtles profit in a given generation

 let i 0
 while [i < group-size]                                                                                          ;; loop through all turtles
 [
  ask turtle i
  [
   if [item 0 my-sum-profit-this-generation] of self - upper-bound-profit-all-turtles >= 0                       ;; if ego's profit is >= the upper bound
   [
    hatch 2                                                                                                      ;; create two offspring
    [
     set duplicate? 1                                                                                            ;; make (ego's) offspring set duplicate? = 1
    ]
    set duplicated? 1                                                                                            ;; set duplicated? = 1
   ]
  ]
  set i i  + 1
 ]


 let k 0
 while [k < group-size]                                                                                          ;; loop through all turtles
 [
  ask turtle k
  [
   if [item 0 my-sum-profit-this-generation] of self - lower-bound-profit-all-turtles >= 0 and duplicated? = 0   ;; if ego's profit is >= the upper bound and it has not left any offsrpings yet
   [
    hatch 1                                                                                                       ;; create 1 offspring
    [
     set duplicate? 1                                                                                             ;; make (ego's) offspring set duplicate?
    ]
     set duplicated? 1                                                                                            ;; set duplicated? = 1
   ]
  ]
  set k k  + 1
 ]

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;   NOTE: As per first principles of evolutionary game-theory, an agent whose performance is successful
 ;;;   leaves offspring while an actor whose performance is not successful leaves no offspring.
 ;;;   This assumption is specified in the article as follows (see footnote 15):
 ;;;
 ;;;   "The actors whose cumulative profits were less than the criterion (i.e., average profit
 ;;;   in the group-standard deviation) leave no offspring. The actors whose cumulative
 ;;;   profits were more than the criterion leave two offspring. The actors whose cumulative
 ;;;   profits were close to the average leave one offspring. For simplicity, I adjusted the
 ;;;   group size to be constant."
 ;;;
 ;;;   As can be seen, the actual way in which the group size is "adjusted" remains quite vague. In this context
 ;;;   the following lines of code represent one of many possible ways in which the group size can
 ;;;   adjusted at the end of each generation.
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 set offsprings-list []                                                         ;; initialize offsprings-list
 set offsprings-list n-values (count turtles) [ ?1 -> ?1 ]                               ;; create as many items in offsprings-list as there are turtles in the current moment (this count includes offspring)
 set offsprings-list sort offsprings-list                                       ;; sort offsprings-list from lower to higher values
 set offsprings-list sublist offsprings-list group-size length offsprings-list  ;; subset offsprings-list to only include duplicates (offsprings)

 if group-size > length offsprings-list                                         ;; loop through the offsprings-list list
 [
  set more-turtles group-size - length offsprings-list                          ;; if there are less offspring than "parents" (i.e. egos with duplicated? = 1)
  let a more-turtles
  while [a > 0]
  [
   ask one-of turtles
   [
    if [duplicated?] of self = 1                                                ;; ask a random parent to duplicate one more time
    [
     hatch 1
     set a a - 1
    ]
   ]
  ]
 ]

 if group-size < length offsprings-list                                         ;; loop through the offsprings-list list
 [
  set less-turtles length offsprings-list - group-size                          ;; if there are more offspring than "parents" (i.e. egos with duplicated? = 1)
  let a less-turtles
  while [a > 0]
  [
   ask one-of turtles
   [
    if [duplicate?] of self = 1                                                 ;; ask a random offsrping to die
    [
     set a a - 1
     die
    ]
   ]
  ]
 ]
end

to dv

 set mean-giving mean [my-giving-gene] of turtles                               ;; compute the average value of the giving genes in the current generation
 set mean-tolerance mean [my-tolerance-gene] of turtles                         ;; compute the average value of the tolerance genes in the current generation
end




to new-generation

 let h 0
 while [h < group-size]                                                         ;; loop through all agents
 [
  let alter (one-of turtles with [who >= (group-size)])                         ;; set alter = the ID of one of the offspring
  ask turtle h
  [
   set my-giving-gene [my-giving-gene] of alter                                 ;; set egos's giving gene = alter's giving gene
   set my-tolerance-gene [my-tolerance-gene] of alter                           ;; set egos's tolerance = alter's tolerance gene

   let mutation (random 100)                                                    ;; set mutation = a random integer between 0 and 99
   if mutation < 5                                                              ;; if mutation is less than 5 (i.e. 5 out of 100 times)
   [
    set my-giving-gene random 11                                                ;; make ego's giving gene a random number between 0 and 10
    set my-tolerance-gene ((random-float max-tolerance) + 0.1)                  ;; make ego's tolerance gene a random number between 0.1 and 2
   ]
  ]

  ask alter                                                                      ;; ask alter to die
  [
   die
  ]

  set h h + 1
 ]

 layout-circle turtles 15                                                       ;; ask agents to make a circle
end



;; The Emergence of Generalized Exchange
;; Code for the model in Takahashi 2000
;; Code Written by Diego F. Leal, University of Massachusetts (www.diegoleal.info)
;; Last updated: September 2016
@#$#@#$#@
GRAPHICS-WINDOW
13
127
331
446
-1
-1
9.4
1
10
1
1
1
0
0
0
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

SLIDER
187
628
339
661
max-giving
max-giving
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
10
589
182
622
max-tolerance
max-tolerance
0.1
2
2.0
0.1
1
NIL
HORIZONTAL

SLIDER
11
555
183
588
group-size
group-size
0
20
20.0
1
1
NIL
HORIZONTAL

BUTTON
88
476
151
509
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
189
556
342
589
new-points-per-trial
new-points-per-trial
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
188
592
340
625
trials-per-generation
trials-per-generation
1
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
11
627
183
660
multiplying-factor
multiplying-factor
0
2
2.0
0.2
1
NIL
HORIZONTAL

BUTTON
174
478
237
511
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

MONITOR
458
466
531
511
generation
generation-number
17
1
11

MONITOR
544
467
640
512
total # of trials
trials
17
1
11

MONITOR
362
512
524
557
mean profit current generation
mean-profit-all-turtles
17
1
11

MONITOR
545
514
770
559
standard deviation profit current generation
sd-profit-all-turtles
2
1
11

PLOT
336
128
783
463
Generalized Exchange Over Time
Value
Generations
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"mean-giving" 1.0 0 -16777216 true "" "plot mean-giving"
"mean-tolerance" 1.0 0 -2674135 true "" "plot mean-tolerance"

TEXTBOX
23
10
439
110
The Emergence of Generalized Exchange\nTakahashi, AJS 2000.\nReplication by Diego F. Leal (www.diegoleal.info)
20
0.0
1

TEXTBOX
361
562
787
719
The number next to each agent is its current giving gene\n\nGreen ties represent an exchange between a sender whose giving gene is <= to that of the recipient\n\nRed ties represent an exchange between a sender whose giving gene is > to that of the recipient
14
0.0
1

SLIDER
95
519
267
552
max-#-generations
max-#-generations
0
1000
1000.0
50
1
NIL
HORIZONTAL

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
  <experiment name="experiment_1" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>mean-giving</metric>
    <metric>mean-tolerance</metric>
    <enumeratedValueSet variable="group-size">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="multiplying-factor">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="trials-per-generation">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-points-per-trial">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-giving">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-tolerance">
      <value value="2"/>
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
