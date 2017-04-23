REBOL [
    Title: "Julian Calendar Converter"
    Date: 8-Nov-1999
    File: %julian.r
    Author: "Russ Yost"
    Purpose: {To provide conversions to/from julian day numbers/dates.}
    Comment: {
        (Note: REBOL provides day of year built-in, but technically
        not Julian conversion.) I'm not sure where these
        algorithms originated, but I used     them in a
        JForth program in 1992.  The epoch date seems to be
        that set by Joseph Scaliger in 1582, i.e., Jan 1 4713
        BC, (that  would be Julian day number 1), but as this
        algorithm takes the   average length of the solar
        year as 365.2425, it works over the  range 0001
        through 3000. Beyond then, the discrepancy with the
        true length, 365.242199, should lead to errors. (The
        year 2000, being divisible by 400,  will be a leap
        year,  although in general, years that are multiples
        of 100 are not  leap years. It *does* yield the
        correct Julian Day number given  in the 1999 World
        Almanac (World Almanac Books, Mahwah NJ) pg  322, for
        31 Dec 1998, 2,451,179.)
    }
    Email: rryost@home.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

print {
    Two functions are defined herein, date-to-jul, with argument a
    date in format dd-mm-yyyy in  year range 0001 through 3000, and 
    jul-to-date, with  argument a julian  day number (JD) based on 1 Jan
    4713 BC, with 31 Dec 1998's JD = 2451179 (as given in the 1999
    Almanac) and corresponding to the above mentioned range.
    This latter function also provides the day of the week for
    the given JD.

    Some other useful functions:
        diy, arg yyyy, yields the number of days in a given year.
        febdays, arg yyyy, yields the number of days in February.
        testj-d, arg yyyy, prints a  yyyy calendar, 1 line per month.   
    }


jul0: 1720997 ; use with jul day based in 365.2425 days in year.

comment {There are 365.242199 solar days in a year, so the preceding
        assumption will lead to trouble after year 3000, I think.}

comment { 'jul0 also compensates for extra days added in the calculation 
        of the number of days per month, and adjusts the result to agree 
        with 1999 Almanac's statement that JD of 31 Dec 1998 is         
        2,451,179.
        }

daysinyear: 365.2425
daysinmo: 30.6001 ; a synthesized number that is used to calc
                    ; days in each month.
weekdays: ["Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat"]



idiv: func [x y][to-integer ( divide x y) ]

comment {REBOL ought to include an integer divide function! }


comment { Th func 'dye calcs a Julian day no based on 1-1-0001, taking  
        into account years that are multiples of 4 are leap years 
        (Feb has 29 days instead of 28) unless they're multiples of
        100 years, but those *are* leap years if they're multiples of
        400.
            }

comment {dye is day number of last day of year y }

dye: func[y][  (y * 365) + (((idiv y 4) - (idiv y 100)) + (idiv y 400))] 


date-to-jul: func [date /local jul mo mox yr][
    jul:  date/day   + jul0
     yr: date/year 
     mo: date/month
     either mo > 2 [mox: mo + 1  ] [
        mox: mo + 13 yr: yr - 1 ]
     jul: jul + (dye yr) + (to-integer mox * daysinmo) 
]

jul-to-date: func [jl /local date da  mo yr dano][
    dano: jl - jul0
    dow: remainder (dano + 6) 7 ; Sunday = 0
    date: j2d jl
    da: date/day mo: date/month yr: date/year
    print [{date is  } to-date reduce[da mo yr]]
    print [{ day of week is }first skip weekdays dow]
]

j2d: func [ jl /local  dano yr mo da dow mox][
    dano: jl - jul0       
    yr: to-integer ((dano - 122.1)  / daysinyear) ; print yr
    mox: to-integer((dano - (to-integer(yr * daysinyear))) / daysinmo)
    da: dano - (to-integer(yr * daysinyear))
    da: da -  (to-integer (mox * daysinmo))
    either mox < 14 [mo: mox - 1][ mo: mox - 13]
    if mo < 3 [yr: yr + 1]
    return to-date reduce [da mo yr]
]

comment { jdye is JD of last day of year }

jdye: func [y][ date-to-jul (to-date reduce [31 12 y])]

comment {'diy yields the number of days in a year - useful for checking
        leap years. }

diy: func [y][(jdye y )- (jdye (y - 1))]

febdays: func[y]
    [(date-to-jul (to-date reduce[1 3 y])) - date-to-jul (to-date 
reduce[1 2 y])]

comment {'testj-d prints a calendar, 1 line per month for its argument,
         a year in format yyyy }

testj-d: func[yr /local strt-dt stjul dx da][
    strt-dt: to-date reduce [1 1 yr]
    stjul: date-to-jul strt-dt
    print {}
    for i 1 diy yr 1 [
        dx: j2d ( stjul + (i - 1))
        da: dx/day
        either da = 1 [
            prin [{^(line)} da {}]][
            prin [da {}]]
    ] 
    print ""
]





