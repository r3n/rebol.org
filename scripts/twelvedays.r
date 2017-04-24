REBOL [
    Title: "Twelve Days of Christmas"
    Date: 14-Dec-1999
    File: %twelvedays.r
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Game 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
    Purpose: "Twelve Days of Christmas"
]

Twelve_Days: make object! [
    Sing: function [] [Gift Christmas_Days] [
        Gift: function [Day [integer!]] [Gifts Gift] [
            Gifts: [
                "a partridge in a pear tree"
                "two turtle doves"
                "three french hens"
                "four calling birds"
                "five golden rings"
                "six geese a-laying"
                "seven swans a-swimming"
                "eight maids a-milking"
                "nine ladies dancing"
                "ten lords a-leaping"
                "eleven pipers piping"
                "twelve drummers drumming"
                ]
            Gift: make string! 100
            until [
                append Gift rejoin [
                    Gifts/:Day
                    either 1 < Day [","] ["."]
                    either 2 = Day [" and"] [{}]
                    newline
                    ]
                Day: Day - 1
                Day < 1
                ]
            Gift
            ]
        Christmas_Days: [
            "first"
            "second"
            "third"
            "fourth"
            "fifth"
            "sixth"
            "seventh"
            "eighth"
            "ninth"
            "tenth"
            "eleventh"
            "twelfth"
            ]
        repeat Day length? Christmas_Days [
            print rejoin [
                "On the " Christmas_Days/:Day " day of Christmas,"
                newline
                "my true love gave to me:"
                newline
                Gift Day
                ]
            ]
        print "Merry Christmas and a Happy New Year!"
        ]
    ]

Twelve_Days/Sing
