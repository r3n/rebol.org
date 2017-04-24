REBOL [
    Title: "rebol Server pages"
    Date: 18-May-2001/9:18:36+2:00
    Version: 1.0.0
    File: %erebol.r
    Author: "Maarten Koopmans"
    Purpose: "Execute embedded rebol code, see www.erebol.com"
    Email: m.koopmans2@chello.nl
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [cgi markup text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

erebol: func [ {Preprocesses a text file and evaluates al rebol code between
 <% and %> tags. Everything that is printed is visible in the output.
 <%# and %> comments code out (useful for debugging).}
 content [file! string!] /local text ]
[

    execs: false
    page-end: copy {}
  either file? content
  [
    text: read content
  ]
  [ text: copy content ]

  ; two rules for parsing
  ; first the comment rule
  ; removes any comment between <%# and %>, useful for debugging
  comment-rule: [ copy pre to "<%#" cs: thru "%>" ce:  (remove/part cs ((index? ce) - (index? cs)))]

  ; next, we copy anything that is between <% and %> and try to execute that
  ; we save the remainder of the page in page-end
  blok: [ do code ]
  bind blok 'do
  exec-rule: [ copy pre to "<%" thru "<%" copy code thru "%>" page-end:
                             (execs: true prin pre error? try blok)
                         ]
  bind exec-rule 'do
  ; now remove the comments
  parse text [ any comment-rule ]

  ; execute the commands
  parse text [any exec-rule]

  ;and... print the end of the page that doesn't contain any code
    either execs
    [
        print page-end
    ]
    [
        print text
    ]
]


