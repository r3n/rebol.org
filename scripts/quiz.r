REBOL [
    Title: "State Quizzer"
    Date: 20-Jul-1999
    File: %quiz.r
    Author: "Bohdan Lechnowsky"
    Purpose: {To demonstrate a simple flashcard-style quizzing script}
    Email: bo@rebol.com
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'Demo 
        domain: [x-file DB] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

questions: [
   "Alabama"        "Montgomery"     "AL"
   "Alaska"         "Juneau"         "AK"
   "Arizona"        "Phoenix"        "AZ"
   "Arkansas"       "Little Rock"    "AR"
   "California"     "Sacramento"     "CA"
   "Colorado"       "Denver"         "CO"
   "Connecticut"    "Hartford"       "CT"
   "Delaware"       "Dover"          "DE"
   "Florida"        "Tallahassee"    "FL"
   "Georgia"        "Atlanta"        "GA"
   "Hawaii"         "Honolulu"       "HI"
   "Idaho"          "Boise"          "ID"
   "Illinois"       "Springfield"    "IL"
   "Indiana"        "Indianapolis"   "IN"
   "Iowa"           "Des Moines"     "IA"
   "Kansas"         "Topeka"         "KS"
   "Kentucky"       "Frankfort"      "KY"
   "Louisiana"      "Baton Rouge"    "LA"
   "Maine"          "Augusta"        "ME"
   "Maryland"       "Annapolis"      "MD"
   "Massachusetts"  "Boston"         "MA"
   "Michigan"       "Lansing"        "MI"
   "Minnesota"      "St. Paul"       "MN"
   "Mississippi"    "Jackson"        "MS"
   "Missouri"       "Jefferson City" "MO"
   "Montana"        "Helena"         "MT"
   "Nebraska"       "Lincoln"        "NE"
   "Nevada"         "Carson City"    "NV"
   "New Hampshire"  "Concord"        "NH"
   "New Jersey"     "Trenton"        "NJ"
   "New Mexico"     "Santa Fe"       "NM"
   "New York"       "Albany"         "NY"
   "North Carolina" "Raleigh"        "NC"
   "North Dakota"   "Bismarck"       "ND"
   "Ohio"           "Columbus"       "OH"
   "Oklahoma"       "Oklahoma City"  "OK"
   "Oregon"         "Salem"          "OR"
   "Pennsylvania"   "Harrisburg"     "PA"
   "Rhode Island"   "Providence"     "RI"
   "South Carolina" "Columbia"       "SC"
   "South Dakota"   "Pierre"         "SD"
   "Tennessee"      "Nashville"      "TN"
   "Texas"          "Austin"         "TX"
   "Utah"           "Salt Lake City" "UT"
   "Vermont"        "Montpelier"     "VT"
   "Virginia"       "Richmond"       "VA"
   "Washington"     "Olympia"        "WA"
   "West Virginia"  "Charleston"     "WV"
   "Wisconsin"      "Madison"        "WI"
   "Wyoming"        "Cheyenne"       "WY"
]

correct: wrong: 0

foreach [state capitol abbr] questions [
   cap: ask rejoin ["^/What is the capitol of " state "? "]
   either cap = capitol [
      print "*** Correct!!! ***" 
      correct: correct + 1
   ][
      print ["Sorry...the capitol of" state "is" capitol]
      wrong: wrong + 1
   ]

   abb: ask rejoin ["^/What is the abbreviation of " state "? "]
   either abb = abbr [
      print "*** Correct!!! ***"
      correct: correct + 1
   ][
      print ["Sorry...the abbreviation of" state "is" abbr]
      wrong: wrong + 1
   ]
]

print ["^/You answered" correct "questions correctly and" 
       wrong "questions incorrectly.^\"
       "This gives you a score of" 
       to-integer (correct / (correct + wrong) * 100 + .5) "%"]
