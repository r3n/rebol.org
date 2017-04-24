Rebol [
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'function
        domain: 'database
        tested-under: ["REBOL/View 1.2.1.3.1 21-Jun-2001" "REBOL/View 1.3.1.3.1 17-Jun-2005 Core 2.6.0"]
        support: none
        license: 'pd
        see-also: none
        ]

    Title: "sort-series-of-elements"
    Date: 06-Nov-2005
    File: %sort-series.r
    Purpose: {Sorting a series of items.  Specify how many fields per record,
       which field to sort on, and Ascending or Descending order.}
    Version: 1.0.0
    Author: "Gordon Raboud with some help from Volker, DideC, Sunanda and BrianH"
]

{ The verbose version - I like comments }
sort-series-of-elements: func [
    "Sort a series of non-blocked items"
    Series [block!] "Continuous sequential series of items"
    Elements [integer!] "Number of items per record"
    SortField [integer!] "Order the records based on this field"
    SortOrder [char!] "Must be 'a' or 'A' for ascending or 'd' or 'D' for descending"
] [
    BlockSeries: copy [] {The array by complete RECORDS}
    SortedSeries: copy [] {The array by a long series of individual items}
    
    forskip Series Elements [append/only BlockSeries copy/part Series Elements]
    { The above "foreach" loop converts the series of individual items into an
      array of record blocks.}

    Switch SortOrder [
       #"a" [sort-method: func [a b] [(at a SortField) < (at b SortField)]]
       #"d" [sort-method: func [a b] [(at a SortField) > (at b SortField)]]
       ]

    foreach Record sort/compare BlockSeries :sort-method [append SortedSeries Record]
    {The above "foreach" loop does the following:
       1. Sorts the array "BlockSeries" by looking at the "SortField" element of each record and
          then comparing to see if [A < B] or [A >B] according to SortOrder.
       2. Then it reduces the array from blocks of records to individual elements and
          stores those elements into the array "SortedSeries".}
    return SortedSeries
]


{ The same function with comments and help removed; just in case
  a year from now you don't want to know how it works. ;) }
  
sort-series-of-elements: func [
    Series [block!] Elements [integer!] SortField [integer!] SortOrder [char!]
] [
    BlockSeries: copy []
    SortedSeries: copy []
    forskip Series Elements [append/only BlockSeries copy/part Series Elements]
    Switch SortOrder [
       #"a" [sort-method: func [a b] [(at a SortField) < (at b SortField)]]
       #"d" [sort-method: func [a b] [(at a SortField) > (at b SortField)]]
       ]
    foreach Record sort/compare BlockSeries :sort-method [append SortedSeries Record]
    return SortedSeries
]


{ Example code on how to use}
UnSortedSeries: read %"DataToSort2.csv" {try exporting a DB from a spreadsheet}
DistinctItems: parse/all Unsortedseries ","

FieldsPerRecord: 9
SortOnFieldNumber: 4
SortOrder: #"d"

Header: copy/part DistinctItems FieldsPerRecord
DistinctItems: skip DistinctItems FieldsPerRecord {Strip header from data to be sorted}

sort-series-of-elements DistinctItems FieldsPerRecord SortOnFieldNumber SortOrder

{ Show results of sort }
Print Header
forskip SortedSeries FieldsPerRecord [
   print [copy/part SortedSeries FieldsPerRecord]
]

halt {so you can see the results }