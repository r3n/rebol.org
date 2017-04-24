REBOL [
    Title: "Rebol date to-timestamp"
    Date: 18-Jul-2001/11:05:22+2:00
    Version: 0.0.3
    File: %to-timestamp.r
    Author: "Oldes"
    Purpose: "For better date storage (in large date databases)"
    Email: oldes@bigfoot.com
    mail: oldes@bigfoot.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
to-timestamp: func[
    {Returns date converted to TIMESTAMP integer (YYYYMMDDHHMMSS)}
    d [date!]   "Date to convert"
    /dateonly   {Returns only date: YYYYMMDD}
    /local pad
][
    pad: func[s][either s < 10 [join "0" s][s]]
    to-integer rejoin [
        d/year
        pad d/month
        pad d/day
        either dateonly [""][
            rejoin [
                pad d/time/hour
                pad d/time/minute
                pad d/time/second
            ]
        ]
    ]
]
                               