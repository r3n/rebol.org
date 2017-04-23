REBOL [
    Title: "ConsoleIO"
    Date: 1-Aug-2002
    Version: 1.0.0
    File: %consoleio.r
    Author: "Norman Deppenbroek"
    Purpose: {Console prompt output save,saves
all console input to history.log file when in console mode.}
    Email: rebolinth@nodep.dds.nl
    library: [
        level: [beginner intermediate advanced] 
        platform: none 
        type: [tool tutorial] 
        domain: [x-file file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

set-console: func ['word value] [ set in system/console word value ]
set-console: rejoin [ echo %history.log ] ">>"

; turn console saving off use:  set-console: rejoin [ echo none ] ">>"
               