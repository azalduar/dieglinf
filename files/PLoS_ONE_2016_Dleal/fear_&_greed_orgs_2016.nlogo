;;;;;;;;;;;;;; GLOBAL VARIABLES ;;;;;;;;;;;;;;

globals
[
 synchronized                ; Switch for synchronized update
 random-tiebreaker           ; Switch: if C-Paragon = D-Paragon, then choose color (red or blue) at random.
 converged?                  ; Boolean: Has the model converged?
 universal?                  ; Boolean: Has the model gotten to a state of full defection or full cooperation?
 no-change?                  ; Boolean: Is there a change in agents' strategy between current round and previous round? If no-change is true, then model is assumed to have converged
 c-equilibrium               ; Number of cooperators at equilibrium, that is, when then model converges
 t-equilibrium               ; Time steps to equilibrium, that is, time steps to convergece
 c-half-time
 equilibrium-count           ; Number of rounds an agent will keep track of his own behavior.
 egos-list
 alters-list
]

;;;;;;;;;;;;;; TURTLES' VARIABLES ;;;;;;;;;;;;;;

turtles-own
[                          ; Specific variables for agents:
 total-sucker-payoff         ; (Sucker payoff) * (# of defectors in the neighborhood), for cooperators only
 VAL_EXCHANGE_PAYOFF         ; Constant for value of exchange (CC). It is set up at 8, for cooperators only
 total-val-exchange-payoff   ; (value of exchange) * (# of cooperators in the neighborhood), for cooperators only
 total-temptation-payoff     ; (Temptation payoff) * (# of cooperators in the neighborhood), for defectors only
 PUNISHMENT_PAYOFF           ; Constant for punishment payoff (DD). It is set up at 0, for defectors only
 total-punishment-payoff     ; (Punishment payoff) * (# number of cooperators in the neighborhood), for defectors only
 cooperator-payoff           ; Cooperator's total payoff after playing the game with all 8 neighbors
 defector-payoff             ; Defector's total payoff after playing the game with all 8 neighbors
 best-cooperator-neighbor    ; Payoff of cooperator with the best performance in the neighborhood
 best-defector-neighbor      ; Payoff of defector with the best performance in the neihgborhood
 cooperator-D-paragon        ; ith cooperator's D-paragon (i.e. highest-scoring defector in a given cooperator's neighborhood)
 cooperator-C-paragon        ; ith cooperator's C-paragon (i.e. highest-scoring cooperator in a given cooperator's neighborhood, including itself)
 defector-C-paragon          ; ith defector's C-paragon (i.e. highest-scoring cooperator in a given defector's neighborhood)
 defector-D-paragon          ; ith defector's D-paragon (i.e. highest-scoring defector in a given defector's neighborhood, including itself)
 cooperator-fitness          ; ith cooperator's strategy in the context of the performance of his/her neighbors
 defector-fitness            ; ith defector's strategy in the context of the performance of his/her neighbors
 cooperators-in-neighborhood ; Number of cooperators in the (Moore) neighborhood
 defectors-in-neighborhood   ; Number of defectors in the (Moore) neighborhood
 my-behavior-history-list
]

;;;;;;;;;;;;;; SETUP PROCEDURES ;;;;;;;;;;;;;;

to setup
 clear-all
 set-default-shape turtles "circle"
 import-data                       ; execute the 'import-data' procedure
 ask turtles
 [
  set VAL_EXCHANGE_PAYOFF 8        ; Assign 8 to the constant "VAL_EXCHANGE_PAYOFF"
  set PUNISHMENT_PAYOFF 0          ; Assign 0 to the constant "PUNISHMENT_PAYOFF"
  set color red                    ; Initially, assume all agents are defectors (i.e. red agents)
  set my-behavior-history-list []  ; set  my-behavior-history-list as an empty list
 ]
 set universal? false              ; Set univeral? to false (i.e. assume there is no universal cooperation/defection at time 0)
 set converged? false              ; Set converged to false (i.e. assume the model has not converged at time 0)
 set no-change? false              ; Set no-change? to false (i.e. assume agents behavior is dynamic at time 0)
 set equilibrium-count 2           ; Number of rounds agents will keep track of their behavior/strategy
 set c-equilibrium -999            ; There is no proportion of cooperators at equilibrium because it is assunmed that the model has not converged at time 0
 set t-equilibrium -999            ; There is not a specfific time step/tick at which equilibrium happen because it is assumed that the model has not converged at time 0
 reset-ticks
 setup-seed-cooperators            ; Execute 'setup-seed-cooperators' procedure/loop
end


to import-data
 no-display                                              ; Initially, do not show the sociogram

 file-open "IDS_orgs_only.txt"                           ; Import the orgs IDs
 while [not file-at-end?]
 [
  let IDs read-from-string (word"[" file-read-line "]")
  create-ordered-turtles 1                               ; Create one agent per org listed in IDS_orgs_only
  [
   set color red                                         ; Initially, all agentes are red, that is, all agents are defectors
   setxy random-pxcor random-pycor                       ; Place agnets at random in the world
   set size 1.1
  ]
 ]
 file-close

 set egos-list []                                        ; Initialize 'egos-list' an empty list
 set alters-list []                                      ; Initialize 'egos-list' an empty list
 file-open "power_elite_data_orgs_only.txt"              ; Import edgelist
 while [not file-at-end?]
 [
  let edges read-from-string (word"[" file-read-line "]")  ; line by line store the info of the first and second colums in power_elite_data_orgs_only.txt
  let ego-ids item 0 edges                                 ; get the info (i.e. org ID) contained in the first position of the local variables 'edges'
  set egos-list lput (ego-ids) egos-list                   ; put the org ID in the list of egos' IDs,  which I call ego's list (remember this is *not* a directed network so it does not make sense to talk about senders & receivers))
  let alters-ids item 1 edges                              ; get the info (i.e. org ID) contained in the second position of the local variables 'edges'
  set alters-list lput (alters-ids) alters-list            ; put the org ID in a list of alter' IDs (remember this is *not* a directed network, so it does not make sense to talk about senders & receivers)
  ask turtle item 0 edges                                  ; ask ego to:
   [
    create-link-with turtle item 1 edges                   ; create a link with alter
   ]
 ]
 file-close

 if sociogram?                                                               ; if 'sociogram?' is on:
 [
  repeat 10
  [
   layout-spring turtles links 1 (world-width * 2 / (sqrt count turtles)) 4   ;use the layout-spring plotting procedure.
  ]
  display                                                                     ; display the sociogram
 ]
end

to setup-seed-cooperators      ; Randomly seed a given proportion of cooperators (i.e. blue agents) depending on the value of the slider "initial-cooperation"
 ask n-of round (initial-cooperation * count turtles) turtles
 [set color blue]
end

;;;;;;;;;;;;;; GO PROCEDURES ;;;;;;;;;;;;;;

to go
 play                     ; Execute 'play' procedure/loop
 behavior-history         ; Execute 'behavior-history' procedure
 if ticks > 2             ; If more than two ticks/rounds have passed:
 [
  convergence              ; Execute convergence procedure/loop
 ]
 if ticks = 500
 [set c-half-time Cooperators]
 if converged? = true     ; If the model converged:
 [stop]                     ;stop the simulation
 tick                     ; advance the tick counter by one.
end

;;;;;;;;;;; THE ACTUAL MODEL STARTS HERE ;;;;;;;;;;;;;;;;

to play
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; If the switch "synchronized" is on:
 ifelse synchronized?
 [
  ask-concurrent turtles          ; First, depending on their color/type, agents execute C-behavior (cooperator behavior) or D-behavior (defector behavior).
  [ play-PD ]

  ask-concurrent turtles          ; Second, agents execute the fitness procedure/loop.
  [ fitness ]

  ask-concurrent turtles          ; Third, agents set to 0 all their variables.
  [
   set best-cooperator-neighbor 0
   set best-defector-neighbor 0
   set cooperator-payoff 0
   set defector-payoff 0
   set total-val-exchange-payoff 0
   set total-sucker-payoff 0
   set total-punishment-payoff 0
   set total-temptation-payoff 0
   set cooperators-in-neighborhood 0
   set defectors-in-neighborhood 0
   set cooperator-D-paragon 0
   set cooperator-C-paragon 0
   set defector-C-paragon 0
   set defector-D-paragon 0
   set cooperator-fitness 0
   set defector-fitness 0
  ]
 ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; If the switch "synchronized" is off:
;;; Then, in an unsynchronized fashion, agents execute the fitness procedure/loop and -depending on their color- reset to 0 all their variables

 [
  ask-concurrent turtles
  [
   play-PD
   fitness
   ifelse (color = blue)
   [
    set best-defector-neighbor 0
    set defector-payoff 0
    set total-temptation-payoff 0
    set total-punishment-payoff 0
    set cooperators-in-neighborhood 0
    set defectors-in-neighborhood 0
    set defector-C-paragon 0
    set defector-D-paragon 0
    set defector-fitness 0
   ]
   [
    set best-cooperator-neighbor 0
    set cooperator-payoff 0
    set total-sucker-payoff 0
    set total-val-exchange-payoff 0
    set cooperators-in-neighborhood 0
    set defectors-in-neighborhood 0
    set cooperator-D-paragon 0
    set cooperator-C-paragon 0
    set cooperator-fitness 0
   ]
  ]
 ]
end


to play-PD                                                                                 ; Play  the Prisoner's Dilemma:
set cooperators-in-neighborhood count link-neighbors with [color = blue]                      ; Get number of cooperators in the (Moore) neighborhood
set defectors-in-neighborhood count link-neighbors with [color = red]                         ; Get number of defectors in the (Moore) neighborhood

ifelse (color = blue)
[
 set total-val-exchange-payoff (cooperators-in-neighborhood * VAL_EXCHANGE_PAYOFF)            ; CC [cooperator meets cooperator(s)] = value of exchange payoff * number of cooperators in (Moore) neighborhood
 set total-sucker-payoff (defectors-in-neighborhood * (PUNISHMENT_PAYOFF - Fear))             ; CD [cooperator meets defectors(s)] = (punishment payoff - Fear) * number of defectors in (Moore) neighborhood
 set cooperator-payoff (total-val-exchange-payoff + total-sucker-payoff)                      ; Compute cooperator's total score before fitness.
]
[
 set total-temptation-payoff (cooperators-in-neighborhood * (VAL_EXCHANGE_PAYOFF +  Greed))   ; DC [defector meets cooperator(s)] = (value of exchange + Greed) * (number of cooperators in (Moore) neighborhood)
 set total-punishment-payoff (defectors-in-neighborhood  * PUNISHMENT_PAYOFF)                 ; DD [defector meets defectors(s)] = punishment payoff ¨* number of defectors in (Moore) neighborhood
 set defector-payoff (total-punishment-payoff + total-temptation-payoff)                      ; Compute defector's total score before fitness.
]
end


to fitness                                                                ; Process of relative fitness:
 ifelse (color = blue)    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; If agent is a cooperator:
 [
  set best-cooperator-neighbor max [cooperator-payoff] of link-neighbors    ; Get score of the highest-scoring cooperator in the (Moore) neighborhood different from the agent itself
  ifelse (cooperator-payoff < best-cooperator-neighbor)                     ; Compare the score of the highest-scoring cooperator with the score of ego (i.e. the cooperator executing this line of code)
  [set cooperator-C-paragon (best-cooperator-neighbor)]                     ; If ego's score is less than the score of the cooperator with the highest score, adopt the former as the payoff of cooperating
  [set cooperator-C-paragon (cooperator-payoff)]                            ; Otherwise, keep ego's own/original score as the payoff of cooperating.

  set cooperator-D-paragon max [defector-payoff] of link-neighbors          ; Get score of the highest-scoring defector in the (Moore) neighborhood.

  set cooperator-fitness (cooperator-C-paragon - cooperator-D-paragon)      ; Cooperation wins if cooperator-C-paragon (the highest-scoring C in the neighborhood) > cooperator-D-paragon (the highest-scoring D in the neighborhood).

                                                                                       ; Change strategy (i.e. become a defector) if:

  if (cooperator-fitness > 0 and random-float 1 < probability-mistake)                                     ; 1) The highest-scoring agent is a cooperator (i.e. cooperation won), but agent makes a mistake or
  [set color red]
  if (cooperator-fitness < 0 and random-float 1 > probability-mistake)                                     ; 2) The highest-scoring agent is a defector (i.e. defection won) and agent makes no mistake or
  [set color red]
  if (cooperator-fitness = 0 and random-float 1 < probability-mistake and defectors-in-neighborhood = 0)   ; 3) There are not defectors at all but agent still makes a mistake or
  [set color red]
  if random-tiebreaker?                                                                                    ; 4) random-tiebraker is on and
  [
   if (cooperator-fitness = 0 and random-float 1 > 0.5 and defectors-in-neighborhood  > 0)                 ;    there is a tie and toss wins.
   [set color red]
  ]
 ]

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; If agent is a defector:

 [
  set best-defector-neighbor max [defector-payoff] of link-neighbors        ; Get score of the highest-scoring defector in the (Moore) neighborhood different from the agent itself
  ifelse (defector-payoff < best-defector-neighbor)                         ; Compare the score of the highest-scoring defecor with the score of ego (i.e. the defector executing this line of code)
  [set defector-D-paragon (best-defector-neighbor)]                         ; If ego's score is less than the score of the defector with the highest score, adopt the former as the payoff of defecting
  [set defector-D-paragon (defector-payoff)]                                ; Otherwise, keep ego's own/original score as the payoff of defecting.

  set defector-C-paragon max [cooperator-payoff] of link-neighbors          ; Get score of the highest-scoring cooperator in the (Moore) neighborhood.

  set defector-fitness (defector-D-paragon - defector-C-paragon)            ; Defection wins if defector-D-paragon (the highest-scoring D in the neighborhood) > defector-C-paragon (the highest-scoring C in the neighborhood).

                                                                                     ; Change strategy (i.e. become a cooperator) if:

  if (defector-fitness > 0 and random-float 1 < probability-mistake)                                       ; 1) The highest-scoring agent is a defector (i.e. defections won), but agent makes a mistake or
  [set color blue]
  if (defector-fitness < 0 and random-float 1 > probability-mistake)                                       ; 2) The highest-scoring agent is a cooperator (i.e. cooperation won) and agent makes no mistake or
  [set color blue]
  if (defector-fitness = 0 and random-float 1 < probability-mistake and cooperators-in-neighborhood = 0)   ; 3) There are not cooperators at all but agent still makes a mistake or
  [set color blue]
  if random-tiebreaker?                                                                                    ; 4) random-tiebraker is on and
  [
  if (defector-fitness = 0 and random-float 1 > 0.5 and cooperators-in-neighborhood > 0)                   ;    there is a tie and toss wins.
  [set color blue]
  ]
 ]
end

to-report Cooperators
  report (count turtles with [color = blue]) / count turtles               ; Compute the D.V.: proportion of cooperators
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CONVERGENCE ROUTINE

to behavior-history
ask turtles
[
 set my-behavior-history-list lput (color) my-behavior-history-list   ; Store in the agent's "memory" the numeric code associated with the agents' cuurent strategy (105 = blue = cooperation; 15 = red = defectoion)
 while [length my-behavior-history-list > equilibrium-count]           ; While the number of rounds stored in the agent'smemory is > equilibrium count (the desired number of rounds the agent is able to remember)
 [
  set my-behavior-history-list but-first my-behavior-history-list      ; Delete the oldest memory
 ]
]
end

to convergence
 let z 0
 if not converged?                                                         ; If the model has not converged:
 [
  if Cooperators = 1 or Cooperators = 0                                      ; If all agents are cooperators or none of them are cooperators:
  [
   set universal? true                                                       ; set univeral? to true
   set converged? true                                                       ; set converged? to true
   set c-equilibrium Cooperators                                             ; Save current proportion of Cooperators as the actual value of the D.V.
   set t-equilibrium ticks + 1                                               ; Save the value of the current tick/time step
  ]

  ask turtles                                                              ; Ask all agents:
  [
   if item 0 my-behavior-history-list = item 1 my-behavior-history-list     ;Compare your startegy in the current round and in the previous round:
   [
    set z z + 1                                                              ;Add 1 to the counter (Z) if past startegy is = to current strategy
   ]
  ]

  if z = count turtles                                                     ;If all agents have the same strategy in the previous and current round:
  [
   set converged? true                                                       ;Set converged? to true
   set no-change? true                                                       ;Set no-change? to true
   set c-equilibrium Cooperators                                             ;Save current proportion of Cooperators as the actual value of the D.V.
   set t-equilibrium ticks + 1                                               ;Save the value of the current tick/time step
  ]
 ]
end

;; Greed and Fear in Network Reciprocity
;; Kitts, Leal, Felps, Jones & Bernman,  PloS ONE 2016
;; Code written by Diego F. Leal (www.diegoleal.info)
;; Last updated: 09/2017
@#$#@#$#@
GRAPHICS-WINDOW
11
97
531
618
-1
-1
5.07
1
10
1
1
1
0
1
1
1
-50
50
-50
50
0
0
1
ticks
30.0

BUTTON
593
529
656
562
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
0

BUTTON
668
529
731
562
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

SLIDER
577
144
749
177
Greed
Greed
0
8
8.0
0.1
1
NIL
HORIZONTAL

SLIDER
576
97
748
130
Fear
Fear
0
8
8.0
0.1
1
NIL
HORIZONTAL

SLIDER
576
198
748
231
initial-cooperation
initial-cooperation
0
1
0.9
0.01
1
NIL
HORIZONTAL

MONITOR
588
462
744
507
proportion of cooperators
Cooperators
3
1
11

SWITCH
581
367
745
400
synchronized?
synchronized?
1
1
-1000

SWITCH
581
410
745
443
random-tiebreaker?
random-tiebreaker?
0
1
-1000

SLIDER
576
248
748
281
probability-mistake
probability-mistake
0
.1
0.0
0.001
1
NIL
HORIZONTAL

SWITCH
595
319
712
352
sociogram?
sociogram?
0
1
-1000

TEXTBOX
16
10
610
90
Greed and Fear in Network Reciprocity:\nKitts, Leal, Felps, Jones & Bernman,  PloS ONE 2016\nOriginal code written by Diego F. Leal (www.diegoleal.info)
20
0.0
1

TEXTBOX
282
620
432
642
Cooperators
18
105.0
1

TEXTBOX
165
621
315
643
Defectors
18
15.0
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
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="F&amp;G_orgs_from_.1_to_ 8_by_0.79_time_liimit_1000_initial_C_.9_reps_TEST_3" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>Cooperators</metric>
    <metric>c-equilibrium</metric>
    <metric>c-half-time</metric>
    <metric>t-equilibrium</metric>
    <metric>universal?</metric>
    <metric>no-change?</metric>
    <steppedValueSet variable="Greed" first="0.1" step="0.89" last="8"/>
    <steppedValueSet variable="Fear" first="0.1" step="0.89" last="8"/>
    <enumeratedValueSet variable="initial-cooperation">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-tiebreaker?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synchronized?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-mistake">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sociogram?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synchronized?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="F&amp;G_org_from_.1_to_ 8_by_0.158_time_500_IC_.9_reps1-50" repetitions="50" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>Cooperators</metric>
    <metric>universal?</metric>
    <metric>no-change?</metric>
    <steppedValueSet variable="Greed" first="0.1" step="0.158" last="8"/>
    <steppedValueSet variable="Fear" first="0.1" step="0.158" last="8"/>
    <enumeratedValueSet variable="initial-cooperation">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="random-tiebreaker?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="synchronized?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-mistake">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sociogram?">
      <value value="false"/>
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
