REBOL [
  Library: [
     level: 'intermediate
     platform: 'all
     type: 'tool
     domain: 'patch 
     tested-under: 'win2k
     support: none
     license: gpl
     see-also: none
   ]

    Title: "FreeMem"
    File: %free-mem.r
    Author: "DocKimble"
    Publisher: "ShadWolf"
    Date: 26/10/04
    Purpose: {A tiny function to free the memory occuped by a variable that is no more used in the program.
 This code is the best code given to us by DocKimble around the memory clearance. So it's the fruit of a colaborative work around memory management that we do using the forum of  REBOLFRANCE.org}
]
; the free mem function
free-mem: func ['word] [set :word make none! recycle]

;  A sample of the running of this function in the rebol console.

>> system/stats
== 3778424
>> s: make string! 50'000'000
== ""
>> system/stats
== 53780344
>> free-mem s
>> system/stats
== 3778424

