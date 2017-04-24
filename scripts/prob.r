REBOL [
    Title: "Primitive Rebol Object Browser"
    Date: 01-nov-2001
    File: %prob.r
    Author: "HY"
    Purpose: "Make a graphical view of the probe function so that users may probe the system object without having to look it all up in the console."
    Library: [
      Level: 'intermediate
      Domain: [debug]
      License: none
      Platform: [all plugin]
      Plugin: [Size: 785x360]
      Tested-under: none
      Type: [tool]
      Support: none
    ]
]

path-words: copy [ ]
list-index: 4 ; this should have been 1, but we add 3 for the lay-out components...
main-styles: stylize [
  list: text-list 180x200 feel [
    detect: func [face event] [
      if event/1 = 'up [
        if not equal? "" to-string face/picked [
          ; make sure clicks on the slider are ignored:
          event-offset: event/offset - face/offset
          if event-offset/x >= face/sld/offset/x [ return event ]
          ; if we get here, everything is ok.
          ; Now make sure only one item is selected:
          if (length? face/picked) > 1 [
            ;print "Faen steike! Mer enn én dings er valgt!"
            ; hvorfor funker ikke dette:
            ;face/picked: face/picked/1
            ;print "Det får holde med den første."
            show face
          ]
          list-clicked: index? find face/parent-face/pane face ;list1 = 4
                                                               ;list2 = 5
                                                               ;list3 = 6
                                                               ;list4 = 7
          ;print ""
          ;print ["list-index er" list-index "og list-clicked er" list-clicked]
          while [list-index > list-clicked] [
            remove back tail path-words
            ;if list-index < 8 [
              clear face/parent-face/pane/:list-index/lines
              clear face/parent-face/pane/:list-index/picked
              show face/parent-face/pane/:list-index ; immediately update
            ;]
            list-index: list-index - 1
          ]
          ;print ["list-index er" list-index "og list-clicked er" list-clicked]
          to-append: to-word to-string face/picked/1
          while [all [((length? path-words) > (list-clicked - 3)) list-clicked < 7]] [
            ;print ["(length? path-words) > (list-clicked - 3) er"
            ;        (length? path-words) > (list-clicked - 3)]
            ;print ["length? path-words er" (length? path-words)]
            ;print ["list-clicked er" list-clicked]
            move-lists-right
            list-clicked: min 7 list-clicked + 1
          ]
          append path-words to-append
          path-text/text: to-path path-words
          show path-text
          ; set up right highlight colour:
          for x 4 7 1 [
            face/parent-face/pane/:x/iter/feel/set-high-col either (x = list-clicked) [240.240.50] [130.130.130]
            show face/parent-face/pane/:x
          ]
          ;print ["list-index er" list-index "og list-clicked er" list-clicked]
          list-index: list-clicked + 1 ; list-index is the one we're manipulating,
                                       ; i.e. the one to the right of list-clicked
          ;print "^(1B)[J" ; clear screen ; ] (added end bracket so that textpad may find the right brackets)
          to-display: do compose [(to-path path-words)] ;to-path path-words
          c: do compose [(to-path copy/part path-words (length? path-words) - 1)]
          if unset? get/any in c last path-words [
            pop-up join form to-path path-words ": undefined"
            if list-index = 8 [ list-index: 7 ]
            return
          ]
          if any-function? get in c last path-words [
            cc: get in c last path-words
            pop-up source-string cc
            if list-index = 8 [ list-index: 7 ]
            return
          ]
          if object? get in c last path-words [
            if list-index = 8 [ ; 8 would be the slider bar
              ;print ""
              ;print reduce ["list4/lines er" mold list4/lines]
              move-lists-left
              list4/iter/feel/set-high-col 240.240.50
              list-index: 7
            ]
            ;face/parent-face/pane/:list-index/lines: sort first to-display
            face/parent-face/pane/:list-index/lines: sort first get in c last path-words
            face/parent-face/pane/:list-index/data: sort first get in c last path-words
            clear face/parent-face/pane/:list-index/picked
            update-slider face/parent-face/pane/:list-index
            show face/parent-face/pane/:list-index ; update this view again
            return
          ]
          if port? get in c last path-words [
            pop-up mold get in c last path-words
            if list-index = 8 [ list-index: 7 ]
            return
          ]
          if block? get in c last path-words [
            pop-up mold get in c last path-words
            if list-index = 8 [ list-index: 7 ]
            return
          ]
          pop-up to-string to-display
          if list-index = 8 [ list-index: 7 remove back tail path-words ]
        ] ; end face/picked not ""
      ] ; end event/1 = 'up
      return event
    ] ; end detect
  ] ; end list
] ; end main-styles
move-lists-left: func [] [
  ;print "Flytter listene ett hakk til venstre"
  list1/lines: head copy list2/lines
  list1/picked: copy list2/picked
  list1/iter/feel/set-high-col list2/iter/feel/high-col
  show list1
  update-slider list1
  list2/lines: head copy list3/lines
  list2/picked: copy list3/picked
  list2/iter/feel/set-high-col list3/iter/feel/high-col
  show list2
  update-slider list2
  list3/lines: head copy list4/lines
  list3/picked: copy list4/picked
  list3/iter/feel/set-high-col list4/iter/feel/high-col
  show list3
  update-slider list3
  ; don't need to mess with list4, as we do so in feel code itself
]
move-lists-right: func [/local to-remove list1-path] [
  list4/lines: head copy list3/lines
  list4/picked: copy list3/picked
  show list4
  update-slider list4
  list3/lines: head copy list2/lines
  list3/picked: copy list2/picked
  show list3
  update-slider list3
  list2/lines: head copy list1/lines
  list2/picked: copy list1/picked
  show list2
  update-slider list2
  to-remove: (length? path-words) - (list-clicked - 3)
  list1-path: to-path head remove/part at copy path-words ((length? path-words) - (to-remove - 1)) to-remove
  list1/lines: sort first list1-path
  list1/picked: to-block first find head list1/lines first at path-words ((length? path-words) - (to-remove - 1))
  show list1
  update-slider list1
]
update-slider: func [faces [object! block!]] [
  foreach lv-list to-block faces [
    lv-list/sn: 0
    lv-list/sld/data: 0
    lv-list/sld/redrag lv-list/lc / max 1 length? head lv-list/lines
    show lv-list
  ]
]
pop-up: func [to-show /name 'word] [
  l: layout [
    info 300x300 to-show
    button "Close" [hide-popup]
  ]
  inform l
]
source-string: func [
    "Returns the source code for a word, as a string."
    'word [word!]
    /local return-value
][
    ;return-value: join "system/words/" [word ": "]
    return-value: to-string reduce [word ": "]
    if not value? word [append return-value "undefined" return return-value]
    if native? get word [
        append return-value "native"
        append return-value mold third get word
        return return-value
    ]
    if op? get word [
        append return-value "op"
        append return-value mold third get word
        return return-value
    ]
    if action? get word [
        append return-value "action"
        append return-value mold third get word
        return return-value
    ]
    append return-value mold get word
    return return-value
]
PROB: func ['to-be-probed] [
  if not value? 'to-be-probed [to-be-probed: 'system]
  if any [any-function? get to-be-probed port? get to-be-probed] [
    pop-up source-string :to-be-probed
    exit
  ]
  clear path-words
  append path-words to-be-probed
  to-display: do compose [(to-path path-words)] ;to-path path-words
  dom?: attempt [do-browser "true;"]
  link: either dom? ["Try Romano Paolo Tenca's AnaMonitor!"] [""]
  main: layout [
    styles main-styles
    title "Primitive Rebol Object Browser"
    text "Current path: "
    path-text: text form to-path path-words 745x16
    across
    list1: list data sort first to-display
    list2: list
    list3: list
    list4: list
    below
    ;slider1: slider 745x16 [
    ;]
    across
    button "Quit" [quit]
    box 400x1
    text 200 underline blue center link feel [
      over: func [face act pos] [
        face/font/style: either act [[bold]][[underline]]
        show face
      ]
      engage: func [face action event] [
        if action = 'down [ if dom? [ do-browser {top.location.href="http://www.rebol.net/plugin/demos/anamonitor.html";} ] ]
      ]
    ]
  ]
  list1/iter/feel: make list1/iter/feel [
    high-col: 240.240.50 ; actually rebol default colour.
    set-high-col: func [colour] [
      high-col: colour
    ]
    redraw: func[f a i] bind [
      f/color: either find picked f/text [high-col] [slf/color]
    ] in list1 'self
  ]
  list2/iter/feel: make list2/iter/feel [
    high-col: 240.240.50
    set-high-col: func [colour] [
      high-col: colour
    ]
    redraw: func[f a i] bind [
      f/color: either find picked f/text [high-col] [slf/color]
    ] in list2 'self
  ]
  list3/iter/feel: make list3/iter/feel [
    high-col: 240.240.50
    set-high-col: func [colour] [
      high-col: colour
    ]
    redraw: func[f a i] bind [
      f/color: either find picked f/text [high-col] [slf/color]
    ] in list3 'self
  ]
  list4/iter/feel: make list4/iter/feel [
    high-col: 240.240.50
    set-high-col: func [colour] [
      high-col: colour
    ]
    redraw: func[f a i] bind [
      f/color: either find picked f/text [high-col] [slf/color]
    ] in list4 'self
  ]
  view main
]
prob system