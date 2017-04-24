REBOL [
    Title: "Prime number checker"
    Date: 21-Jul-1999
    Version: 0.0.2
    File: %prime.r
    Home: http://www.cs.uoregon.edu/~tomc
    Author: "Tom Conlin"
    Owner: "Intuitec"
    Rights: "yes"
    Tabs: 4
    Purpose: {
       Address the question, could this integer be a prime number?
       results of false are not prime, 
       results of true are very probably prime 
       and with the /strong refinement, ( I still have to verify this )
       true ( should ) guarantee prime.

       if the argument is outside the domain of the function,
       none is returned 
   }
    Comment: {
       Able to handle integers up to one bit less than the machine (or rebol) 
       is using  for a ( signed? ) integer, this may vary -- but 30 bits probabaly.
   
       If you use the xxx-modulus functions elsewhere (they were kept general), 
       be sure to keep "m" non-zero

       The /strong refinement is yet to be formaly proven (by me) to garantee primes.
   }
    History: [
    0.0.1 [19-Jul-1999 {typed (2 ** (n - 1 )) // n  at the prompt, for n > 1024 }] 
    0.0.2 [21-Jul-1999 "dug out old homework"]
]
    Language: 'English
    Email: tomc@cs.uoregon.edu
    Need: 0.2.1
    Charset: 'ANSI
    Example: "is-prime? 1073741789"
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

is-prime?: func ["return false if argument is composite, and none if can't tell"  
    n [integer!]
    /strong 
    /local b e p z 
][ 
    if n < 2  [return false]  ; no negatives  
    if any [error? try [z: n + n] z < n][return none] 

    e: n - 1
    p: power-modulus  2 e  n
    if strong [
        b: 3
        z:  to-integer (log-2 n  + 1 )
        while [ (p == 1) and (b < z) ][
            p: power-modulus  b e n
            b: b + 1
        ]
    ]
    p == 1
]
comment { 
    an efficent recursive power function, will recurse only the number
    of (significant) bits in the exponent, squareing the base at each
    level but only accumulating the base if the least significant bit
    of the exponent at that level is set.  note: just forwards the
    modulus to the multiply function.  
}

power-modulus: func [ "b to the e power, mod m"   
    b [integer!]  "base" 
    e [integer!]  "exponent"
    m [integer!]  "modulus"
    /local t 
][    
    if  e == 0  [return 1]
    t: power-modulus (multiply-modulus b b m ) to-integer(e / 2) m 
    if odd? e  [ t: multiply-modulus t b m ]  
    t
]

comment { 
    a multiply which if need be, 
    guarantees the product is never more than 
    one bit longer than the modulus
}

multiply-modulus: func[ "j times k, mod m"
    j [integer!]   
    k [integer!]   
    m [integer!]   "modulus"
    /local product
][ 
    if error? try [ product: j * k // m ] [
        product: 0
        while[ k > 0 ][
            if(odd? k )
                [ product: to-integer( product + j ) // m ]
            j:  j + j // m 
            k:  to-integer k / 2
        ]
    ]
    to-integer product
]
