REBOL [
    Title: "Data Directions"
    Date: 9-May-1999
    File: %directions.r
    Purpose: {
        Illustrates the data descriptive capabilities of
        REBOL -- Gives the road directions to the REBOL office
        from San Francisco. Readable by humans and by REBOL.
    }
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

To-New-Office: [
    [take "Freeway 101" north]
    [go north 109 miles]
    [turn left at "Gobbi Street"]
    [go west .5 miles]
    [turn right at "State Street"]
    [go north .5 miles]
    [turn right at "301 S. State Street"]
    [park anywhere]
]
