REBOL [
    File: %collect.r
    Date: 10-Jan-2006	
    Author: "Gregg Irwin"
    Title: "Collect Function"
    Purpose: {Eliminate the "result: copy [] ... append result value" dance.}
    library: [
        level: 'intermediate
        platform: 'all
        type: [function dialect]
        domain: [dialects]
        tested-under: [View 1.3.2 on WinXP by Gregg "And under a lot of other versions and products"]
        license: 'BSD
        support: none
    ]
]

    collect: func [  ; a.k.a. gather ?
        [throw]
        {Collects block evaluations.}
        'word "Word to collect (as a set-word! in the block)"
        block [any-block!] "Block to evaluate"
        /into dest [series!] "Where to append results"
        /only "Insert series results as series"
        ;/debug
        /local code marker at-marker? marker* mark replace-marker rules
    ] [
        block: copy/deep block
        dest: any [dest make block! []]
        ; "not only" forces the result to logic!, for use with PICK.
        ; insert+tail pays off here over append.
        ;code: reduce [pick [insert insert/only] not only 'tail 'dest]
        ; FIRST BACK allows pass-thru assignment of value. Speed hit though.
        ;code: reduce ['first 'back pick [insert insert/only] not only 'tail 'dest]
        code: compose [first back (pick [insert insert/only] not only) tail dest]
        marker: to set-word! word
        at-marker?: does [mark/1 = marker]
        ; We have to use change/part since we want to replace only one
        ; item (the marker), but our code is more than one item long.
        replace-marker: does [change/part mark code 1]
        ;if debug [probe code probe marker]
        marker*: [mark: set-word! (if at-marker? [replace-marker])]
        parse block rules: [any [marker* | into rules | skip]]
        ;if debug [probe block]
        do block
        head :dest
    ]

    ;  Examples
    comment {
        ;collect/debug zz [repeat n 10 [zz: n * 100]]
        collect zz []
        collect zz [repeat i 10 [if (zz: i) >= 3 [break]]]
        collect zz [repeat i 10 [zz: i  if i >= 3 [break]]]
        collect zz [repeat i 10 [either i <= 3 [zz: i][break]]]
        dest: copy []
        collect/into zz [repeat n 10 [zz: n * 100]] dest
        collect zz [for i 1 10 2 [zz: i * 10]]
        collect zz [for x 1 10 1 [zz: x]]
        collect zz [foreach [a b] [1 2 3 4] [zz: a + b]]
        collect zz [foreach w [a b c d] [zz: w]]
        collect zz [repeat e [a b c %.txt] [zz: file? e]]
        iota: func [n [integer!]][collect zz [repeat i n [zz: i]]]
        iota 10
        collect zz [foreach x first system [zz: to-set-word x]]
        x: first system
        collect zz [forall x [zz: length? x]]
        x: first system
        collect zz [forskip x 2 [zz: length? x]]
        collect zz [forskip x 2 [zz: (length? x) / 0]]
        collect/only zz [foreach [a b] [1 2 3 4] [zz: a zz: b zz: reduce [a b a + b]]]
        collect/only zz [
            foreach [a b] [1 2 3 4] [
                zz: a zz: b zz: reduce [a b a + b]
                foreach n reduce [a b a + b] [zz: n * 10]
            ]
        ]

        dest: copy ""
        collect/into zz [repeat n 10 [zz: n * 100 zz: " "]] dest

        dest: copy []
        collect/into zz [
            foreach [num blk] [1 [a b c] 2 [d e f] 3 [g h i]] [
                zz: num
                collect/only/into yy [
                    zz: blk
                    foreach word blk [zz: yy: num  yy: word]
                    yy: blk
                ] dest
            ]
        ] dest

    }
