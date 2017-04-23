REBOL [
    Title: "Black Scholes Option Price"
    Date: 11-Nov-2001
    Version: 0.1.1
    File: %black-scholes.r
    Author: "Matt Licholai"
    Rights: "(C)Matt Licholai 2001 "
    Usage: { black-scholes/put $42.0 $40.0 .5 .1 .2
^-^-to compute the put price of an option where the strike is $40
^-^-the current underlying is at $42 there are 6 months till
        expiration, the risk free interest rate is 10% per annum
        and the volatility of the underlying is 20% per annum.}
    Purpose: {Provide a Rebol function for computing the Black-Scholes (1973) formula for determining an European style Option Price.}
    Comment: {Written for clarity and following Espen Gaarder Haug's
              Black-Scholes notation. See
              http://home.online.no/~espehaug/SayBlackScholes.html
              for other interesting versions.}
    History: [0.1 [{Initial version using parens and multiple assignment
                   lines for clarity}] 
        0.1.1 [{Changed assignments of constants to use set block
                syntax sugar}]
    ]
    Email: M.S.Licholai@ieee.org
    library: [
        level: 'intermediate 
        platform: none 
        type: 'module 
        domain: [financial math] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

cum-normal-dist: func [ 
    {Calculate the cumulative normal distribution using a fifth order polynomial approximation.}
    x [number!] 
    /local
    K L a a1 a2 a3 a4 a5 w1 w
][
    L: abs x

    set [a a1 a2 a3 a4 a5] [0.2316419 0.31938153 (- 0.356563782) 1.781477937 (- 1.821255978) 1.330274429]
    
    K: 1 / (1 + (a * L))
    
    w1: (K * a1) + (a2 * (K ** 2)) + (a3 * (K ** 3)) + (a4 * (K ** 4)) + (a5 * (K ** 5))
    w: 1 - ((w1 / square-root (2 * pi)) * exp (- (L * L) / 2))
    
    if negative? x [return 1 - w]
    return w
]


black-scholes: func [
    {Calculate the Black Scholes (1973) stock option pricing formula}
    s [money!] "actual stock price"
    x [money!] "strike price"
    t [number!] "years to maturity"
    r [number!] "risk free interest rate"
    v [number!] "volatility"
    /call "call option (default)"
    /put "put option"
    /local
    d1 d2
][
    d1: (log-e (s / x) + ((r + ((v ** 2) / 2)) * T)) / ( v * square-root t)
    d2: d1 - ( v * square-root t)

    either (not put) [
        (s * cum-normal-dist d1) - ((x * exp (- r * t)) * cum-normal-dist d2)
    ][
        ((x * exp (- r * t)) * cum-normal-dist negate d2) - (s * cum-normal-dist - d1)
    ]
]








                                                                           