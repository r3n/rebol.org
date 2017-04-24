#! /usr/bin/rebview -qs
REBOL [
	File: %randomr.r
    Date: 17-June-2009
    Title: "Random Number Generator"
    Version: 1.0
    Author: "François Jouen. Based on Vincent Levorato's java code"
    Rights: {}
    Purpose: {Random Number Generator using continous and discret statistical laws}
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool ]
        domain: [math]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
	]
]



random/seed now/time/precise 
; some constant values

umax: power (1 / (2 * pi)) 0.25
vmax: power (2 / (pi * exp 2)) 0.25
log2pi: log-e (2 * pi)
; and an useful function for rebol

rand_real: func ["return a decimal value beween 0 and 1. Base 16 bit" ] [
	x: random power 2 16
	return x / power 2 16
]



; ////////////////////
; //CONTINUOUS LAWS//
;///////////////////

;uniform law on 
rand_unif: func [i [decimal!] j [decimal!]]
[
	return rand_real * (j - i) + i
]



;exponential law
rand_exp: func [] [
	return - log-e rand_real
]

;exponential law with a l degree 
rand_expm: func [l [decimal!]] [
	return - log-e (rand_real / l)
]



;normal law
rand_norm: func [A [decimal!] /local u v] [
	u: rand_real * umax
	v: ((2 * rand_real) - 1) * vmax
	while [( v * v + (A + 4 * log-e u) * (u * u)) >= 0]
		[u: rand_real * umax v: ((2 * rand_real) -1) * vmax]
	return v / u
]		

; normal polar law
rand_normpol: func [ /local t u v v1 v2 v3]
[
	t: copy []
	u: square-root (-2 * log-e rand_real)
	v1: to-binary (6.28318530718 * rand_real)
	v2: to-binary pi
	v3: v1 and v2
	v: to-decimal to-string v3
	
	append t u * cosine v
    append t v * sine u
	return t
]

;lognormal law
rand_lognorm: func [a [decimal!] b [decimal!] z [decimal!]] [
	return exp (a + b * z)
]	


; gamma law
rand_gamma: func [k [integer!] l [decimal!] /local r i] [
	r: 0
	for i 0 k 1 [r: r + rand_expm l]
	return r
]	


;geometric law in a disc	
rand_disc: func [ /local u v t]
[
	t: copy []
	u: 2 * rand_real - 1
	v: 2 * rand_real - 1
	
	append t u
	append t v
	while [(u * u + v * v) > 1]
		[ poke t/1 u poke t/2 v]
	return t
]


;geometric law in a rectangle 

rand_rect: func [a [decimal!] b [decimal!] c [decimal!] d [decimal!] /local t]
[
	t: copy []
	append t a + (b - a) * rand_real / 2
	append t c + ( d - c) * rand_real / 2
	return t
]




;chi square law
rand_chi2: func [v [integer!] /local i  z] [
	z: 0
	for i 0 (v - 1) 1 [z: z + power (rand_norm log2pi) 2]
	return z	
] 

; Erlang law
rand_erlang: func [n [integer!] /local t i] [
	t: 1.0
	for i 0 (n - 1) 1 [t: t * (1.0 - rand_real)]
	return - log-e t
]


;Student law
rand_student: func [ n [integer!] z [decimal!] /local v] [
	v: rand_chi2 n
	return z / (square-root (absolute (v / n)))
]

;Fisher law
rand_fischer: func [ n [integer!] m [integer!] /local x y] [
	x: rand_chi2 n
	y: rand_chi2 m
	return (x / to-decimal (n)) / (y / to-decimal (m))
]

;Laplace Law
rand_laplace: func [a [decimal!] /local u1 u2][
	u1: rand_real
	u2: rand_real
	either u1 < a [return - a * log-e u2] [return a * log-e u2]
]

;beta law 

rand_beta: func [a [integer!] b [integer!] /local x1 x2]
[
	x1: rand_gamma a 1.0
	x2: rand_gamma b 1.0
	return x1 / (x1 + x2)
]

;weibull law
rand_weibull: func [a [decimal!] l [decimal!] /local x] [
	x: rand_real
	return power (- 1 / a * log-e (1 - x)) 1 / l
]
; Rayleigh law

rand_rayleigh: func [a [decimal!] b [decimal!]]
[
	return rand_weibull 2.0 0.5
]


; //////////////////
; DISCRETE LAWS
;//////////////////

;Bernouilli law
rand_bernouilli: func [p [decimal!] /local u] [ 
	u: rand_real	
	either  u < p [return 1][ return 0]
]

;binomial law 
rand_binomial: func [n [integer!] p [decimal!] /local x i] [
	x: 0
	for i 0 (n - 1)  1 [ if rand_real < p [x: x + 1]]
	return x
]

;binomial negative law
rand_binomialneg: func [n [integer!] p [decimal!] /local x i] [
	x: 0
	for i 0 (n - 1)  1 [
		while [rand_real >= p] [x: x + 1]
	]
	return x
]
;geometric law
rand_geo: func [p [decimal!] /local x] [
	x: 0
	while [rand_real >= p] [ x: x + 1]
	return x
]

; Poisson law
rand_poisson: func [l [decimal!] /local j p f u] [
	j: 0.0
	p: f: exp (- l)
	u: rand_real
	while [u > f ] [
		p: l * p / (j + 1)
		f: f + p
		j: j + 1
	]
	return j 
]


	


