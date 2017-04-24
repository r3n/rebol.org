REBOL [
    title: "Paypal Reports"
    date: 22-1-2013
    file: %paypal-reports.r
    author:  Nick Antonaccio
    purpose: {

        This is a beginner's example taken from the tutorial at:

        http://re-bol.com/business_programming.html

        It creates reports on columns and rows of data in a .csv table.

        The script demonstrates typical CSV file operations using parse, foreach,
        and simple series functions. The code performs sums upon columns, and
        selective calculations upon specified fields, based upon conditional
        evaluations, searches, etc.  The script automatically handles tables with
        any arbitrary number of columns, allowing fields to be referred to by
        labels present in the first line of the .csv file.

        Practical column and row based reporting capabilities such as this are a
        simple and useful skill in REBOL.  Using basic permutations of techniques
        shown here, it's easy to surpass the capabilities of spreadsheets and
        other "office" reporting software.

        For more information about how to obtain CSV data from Paypal, and a 
        line-by-line explanation of the code, see:

        http://re-bol.com/business_programming.html#section-6.12)

    }
]

filename: request-file/only/file %Download.csv
lines: read/lines filename
labels: copy parse/all lines/1 ","
foreach label labels [trim label]
database: copy []
foreach line (at lines 2) [
    parsed: parse/all line ","
    append/only database parsed
]

; Show all names in the "Names" column of the table:

name-index: index? find labels "Name"
names: copy {}
foreach row database [
    append names rejoin ["Name:  " (pick row name-index) newline]
]
editor names

; Show all net transaction amounts for rows in which the "Names"
; column contains the text "Netflix":

net-index: index? find labels "Net"
amounts: copy {}
foreach row database [
    if find/only (pick row name-index) "Netflix" [
        append amounts rejoin ["Amount:  " (pick row net-index) newline]
    ]
]
editor amounts

; Display a sum of all net transaction amounts for rows in which the
; "Names" column contains the text "Netflix", and the "Date" column
; contains a date between 1-1-2012 and 12-1-2012:

date-index: index? find labels "Date"
sum: $0
foreach row database [
    if find/only (pick row name-index) "Netflix" [
        date: parse (pick row date-index) "/"
        month:  pick system/locale/months to-integer date/1
        reb-date: to-date rejoin [date/2 "-" month "-" date/3]
        if ((reb-date >= 1-jan-2012) and (reb-date <= 31-dec-2012)) [
            sum: sum + (to-money pick row net-index)
        ]
    ]
]
alert form sum