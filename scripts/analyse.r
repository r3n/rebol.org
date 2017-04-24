REBOL [
    Title: "Script Analyser"
    Date: 13-Jan-2003
    Version: 1.0.1
    File: %analyse.r
    Author: "JL MEYRIAL"
    Needs: %anamonitor.r
    Usage: { - You can Insert the word break_analyse in the script to analyse for stopping evaluation at breakpoints 
                - Run analyse.r (do %analyse.r)
                - Then Select the script to evaluate with the "local" or "URL" choice button
              }
    Purpose: {Front-End User Interface for anamonitor to analyse a rebol script. }
    History: "^/           1.0.0 - Creation^/       "
    Email: jl_meyrial@ciriel.fr
    Category: [util vid view]
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: []
        tested-under: none
        support: none
        license: none
        see-also: none
        ]
] 

explor: context [
   defword: none
   l_liste: make block! []
   scroll-off: 0
   sizefspec: 0x0
   scan_ana:  [ object! port! block! hash! list! ]
   lef: func [data num [integer!]][
            data: to-string data
            head insert/dup tail data " " max 0 num - length? data
   ]
   affiche-listes: does [
      fix-slider: func [ faces [object! block!]]
      [
         foreach list to-block faces
         [
;           print length? list/lines print list/lc
            either 0 = length? list/lines
            [ list/sld/redrag 1 ]
            [ list/sld/redrag list/lc / length? list/lines ]
         ]
      ]
      fix-slider f_lis
      show f_lis
   ]
   p_appel_monitor: func [ strobj [string!] /local f_ana f_text redrag-txt ]
   [
      redrag-txt: func [face sld][sld/redrag min 1 face/size/y / second size-text face]
      f_ana: to-word (first parse strobj none)
      either found? find scan_ana type?/word (get in system/words f_ana)
      [   do reduce ['monitor f_ana] ]
      [
         either function? get in system/words f_ana
         [ f_text:  detab (mold get in system/words f_ana) ]
         [ f_text:  detab (form get in system/words f_ana) ]
         view/new/offset/title layout [ across ar: area f_text sld: slider 15x150 [scroll-para ar sld]
                                do [redrag-txt ar sld] ]
                                    l_lay/size * 0x1 + l_lay/offset form f_ana
      ]
   ]
   new_view: func [data /new /offset xy /options opts /title text] [
      view_layout: data
   ]
   p_eval: func [file /local scr scr1 ret breakpt]
   [
      scr: read/lines file
      scr1: make string! ""
      breakpt: false
      forall scr
      [
    if find first scr "break_analyse" [
           change/part find first scr "break_analyse" 
                       reduce ["throw " (join {"ligne } [(index? scr) ": " (first scr) {"}])] 13
           breakpt: true
        ]
        append scr1 reduce [(first scr) newline ]
      ]
      either breakpt
      [ append scr1 {throw "End"} ret: catch load scr1 ]
      [ ret: [] catch load scr1 ]
      f_bpt/text: copy "Breakpoint at "
      either string? ret
         [ append f_bpt/text ret]
         [ append f_bpt/text "End"]
      show f_bpt
   ]
   p_analyse: func [/local b_fic file mot save_view f_val def1]
   [
      save_view: :view
      view: :new_view
      b_fic: to-block f_script/text
      foreach file b_fic
      [
         either f_type/text = "URL"
         [
            if not url? file
            [ file: to-url file ]
         ]
         [
            if not file? file
            [ file: to-file file ]
         ]
         if not none? defword 
         [   foreach mot defword [unset mot] ]
         if value? 'view_layout [ unset 'view_layout]
         def1: first system/words
     if all [ exists? file not dir? file ]
         [ p_eval file ]
         defword: exclude (first system/words) def1
         f_lis/lines: copy [] 
if value? 'view_layout 
[ 
   append f_lis/lines rejoin [lef "view_layout" 21 " " lef 'object 6 ]
]
         foreach mot defword
         [
            if error? try
            [  
               if value? get in system/words mot
               [
;                  either found? find scan_ana type?/word (get in system/words mot)
                  either any [ found? find scan_ana type?/word (get in system/words mot)
                               function? (get in system/words mot) ]
                  [ f_val: copy " "]
                  [ f_val: rejoin [ " : " (to-string get in system/words mot)] ]
                  append f_lis/lines rejoin [lef mot 21 " " lef type? get in system/words mot 6 
                  f_val ]
               ]
            ] [ ]
         ]
      ]
      affiche-listes
      view: :save_view
   ]
   p_choix: func [n_choix /local files ]
   [
      if n_choix = "local"
      [
         if files: request-file
         [
            f_script/text: files show f_script
         ]
      ]
   ]
   l_lay: layout [
      style text_l text middle font-size 11
      across
      f_type: choice "URL" "local" [ p_choix first value p_analyse ]
      f_script: field 300 "Rebol script to analyse"
      return
      below
      f_bpt: text 410
      text "WORDS" 
      f_lis: text-list 410x200 black font-name font-fixed font-size 12 no-wrap
             [ p_appel_monitor first f_lis/picked ]
   ]
]

my_local_user: true
do %anamonitor.r
view explor/l_lay                                                                                                                                                            