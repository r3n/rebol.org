REBOL [
    title: "99 Bottles of Beer"
    date: 7-Dec-2013
    file: %99-bottles-of-beer.r
    author:  Nick Antonaccio
    purpose: {
        Prints the "99 Bottles of Beer" song lyrics, with proper grammar.
        "Bottles" changed to "bottle" at the end of the 2 line, and
         throughout the 1 line.  0 changed to "No" in the last line. 
    }
]
for i 99 1 -1 [ 
     x: rejoin [ 
         i b: " bottles of beer" o: " on the wall. " i b 
         ". Take one down, pass it around. " (i - 1) b o "^/" 
     ] 
     r: :replace j: "bottles" k: "bottle" 
     switch i [1 [r x j k r at x 10 j k r x "0" "No"] 2 [r at x 40 j k]] 
     print x 
] halt 
    
; Here's a simple 1 line console version: 
    
for i 99 1 -1[print rejoin[i b:" bottles of beer"o:" on the wall. "i b". Take one down, pass it around. "(i - 1)b o"^/"]]