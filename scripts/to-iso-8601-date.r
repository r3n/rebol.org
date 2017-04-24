REBOL [
    Title: "to-iso8601-date"
    Version: 1.1.1
    Date: 26-01-2005
    Author: "Peter WA Wood"
    Copyright: "Peter WA Wood"
    File: %to-iso-8601-date.r
    Purpose: {A function which converts a Rebol date! to a string which complies
              with ISO 8601.
              
              If the time is not provided, a default of 00:00 is used.
              Truncates any milli-seconds.
              (NB The zone defaults to 00:00 in a Rebol date)
             }              
    Usage: { example: to-iso8601-date rebol-date }
    Library: [
        level: 'beginner
        type: 'function
        domain: [web ]
        platform: 'all
        tested-under: [ core 2.5.6.2.4 "Mac OS X 10.2.8"
                        core 2.5.6.3.1 "Windows XP Professional"
                        view 1.3.10.2.1 "Windows XP Professional"
        ]
        support: none
        license: cc-by 
	   {see htt4p://www.rebol.org/cgi-bin/cgiwrap/rebol/license-help.r}
    ]
]

to-iso8601-date: func [
     {converts a date! to a string which complies with the ISO 8602 standard.
      If the time is not set on the input date, a default of 00:00 is used.
     }
     
    the-date [date!]
        "The date to be reformatted"
    /local
        iso-date
            "The string to be returned"
][ 

    iso-date: copy ""           

    either the-date/time [ 
                                                    ; the date has a time
        insert iso-date rejoin [
            " "
            either the-date/time/hour > 9           ; insert leading zero if
                [the-date/time/hour]                ;  needed
                [join "0" [the-date/time/hour]]
            ":"
            either the-date/time/minute > 9
                [the-date/time/minute]
                [join "0" [the-date/time/minute]]
            ":"
            either the-date/time/second > 9         ; Rebol only returns 
                [to-integer the-date/time/second]   ;  seconds if non-zero
                [join "0" [to-integer the-date/time/second]]
            
            either the-date/zone = 0:00 [
                "Z"                                 ; UTC
            ][
                rejoin [
                    either the-date/zone/hour > 0   ; + or - UTC
                        ["+"]
                        ["-"]
                    either  (absolute the-date/zone/hour) < 10
                        [join "0" [absolute the-date/zone/hour]]
                        [absolute the-date/zone/hour]
                    either the-date/zone/minute < 10
                        [join "0" [the-date/zone/minute]]
                        [the-date/zone/minute]
                ]
            ]
        ] ; end insert  
    ][
        iso-date: " 00:00:00Z"                     ; the date has no time
    ] 
     
    insert iso-date rejoin [
        join copy/part "000" (4 - length? to-string the-date/year)
            [the-date/year]
        "-"
        either the-date/month > 9
            [the-date/month]
            [join "0" [the-date/month]]
        "-"
        either the-date/day > 9
            [the-date/day]
            [join "0" [the-date/day]]
     ] ; end insert
   
    return head iso-date
    
] ; end to-fussy-idate

;; History
;; 
;; 1.0.0 24-Jan-2005    Initial release (no optimisation)
;; 1.1.0 26-Jan-2005    Ignore milli-seconds if precise time set
;; 1.1.1 18-Apr-2205    Tested under View 1.2.10.3.1 Windows XP
;; 