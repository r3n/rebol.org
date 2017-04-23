Rebol [
    Title: "Prime factors"
    Date: 20-Jul-2003
    File: %oneliner-prime-factors.r
    Purpose: {Defines a function, f, that returns a block of the prime factors of any integer up to
about 9'999'999'999'999'999 (after than decimal rounding starts to made things a bit
arbitrary) -- Example: f 777'666'555'666'777 Returns: [3 7 37 743 1347049607] -- Bugs: f 0
and f 2 are a bit dodgy.}
    One-liner-length: 132
    Version: 1.0.0
    Author: "Sunanda"
    Library: [
        level: 'beginner
        platform: 'all
        type: [How-to FAQ one-liner function]
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
f: func[n][m: 2 s: 1 w: :append a: copy[]until[either n // m = 0[n: n / m w a m][m: m + s s: 2]if 1. * m * m > n[w a n n: 1]n = 1]a]
