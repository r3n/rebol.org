Rebol [
    Library: [
       level: 'beginner
       platform: 'all
       type: [one-liner function]
       domain: [db text text-processing]
       tested-under: ["REBOL/View 1.2.1.3.1 21-Jun-2001" "REBOL/View 1.3.1.3.1 17-Jun-2005 Core 2.6.0"]
       support: none
       license: 'pd
       see-also: none
    ]
    Title: "Convert 'Date' datatype to International Date - ISO 8601."
    Date: 08-Nov-2005
    File: %iso-8601-date.r
    Purpose: {Simple one-liner function to covert date to ISO 8601 format. In
       my application a time stamp is not needed nor included in this function.
       For a function that includes a timestamp see: to-iso-8601-date.r}
    Version: 1.0.0
    Author: "Gordon Raboud"
]
{ One line format }
ISO8601Date: func [Date [Date!]] [to-string join Date/year ["-" copy/part tail join "0" [Date/month] -2 "-" copy/part tail join "0" [Date/day] -2 ]]

{ A bit more readable with shorter lines.}
ISO8601Date: func [Date [Date!]] [
   to-string join Date/year
   ["-" copy/part tail join "0" [Date/month] -2 "-" copy/part tail join "0" [Date/day] -2 ]
]