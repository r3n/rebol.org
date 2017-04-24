REBOL[
    Title: "to-fussy-idate"
    Version: 1.0.1
    Date: 17-01-2005
    Author: "Peter WA Wood"
    Copyright: "Peter WA Wood"
    File: %to-fussy-idate.r
    Purpose: {A function which converts a Rebol date! to a string formatted 
              according to a strict interpretation of the RFC 822 standard.
              
              If the time is not provided, a default of 00:00 is used.
              If the seconds are not set, 00 is used.
              (NB The zone defaults to 00:00 in a Rebol date)
                           
              Based on the original to-idate of Rebol/core and comments on the
              Rebol mailing list.}
    Usage: { example: to-fussy-idate rebol-date }
    Library: [
        level: 'beginner
        type: 'function
        domain: [web ]
        platform: 'all
        tested-under: [ core 2.5.6.2.4 "Mac OS X 10.2.8"
                        core 2.5.6.3.1 "Windows XP Professional"
                        view 1.2.10.3.1 "Windows XP Professional"
        ]
        support: none
        license: cc-by 
	   {see http://www.rebol.org/cgi-bin/cgiwrap/rebol/license-help.r}
    ]
]

to-fussy-idate: func [
     {converts a date! to a string formatted according to a strict
     interpretation of the RFC 822 standard.
     If the time is not set on the input date, a default of 00:00 is used.
     If the seconds of the time is not set, 00 is used.
     
     Warning: if the year supplied is four digits, Rebol correctly allocates
      the weekday taking into account the century. This may cause validation 
      problems if the date is before the late 20th century or after the early
      21st century.
     }
      
    the-date [date!]
        "The date to be reformatted"
    /local
        fussy
            "The string to be returned"
][

;;  Build the output string from back forwards

    fussy: copy " UT"                          ; Always use UT (GMT) for time
                                               ;  zone offset

    either the-date/time [ 
                                               ; the date has a time                    
        insert fussy the-date/zone/minute
        if the-date/zone/minute < 10 [insert fussy "0"]
        insert fussy absolute the-date/zone/hour
        if 10 > absolute the-date/zone/hour [insert fussy "0"]
        either the-date/zone/hour < 0 
            [insert fussy " -"]
            [insert fussy " +"]
        if the-date/time/second = 0             ; Rebol only returns hh:mm if
            [insert fussy ":00"]                ;  seconds is zero
            
        insert fussy rejoin [the-date/time]
        either the-date/time/hour < 10          ; Rebol doesn't return leading
            [insert fussy " 0"]                 ;  zero on hour
            [insert fussy " "]
    ][
        fussy: " 00:00:00 +0000 UT"             ; the date has no time
    ] 
    
    insert fussy remainder the-date/year 100    ; last 2 digits of the year
    either 10 > remainder the-date/year 100
        [insert fussy " 0"]
        [insert fussy " "]
 
    insert fussy rejoin [
        " "
        pick [
            "Jan" "Feb" "Mar" "Apr" "May" "Jun" 
            "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"] the-date/month
    ]
    insert fussy the-date/day
    either the-date/day < 10
        [insert fussy ", 0"]
        [insert fussy ", " ]
    insert fussy pick ["Mon" "Tue" "Wed" "Thu"
                       "Fri" "Sat" "Sun"] the-date/weekday
        
    return head fussy
    
] ; end to-fussy-idate

;; History
;; 
;; 1.0.0 17-Jan-2005    Initial release (no optimisation)
;; 1.0.1 18-Apr-2005    Tested under View 1.2.10.3.1 Windows XP
;; 