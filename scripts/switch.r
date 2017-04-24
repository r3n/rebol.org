REBOL [
    Title: "Examples Using Switch Function"
    Date: 15-Oct-1998
    File: %switch.r
    Purpose: {
        Switch between a set of choices or a default.
        Should make C programmers happy.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tutorial 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;-- Switch on simple numbers like in C:

switch 22 [
    11 [print "here"]
    22 [print "there"]
]

switch/default 400 [
    11 [print "here"]
    22 [print "there"]
] [ print "nowhere"]


;-- Or, words used as symbols:

car: pick [Ford Chevy Dodge] random 3
print switch car [
    Ford  [ 351 * 1.4 ]
    Chevy [ 454 * 5.3 ]
    Dodge [ 154 * 3.5 ]
]

;-- Strings too:

html-tag: "pre"
print switch html-tag [
    "HREF" ["Hypertext Reference"]
    "IMG"  ["JPEG or GIF Image File"]
    "PRE"  ["Preformatted text"]
    "LI"   ["Bulleted list item"]
]

;-- Times (dates, or most other types of values in REBOL):

time: 10:30
switch/default time [
     8:00 [send wendy@domain.dom "Hey, get up"]
    12:30 [send cindy@dom.dom "Join me for lunch."]
    16:00 [send group@every.dom "Dinner anyone?"]
] [print "Nothing to do!"]

;-- The "cases" can be a variable too:

schedule: [
     8:00 [send wendy@domain.dom "Hey, get up"]
    12:30 [send cindy@dom.dom "Join me for lunch."]
    16:00 [send group@every.dom "Dinner anyone?"]
]

switch time schedule

; And, there are many dozen other possibilities...