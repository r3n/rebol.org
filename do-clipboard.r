
REBOL [] 
use [file sandbox data target] [
    file: to-file read clipboard:// 
    make-dir/deep sandbox: clean-path %sandbox/ 
    either error? try [data: read/binary file] [
        alert "seems to be no filename on clipboard.."
    ] [
        target: join sandbox second split-path file 
        write/binary target data 
        secure [shell ask library ask file ask %sandbox/ allow] 
        do system/options/script: target 
        if not empty? system/view/screen-face/pane [do-events] 
        alert join form target " done."
    ]
]