rebol[
title: "lexigraphic permutations"
author: "Tom Conlin"
date:   10-Oct-2003
file:    %lexpem.r
purpose: {to generate permutations of a series in the order they would be found in a dictionary}
example: {last lexperm "belor" 104}
Library: [
    level: 'intermediate         
    platform: 'all         
    type: [function tool]        
    domain: [text math]         
    tested-under: none         
    support: none         
    license: none         
    see-also: none
    ] 
]    
lexperm: func [{I think I first saw this algo in the TOMS fortran library @ ACM}
        perm [series!] "series to be permuted" 
        n [integer!]   {Natural number of permutations to attempt,                         
                       stops short if sorted order is reached first }
        /local lo hi result tmp swap
][  
    if not positive? n [return none]
    swap: func [a [series!] b [series!] /local t][
        if not equal? a b [t: pick a 1 change a pick b 1 change b t
    ]]       
    result: make block! n
    insert result copy perm 
    for i 2 n 1 [
        hi: back tail perm lo: back hi
        ; while suffix decending -- seek from tail towards head   
        while[all[not head? lo greater? pick lo 1 pick (next lo) 1 ]][lo: back lo]
        ; lo points to mis-ordered item nearest to tail (pivot)    
        ; set hi to first item from tail not in order w.r.t. the (pivot) item
        ; either exists or we have searched to (pivot)
        while[greater? pick lo 1 pick hi 1][hi: back hi]
        ;if no mis-ordered item exists we are done 
        if equal? hi lo [break]
        ; otherwise exchange dis-ordered items
        swap lo hi 
        ; reverse all items ABOVE but not including the (pivot)
        hi: back tail perm  lo: next lo          
        while[lesser? index? lo index? hi][
            swap lo hi 
            lo: next lo 
            hi: back hi
        ]
        insert tail result copy perm
    ]  
    result     
]