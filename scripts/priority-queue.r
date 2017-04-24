REBOL [
    Library: [
        level: 'beginner
        platform: 'all
        type: [function module]
        domain: [extension x-file]
        tested-under: [
            [View 1.3.2 on WinXP by Gregg]
        ]
        support: none
        license: 'MIT
    ]
    title:   "Priority Queue"
    file:    %priority-queue.r
    author:  "Gregg Irwin"
    email:   greggirwin@acm.org
    date:    30-Apr-2007
    version: 0.0.1
    purpose: {
        Provides functions, and an object def that uses them, to treat
        a series as a priority queue. When you insert items, you give
        them a priority (higher numbers mean a higher priority). In the
        actual series, the priority is stored along with the value, so
        you should always use the pq* functions to access them, to make
        things easier. 
    }
]

pq-insert: func [
    series [any-block!] "Series to insert value into"
    value "The value to insert"
    priority [integer!] "Higher numbers have higher priority"
][
    sort/skip/reverse append series reduce [priority value] 2
]

pq-remove: func [
    "Remove an item from the priority queue"
    series [any-block!] "Series to remove value from"
    /index  "Remove a specific item"
        idx [integer!] "The index of the item to remove"
][
    remove/part either index [at series (idx * 2 - 1)] [head series] 2
]

pq-first: func [
    series [any-block!]
][
    ; skip over the priority value and return the actual value
    ; that was inserted in the queue.
    attempt [first next head series]
]

pq-take: func [
    series [any-block!] 
    /local value
][
    value: pq-first series  pq-remove series  value
]

priority-queue: make object! [
    data: copy []

    insert: func [item priority] [pq-insert data item priority]

    remove: func [/index idx] [
        either index [pq-remove/index data idx][pq-remove data]
    ]

    first: does [pq-first data]

    take: does [pq-take data]
]
