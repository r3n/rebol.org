REBOL [
    Title: "Form Letter"
    Date: 10-Sep-1999
    File: %formletter.r
    Purpose: "Example of how to create an email form letter."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [x-file email other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Database: [
    "Ms." "Ronda" "Adnor" "Hawaii"   ra@sanfran.dom
    "Ms." "Mari"  "Iram"  "New York" iram@miami.dom
    "Mr." "Bill"  "Clint" "Alcatraz" billc@bwh.dom
]

foreach [Mr-Ms first-name last-name place email] database [
    letter: rejoin [

"Dear " Mr-Ms " " last-name {,

We are interested in hearing more about your upcoming vacation
plans to } place { and what we can do to make your trip more
enjoyable.  } first-name {, you know you can contact us anytime to
find out more about the details of your travel package.

Have fun in } place {!

   Bob "Jetman" Bobbob
   Quantity Travel, Inc.
}
]
    print ["Sending to:" first-name last-name]
    send email letter
]

