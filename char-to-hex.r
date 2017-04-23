Rebol [
  Author: "Gordon Raboud with help from TomC and Sunanda"
  File: %char-to-hex.r
  Date: 7-May-2005
  Title: "Convert Character to Hexidecimal"
  Purpose: {Convert an ASCII char to a two hex code.  This is just one of
           those things in Rebol where you waste time looking for a solution
           to an otherwise extremely simple problem because the obvious
           doesn't work (ie: to-hex "M" doesn't work because to-hex wants
           an integer and to-integer wants a character not a string)!  The
           C2I function is thrown in for completeness.}
  Library: [
    Level: 'beginner
    Platform: [all]
    Type: [one-liner function]
    Domain: 'text
    Tested-under: 'W2K
    Support: none
    License: none
  ]
  Version: 1.0
]

C2H: func [
  "ASCII char to two byte hex"
  letter
  ][
  copy/part tail to-hex to-integer to-char letter -2
  ]
  
C2I: func [
  "ASCII char to integer"
  letter
  ][
  to-integer to-char letter
  ]