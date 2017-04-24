rebol [
    title:   "Engroup"
    file:    %engroup.r

    version: 0.2
    date:    12-4-2009

    author: "Christian Ensel"

    purpose: "Mezzanine function to arrange values into groups of all equal values."

    comment: {
        What's with the superfluous WORD! argument in the simple envocation?
        Having to use a word here is really pointless, compare

        >> engroup i [1 1 2 2 2 3 4 4 4 4 5 6 7 7]
        == [[1 1] [2 2 2] [3] [4 4 4 4] [5] [6] [7 7]]

        vs.

        >> engroup [1 1 2 2 2 3 4 4 4 4 5 6 7 7]
        == [[1 1] [2 2 2] [3] [4 4 4 4] [5] [6] [7 7]]

        For now, I'm going with the WORD! argument, anyway.
    }

    usage: {
        Simple usage of ENGROUP arranges values into groups of values all equal:

        >> engroup i [1 1 2 2 2 3 4 4 4 4 5 6 7 7]
        == [[1 1] [2 2 2] [3] [4 4 4 4] [5] [6] [7 7]]

        The /OVER refinement specifies over wich value such groups are build.
        This is particular useful when dealing with objects.

        Compare the different grouping in the following examples:

        >> engroup i [#1 #11 #12 #2 #31 #32 #4 #41 #411 #412 #42 #43]
        == [[#1] [#11] [#12] [#2] [#31] [#32] [#4] [#41] [#411] [#412] [#42] [#43]]
        >> engroup/over i [#1 #11 #12 #2 #31 #32 #4 #41 #411 #412 #42 #43] [first i]
        == [[#1 #11 #12] [#2] [#31 #32] [#4 #41 #411 #412 #42 #43]]

        By default, ENGROUP ignores include NONE values.
        But beware, NONE values by design still have an group separating effect:

        >> engroup i reduce [1 1 2 none 2 3 3]
        == [[1 1] [2] [2] [3 3]]

        If by /OVER-ing NONE values are introduced, the by default
        will be ignored, too:

        >> engroup/over i [1 1 2 2 2 2 3 4 4 4 5 5 5] [if odd? i [i]]
        == [[1 1] [3] [5 5 5]]

        Use /ANY to include NONE values:

        >> engroup/any i reduce [1 1 2 2 2 3 none none none none 5 6 7 7]
        == [[1 1] [2 2 2] [3] [none none none none] [5] [6] [7 7]]

        Use /ONLY to group block values as blocks:

        >> engroup i [[1] [1] [2] [2]]
        == [[1 1] [2 2]]
        >> engroup/only i [[1] [1] [2] [2]]
        == [[[1] [1]] [[2] [2]]]

        For convenience, the /AS refinement allows to modify the value "in place".

        >> engroup/as/over i [#1 #1.1 #1.2 #2 #3.1 #3.2 #4 #4.1 #4.1.1 #4.1.2 #4.2 #4.3] [join "" [<item> i </item>]] [first i]
        == [["<item>1</item>" "<item>1.1</item>" "<item>1.2</item>"] ["<item>2</item>"] ["<item>3.1</item>" "<item>3.2</item>"] ["<item>4</...

        But beware, different input values that are equal after modification still
        will belong to different groups (grouping is applied after /OVER but
        before /AS, so to say):

        >> engroup/as i [1 2 3] [max i 4]
        == [[4] [4] [4]]
        >> engroup/over i [1 2 3 4] [round/to i 2]
        == [[1 2] [3 4]]
        >> engroup/over/as i [1 2 3 4] [round/to i 2] [round/to i 2]
        ==  [[2 2] [4 4]]

        Use /ALL to include NONE values introduced by /AS modifications (usually
        these are not part of the resulting groups):

        >> engroup/as i reduce [1 2 2 3 3 3 4 4 4 4] [all [even? i i]]
        == [[2 2] [4 4 4 4]]
        >> engroup/all/as i reduce [1 2 2 3 3 3 4 4 4 4] [all [even? i i]]
        == [[none] [2 2] [none none none] [4 4 4 4]]
    }

    library: [
        level:          'intermediate
        Platform:       'all
        type:           [function idiom]
        code:           'function
        domain:         'dialects
        license:        'public-domain
        support:        none
        see-also:       none
        tested-under:   [view 2.7.6.3.1 on [WinXP] "CHE"]
    ]
]

engroup: func [
    "Arranges values into groups of all equal values."
    'word    [word!]   "Variable to hold current value"
    data     [series!] "The series to traverse"
    /over    input  [block!] "Value to compare"
    /as      output [block!] "Modify values before grouping"
    /any     "Build groups over NONE values, too."
    /all     "Don't exclude NONE values from groups."
    /only    "Group block values as blocks."
    /into    collector "Where to collect results"
    /local   any* all* do-input value do-output group groups val args prev
][
    any*: any any: get in system/words 'any
    all*: all all: get in system/words 'all

    do-input:  func reduce [[throw] word] any [input  reduce [word]]
    do-output: func reduce [[throw] word] any [output reduce [word]]

    groups: any [all [into collector] copy []]

    until [
        group: copy [] args: 0 prev: none

        foreach input data [
            value: do-input input

            either all [args > 0 previous <> value] [break] [
                args: args + 1
                previous: value
                output: do-output input
                if all [
                    any [any* value]
                    any [all* output]
                ][
                    either only [append/only group output] [append group output]
                ]
            ]
        ]

        unless empty? group [append/only groups group]

        tail? data: skip data args
    ]

    groups
]
