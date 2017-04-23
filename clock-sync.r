REBOL [
    title: "Windows clock sync"
    date: 28-feb-2009
    file: %clock-sync.r
    purpose: {
        Synchronize your Windows date and time with the clock on your
        web server.   The 4 line CGI script given at the end of this example
        prints out the current date and time on your web server, and this
        script reads it and sets the operating system clock to match it.
        (To do the same thing in Linux, see Ladislav Mecir's "set-system-time-lin"
        function at http://www.fm.tul.cz/~ladislav/rebol/nistclock.r).

        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

dif: 7:00  ; difference between web server and your local time zone
date: (to-date trim read http://yoursite.com/time.cgi) + dif

lib: load/library %kernel32.dll

set-clock: make routine! [
    systemtime    [struct! []]
    return:       [integer!]
] lib "SetSystemTime"

current: make struct! [
    wYear         [short]
    wMonth        [short]
    wDayOfWeek    [short]
    wDay          [short]
    wHour         [short]
    wMinute       [short]
    wSecond       [short]
    wMilliseconds [short]
] reduce [
    date/year
    date/month
    date/weekday
    date/day
    date/time/hour
    date/time/minute
    to-integer date/time/second
    0
]

set-clock current

free lib


{ 

; Here's the CGI script that the above code needs (to obtain the date and time from the web server).
; Put it at the URL which is read when the 'date word above is set:

#! /home/path/public_html/rebol/rebol -cs
REBOL [title: "time"]
print "content-type: text/html^/"
print now

}
