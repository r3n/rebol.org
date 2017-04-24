REBOL [
    Library: [
        level: 'beginner
        platform: 'all
        type: 'function
        domain: 'ui
        tested-under: [
            [View 1.3.2 on WinXP by Gregg]
        ]
        support: none
        license: 'MIT
    ]
    title:   "Insert - Most Recently Used list idiom"
    file:    %insert-mru.r
    author:  "Gregg Irwin"
    email:   greggirwin@acm.org
    date:    30-Apr-2007
    version: 0.0.1
    purpose: {
        Insert an item in a series, where the series is treated
        as an MRU list. That is, the newest item is at the head,
        there are no duplicates (inserting a value removes the
        previous instance of that value if it exists), and the
        series may be limited to a specific size. If a new item
        causes the series to grow beyond that size, the last item
        is removed.

        It is often used with menus of recently accessed files.
    }
]

insert-MRU: func [
    "Insert value in series, removing first existing instance."
    series [series!] 
    value 
    /limit size [integer!] "Limit the series to the given size by removing the last item."
] [
    remove find/only series value
    insert/only series value
    if all [size  size < length? series] [remove back tail series]
    series
]

