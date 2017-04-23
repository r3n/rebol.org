REBOL [
    title: "Remove Type"
    date: 10-Feb-2014
    file: %remove-type.r
    author:  Nick Antonaccio
    purpose: {
        Removes all values of a given type from a list, or from nested lists any
        number of levels deep.
    }
]
remove-type: func [lst my-type] [ 
     foreach item lst [ 
         if block! = (type? item) [remove-type item my-type] 
         repeat i (length? lst) [if my-type = type? pick lst i [remove at lst i]] 
     ]     
] 
x: [
    12 "ads" 343 "sodf" $12.23 [
        123 4343 "sdadfdf" "idsf" 2-feb-2014 [
            "asdafdf" "sduf" 25 23
        ] [
            "oiwsjdf" 23 "sdfw"
        ]
    ]
] 
y: copy/deep x 
z: copy/deep x 
remove-type y string! 
remove-type z integer! 
probe y 
probe z 
halt