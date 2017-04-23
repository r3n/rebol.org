REBOL [
    title: "Number Verbalizer"
    date: 13-Mar-2010
    file: %number-verbalizer.r
    author:  Nick Antonaccio
    purpose: {
        Converts number values to their spoken English equivalent.
        (i.e., 23482194 = "Twenty Three million, Four Hundred Eighty
        Two thousand, One Hundred Ninety Four").  This code was
        created for a check writing application, but is perhaps
        useful elsewhere.  The algorithm was partially derived from
        the article at http://www.blackwasp.co.uk/NumberToWords.aspx
        (C# code).
        Taken from the tutorial at http://re-bol.com.
    }
] 

verbalize: func [a-number] [
    if error? try [a-number: to-decimal a-number] [
        return "** Error **  Input must be a decimal value"
    ]
    if a-number = 0 [return "Zero"]
    the-original-number: round/down a-number
    pennies: a-number - the-original-number
    the-number: the-original-number
    if a-number < 1 [
        return join to-integer ((round/to pennies .01) * 100) "/100"
    ] 
    small-numbers: [
        "One" "Two" "Three" "Four" "Five" "Six" "Seven" "Eight"
        "Nine" "Ten" "Eleven" "Twelve" "Thirteen" "Fourteen" "Fifteen"
        "Sixteen" "Seventeen" "Eighteen" "Nineteen"
    ]
    tens-block: [
        { } "Twenty" "Thirty" "Forty" "Fifty" "Sixty" "Seventy" "Eighty"
        "Ninety"
    ]
    big-numbers-block: ["Thousand" "Million" "Billion"]
    
    digit-groups: copy []
    for i 0 4 1 [
        append digit-groups (round/floor (mod the-number 1000))
        the-number: the-number / 1000
    ]    
    spoken: copy ""
    for i 5 1 -1 [
        flag: false
        hundreds: (pick digit-groups i) / 100
        tens-units: mod (pick digit-groups i) 100
        if hundreds <> 0 [
            if none <> hundreds-portion: (pick small-numbers hundreds) [
                append spoken join hundreds-portion " Hundred "
            ]
            flag: true
        ]
        tens: tens-units / 10
        units: mod tens-units 10
        if tens >= 2 [
            append spoken (pick tens-block tens)
            if units <> 0 [
                if none <> last-portion: (pick small-numbers units) [
                    append spoken rejoin [" " last-portion " "]
                ]
                flag: true
            ]
        ]
        if tens-units <> 0 [
            if none <> tens-portion: (pick small-numbers tens-units) [
                append spoken join tens-portion " "
            ]
            flag: true
        ]
        if flag = true [
            commas: copy {}    
            case [
                ((i = 4) and (the-original-number > 999999999)) [
                    commas: {billion, }
                ]
                ((i = 3) and (the-original-number > 999999)) [
                    commas: {million, }
                ]
                ((i = 2) and (the-original-number > 999)) [
                    commas: {thousand, }
                ]
            ]
            append spoken commas
        ]
    ]
    append spoken rejoin [
        "and " to-integer ((round/to pennies .01) * 100) "/100"
     ]
    return spoken
]

; HERE'S AN EXAMPLE:

print verbalize ask "Enter a number to verbalize: "
halt