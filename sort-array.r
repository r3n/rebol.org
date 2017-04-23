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
    Title: "Sort an array of records"
    Date: 07-Nov-2005
    File: %sort-array.r
    Purpose: {Sort an array where each record is separated by a 'newline' and
              each field in each record is separated by a comma.}
    Version: 1.0.0
    Author: "Gordon Raboud"
]

sort-array-of-blocked-records: func [
   "Sort an array of blocked records"
   ArrayBlocks [block!] "Array containing blocks of records"
   SortField [integer!] "Order the records based on this field"
   SortOrder [char!] "Must be 'a' or 'A' for ascending or 'd' or 'D' for descending"
]  [
   
   Switch SortOrder [
      #"a" [sort-method: func [a b] [(at a SortField) < (at b SortField)]]
      #"d" [sort-method: func [a b] [(at a SortField) > (at b SortField)]]
      ]

   sort/compare ArrayBlocks :sort-method
   {Sorts the 'ArrayBlocks' by looking at the 'SortField' element of each record
    and then comparing to see if [A < B] or [A >B] according to 'SortOrder'. }
   return
]


{ Example code on how to use}
ImportFile: %"ArrayToSort.csv"
ImportData: read/lines ImportFile { Each record is separated by a 'newline'. }
ParsedArray: copy []

{ Parse the records into fileds - remove the comma.}
Foreach Line ImportData [
   ParsedArray: append/only ParsedArray parse/all Line ","
]

Header: first ParsedArray
ParsedArray: skip ParsedArray 1 {Strip header from array to be sorted}
SortOnFieldNumber: 2
SortOrder: #"d"

sort-array-of-blocked-records ParsedArray SortOnFieldNumber SortOrder


{ Show results of sort }
Print Header
foreach Record ParsedArray [
   print Record
]


halt {so we can see the results }