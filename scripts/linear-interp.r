REBOL [
    Library: [
        level: 'beginner
        platform: 'all
        type: 'tool
        domain: [math scientific]
        tested-under: none
        support: none
        license: 'lgpl
        see-also: none
    ]
    Title: "linear-interp"
    Description: "Linearly interpolate between two numbers"
    Date: 2006-11-08
    Version: 0.0.1
    Author: "Glenn M. Lewis"
    File: %linear-interp.r
    Purpose: {Linearly interpolate between two numbers}
    License: "GNU Lesser General Public License (Version 2.1)"
    Comment: {Makes it easy to transform a source from/to pair to a destination from/to pair}
]

linterp: func [
    "Linearly interpolates from start to end, given an input from 0..1."
    val [decimal!] "Val must run from 0..1"
    start [number!] "When val==0.0, output==start"
    end [number!] "When val==1.0, output==end"
] [
    ((1.0 - val) * start) + (val * end)
]

linear-interp: func [
    "Linearly interpolates from outStart to outEnd, given an input from inStart to inEnd."
    val [number!] "Val must run from inStart to inEnd"
    inStart [number!] "When val==inStart, output==outStart"
    inEnd [number!] "When val==inEnd, output==outEnd"
    outStart [number!] "When val==inStart, output==outStart"
    outEnd [number!] "When val==inEnd, output==outEnd"
    /local diff newval
] [
    if (inStart == inEnd) [ return 0.0 ]
    diff: to-decimal (inEnd - inStart)
    newval: ((val - inStart) / diff)
    linterp newval outStart outEnd
]
