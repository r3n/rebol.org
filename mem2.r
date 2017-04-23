REBOL [
    Title: "Mem-Usage - a set of routines to test memory usage"
    Date: 9-Oct-2001
    Version: 0.0.2
    File: %mem2.r
    Author: "Romano Paolo Tenca"
    Purpose: {Functions to test memory usage}
Notes: {
pool: "Return the total of used memory in the allocated pool"
mem-free: "Return the total of free memory in the allocated pool"
mem-ld: return memory usage of "load string"
mem-tb: return memory usage of "to-block string"
mem-do: return memory usage of "do load string"
mem-all: call mem-ld and mem-do and return the difference
mem-func: memory usage of loading and creating a function

Examples:
^-a: 1
^-mem-all ""^-^-^-; memory usage of a empty block
^-mem-all "a"^-^-^-; memory usage of a block with a word
^-mem-all "func [][]"^-; memory usage of a new void func
^-mem-all "make object! []"^-; memory usage of a void object
^-mem-all %prova.r^-; memory usage of executing a rebol program
^-mem-do "help 4"     ; memory usage of executing some code
^-mem-func :help^-    ; memory usage of re-loading and re-creating a function
^-print pool^-^-^-; memory used
^-print mem-free^-^-; memory free
}
    History: [
    0.0.2 "First public release"
]
    Email: rotenca@libero.it
    library: [
        level: 'intermediate 
        platform: [] 
        type: [] 
        domain: [debug] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
pool: has ["Return the total of used memory in the allocated pool"][
    tot-used: 0
    foreach y system/stats/pools [
        if 1 <> first y [
             tot-used: y/2 - y/3 * y/1 + tot-used
        ]
    ]
    tot-used
]
mem-free: has ["Return the total free memory in the allocated pool"] [system/stats - pool]
;funzione per stabilire il valore da sottrarre
init-mem: func [code /local old new ret][
    recycle
    old: pool
    new: pool
    print ["Pool usage:" ret: new - old]
    ret
]
mem-tb: func [{Return memory usage of "to-block string"} code [string! file!] /local old new ret][
    recycle
    old: pool
    to-block code
    new: pool
    print ["To block  :" ret: new - old - pool-usg]
    ret
]
mem-ld: func [{Return memory usage of "load string"} code [string! file!] /local old new ret][
    recycle
    old: pool
    load code
    new: pool
    print ["Load      :" ret: new - old - pool-usg]
    ret
]
mem-do: func [{Return memory usage of "do load string"} code [string! file!] /local old new ret][
    recycle
    old: pool
    do load code
    new: pool
    print ["Execute   :" ret: new - old - pool-usg]
    ret
]
mem-func: func [{Return difference between "load a function" and "load and create a function"} code [function!]][
    - (mem-ld mold :code) + (mem-do mold :code)
]
mem-all:  func [{Return difference between "load string" and "do load string"} code [string! file!]][
    - (mem-ld :code) + (mem-do :code)
]

;example
pool-usg: init-mem ""
mem-ld ""
mem-do ""
mem-all ""
;change 'comment in 'do to try all examples
comment [
    a: 1
    mem-all ""          ; memory usage of a empty block
    mem-all "a"         ; memory usage of a block with a word
    mem-all "func [][]" ; memory usage of a new void func
    mem-all "make object! []"   ; memory usage of a void object
    ;mem-all %prova.r   ; memory usage of a rebol program
    mem-do "help 4"     ; memory usage of using a function
    mem-func :help      ; memory usage of re-loading and re-creating a function
    print pool          ; memory used
    print mem-free      ; memory free
    recycle
    print pool          ; memory used after recycle
    print mem-free      ; memory free after recycle
]
print system/script/header/Purpose
ask "See the source for examples - Return to Quit - Esc for Shell "
                                                                                                          