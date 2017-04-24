REBOL [
    Title: "Data formatter"
    Date: 20-Jul-1999
    File: %align.r
    Author: "Bohdan Lechnowsky"
    Purpose: "Create text columns"
    Comment: {
        this function will form any data passed to it and will force
        it into the specified number of columns with optional
        alignment (left alignment is the default).  
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'function 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

align: func [
    "Forms data into a specified number of columns with optional alignment"
    data length /left /right /center /len
][
    if right [
        return head copy/part 
            tail insert/dup head form data " " length 
            (length * -1)
    ]
    if center [
        data: head insert/dup head form data " " len: (length / 2)
        data: head insert/dup tail data " " len
        return copy/part at data ((length? data) / 2 - len + 1) length
    ]
    return copy/part head insert/dup tail form data " " length length
]
