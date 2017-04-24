REBOL [
    Title: "HTML Rainbow generator for Rebol/View"
    Date: 31-May-2001/1:18-7:00
    Version: 1.0.1
    File: %view-rainbow.r
    Author: "Cal Dixon"
    Purpose: {Create HTML color fade effects.  Places output on the  clipboard}
    Email: rebol@programmer.net
    Web: http://flyingparty.com/deadzaphod/
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: [GUI web markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

window: layout [
   sourcetext: area "Type text to rainbowize here."
   across
   startcolor: button black "Start Color" [
      face/color: request-color/color any [face/color gray]
      show face
      ]
   endcolor: button black "End Color" [
      face/color: request-color/color any [face/color gray]
      show face
      ]
   return
   button "Make HTML" [
      if not empty? sourcetext/text [
         html: rainbow-html sourcetext/text startcolor/color endcolor/color
         write clipboard:// html
         if confirm "Result has been sent to clipboard. View it now?" [
            write %temp-rainbow.html reduce [<HTML><BODY> html </BODY></HTML>]
            browse %temp-rainbow.html
         ]
         ]
      ]
   label "The resulting HTML will be placed on the clipboard"
   ]

rainbow-html: func [ text color1 color2 /local
   out steps difblock stepblock color rs gs bs r g b i letter
   ] [
   steps: -1 + length? replace/all copy text " " ""
   difblock: reduce [
      ((pick color2 1) - (pick color1 1))
      ((pick color2 2) - (pick color1 2))
      ((pick color2 3) - (pick color1 3))
      ]
   stepblock: reduce [
      to-integer ((pick difblock 1) / steps)
      to-integer ((pick difblock 2) / steps)
      to-integer((pick difblock 3) / steps)
      ]
   color: reduce [ pick color1 1 pick color1 2 pick color1 3 ]
   set [ rs gs bs ] stepblock
   out: copy ""
   for i 1 steps 1 [
      until [
         letter: pick text 1
         text: next text
         either letter = #" " [ append out " " false ] [ true ]
         ]
      append out rejoin [ {<font ^/color="} skip to-hex to-integer to-binary color 2 {">}
         letter {</font>} ]
      set [ r g b ] color
      color: reduce [ (r + rs) (g + gs) (b + bs) ]
      ]
   color: reduce [ pick color2 1 pick color2 2 pick color2 3 ]
   letter: last head text
   append out rejoin [ {<font color="} skip to-hex to-integer to-binary color 2 {">}
      letter {</font>} ]
   return out
   ]

view window
quit
