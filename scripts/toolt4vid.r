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
 
  Title: "tooltipVid.r"
   File: %toolt4vid.r   
   Author: "Shadwolf, Boss, DideC, Volker" 
   Date: 3-Feb-2006
   Version: 1.0 
   Purpose: "Tooltip for VID (less bugged than previous version. This work is the mixing of  2 different ways to handle tooltips in vid not using style package anymore"  
]   

; cut here until end and add it to your own REBOL/View script can be externalise too 

tip-face: none
untip: has [win p] [
    if all [ tip-face        win: find-window tip-face  p: find win/pane tip-face ] [
        remove p   hide tip-face tip-face: none
    ]
]

tip: func [face offset act te /local win] [
     untip
     if act [
        win: find-window face
        layout/tight [
           tip-face: text (te) gold black  rate 0:0:3 
            feel [ engage: func [face action event][  
       if action = 'time [ if face/show? [hide face]  ] ] ] 
        ]
        tip-face/offset:  either  face/offset/x > ((face/parent-face/size/x / 4) * 3) 
     [ as-pair (offset/x - tip-face/size/x ) offset/y ] [offset - 20x0 ]
        append win/pane tip-face show win
    ]
]

tip-over: make block! [if all[in f 'tooltip f/tooltip (length? f/tooltip) > 0] [   tip f e a f/tooltip ]]

effect-face: func [  
    {Permet d'ajouter du code dans le gestionnaire d'événements d'une facet.  
        Le code ajouté peut faire usage des variables f a e  (la face, l'action et l'événement courants)}  
    face [object!]      ; objet de type face (facet)  
    fu   [word!]        ; au choix 'engage  'detect 'over 'redraw  
    code                ; block contenant le code à ajouter  
][  
  set in face/feel :fu func [f a e] bind append compose [  
    (get in face/feel :fu) f a e  ; ancien code avant ajout de la gestion du tooltip
     ] code in face/feel :fu  
]

Add-tooltip-2-style: func [ { Allow to add the  tooltip support to all widgets passed in parameter}
    style-lst [block! ] "Contains the listing of Vid widgets to patch"
    style-root "Countain the path of the root-styles to patch"
][
    foreach style style-lst [
        if find style-root style [     ; Teste si le style existe pour la compatibilité avec les versions antérieures de view
                effect-face style-root/:style 'over tip-over
        ]
    ]
]

; here is the list of widget affected by the tooltip ability
vid-styles: [image btn backtile box sensor key base-text vtext text body txt banner vh1 vh2 vh3 vh4 
             title h1 h2 h3 h4 h5 tt code button check radio check-line radio-line led 
             arrow toggle rotary choice drop-down icon field info area slider scroller progress 
             anim btn-enter btn-cancel btn-help logo-bar tog]

Add-tooltip-2-style vid-styles system/view/vid/vid-styles 


; end of cut

; HOWTO USE IT CODE CODE;
view win: layout [
    area "another face" with [tooltip: "an area"]
    panel [across
        button "test" with [tooltip: "the first button" ]
        button "test2" with [tooltip: "the second button" ]
    ]
]


