Rebol[
    Title: "Binary Search"
    Author: "Tom Conlin"
    File: %binary-search.r
    Date: 3-Jun-2003
    Purpose:{
        Find an index in a sorted list, at which an item must occur,
        if the item exists in the list.
        in time porportional to log-2 of the number of items in the list.
        NOTE WELL no effort is made to confirm the series is actually sorted.
        returns none if the input arguments are (detectably) flawed
        returns a index of a match OR an index adjecent to
        where in the list the item would be found if it existed.
   }
      library: [
        level: 'intermediate
        platform: all
        type: 'function
        domain: 'text-processing
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

binary-search: func [
    sorted-list[series!]    {smaller to bigger series by default,
                             or else supply your own comparison function}
    key                     "item to try and find in the sorted series of 'skip' size records"
    /low     L[integer!]    "opt low index in series to begin search: default 1"
    /high    H[integer!]    "opt high index in series to end search: default (length? sorted-list) "
    /compare cmp[function!] "opt comparison function of two args: cmp a b"
    /local lo mid hi size
][  
    either low  [lo: L][lo: 1]
    either high [hi: H][hi: length? sorted-list]
    
    ;error conditions in input
    if any[lo < 1 hi < lo  hi > length? sorted-list][return none]
    if not compare [cmp: func [a b][a < b]]
    
    mid: to integer! (hi - lo / 2 + .5) + lo
    while[hi >= lo][
        either  key = pick sorted-list mid
            [return mid]
            [either cmp pick sorted-list mid key[lo: mid + 1][hi: mid - 1]]
        mid: to integer! (hi - lo / 2 + .5) + lo
    ]
    mid
]