REBOL [
    Title: "Print-Hex" 
    Author: "Vincent Ecuyer" 
    Date: 1-Feb-2013 
    Version: 1.0.0 
    File: %print-hex.r 
    Purpose: {Displays binary data both in hexadecimal and filtered ASCII.} 
    Usage: {
        Like the AmigaDOS command "TYPE HEX NUMBER", this function shows binary
        data with numbered rows of 16 bytes, followed by their ASCII equivalent.
        
        Only the non-control pure ASCII values are printed (32 to 126), others 
        are displayed as a single dot "."
        
        It's mainly useful as a debugging tool or to examine unknown data, with
        cues like magic numbers or ids easily spottable.
        
        For convenience, it pauses every 16 lines, waiting for either a quit
        command ('q', 'quit', 'x', 'exit'), or a newline to continue. The 
        refinement /no-wait disables this behavior.
        
        Syntax:
        
        print-hex data /no-wait
        
        data : source to examine (file! url! binary! string! port!)
        /no-wait : doesn't stop until the end or a <ctrl>-c 
        
        When launched from the command line, this script accepts a file argument:
        
        $ r3 print-hex.r path/to/my/file
        
        (the script name must not be altered or must be changed too in the 
        "if %print-hex.r =" statement for this to work)
    }
    Library: [
        level: 'intermediate 
        platform: 'all 
        type: [tool function] 
        domain: [debug text text-processing] 
        tested-under: [ 
            view 2.7.8.2.5 on [Macintosh osx-x86] 
            core 2.101.0.2.5 on [Macintosh osx-x86] 
        ] 
        support: none 
        license: 'apache-v2.0 
        see-also: none 
    ]
]

print-hex: func [
    {Displays binary data both in hexadecimal and filtered ASCII.
     It pauses every 256 bytes: press enter to continue, or type q/quit/x/exit
     to stop.}
    data [file! url! binary! string! port!] "Data to display."
    /no-wait "Doesn't wait for user input."
    /local
    line binary-chars string-chars part
    index direct try-copy end print-line
][
    if string? data [data: to-binary data]
    
    either any [file? data url? data][
        either system/version > 2.100.0 [
            data: open data
        ][
            data: open/direct/binary data
        ]
        direct: true
        end: [
            if not empty? line [
                insert/dup tail line #" " 36 - length? line
                do print-line
            ]
            close data return none
        ]
    ][
        direct: all [
            port? data
            not zero? data/state/flags and system/standard/ports-flags
        ]
        end: [
            if not empty? line [
                insert/dup tail line #" " 36 - length? line
                do print-line
            ]
            return none
        ]
    ]
    
    try-copy: func [value] either port? data [[
        either all [value: copy/part value 4 empty? value][none][value]
    ]][[
        either tail? value [none][copy/part value 4]
    ]]
    
    print-line: [
        forall binary-chars [
            append string-chars either any [
                binary-chars/1 < 32
                binary-chars/1 >= 127
            ][#"."][to-char binary-chars/1]
        ]
        print [at tail mold to-hex index -8 ":" line string-chars]
    ]
    
    index: -1 + index? data
    line: copy ""
    binary-chars: copy #{}
    string-chars: copy ""
    
    forever [
        loop 16 [
            loop 4 [
                if none? part: try-copy data end
                append binary-chars part
                append line enbase/base part 16
                append line " "
                if not direct [data: skip data 4]
            ]
            do print-line

            index: index + 16
            clear line
            clear binary-chars
            clear string-chars
        ]
        if all [not no-wait find ["q" "x" "quit" "exit"] lowercase trim input] end
    ]
]

if %print-hex.r = system/options/script [
    print-hex to-rebol-file system/script/args
    quit
]
