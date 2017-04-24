REBOL [
    Title: "HOF"
    Date: 16-Nov-2002
    Name: "HOF"
    Version: 1.0.1
    File: %hof.r
    Author: "Jan Skibinski"
    Needs: []
    Purpose: "Higher Order Functions and series manipulators"
    Email: jan.skibinski@sympatico.ca
    Acknowledgments: {
        Version 1.0.0 - The basic set of HOF functions
    }
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

comment {
    This collection of Higher Order Functions and
    series manipulators mirrors a small subset
    of functions found in the Haskell modules Prelude
    and List.

    I did not however strive to provide the same
    implementation; in contrary, I tried to take
    advantage of Rebol facilities for efficiency reasons.
    While most of the Haskell functions are recursive
    in nature, their Rebol counterparts use imperative
    looping instead.

    However, the spirit of the original design is
    preserved stressing the importance of reusable
    patterns.
    While some of the functions provided here can be
    easily implemented in some alternate ways, other
    functions do not have obvious counterparts in the
    Rebol Core. I hope you will find them useful.

    In addition, I provide alternative implementations
    of several basic Rebol functions, such as OR', AND',
    ANY' and ALL'. The first two are lazy block replacements
    for OR and AND - quite useful in WHILE clauses.
    The other two, based on predicates (a -+ logic)
    are very convenient for scanning the series.

    The following is a list of all the functions provided
    here, with their corresponding patterns. The list
    has been created by a 'summary function from unpublished
    yet version of script %signature.r - a prototype
    type checker for Rebol. Among other things, I use this
    module to test the type checker itself.


------------------------------------------------------------
SUMMARY of script HOF.R
------------------------------------------------------------
.                    ([number] -+ [number] -+ number)
..                   ([ord] -+ [ord])
all'                 ((a -+ logic) -+ [a] -+ logic)
and'                 ([logic] -+ logic)
any'                 ((a -+ logic) -+ [a] -+ logic)
cat                  ([[a]] -+ [a])
cycle                (integer -+ [a] -+ [a])
drop                 (integer -+ [a] -+ [a])
drop-while           ((a -+ logic) -+ [a] -+ [a])
elem                 (series -+ any-type -+ logic)
ensure               ([[logic]] -+ logic)
filter               ((a -+ logic) -+ [a] -+ [a])
foldl                ((a -+ b -+ a) -+ a -+ [b] -+ a)
foldl-2              ((a -+ b -+ c -+ a) -+ a -+ [b] -+ [c] -+ a)
foldl1               ((a -+ a -+ a) -+ [a] -+ a)
foldr                ((a -+ b -+ b) -+ b -+ [a] -+ b)
implies              (logic -+ logic -+ logic)
inner-2              (([a] -+ [b] -+ c) -+ [[a]] -+ [[b]] -+ [[c]])
insert-by            ((a -+ a -+ logic) -+ a -+ [a] -+ [a])
iterate              (integer -+ (a -+ a) -+ a -+ [a])
map                  ((a -+ b) -+ [a] -+ [b])
map-2                ((a -+ b -+ c) -+ [a] -+ [b] -+ [c])
max-block            ([ord] -+ ord)
min-block            ([ord] -+ ord)
or'                  ([logic] -+ logic)
partition            ((a -+ logic) -+ [a] -+ [[a] [a]])
poly                 ([number] -+ number -+ number)
product              ([ring] -+ ring]
remove-by            ((a -+ a -+ logic) -+ a -+ [a] -+ [a])
replicate            (integer -+ a -+ [a])
require              ([[logic]] -+ logic)
scanl                ((a -+ b -+ a) -+ a -+ [b] -+ [a])
span                 ((a -+ logic) -+ [a] -+ [[a] [a]])
sum                  ([ring] -+ ring)
take                 (integer -+ [a] -+ [a])
take-while           ((a -+ logic) -+ [a] -+ [a])
unzip                ([[c]] -+ [[a] [b]])
zip                  ([a] -+ [b] -+ [[a b]])
|      ((number -+ number -+ number) -+ n-ring -+ n-ring -+ n-ring)
}


    map: function [
        {Maps a function (a -+ b) to all elements
        of a series [a] producing series of type [b]
            ((a -+ b) -+ [a] -+ [b])
        }
        [throw]
        f [any-function!]
        blk [series!]
    ][
        result [series!]
    ][
        result: make blk length? blk
        foreach elem blk [
            insert/only tail result f :elem
        ]
        result
    ]


    filter: func [
        {Filter a 'series using a 'selector function.
            ((a -+ logic) -+ [a] -+ [a])
        }
        [throw]
        selector [any-function!] {(a -> logic)}
        series [series!] {[a]}
        /local result [series!]
        pattern ((a -+ logic) -+ [a] -+ [a])
    ][
        result: make :series length? :series
        foreach element :series [
            if selector :element [
                insert/only tail result :element
            ]
        ]
        result
    ]


    foldl: func [
        {Fold left operation:
            ((a -+ b -+ a) -+ a -+ [b] -+ a)
        }
        f [any-function!]
        x [any-type!]
        ys [series!]
        /local result [any-type!]
    ][
        result: x
        while [not tail? ys][
            result: f result first ys
            ys: next ys
        ]
        result
    ]


    sum: func [
        {Sum of all ring components of the block 'xs
            ([ring] -+ ring)
        }
        xs [block!]
    ][
        foldl :+ 0 xs
    ]


    product: func [
        {Product of all ring components of the block 'xs
            ([ring] -+ ring)
        }
        xs [block!]
    ][
        foldl :* 1 xs
    ]


    foldl-2: func [
        {Fold left operation on two series:
            ((a -+ b -+ c -+ a) -+ a -+ [b] -+ [c] -+ a)
        }
        f [any-function!]
        x [any-type!]
        ys [series!]
        zs [series!]
        /local result [any-type!]
    ][
        result: x
        for k 1 min (length? ys) (length? zs) 1 [
            result: f result ys/:k zs/:k
        ]
        result
    ]

    .: func [
        {Scalar product, or dot product of two real 
        vectors 'xs and 'ys
            ([number] -+ [number] -+ number)
        }
        xs [block!]
        ys [block!]
        /local f result [number!]
    ][
        f: func[u x y][u + (x * y)]
        result: foldl-2 :f 0 xs ys
        result
    ]


    map-2: func [
        {Mapping two series via binary function:
            ((a -+ b -+ c) -+ [a] -+ [b] -+ [c])
        }
        f [any-function!]
        xs [series!]
        ys [series!]
        /local size result [block!]
    ][
        size: min (length? xs) (length? ys)
        result: make xs size
        for k 1 size 1 [
            insert/only tail result f xs/:k ys/:k
        ]
        result
    ]


    inner-2: func [
        {Inner generic operation 'f on two matrices:
            (([a] -+ [b] -+ c) -+ [[a]] -+ [[b]] -+ [[c]])
        }
        f [any-function!]
        xs [block!]
        ys [block!]
        /local col result [block!]
    ][
        result: copy []
        for i 1 (length? ys)1 [
            col: copy []
            for k 1 (length? xs) 1 [
                insert/only tail col f xs/:k ys/:i
            ]
            insert/only tail result col
        ]
        result
    ]


    |: func [
        {
        Overloaded binary operation 'f for numbers,
        vectors and matrices, such as addition, subtraction,
        multiplication, linear combination, such as
        (3 * x) + (4 * y); i.e., for those operations 'f
        which have this signature:
            (number -+ number -+ number)
        The signature of the functional '| itself is:
        ((number -+ number -+ number) -+ n-ring -+ n-ring -+ n-ring)
        where
            nring: (number [number] [[number]])
        }
        f [any-function!]
        x
        y
        /local v m
    ][
        v: func [x y][map-2 :f x y]
        m: func [x y][map-2 :v x y]

        either number? x [
            f x y
        ][
            either number? x/1 [
                v x y
            ][
                m x y
            ]
        ]
    ]


    foldr: func [
        {Fold right operation
            ((a -+ b -+ b) -+ b -+ [a] -+ b)
        }
        f [any-function!]
        z [any-type!]
        xs [series!]
        /local result [any-type!]
    ][
        either empty? xs [
            result: z
        ][
            result: f xs/1 (foldr :f z next xs)
        ]
    ]


    foldl1: func [
        {As foldl but with the first alement of the series 'ys
        serving as the starting point. The series ys should
        not be empty.
            (a -+ a -+ a) -+ [a] -+ a)
        }
        f [any-function!]  {a -> a -> a}
        ys [series!]  {[a]}
        /local result [any-type!]
    ][
        require [[not empty? ys]]
        result: foldl :f (first ys) (next ys)
        result
    ]


    cat: func [
        {Concatenates block of blocks
            ([[a]] -+ [a])
        }
        xs [block!] {Block of blocks [[a]]}
        /local result [block!]
    ][
        result: copy []
        foreach k xs [
            insert tail result :k
        ]
        result
    ]

    scanl: func [
        {Scan left operation.
        This is a foldl operation aplied to all prefixes
        of the series ys: [], [y1], [y1 y2], [y1 y2 y3].
        Returns a block of length + 1 with partial results.
            ((a -> b -> a) -> a -> [b] -> [a])
        }
        f [any-function!]  {a -> b -> a}
        x [any-type!] {a}
        ys [series!]  {[b]}
        /local n result [block!] {:: a}
    ][
        n: length? ys
        result: make block! (n + 1)
        for k 0 n 1 [
            result: append result (foldl :f x (copy/part ys :k))
        ]
        result
    ]


    max-block: func [
        {Returns maximum value from a block
            ([a] -> a}
        xs [block!] {[a]}
        /local result [any-type!]
    ][
        result: foldl1 :max xs
        result
    ]

    min-block: func [
        {Returns maximum value from a block
        min-block :: [a] -> a
        }
        xs [block!] {[a]}
        /local result [any-type!]
    ][
        result: foldl1 :min xs
        result
    ]


    poly: func [
        {Evaluates a polynomial represented as block
        of its coefficients 'as, as in:
        as = [a(n-1) a(n-2) ... a0],
        where 'x is a power base.
        result: [a(n-1)*x**(n-1) + ... a1*x**1 + a0*x**0]
            ([number] -+ number -+ number)
        }
        as [block!] {[..a3 a2 a1 a0]}
        x  [number!]
        /local pack result [number!]
    ][
        require [[all' :number? as]]

        pack: func[u v][u * x + v]
        result: foldl :pack 0 as
        result
    ]

    ..: func [
        {Makes a block containing a range of ord! values.
        Format: .. [1 5]   == [1 2 3 4 5]
                .. [1 3 6] == [1 2 5]
                .. [2 2 6] == [2 2 2 2 2 2]
            ([ord] -> [ord])
        }
        [catch throw]
        xs [block!] {either [start end] or [start next end]}
        /local range x1 x2 delta result [block!]
    ][

        range: reduce xs
        throw-on-error [
            x1: range/1
            either range/3 [
                x2: range/3
                delta: (range/2 - x1)
            ][
                x2: range/2
                delta: 1
            ]

            ;result: make block! (x2 - x1) / delta
            result: copy []
            either delta <> 0 [
                for k x1 x2 delta [
                    insert tail result k
                ]
            ][
                loop abs x2 [
                    insert tail result x1
                ]
            ]
            result
        ]
    ]


    take: func [
        {Take first 'n elements from the series 'xs
            (integer -+ [a] -+ [a])
        }
        n [integer!]
        xs [series!]
        /local result [series!]
    ][
        result: copy/part xs n
        result
    ]


    drop: func [
        {Drop first 'n elements from the series 'xs
            (integer -+ [a] -+ [a])
        }
        n [integer!]
        xs [series!]
        /local result [series!]
    ][
        result: copy skip xs n
    ]


    take-while: func [
        {Take successive elements from the series 'xs
        while the predicate 'p is true
            ((a -+ logic) -+ [a] -+ [a])
        }
        p [any-function!]
        xs [series!]
        /local n result [series!]
    ][
        n: 0
        while [and' [(not tail? xs) (p xs/1)]][
            n: n + 1
            xs: next xs
        ]
        xs: head xs
        result: copy/part xs n
        result
    ]


    and': func [
        {True if all block predicates 'ps are true.
        False otherwise. This is lazy 'and, since
        no predicate is evaluated unless needed.
            ([logic] -+ logic)
        }
        ps [block!]
        /local result [logic!]
    ][
        result: not none? all ps
        result
    ]


    or': func [
        {True if any predicate from block 'ps is true.
        False otherwise. This is lazy 'or, since
        no predicate is evaluated unless needed.
            ([logic] -+ logic)
        }
        ps [block!]
        /local result [logic!]
    ][
        result: not none? any ps
        result
    ]


    drop-while: func [
        {Drop successive elements from the series 'xs
        while the predicate 'p is true
            ((a -+ logic) -+ [a] -+ [a])
        }
        p [any-function!]
        xs [series!]
        /local n result [series!]
    ][
        n: 0
        while [and' [(not tail? xs) (p xs/1)]][
            n: n + 1
            xs: next xs
        ]
        xs: head xs
        result: copy skip xs n
        result
    ]


    span: func [
        {Split the series 'xs in two parts,
        'success and 'failure, delineated
        by a first element of 'xs which
        failed to satisfy the predicate 'p.
            ((a -+ logic) -+ [a] -+ ([a],[a]))
        }
        p [any-function!]
        xs [series!]
        /local n result [block!]
    ][
        n: 0
        while [and' [(not tail? xs) (p xs/1)]][
            n: n + 1
            xs: next xs
        ]
        xs: head xs
        result: copy []
        append/only result copy/part xs n
        append/only result copy skip xs n
        result
    ]


    partition: func [
        {Partition the series 'xs in two parts,
        'success and 'failure - according to the
        outcome of application of the predicate 'p
        to all elements of 'xs.
            ((a -+ logic) -+ [a] -> [[a] [a]])
        }
        p [any-function!]
        xs [series!]
        /local us vs result [block!]
    ][
        us: copy []
        vs: copy []
        foreach k xs [
            either p :k [
                insert/only tail us :k
            ][
                insert/only tail vs :k
            ]
        ]
        result: copy []
        append/only result us
        append/only result vs
        result
    ]


    replicate: func [
        {A block with item 'x replicated n times
            (integer -+ a -+ [a])
        }
        n [integer!]
        x [any-type!]
        /local result [block!]
    ][
        result: copy []
        loop n [
            insert/only tail result x
        ]
        result
    ]


    iterate: func [
        {A block with results of 'n iterations
        of application of 'f  to 'x.
            (integer -+ (a -+ a) -+ a -+ [a])
        }
        n [integer!]
        f [any-function!]
        x [any-type!]
        /local u result [block!]
    ][
        u: x
        result: copy []
        if n >= 1 [
            insert tail result u
            loop (n - 1) [
                u: f u
                insert/only tail result u
            ]
        ]
        result
    ]


    cycle: func [
        {A series made of 'n cycles of series 'xs.
            (integer -+ [a] -+ [a])
        }
        n [integer!]
        xs [series!]
        /local result [block!]
    ][
        result: make xs (n * length? xs)
        loop n [
            insert tail result xs
        ]
        result
    ]


    any': func [
        {True if any element of the series 'xs
        satisfies the predicate 'p
            ((a -+ logic) -+ [a] -+ logic)
        }
        p [any-function!]
        xs [series!]
        /local result [logic!]
    ][
        result: or' map :p xs
        result
    ]


    all': func [
        {True if all elements of the series 'xs
        satisfy the predicate 'p
            ((a -+ logic) -+ [a] -+ logic)
        }
        p [any-function!]
        xs [series!]
        /local result [logic!]
    ][
        result: and' map :p xs
        result
    ]


    elem: func [
        {True if a set 'xs includes elem 'x

        }
        xs [series!]
        x [any-type!]
        /local result [logic!]
    ][
        result: not none? find xs x
        result
    ]


    insert-by: func [
        {Insert elem 'z into series xs' according
        to a 'compare rule.
            ((a -+ a -+ logic) -+ a -+ [a] -+ [a])
        }
        compare [any-function!]
        z [any-type!]
        xs [series!]
        /local done?
    ][
        done?: false
        while [not tail? xs][
            if compare z xs/1 [
                insert/only xs z
                done?: true
                break
            ]
            xs: next xs
        ]
        if not done? [
            insert/only xs z
        ]
        xs: head xs
        xs
    ]


    remove-by: func [
        {Remove first element of a series 'xs which
        satisfies the 'compare rule
            ((a -+ a -+ logic) -+ a -+ [a] -+ [a])
        }
        compare [any-function!]
        z [any-type!]
        xs [series!]
    ][
        while [not tail? xs][
            if compare z xs/1 [
                insert/only xs z
                break
            ]
            xs: next xs
        ]
        xs: head xs
        xs
    ]


    zip: func [
        {Zip two series producing a block of pair-blocks
            ([a] -+ [b] -+ [[a b]])
        }
        xs [series!]
        ys [series!]
        /local result [block!]
    ][
        size: min (length? xs) (length? ys)
        result: make block! size
        for i 1 size 1 [
            insert/only tail result reduce [xs/:i ys/:i]
        ]
        result
    ]


    unzip: func [
        {Unzip a block of pair-blocks producing a block of two blocks
            ([[a b]] -+ [[a] [b]])
        }
        zs [block!]
        /local result [block!]
    ][
        size: length? zs
        result: make block! 2
        xs: make block! size
        ys: make block! size
        for i 1 size 1 [
            insert/only tail xs zs/:i/1
            insert/only tail ys zs/:i/2
        ]
        insert/only tail result xs
        insert/only tail result ys
        result
    ]


    intersperse: func [
        {A copy of a series 'xs with a separator 'sep
        inserted between elements of 'xs
            (a -+ [a] -+ [a])
        }
        sep [any-type!]
        xs [series!]
        /local result [series!]
    ][
        result: copy/deep xs
        if (length? result) >= 2 [
            result: next result
            while [not tail? result][
                insert/only result sep
                result: next next result
            ]
            result: head result
        ]
        result
    ]

    require: func [
        {Throws an error if any 'precondition' is violated,
        otherwise returns 'true'. Used for preconditions validation.
            ([[logic]] -+ logic)
        }
        [throw]
        preconditions [block!]
        /local result [logic!]
    ][
        foreach p preconditions [
            if not (do p) [
                throw make error! (join "Violated precondition " (mold p))
            ]
        ]
        result: true
        result
    ]


    ensure: func [
        {Throws an error if any 'postcondition' is violated,
        otherwise returns 'true'. Used for postconditions validation.
            ([[logic]] -+ logic)
        }
        [throw]
        postconditions [block!]
        /local result [logic!]
    ][
        foreach p postconditions [
            if not (do p) [
                throw make error! (join "Violated postcondition " (mold p))
            ]
        ]
        result: true
        result
    ]


    implies: func [
        {True if condition c1 is false, or if c1 and c2 are both true.
        Used to encode this logic:
        if c1 is true then c2 must also be true
            (logic -+ logic -+ logic)
        }
        c1 [logic!]
        c2 [logic!]
        /local result [logic!]
    ][
        result: (c1 and c2) or not c1
        result
    ]


comment {
    Some examples:

        Ranges:
        ..[1 4]
            ; == [1 2 3 4]

        ..[1 3 8]
            ; == [1 3 5 7]  Arithmetical progresion

        ..[1 1 6]
            ; [1 1 1 1 1 1] or constant block if step=0

        cat [..[1 5] ..[100 110 200]]
            ; Combining many ranges

        map :..[[1 5] [10 110 200]]
            ; Mapping range operator to produce block of blocks

        cat map :..[[1 5] [10 110 200]]
            ; then concatenating them (rejoin does not do it well)

        map :to-money ..[1 10]
            ; Converting to money at your leisure

        map :to-string .. [1 10]
            ; or to other objects

        map :log-10 ..[1 10]
            ; or producing logarithmic scales

        foldl :+ 0 [1 2 3 4 5]
            ; Sum of all numbers on the list

        foldl :+ 0 ..[1 5]
            ; Same using range function to define a block

        foldl :* 1 ..[1 10]
            ; Factorial 10

        foldl :subtract 0 [1 2 3 4]
            ; Does not work with, confusion with unary :-

        max-block [1 6 3 7 3]
            ; Picking max numerical values

        min-block [1 6 3 7 3]
            ; or minimum numerical values

        poly ..[1 8] 10
            ; computing polynomials (12345678)

        poly ..[1 9] 0.1
            ; using different bases 9.87654321

        poly [1 4 5 6 8 1] 16
            ; such as hex base (1332865)

        scanl :* 1 [1 2 3 4 5]
            ; list of partial products

        scanl :+ 0 .. [1 20]
            ; list of partial sums

        filter :prime? ..[1 20]
            ; Computing list of prime numbers
            ; == [3 5 7 11 13 17 19]

        filter :prime? (filter :odd? ..[1 20])
            ; A shorter way

        ..[1 1 6]
            ; Constant of six ones [1 1 1 1 1 1]

        scanl :* 1 ..[3 3 6]
            ; Geometrical progression
            ; [1 3 9 27 81 243 729]

        scanl :* 1 ..[2 2 10]
            ; And another one
            ;[1 2 4 8 16 32 64 128 256 512 1024]

        foldl :+ 0 (scanl :* 1 ..[2 2 10])
            ; Sum of geom progression == 2047
    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               