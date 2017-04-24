REBOL [
    Title: "Pretty numbers"
    File: %pretty-numbers.r
    Date: 24-Sept-2005
    Version: 1.0
    Purpose: {Add spaces to numbers so they get more readable. E.g. 126789 => 126 789}
    Library: [
      Level: 'beginner
      Domain: [printing text-processing]
      License: none
      Platform: [all]
      Tested-under: none
      Type: 'function
      Support: none
    ]
]

pretty-number: func [to-print] [
  if not number? to-print [return to-print]

  to-print: reverse to-string to-print

  to-return: copy ""
  index: 0
  forall to-print [
    if all [index <> 0 0 = (index // 3)] [
      append to-return " "
    ]
    append to-return first to-print
    if any [ #"." = first to-print
             #"," = first to-print ] [
      index: -1
    ]
    index: 1 + index
  ]
  trim reverse to-return
]


halt