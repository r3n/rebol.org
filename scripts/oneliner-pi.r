Rebol [
    Title: "Calculate Pi"
    Date: 20-Jul-2003
    File: %oneliner-pi.r
    Purpose: {Approximate PI with John Wallis formula.
Precision limited to 15 digits due to REBOL. Just press ESC when fed up ;-)
Formula from http:// www.chez.com/algor/math/pi.htm}
    One-liner-length: 83
    Version: 1.0.0
    Author: "Jean-Nicolas Merville"
    Library: [
        level: 'beginner
        platform: none
        type: [How-to FAQ one-liner]
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
rebol[] s: 1 i: 0 forever [i: i + 2 s: s * (i / (i - 1) * i / (i + 1)) print 2 * S]
