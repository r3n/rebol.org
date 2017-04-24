copyright (c) 2010 Peter W A Wood

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

REBOL [
  title: "Decimal Arithmetic"
  version: {see money/version}
  date: 22-Jul-2010
  author: Peter W A Wood
  file: %money.r
  purpose: {Decimal arithmetic for numbers held as strings.
            Numbers may have up to 12 integral digits
            and always have 2 fractional digits} 
  library: [
    type: [package tool]
    domain: [math]
    license: 'mit
  ]
]

money: make object! [
  
  ;; object variables
  version: "0.5.5"  
  lib: none                       ;; the money library
  add-routine: none
  subtract-routine: none
  multiply-routine: none
  divide-routine: none
  format-routine: none
  accounting-format-routine: none
  version-routine: none
  answer: none
  answer-length: none
  float-first: none
  float-second: none
  answer-init: "^(20)********************************"
  
  ;; parse validation rules
  dec: charset [#"0" - #"9"]
  valid-number: [[opt #"-"] any dec opt [#"." [0 2 dec]]]

  ;; internal functions  
  _check-numbers: func [
    first-number [string!]
    second-number [string!]
  ][
    any [
      not parse/all first-number valid-number
      not parse/all second-number valid-number
      error? try [float-first: to decimal! first-number]
      error? try [float-second: to decimal! second-number]
      999999999999.99 < abs float-first
      999999999999.99 < abs float-second
    ]
  ]
  
  _check-number: func [
     number [string!]12
  ][
    any [
      not parse/all number valid-number
      error? try [float-first: to decimal! number]
      999999999999.99 < abs float-first
    ]
  ]
  
  _extract-answer: func [] [
    answer-length: to integer! first answer
    remove answer 
    copy/part answer answer-length
  ]
  
  _prepare: func[ n [string!]] [
    insert copy n to char! min length? n 32
  ]
    
  
  init: func [
    {Loads the library and creates the routines}
    library-name [file!]
    /local
      script-vers
      lib-vers
  ][
    ;; Load the library
    lib: load/library library-name
    
    ;; Check it is the correct version by comparing the major and minor release
    ;;  numbers of the script and libary
    version-routine: make routine! [
      answer [string!]
    ] lib "version"
    answer: copy answer-init
    version-routine answer
    remove answer
    script-vers: copy version
    script-vers: 
      remove/part find next find script-vers "." "." index? tail script-vers
    lib-vers: copy answer
    lib-vers: remove/part find next find copy lib-vers "." "." length? lib-vers
    if lib-vers <> script-vers [
      make error! "Incompatible versions of the script and dynamic libary"
    ]
    ;; setup the working routines
    add-routine: make routine! [
      first-number [string!] 
      second-number [string!]
      answer [string!]
    ] lib "add"
    subtract-routine: make routine! [
      first-number [string!] 
      second-number [string!]
      answer [string!]
    ] lib "subtract"
    multiply-routine: make routine! [
      first-number [string!] 
      second-number [string!]
      answer [string!]
    ] lib "multiply"
    divide-routine: make routine! [
      first-number [string!] 
      second-number [string!]
      answer [string!]
    ] lib "divide"
    format-routine: make routine! [
      number [string!]
      answer [string!]
    ] lib "format"
    accounting-format-routine: make routine! [
      number [string!]
      answer [string!]
    ] lib "accountingformat"
    #[unset!]                   ;; so as not to return the last routine made
  ]
  
  free-lib: func [
    {Frees the dynamic library}
  ][
    free lib
    #[unset!]
  ]
  
  add: func [
    {Returns the addition of two numbers}
    first-number [string!]
    second-number [string!]
  ][
    if any [
      _check-numbers first-number second-number
      999999999999.99 < abs (float-first + float-second)
    ][
      return "error"
    ]
    
    ;; initialise the "return string"
    answer: copy answer-init
    
    ;; call the library routine
    add-routine _prepare first-number _prepare second-number answer
    _extract-answer
  ]
  
  subtract: func [
    {Returns the result of subtracting the second number from the first}
    first-number [string!]
    second-number [string!]
  ][
    if any [
      _check-numbers first-number second-number
      999999999999.99 < ((abs float-first) + (abs float-second))
    ][
      return "error"
    ]
    
    ;; initialise the "return string"
    answer: copy answer-init
    
    ;; call the library routine
    subtract-routine _prepare first-number _prepare second-number answer
    
    _extract-answer
  ]
  
  multiply: func [
    {Returns the multiplication of the two numbers}
    first-number [string!]
    second-number [string!]
  ][
    if any [
      _check-numbers first-number second-number
      999999999999.99 < ((abs float-first) * (abs float-second))
    ][
      return "error"
    ]
    
    answer: copy answer-init
    
    ;; call the library routine
    multiply-routine _prepare first-number _prepare second-number answer
    
    _extract-answer
  ]

  divide: func [
    {Returns the result of dividing the first number by the second}
    first-number [string!]
    second-number [string!]
  ][
    if any [
      _check-numbers first-number second-number
      float-second = 0
      999999999999.99 < ((abs float-first) / (abs float-second))
    ][
      return "error"
    ]
    
    answer: copy answer-init
    
    ;; call the library routine
    divide-routine _prepare first-number _prepare second-number answer
    
    _extract-answer
  ]
  
  format: func [
    {returns a formatted number with thousands separators}
    number [string!]
  ][
    if any [
      _check-number number
    ][
      return "error"
    ]
    
    answer: copy answer-init
    
    format-routine _prepare number answer
    
    _extract-answer
  ]
  
  accounting-format: func [
    {returns a formatted number with thousands separators and negative numbers
      enclosed in parentheses}
    number [string!]
  ][
    if any [
      _check-number number
    ][
      return "error"
    ]
    
    answer: copy answer-init
    
    accounting-format-routine _prepare number answer
    
    _extract-answer
  ]

]
