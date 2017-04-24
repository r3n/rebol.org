REBOL [
    Title: "REBOL stress test"
    Date: 12-Oct-2003
    Version: 0.0.1
    Author: "Sunanda"
    File: %rebol-stress-test.r
    Purpose: {
        Run various things to see what limits REBOL has.
        Largest integer, largest decimal, depth of
        stack, maximum words definable, etc.
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool demo] 
        domain: [debug]   
        tested-under: 'win
        support: none 
        license: 'pd 
        see-also: none
    ]
    
]

print ["REBOL Version: " system/version]
print ["        Build: " system/build]
print ["      Product: " system/product]

loop 5 [print ""]

;;	---------------------
;;	How large an integer?
;;	---------------------


int-factorial: func [n [integer!]]
[
 if any [n = 0 n = 1] [return 1]
 return n * int-factorial n - 1

]


	
;;	---------------------
;;	How large an number?
;;	---------------------

num-factorial: func [n [number!]]
[
 if any [n = 0 n = 1] [return 1]
 return n * num-factorial n - 1.0

]




;;	-------------------------
;;	How deep can you recurse?
;;	--------------------------
;;
;;	(Adding logarithms to find
;;	 factorials lets you find larger
;;	 factorials than multiplying
;;	 the numbers. Though what you
;;	 get back is a logarithm, of
;;	 course)
	
log-factorial: func [n [number!]]
[
 if any [n = 0 n = 1] [return 0]
 return (log-10 n) + log-factorial n - 1.0
]

	
	
;;	===================================
;;	Run tests using the above functions	
;;	===================================

;;	---------------
;;	Largest integer
;;	---------------

test: "largest integer factorial test"
ask join "press enter to run " test

if error? capture-error: try
[	
 n: 0
 forever
 [
   print [test " --" n " -- " int-factorial n]
   n: n + 1	 
		]
]
[
  Print ["failed on " n]
]
	
	
;;	----------------------	
;;	Largest decimal number
;;	----------------------	

test: "largest decimal factorial test"
ask join "press enter to run " test
	
if error? capture-error: try
[		
 n: 0
 forever
  [
   print [test " -- " n " -- " num-factorial n]
  n: n + 1	 
  ]
]
[
 Print ["failed on " n]
]


;;	-----------------
;;	Print stack depth
;;	-----------------
test: "Stack depth for recursion test"
ask join "press enter to run " test

if error? capture-error: try
[	
 n: 0
 forever
  [
   print [test " --" n " -- " log-factorial n]
   n: n + 1	 
  ]
]	
[
  Print ["failed on " n]
]	
	
;;	==========================================	
;;	Other tests not using predefined functions
;;	===========================================	
	
;;	-------------------------	
;;	Stack size for arithmetic
;;	-------------------------

test: "Stack depth for recursion"
ask join "press enter to run " test



if error? capture-error: try
[
 n: 0
 n-str: copy "0"
 forever [
  print [test " -- "do n-str]
  insert n-str "1 + ("
  append n-str ")"
  n: n + 1
  ]
]
 [
   Print ["failed on " n]
 ]
	

	
	
;;	------------------------------	
;;	How many words can you define?
;;	------------------------------
;;
;;	Your console session will probably
;;	be completely useless after this
;;	test -- time to restart.

test: "Maximum words test"
ask join "press enter to run " test

if error? capture-error: try
[
 n: 0
 forever [
    print [test " -- " length? first system/words]
   to-word join "zzz" n
  n: n + 1
]
]
[
  Print ["failed with system/words length: " length? first system/words]
]
	