Rebol [
    Title: "Prime factors"
    Date: 20-Jul-2003
    File: %oneliner-prime-factors.r
    Author: "Sunanda"
    ]

;; Defines a function, f, that returns a block of the prime factors of any integer.
;; -- Limits: above 9'999'999'999'999'999 decimal rounding starts to
;;   make things a little arbitrary
;; -- Example: f 777'666'555'666'777 Returns: [3 7 37 743 1347049607]
;; -- Bugs: f 0 and f 2 are a bit dodgy.

f: func[n][m: 2 s: 1 w: :append a: copy[]until[either n // m = 0[n: n / m w a m][m: m + s s: 2]if 1. * m * m > n[w a n n: 1]n = 1]a]
