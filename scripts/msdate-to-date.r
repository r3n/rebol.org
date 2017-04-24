REBOL [
    Title: "msdate-to-date"
    Date: 3-Dec-2001/13:11:09+1:00
    Version: 0.1.0
    File: %msdate-to-date.r
    Author: "Oldes"
    Usage: "msdate-to-date #{27A6822B}"
    Purpose: {Converts standard MS DOS binary time to Rebol's one}
    Email: oliva.david@seznam.cz
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

msdate-to-date: func[
    "Converts standard MS DOS binary time to Rebol's"
    ms [binary! string!] "4bytes of MS DOS binary time"
    /local to-int y m d h mi s
][
    ms: enbase/base head reverse ms 2
    to-int: func[v][
        insert/dup v "0" 8 - length? v
        to-integer debase/base head v 2
    ]
    parse ms [
        copy y 7 skip  (y: 1980 + to-int y)
        copy m 4 skip  (m: to-int m)
        copy d 5 skip  (d: to-int d)
        copy h 5 skip  (h: to-int h)
        copy mi 6 skip (mi: to-int mi)
        copy s 5 skip  (s: 2 * to-int s)
    ]
    to-date rejoin [d "-" m "-" y "/" h ":" mi ":" s]
]                               