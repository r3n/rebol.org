REBOL [ 
   File: %list-supply-how-to.r
   Date: 2006-04-19
   Title: "List How-To" 
   Purpose: "How-To use a list and the 'supply block" 
   library: [
        level: 'beginner
        platform: 'all
        type: [how-to]
        domain: [gui]
        tested-under: [winxp]
        license: [bsd]
        support: none
    ]
   Comment: {
      I just extracted this out of a script, in answer to a question on the ml.
      Thats why the names may seem a little odd ;-)

      I myself got it from one of Carls scripts once. 

      The slider is not updated when the list-data changes, this is left as an
      exercise to the reader :-)
   }
]


comm-list-data: [
   ["first 1" "first 2"]
   ["second 1" "second 1"]
   ["third 1" "third 3"]
]

comm-sld-cnt: 0 ; needed to connect the slider to the list

view layout [

   across
   comm-list: list 280x200 [
      across t1: text 100 t2: text 100
   ] supply [
      ; supply block is the body of a function that is called like this:
      ; supply: func [face count index]
      ; face the current face, thus either t1 or t2
      ; count like the "linenumber" in the display
      ; index for every "line" it is called twice, once for t1, once for t2
      ;       (and so on for more elements), index tells you which face in
      ;       the current "line" it is

      ; add the slider offset (comm-sld-cnt) to the "linenumber" (count)
      ; to find the position in your data
      count: count + comm-sld-cnt ;comm-sld-cnt is from the slider ...

      ; if we're out of data, we can set everything to none, and exit
      if none? v: pick comm-list-data count [
         ; set color to background color, otherwise the last color would be used
         face/color: snow 
         ; set face/text to none, otherwise last text would be used
         face/text: none 
         ; nothing else to do, exit
         exit
      ]

      ; color the lines in alternating colors
      face/color: either even? count [ivory - 50.50.50][ivory]

      ; now set the text ...
      face/text: pick v index
   ]
   comm-sld: slider 16x200 [
      comm-sld-c: max 0 to-integer (length? comm-list-data) * value
      if comm-sld-c <> comm-sld-cnt [comm-sld-cnt: comm-sld-c show comm-list]
   ]

   return

   button "Add" [
      append/only comm-list-data reduce [form random 1000 form random 1000]
      show comm-list
   ]

   button "Remove" [
      remove back tail comm-list-data
      show comm-list
   ]
]
