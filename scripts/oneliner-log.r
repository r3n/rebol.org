Rebol [
    Title: "Write a log file"
    Date: 20-Jul-2003
    File: %oneliner-log.r
    Purpose: {Logs Rebol values to a file named %Log.txt. I use 'Log to help debug CGI scripts.
Use 'Log like:
Log/clear now ; Start a new log file.
; What's the CGI query string contents?
Log Rebol/options/cgi/query-string}
    One-liner-length: 113
    Version: 1.0.0
    Author: "Andrew Martin"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner function]
        domain: [file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
Log: func [Value /Clear][if Clear[delete %Log.txt]write/append/lines %Log.txt reform[now/time mold :Value]:Value]
