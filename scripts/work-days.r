rebol [
    Library: [
           level: 'beginner
        platform: 'all
            type: [tool function]
          domain: [math financial]
    tested-under: [windows bsd linux]
         support: none
         license: [mit]
        ]

       file: %work-days.r
       date: 18-feb-2007
     author: "Sunanda"
    version: 0.0.1
      title: "Calculate working days between two dates"
    purpose: {Given two dates, and a list of holidays that
              occur between them, returns the number of
              work days between those two days. With the
              /non refinement, will return the number of
              non-working days between the two dates.}
    ]


calc-work-days: func [
    date1 [date!]
    date2 [date!]
    holidays [block!]
    /non
    /local
    dates
    offset
    hol-count
    working-days
] [

    ;; Put dates in order
    ;; ------------------
    dates: copy reduce [date1]
    either date1 < date2 [append dates date2] [insert dates date2]

    ;; count holidays in range
    ;; -----------------------
    hol-count: 0
    foreach hd holidays [
        if all [
            hd/weekday <= 5 ;; got to be a weekday to count
            hd >= dates/1
            hd <= dates/2] [
            hol-count: hol-count + 1
        ]
    ]

    ;; Round dates to Mondays
    ;; ----------------------
    offset: 0
    offset: offset + pick [0 -1 -2 -3 -4 -4 -4] dates/1/weekday
    dates/1: dates/1 + 1 - dates/1/weekday

    offset: offset + pick [-5 -4 -3 -2 -1 -1 -1] dates/2/weekday
    dates/2: dates/2 + 8 - dates/2/weekday

    ;; Calculate the working / non-working days
    ;; ----------------------------------------

    working-days: (dates/2 - dates/1) / 7 * 5 + offset - hol-count
    if non [return (abs (date1 - date2)) - working-days]
    return working-days
]






