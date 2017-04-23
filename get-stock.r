REBOL [
  Library: [
     level: 'beginner
     platform: 'all
     type: [function]
     domain: [other-net financial]
     tested-under: none
     support: none
     license: none
     see-also: none
   ]

    Title: "Download stock data"
    Date: 8-jan-2006
    Version: 0.1.9
    File: %get-stock.r
    Author: ["Matt Licholai" "Steve Shireman(for new view)"]
    Rights: "(C) Matt Licholai 2001, 2002 "
    Usage: {Example:
    set [dt op hi lo cl vo] get-stock/data "IBM" (now/date - 20) now/date
    set [dt op hi lo cl vo] get-stock/data/store "IBM" (now/date - 20) now/date %IBM.csv
    set [dt op hi lo cl vo] get-stock/data/retrieve "IBM" now/date now/date %IBM.csv
        string_data: get-stock/csv "IBM" (now/date - 20) now/date
        string_data: get-stock/csv/store "IBM" (now/date - 20) now/date %IBM.csv
        string_data: get-stock/csv/retrieve "IBM" now/date now/date %IBM.csv
         }
    Purpose: {Get stock data from Yahoo. Return a block of blocks:
date, open, high, low, close, volume, or the csv data as a sting.  Optionally store the csv data as a file. }
    Comment: {Downloads historic data for a stock between two dates from Yahoo.
        Returns date, open, high, low, close and volume as vectors [blocks],
        or as as string.
        Note that when reading from a file, the start and end dates are ignored,
        the entire file is read in and processed.
        Newest data is at the bottom of each block or the string.}
    History: [0.1.0 ["Initial version to get csv as a string"]
    0.1.1 ["Modified from %get-csv.r to get data blocks"]
    0.1.2 [15-Nov-2001 {Combined data and csv versions into one and
              added file option}]
    0.1.3 ["Modified so that the newest data is always last"]
    0.1.4 [{Added reading from a tile (retrieve) and
                changed name for writing a file (store)}]
    0.1.5 [20-Jan-2002 {Removed parallel assignments, to prevent setting
          global words}]
    0.1.8 [5-sep-2004 {change URL. skip last line of download. Fix compose brackets -- Sunanda/ScottJ}]

]
    Email: %M--S--Licholai--ieee--org
    Category: [web database 3 ldc net db tcp]
]

get-stock: func [
    {Download historic data for the specified stock from Yahoo}
    ticker [string!] "Stock ticker"
    start [date!] "data start date"
    end [date!] "data end date"
    /data    "return a block of results"
    /csv     "return a string with the data"
    /store    "save the csv data as file-name"
    file-out [file!] "file name under which to save the csv data"
    /retrieve
    file-in [file!] "file name from which to read the csv data"
    /local
    yahoo-url data-path refiner codes id val stock-data prices dates
    opens highs lows closes volumes header result
][
    dates: copy []
    opens: copy []
    highs: copy []
    lows: copy []
    closes: copy []
    volumes: copy []
    yahoo-url: http://ichart.finance.yahoo.com

    data-path: copy "table.csv?"

    refiner: func [
        str [string!]
        const
        var
    ][
        append append append append str "&" :const "=" :var
    ]

    codes: compose [
        s (ticker)
        a (start/month)
        b (start/day)
        c (start/year)
        d (end/month)
        e (end/day)
        f (end/year)
        g d
        q q
        y 0
        z (:ticker)
        x .csv
    ]

    foreach [id val] codes [
        refiner data-path id val
    ]

    either csv [

        stock-data: read/lines either not retrieve [
            yahoo-url/:data-path
        ][
            file-in
        ]

        if not (header: first stock-data) =  "Date,Open,High,Low,Close,Volume,Adj. Close*" [
            throw make error! "Something is wrong with the data, try again"]

        ; skip the column header data
        stock-data: next stock-data

        ;  flip the data (newest at the bottom)
        if not retrieve [reverse stock-data]
        result: stock-data

    ][

        stock-data: read/lines either not retrieve [
            yahoo-url/:data-path
        ][
            file-in
        ]

        if not (header: first stock-data) =  "Date,Open,High,Low,Close,Volume,Adj. Close*" [
            throw make error! "Something is wrong with the data, try again"]
        stock-data: next stock-data ; skip the column header data
        ; "Date,Open,High,Low,Close,Volume"

        if find last stock-data "<" [stock-data: copy/part stock-data -1 + length? stock-data]


        ; flip the data (newest at the bottom)
        if not retrieve [reverse stock-data]

        foreach line stock-data [
            ; Don't use set to keep the words local.
            ; set/any [dt op hi lo cl vo] parse line none
            prices: parse line none

            ; now make all the assignments
            append dates to-date first prices     ; dt
            append opens to-decimal second prices ; op
            append highs to-decimal third prices  ; hi
            append lows to-decimal fourth prices  ; lo
            append closes to-decimal fifth prices ; cl
            append volumes to-integer last prices ; vo
        ]

        result: reduce [dates opens highs lows closes volumes]
    ]

    if store [
        write/lines file-out head header
        write/lines file-out head stock-data
    ]
    result
]