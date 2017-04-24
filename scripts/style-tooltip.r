REBOL [
  Library: [
     level: 'intermediate
     platform: 'all
     type: [tool]
     domain: [vid]
     tested-under: "win2k"
     support: "shadwolf/france groupe on altme"
     license: 'public-domain
     see-also: none
   ]
 
  Title: "style-tooltip.r"
   File: %style-tooltip.r	
   Author: "Shadwolf, Boss, DideC" 
   Date: 29-Nov-2004
   Version: 1.0	
   Purpose: "Use in the simplest way the tooltip. This is a first intent it's a little bit deprecated and we have worked on a better way to generate and handle tooltips. I share this with you because I think this code have a good educationnal value and is a good point start if you are interested in tooltips avanced filnal version please visit http://rebol.agora-dev.org/ . Sample script is added in documentation related to this script" 	
] 	
 	
stylize/master [ 	
 	
    tooltip: face with [ 	
        size: 1x1 widget: none help-text: none show?: false 	
        effect-face: func [ 	
           {BOOS- Permet d'ajouter du code dans le gestionnaire d'événements d'une facet. 	
           Le code ajouté peut faire usage des variables f a e  (la face, l'action et l'événement courants)} 	
            face [object!]      ; objet de type face (facet) 	
            fu   [word!]        ; au choix 'engage  'detect 'over 'redraw 	
            code                ; block contenant le code à ajouter 	
        ][ 	
              set in face/feel :fu func [face act evt] bind append compose [ 	
            (get in face/feel :fu)  face act evt; ancien code avant ajout de la gestion du tooltip 	
             ] code in face/feel :fu 	
        ] 	
        over-tooltip: make block! [ {made by BOSS} 	
            either act [ 	
                if not find face/parent-face/pane helper [append face/parent-face/pane helper] 	
                helper/offset: face/offset + 10x10 	
                helper/text: copy face/help 	
                    helper/size: as-pair ( 6 * (length? helper/text) )  16 	
                show helper 	
            ][ 	
                hide helper 	
                show face/parent-face 	
            ]] 	
        init:  [ 	
            if not in system 'helper [ 	
                helper: make-face 'box 	
                helper/font: make helper/font [align: 'left size: 10 name: 'arial color: black shadow: none valign: 'middle] 	
                helper/edge: make helper/edge [size: 1x1 color: black] helper/color: 250.250.210 	
                helper/show?: false helper/rate: 0:0:5                  ; durée d'affichage de l'info-bulle 	
                helper/feel: make helper/feel [ 	
                        engage: func [face action event][ if action = 'time [ hide helper ]] 	
            ]] 	
             set [ 'widget 'help-text] data 	
            widget/help: to-string copy help-text 	
            ;on affect les evenements au widget 	
             effect-face widget 'over over-tooltip 	
             show compose [ (widget/var) ] 	
             widget: make none help-text: make none 	
             recycle 	
] ] ] 