Rebol [
    Title: "Save console history"
    Date: 20-Jul-2003
    File: %oneliner-save-console-history.r
    Purpose: {Takes the history of input into the console and prints it out, line by line, to a file.
This way you can paste in functions and whole scripts, and save them for viewing and
editing. Sorts it to display the oldest commands at the top.}
    One-liner-length: 59
    Version: 1.0.0
    Author: "Saw it on the ML a while ago"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
write/lines %hist.r head reverse copy rebol/console/history
