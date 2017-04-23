REBOL [
    Title: "Time a Block"
    Date: 28-Oct-1998
    File: %timeblk.r
    Author: "Brian Casiello"
    Purpose: "Times the execution of a REBOL block."
    Comment: {
        Prints the elapsed time to execute the passed-in block.
        The /reps refinement specifies the number of times to
        execute the block.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

time-block: func [block /reps times] [
    if not reps [times: 1]
    start: now/time
    loop times [do :block]
    print now/time - start
]

example: [
    fib: func [x] [
        if (x < 2)[return x]
        return (fib x - 2) + (fib x - 1)
    ]
    time-block [fib 20]
    time-block/reps [fib 20] 5 
]

;do example     ; remove comment to run example