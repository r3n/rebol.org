REBOL [
    Title: "Days until Christmas"
    Date: 25-Nov-2001/16:04:58
    Version: 1.0.0
    File: %days-till-christmas.r
    Author: "Izkata"
    Purpose: {Starting on Halloween, Tells how long till Christmas: Days, Hours, Minutes, Seconds}
    Email: Meyroy@DragonWarrior.every1.net
    library: [
        level: 'intermediate
        platform: 'all
        type: [Demo Tool]
        domain: 'math
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

xdate: "31-Oct-"
append xdate now/year
xdate: to-date xdate

if now/date < xdate [quit]

xdate: "25-Dec-"
append xdate now/year
xdate: to-date xdate
xtime: 06:00
If now/date < xdate [
    if now/time < 06:00 [
        print rejoin [xdate - now/date " Days Till Christmas!!!!!"]
        ]
    ]

If now/date < xdate [
    if now/time > 06:00 [
        xtime: 30:00
        print rejoin [xdate - now/date - 1 " Days and"]
        print rejoin [xtime - now/time " hours till Christmas!!!!!"]
        ]
    ]

wait 4
