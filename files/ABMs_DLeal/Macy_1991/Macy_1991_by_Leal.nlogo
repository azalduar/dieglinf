globals [
  new-π                      ;; proportion of the group who chooses to participate
  current-π                  ;; proportion of the group who is participating now
  L                          ;; production function (i.e. level of production of the public good)
  ego-resources              ;; resources of a particular turtle
  total-resources            ;; list of all resources of each turtle (i.e. pool of resources)
  sumResources               ;; sum of all the resources of each turtle
  levelContribution          ;; proportion participating (π) at a given point in time
        ]

turtles-own [
  ij               ;; j's interest in the public good
  ej               ;; j's learning parameter
  pj               ;; j's probability of participation
  vj               ;; j's decision to volunteer
  cj               ;; j's resource contribution to the collective good
  sj               ;; j's share of the public good
  oj               ;; j's outcome
  tj               ;; j's threshold
  tj-history       ;; j's threshold history (i.e. list of all tj for a given turtle)
  sj-history       ;; j's share of the public good (sj) history (i.e. list of all sj for a given turtle)
  rDist            ;; j's resources
  rj               ;; j's share (i.e. proportion) of the total resources available in the population

  sMax             ;; maximum value of sj, given j's the distribution of interes of resources. This is part of the denominator in equation 5.

  ;;;;;;; these variables are used to calculate sMax; they can be ignored ;;;;;;;;;
  lmax
  lmin
  minS
  maxS
  absMinS
  absMaxS
  maxMin
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

            ]

to setup
  clear-all
  create-turtles N     ;; create N number of turtles. N is a global variable that can be found on the interface. In Macy's article N = 100.

   ask-concurrent turtles [
   set rDist (random-normal 0 1)              ;; resources are normally distributed over turtles (p. 737)
   set rDist (rDist - min [rDist] of turtles)  ;; the minimum turtle has zero resources (rescale to remove any negative resources)

;; According to Macy "the mean interest is one" (p. 738) but does not specify the distribution; assume normal bounded by 2 standard deviations
   set ij random-normal interest-mean interest-std     ;; use the user-specified mean and standard deviation
    if (ij < interest-mean - 2 * interest-std) [        ;; cap lower bound of Interest (I) at 2 standard deviations
     set ij ((interest-mean - 2 * interest-std) + 0.1)
                                          ]
    if (ij > interest-mean + 2 * interest-std) [        ;; cap upper bound of Interest (I) at 2 standard deviations
     set ij (interest-mean + 2 * interest-std)
                                          ]

;; Accordign to Macy "the similations assumes that ej is is normally distibuted" (p. 740). Given that 0 <=ej <= 1 (p. 740), I assumed Ej is normally
;; distributied with mean 0.5 and std dev. 0.2, truncated at -2 and 2 std dev from the mean.
   set ej random-normal learning-rate-mean learning-rate-std  ;; each turtle generates a random number (ej) drawn from a normal distribution with mean = mean-2 and standard deviation = std-deviation-2
    if (ej < learning-rate-mean - 2 * learning-rate-std) [  ;; cap lower bound of learning rate (ej) at 2 standard deviations
     set ej (learning-rate-mean - 2 * learning-rate-std)
                                           ]
    if (ej > learning-rate-mean + 2 * learning-rate-std) [  ;; cap upper bound of learning rate (ej) at 2 standard deviations
     set ej (learning-rate-mean + 2 * learning-rate-std)
                  ]
                       ]

  setup-total-resources   ;; call the procudure setup-total-resources

  ask-concurrent turtles [
   set rj (rDist / sumResources) ;; Each turtle calculates its share (i.e. proportion) of the total resources (sumResources) (p. 737)
                         ]

  ask-concurrent turtles [
   compute-Smax        ;; Each turtle calculates S-max, its maximum possible share of the public good. See equation 5.
                         ]

  setup-initial-π     ;; call setup-initial-π procedure

  ask-concurrent turtles [
   setup-initial-sj    ;; call setup-initial-sj procedure
   setup-initial-tj    ;; call setup-initial-tj procedure
                         ]

  ;;;;;;;;;;;;;;;;;;;; these lines are code are developed for visualization purposes. As such they can be ignored ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ask-concurrent turtles [
   setxy 16 random-pycor ;; for visualization purposes turtles start at the right end of the world.
   set color blue        ;; for visualization puroses turtles start being blue. Blue color identifies turtles that choose not to volunteer (i.e. vj = 0)
   set heading 90        ;; for visualization purposes turtles all turtles lood at East
   ;move                  ;; this is a procudure used for visualization purposes, it assigns one patch per turtle.
                         ]
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;probability to volunteer (Pj) and decision to volunteer (Vj);;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to next-pj
  ifelse ticks < 1 [   ;; if ticks < 1 (i.e. when t = 0), this is analogous to set the initial value to pj and vj to 0
    ask-concurrent turtles [
      set pj 0   ;; set pj (rprobability to volunteer) to 0
      set vj 0   ;; set vj (volunteering)  to 0
                           ]

                   ]
  ;; else (i.e if ticks >= 1):
  [
   ask-concurrent turtles [
    set pj (1 / (1 + e ^ ((tj - last current-π ) * M-choice-function)))  ;;calculate ptobability to volunteer (pj). See equation 1 (p. 736)
                          ]
  ask-concurrent turtles [ ;; "the decision to volunteer is then determined by magnitude of pj relative to a random number from a uniform distribution (0 < n < 1)" (p. 736)
    ifelse (random-float 1 < pj) [   ;; if a random number from a uniform distribution is < pj
    set vj 1                          ;; set volunteering (vj) to 1
     set color red                    ;; set color red
                                 ]
    [                                ;; else
     set vj 0                         ;; set volunteering (vj) to 0
     set color blue                   ;; set color red
     ]
                         ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; participation rate (π) ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-initial-π
 set current-π [0]  ;; make the initial participation rate (π) = 0.
end

to next-π
  set new-π ((count turtles with [vj = 1]) / N) ;; calculate the new participation rate (π)
  set current-π  lput (new-π) current-π  ;; store the new participation-rate in the list current-π
  if (length current-π > 2) [set current-π but-first current-π]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;
; production function (L);
;;;;;;;;;;;;;;;;;;;;;;;;;;

to compute-L
  set L ((1 / (1 + e ^ ((0.5 - last current-π) * M-production-function))) - ((1 - X) / 2 )) ;; compute the production function (L). equation 3 (p. 737)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cj resource contribution ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to compute-cj
  ask-concurrent turtles [
    set cj (rj * N * vj)  ;; equation 2. "Having choosen to volunteer (vj = 1), the magnitude of each undividual contribution is limited by that individual's share [R] of the group's total resources [N]" (p. 737)
              ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; share of the public good Sj ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-initial-sj
  set sj-history [0] ;; initial value for j's share of the public good
end

to next-sj
 ask-concurrent turtles [
  set sj ((L * N * ij  / (N ^ (1 - J))) - cj) ;; equation 4 (p. 738)
  set sj-history lput (sj) sj-history ;; store sj in the list "sj-history"
  if (length sj-history > 2) [set sj-history but-first sj-history] ;; if the length of the list "sj-history" is > 2, delete (i.e. forget) the first value (i.e. more distante memory of) sj
             ]
end

;;;;;;;;;;;;;;;;;;
;;; Outcome Oj ;;;
;;;;;;;;;;;;;;;;;;

to compute-oj
 ask-concurrent turtles [
 set oj ((Ej * ((2 * last sj-history) - first sj-history )) / (3 * sMax))  ;; equation 5 (p. 739)
 if oj > 1 [set oj 1]  ;; range check: if outcome (oj) is > 1, set outcome (oj) to 1
 if oj < -1 [set oj -1] ;; range check: if outcome (oj) is < 1, set outcome (oj) to -1
                        ]
end

;;;;;;;;;;;;;;;;;;;;
;;; Threshold Tj ;;;
;;;;;;;;;;;;;;;;;;;;

to setup-initial-tj
  set tj-history []  ;; set the list tj history as an empty list
  set tj-history fput (1) tj-history ;; make the inital value of turtles threshold = 1. "The simulation begins with Tij = 1" (p. 740).
end

to next-tj
  let w ticks  ;; this local variable were developed for visualization purposes, as such can be ignored
   ask-concurrent turtles [
     if (vj = 1 and oj > 0) or (vj = 0 and oj < 0)[
      set tj (last tj-history - (oj * (1 - ((1 - last tj-history ) ^ (1 / abs (oj)))) * vj) + (oj * (1 - ((1 - last tj-history) ^ (1 / abs (oj)))) * ( 1 - vj))) ;; equation 6
       if tj > 1 [set tj 1] ;; range check, if tj > 1, set tj = 1
       if tj < 0 [set tj 0] ;; rnahe check, if tj < 0, set tj = 0
       setxy ((tj * 32) - 16) pycor
                                                  ]

     if (vj = 1 and oj < 0) or (vj = 0 and oj > 0) [
       set tj (last tj-history + (oj * (1 - (last tj-history ^ (1 / abs (oj)))) * (1 - vj)) - (oj * (1 - (last tj-history ^ (1 / abs (oj)))) * vj)) ;; equation 6
       if tj > 1 [set tj 1] ;; range check, if tj > 1, set tj = 1
       if tj < 0 [set tj 0] ;; rnahe check, if tj < 0, set tj = 0
       setxy ((tj * 32) - 16) pycor
                                                   ]
       set tj-history lput (tj) tj-history ;; store tj in the list "tj-history"
        if (length tj-history > 2) [set tj-history but-first tj-history] ;; if the length of the list "tj-history" is > 2, delete (i.e. forget) the first value (i.e. more distante memory of) tj
                         ]
   end

to go
  next-pj     ;; calculate Pj
  next-π      ;; calcuate π
  compute-L   ;; calcualte L
  compute-cj  ;; calculate Cj
  next-sj     ;; calculate Sj
  compute-oj  ;; calculate Oj
  next-tj     ;; calculate Tj
  compute-level-of-contribution ;;calculate the dependent variable, π at a given time step
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; these are auxiliary procedures ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; this procedure is used to calculate the sum of all turtles' resources (i.e. sum of rDist)
to setup-total-resources
  set total-resources []  ;; create an empty list to store turtles' rDist
   let z 0                ;;  create a the local variable z and set it to 0
    while [z < count turtles] [ ;; while z is less than total number of turtles
            set ego-resources ([rDist] of turtle z) ;; retrieve rDist from turtle with who/id number = z
            set total-resources fput (ego-resources) total-resources ;; store information in the list total-resources
      set z z + 1  ;; go to the turtle with the next who/id number
                              ]
    set sumResources sum total-resources ;; summ all number in the list total-resources
end

;;; SMax ;;;

to compute-sMax
 set lMax ((1 / (1 + e ^ ((0.5 - ((N - 1) / N)) * 10))) - ((1 - X) / 2))
 set lMin ((1 / (1 + e ^ ((0.5 - (1 / N)) * 10))) - ((1 - X) / 2))
 set minS (lMin * N * ij / (N ^ (1 - J)) - N * rj)
 set maxS (lMax * N * ij / (N ^ (1 - J)))
 set absMinS abs(minS)
 set absMaxS abs(maxS)
 ifelse (absMinS - absMaxS <= 0)
 [set sMax absMaxS]
 [set sMax absMinS]
end

to compute-level-of-contribution
    set levelContribution (last current-π)  ;; this procedure calculates the dependent variable on figure 739. Warning: Macy is not clear about this variable
end


;; this procudure is used only for visual purposes
to move
     if any? other turtles-here
      [setxy 16 random-pycor
        move]
end

;;;; replication of Macy (1991) Chains of Cooperation
;;;; Code Written by Diego F. Leal (www.diegoleal.info)
;;;; Last updated: 10/21/2014
@#$#@#$#@
GRAPHICS-WINDOW
231
93
638
501
-1
-1
12.1
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

SLIDER
22
138
194
171
N
N
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
661
181
833
214
X
X
-1
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
662
247
834
280
J
J
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
663
100
835
133
M-choice-function
M-choice-function
0
10
5.0
0.1
1
NIL
HORIZONTAL

BUTTON
121
390
184
423
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

PLOT
666
335
941
553
Level of contribution (pj) over time
Time
Level of contribution (pj)
0.0
50.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot levelContribution"

TEXTBOX
840
93
1197
141
This is the shape parameter of the cumulative logistic function that models the probability to volunteer (Pj) (p. 736).
13
0.0
1

TEXTBOX
840
177
1282
260
X determines the range of the production function (L).  (p. 737)\nPublic Bads: (X = -1 --> -1 < L < 0) \nPublic Goods: (X = 1 --> -1 < L < 0)\nMixed Outcome: (X = 0 --> -.5 < L < .5).
13
0.0
1

TEXTBOX
842
248
1244
319
J is jointness of supply. J=0 is a rival public good (peers consume public good, so achieving a given benefit costs more in a larger group). J=1 is pure jointness (group size does not affect ego's benefit from ego's contribution).  Macy reports J = 0.25 and J = 0.5. (p. 738)
13
0.0
1

TEXTBOX
231
509
431
547
0
18
15.0
1

TEXTBOX
643
507
658
545
1
18
15.0
1

SLIDER
25
235
197
268
interest-std
interest-std
0
.5
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
25
198
197
231
interest-mean
interest-mean
0
2
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
29
338
201
371
learning-rate-std
learning-rate-std
0
.5
0.15
0.01
1
NIL
HORIZONTAL

SLIDER
28
302
201
335
learning-rate-mean
learning-rate-mean
0.01
1
0.5
0.01
1
NIL
HORIZONTAL

TEXTBOX
27
280
231
298
Set distribution of learning rate (E)
13
0.0
1

TEXTBOX
24
177
204
195
Set distribution of Interests (I)
13
0.0
1

SLIDER
662
140
834
173
M-production-function
M-production-function
0
20
10.0
.1
1
NIL
HORIZONTAL

TEXTBOX
839
134
1192
166
This is the shape parameter of the cumulative logistic production function (L).
13
0.0
1

TEXTBOX
23
99
212
131
AGENT-LEVEL PARAMETERS \n(initialized on setup):
13
0.0
1

TEXTBOX
681
107
827
125
PROCESS PARAMETERS
13
0.0
1

PLOT
20
435
220
555
threshold-histogram
NIL
NIL
0.0
1.05
0.0
100.0
true
false
"histogram [tj] of turtles" ""
PENS
"default" 0.05 1 -16777216 true "" "histogram [tj] of turtles"

TEXTBOX
380
507
530
529
Threshold
18
14.0
1

PLOT
949
335
1244
554
reinforcement-plot
NIL
NIL
-0.5
0.5
0.0
1.0
true
false
"" ""
PENS
"default" 0.05 1 -16777216 true "" "histogram [oj] of turtles"

TEXTBOX
22
10
506
85
Chains of Cooperation\nMacy, ASR 1991.\nReplication by Diego F. Leal (www.diegoleal.info)
20
0.0
1

BUTTON
31
390
98
423
setup
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
