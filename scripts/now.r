REBOL[
file: %now.r
Title: "How many seconds old are you?"
Author: "Leke"
Purpose: {Newbie exercise (written by a newbie) to learn more about the NOW Function Word.}
Date: 6-Aug-2004
    library: [
        level: 'beginner 
        domain: math
Platform: all
Type: tool
Tested-under: none
Support: none
License: none
    ]
]

;*** 1. Gets the seconds since your birthday, until the start of today ***
days_old: now - 23-Nov-1975 ; outputs answer in days (replace 23-Nov-1975 with your birthday).
seconds_old: days_old * 86400 ; 86400 = seconds in EVERY day.
print [ "You are" seconds_old "seconds old on this DAY."]
;*** end 1.***

;*** 2. gets the exact amount of seconds elapsed today. ***
nt: now/time ; create a variable from now/time (current time).

hour: nt/hour ; gets the hours from now/time.
mins: nt/minute ; ...and so on...
sec: nt/second 

get_seconds: (hour * 3600) + (mins * 60) + sec ; converts and adds the 3 lines above to seconds only.
;*** end 2.***

;*** 3. gets seconds from 1. AND seconds from 2. ***
exactly: seconds_old + get_seconds
;*** end 3. ***

;*** 4. prints seconds from 3. See the print statement for what it does ***
print [ "You were" exactly "seconds old when this program was executed!"]
;*** end 4. ***

halt