REBOL [
    Title: "Library history - console version"
    Date: 12-Jul-2001/15:02:59+2:00
    Version: 0.1.1
    File: %lib-history.r
    Author: "Oldes"
    Usage: {
^-^-lib-history/by-day/update^-;to see todays scripts
^-^-lib-history/by-day/days 7 ^-;scripts in last 7 days (without reloading the log)
^-}
    Purpose: "To display recent Rebol library uploads"
    Comment: {to Carl: It would be better if we had the possibility to download only the info about the new scripts (specified by since-date and not to download all the scripts again - even the old one, if we want only todays changes (or new scripts in last hour):(}
    Email: oldes@bigfoot.com
    mail: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
lib-history: make object! [
    log-file: http://www.reboltech.com/library/add-script-log.txt
    history: []
    update-data: does [
        history: copy []
        if error? try [
            foreach line read/lines log-file [
                if not find/match line "%" [insert line "%"]
                if all [not error? try [line: load line] file? line/1 date? line/2] [
                      if not tuple? last line [append line 0.0.0.0]
                      insert history line
                ]
            ]
        ][print "Error while reading log-file!"]
    ]
    by-day: func[/days d [integer!] /update /local since scripts][
        if update [update-data]
        since: now - either days [d][0]
        scripts: copy []
        foreach [file date ip] history [
            if (date >= since/date) and (not found? find scripts file) [repend scripts [file date ip]]
        ]
        either empty? scripts [
            print reduce ["No new scripts since" since/date]
        ][
            print reduce [(length? scripts) / 3 "scripts since" since/date]
            print "========================================="
            foreach [file day ip] scripts [
                print reduce [file "^/^-^-\_uploaded from:" ip day]
            ]
        ]
    ]
]
