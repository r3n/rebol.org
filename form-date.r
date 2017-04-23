REBOL [
    Title: "form-date"
    Author: "Christopher Ross-Gill"
    Date: 26-Apr-2007
    Version: 1.0.1
    File: %form-date.r
    Rights: {Copyright (c) 2007, Christopher Ross-Gill}
    Purpose: {Return formatted date string using strftime style format specifiers}
    Home: http://www.ross-gill.com/QM/
    Comment: {Extracted from the QuarterMaster web framework}
    History: [
        1.0.1 18-Jul-2007 btiffin "Obtained permission to add %c and %s precise seconds"
        1.0.0 26-Apr-2007 btiffin "Obtained permission to prepare script for rebol.org library"
        1.0.0 24-Apr-2007 chrisrg "The original"
    ]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [tool function]
        domain: [text text-processing math ui user-interface]
        tested-under: [view 2.7.6.4.2 Debian GNU/Linux 4.0]
        support: none
        license: 'cc-by-sa
        see-also: http://www.rebol.org/cgi-bin/cgiwrap/rebol/documentation.r?script=form-date.r
    ]
    Notes: {do %form-date.r to include the form-date function in the global namespace
        >> form-date now "%A %e%i %B, %Y at %T"
        == "Thursday 26th April, 2007 at 00:44:12"

        >> form-date now "%d-%b-%Y/%H:%M:%S%Z"
        == "26-Apr-2007/00:49:39-04:00"

        >> now
        == 26-Apr-2007/0:52:13-4:00

        >> form-date now/precise "%c"
        == "19-Jul-2007/01:02:03.012000-04:00"}

]

form-date: use [get-class interpolate pad pad-zone get-iso-year date-codes] [

;--## SERIES HELPER
;-------------------------------------------------------------------##
    get-class: func [classes [block!] item][
        all [
            classes: find classes item
            classes: find/reverse classes type? pick head classes 1
            first classes
        ]
    ]

;--## STRING HELPERS
;-------------------------------------------------------------------##
    interpolate: func [body [string!] escapes [any-block!] /local out][
        body: out: copy body

        parse/all body [
            any [
                to #"%" body: (
                    body: change/part body reduce any [
                        select/case escapes body/2 body/2
                    ] 2
                ) :body
            ]
        ]

        out
    ]

    pad: func [text length [integer!] /with padding [char!]][
        padding: any [padding #"0"]
        text: form text
        skip tail insert/dup text padding length negate length
    ]

;--## DATE HELPERS
;-------------------------------------------------------------------##
    pad-zone: func [time /flat][
        rejoin [
            pick "-+" time/hour < 0
            pad abs time/hour 2
            either flat [""][#":"]
            pad time/minute 2
        ]
    ]

    pad-precise: func [time /local tstr tsec tpre] [
        tstr: form time
        tsec: copy/part tstr find tstr "."
        tpre: find tstr "."
        rejoin [pad tsec 2 head change/part copy ".000000" tpre length? tpre]
   ]

    get-iso-year: func [year [integer!] /local d1 d2][
        d1: to-date join "4-1-" year
        d2: to-date join "28-12-" year
        return reduce [d1 + 1 - d1/weekday d2 + 7 - d2/weekday]
    ]

    to-iso-week: func [date [date!] /local out d1 d2][
        out: 0x0
        set [d1 d2] get-iso-year out/y: date/year

        case [
            date < d1 [d1: first get-iso-year out/y: date/year - 1]
            date > d2 [d1: first get-iso-year out/y: date/year + 1]
        ]

        out/x: date + 8 - date/weekday - d1 / 7
        out
    ]

    date-codes: [
        #"a" [copy/part pick system/locale/days date/weekday 3]
        #"A" [pick system/locale/days date/weekday]
        #"b" [copy/part pick system/locale/months date/month 3]
        #"B" [pick system/locale/months date/month]
        #"c" [pad date/day 2 "-"
              copy/part pick system/locale/months date/month 3 "-"
              pad date/year 4 "/"
              pad time/hour 2 ":"
              pad time/minute 2 ":"
              pad-precise time/second
              pad-zone zone]
        #"C" [to-integer date/year / 100]
        #"d" [pad date/day 2]
        #"D" [date/year #"/" pad date/month 2 #"/" pad date/day 2]
        #"e" [date/day]
        #"g" [pad (second to-iso-week date) // 100 2]
        #"G" [second to-iso-week date]
        #"H" [pad time/hour 2]
        #"i" [any [get-class ["st" 1 21 31 "nd" 2 22 "rd" 3 23] date/day "th"]]
        #"I" [pad time/hour + 11 // 12 + 1 2]
        #"j" [pad date/julian 3]
        #"J" [date/julian]
        #"m" [pad date/month 2]
        #"M" [pad time/minute 2]
        #"p" [pick ["AM" "PM"] time/hour < 12]
        #"s" [pad-precise time/second]
        #"S" [pad round time/second 2]
        #"t" [#"^-"]
        #"T" [pad time/hour 2 #":" pad time/minute 2 #":" pad round time/second 2]
        #"u" [date/weekday]
        #"U" [pad to-integer date/julian + 6 - (date/weekday // 7) / 7 2]
        #"V" [pad first to-iso-week date 2]
        #"w" [date/weekday // 7]
        #"W" [pad to-integer date/julian + 7 - date/weekday / 7 2]
        #"y" [pad date/year // 100 2]
        #"Y" [date/year]
        #"z" [pad-zone/flat zone]
        #"Z" [pad-zone zone]
        #"%" ["%"]
    ]

    func [
        "Renders a date to a given format (largely compatible with strftime)"
        date [date!] format [any-string!]
        /gmt "Align time with GMT"
        /local time zone nyd
    ][
        bind date-codes 'date
        all [
            gmt date/time date/zone
            date/time: date/time - date/zone
            date/zone: none
        ]

        time: any [date/time 0:00]
        zone: any [date/zone 0:00]
        interpolate format date-codes
    ]
]
