REBOL [
    Title: "Word Wrap Text"
    Date: 18-Jun-1999
    File: %wraptext.r
    Author: "Scrip Rebo"
    Purpose: "Handy function to fill and wrap a text paragraph."
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

wrap-text: func [
    para
    /margin size "Char count after which the wrap occurs."
    /local count
][
    count: 1
    if not margin [size: 50] ; default size
    trim/lines para
    forall para [
    if all [count >= size find/match para " "][
        change para newline
        count: 0
    ]
    count: count + 1
    ]
    head para
]

print wrap-text {
       This is a paragraph that
       we want to
       fill and wrap using the default margin which is
       set to 50.
}



