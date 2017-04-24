REBOL [
    Title: "Reversi"
    Date: 27-Mar-2006
    Version: 2.3.0
    File: %reversi.r
    Author: "Vincent Ecuyer"
    Purpose: "Reversi / Othello"
    Usage: {
        ===English

        Classic Reversi / Othello game.

        It's a two players board game, where the objective is to cover the
        board with the greatest number of pieces of your chosen color.

        The first four pieces must be placed at the center of the plate,
        then the normal game begins.

        At each turn, each player puts a two faced piece on the board -
        all adjacent opponent pieces between the new one and the ones on the
        board are reversed to match the player color:

        right after the start:               after more turns: (two diagonals
        (one horizontal line reversed)       and one vertical lines reversed)
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .
        . . . . . . . .   . . . . . . . .    . . . X . . . .   . . . X . . . .
        . . . . . . . .   . . . . . . . .    . . . X v X . .   . . . X O X . .
        . . . O X v . . > . . . O O O . .    . . X X X X . . > . . X O O O . .
        . . . X O . . . > . . . X O . . .    . . X X X X O . > . . O X O X O .
        . . . . . . . .   . . . . . . . .    . O O O O O X .   . O O O O O X .
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .

        If it doesn't reverse opponent pieces, you can't place a piece on the
        board - you must skip your turn.

        The game ends when the board is fully covered, or when both players
        can't puts pieces on the plate anymore.

        This script allows you to play against another player or a basic AI .

        If the game starts in french, change the first code line from
            language: 'francais
        to
            language: 'english
        .

        ===Français

        Le jeu Reversi, aussi appelé Othello.

        C'est un jeu de plateau pour deux joueurs, où l'objectif est de
        couvrir le plateau avec le plus grand nombre de pièces de votre
        couleur.

        Les quatre premières pièces doivent être placées sur les cases du
        centre du plateau, puis la partie normale commence.

        Dans un tour, chaque joueur place une pièce à deux faces sur le
        plateau - toutes les pièces adjacentes de l'adversaire situées entre
        la nouvelle pièce et les pièces déjà placées sont retournées pour
        présenter la couleur du joueur:

        juste après le début:                 plus tard dans la partie: (deux
        (une ligne horizontale retournée)diagonales et une colonne retournées)
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .
        . . . . . . . .   . . . . . . . .    . . . X . . . .   . . . X . . . .
        . . . . . . . .   . . . . . . . .    . . . X v X . .   . . . X O X . .
        . . . O X v . . > . . . O O O . .    . . X X X X . . > . . X O O O . .
        . . . X O . . . > . . . X O . . .    . . X X X X O . > . . O X O X O .
        . . . . . . . .   . . . . . . . .    . O O O O O X .   . O O O O O X .
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .
        . . . . . . . .   . . . . . . . .    . . . . . . . .   . . . . . . . .                                                           .......   ........

        Vous devez retourner des pions de l'adversaire à chaque coup - si
        c'est impossible vous passez votre tour.

        La partie se termine lorsque le plateau est recouvert où lorsque aucun
        joueur ne peut placer de pion.

        Ce script vous permet de jouer contre un autre joueur où contre une 
        AI basique.

        Pour jouer en français, changez la première ligne de code de
            language: 'english
        en
            language: 'francais
        .
    }
    Library: [
        level: 'advanced
        platform: 'all
        type: 'game
        domain: [gui vid game]
        tested-under: [
            view 1.3.2.3.1 on [Win2K]
            view 1.2.1.1.1 on [AmigaOS30]
            view 1.2.1.3.1 on [Win2K]
        ]
        support: none
        license: 'gpl
        see-also: none
    ]
    History: [
        1.0.0 26-7-2001
            "Première version jouable"
        2.0.0 15-5-2002
            "Première version publique. Refonte du moteur et ajout du niveau de difficulté"
        2.1.0 2-2-2004
            "Nettoyage du code pour View 1.3 et amélioration du redimensionnement."
        2.2.0 28-1-2005
            "Plus de libertés pour le redimensionnement."
        2.3.0 27-3-2006
            "Refonte de l'interface."
    ]
]

; ===Localisation

; choix de la langue/language selection (actuellement, 'francais ou 'english)
language: 'english

; textes de l'application
locale-strings: [
    francais [
        doc [
            usage {
Le jeu commence en mode deux joueurs.

Le premier bouton indique le mode de jeu actuel,
et permet de le modifier.

Le second règle le niveau de difficulté:
    - minimum : un des trois meilleurs coups trouvés est joué
    - moyen   : un des deux meilleurs coups trouvés est joué
    - maximum : le meilleur coup trouvé est joué
}
            usage-title "Utilisation"
            usage-close "(cliquez sur la fenêtre pour la fermer)"
        ]
        mode [
            human-human "2 joueurs"
            computer-white "Ordinateur joue blancs"
            computer-black "Ordinateur joue noirs"
        ]
        level [
            min "Minimum" med "Moyen" max "Maximum"
        ]
        button [
            skip "Passer le tour" end "Fin de la partie"
        ]
        score [
            draw "Egalité"
            white "Joueur blanc gagnant"
            black "Joueur noir gagnant"
        ]

    ]
    english [
        doc [
            usage {
The game starts in two players mode.

The leftmost button shows the current mode,
and allows to change it.

The second button controls difficulty:
    - minimum : one of the three best moves is played
    - medium  : one of the two best moves is played
    - maximum : the best move is played
}
            usage-title "Usage"
            usage-close "(click on this window to close it)"
        ]
        mode [
            human-human "2 Players"
            computer-white "Computer plays light"
            computer-black "Computer plays dark"
        ]
        level [
            min "Minimum" med "Medium" max "Maximum"
        ]
        button [
            skip "Skip turn" end  "End game"
        ]
        score [
            draw "Draw game"
            white "Light Wins"
            black "Dark Wins"
        ]
    ]
]

; fonction de localisation
locale: func [
    "Sélectionne la chaîne dans la langue courante."
    'name [word! path!] "Nom de la chaîne"
    /local r
][
    r: locale-strings/:language
    foreach i :name [r: r/:i]
]

; ===Aspect visuel

; motif de fond du plateau 
; (ici, le motif %wood1.pat de GIMP, avec l'effet [colorize 170.100.70])
fond.png: load 64#{
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
/p0+lCkKJWo8AAAAASUVORK5CYII=}

; apparence des jetons (en réalité, des cases)
jeton-effects: [
     noir [
         gradient 1x1 127.127.127 0.0.0
         oval 255.255.255
         key 255.255.255
     ]
     blanc [
         gradient 1x1 255.255.255 128.128.128
         oval 255.255.255
         key 255.255.255
     ]
     vide none
]

; ===Déclaration des styles de l'application

reversi-style: stylize [
    ; interface
    button: button gold
        font [colors: [0.0.0 255.0.0] shadow: none]
        effect []
        edge [size: 1x1 color: 0.0.0]
    choice: choice gold white
        font [colors: [0.0.0 255.0.0] shadow: none]
        effect []
        edge [size: 1x1 color: 0.0.0]
    ; jetons noirs et blancs
    jeton: box 74x74 with [
        ; 'noir, 'blanc ou 'vide
        data: 'vide
        ; coordonnées sur le plateau en cases
        coords: none
        ; listes des cases adjacentes (pour simplifier les calculs)
        gauche: droite: haut: bas: none
        haut-gauche: haut-droite: bas-gauche: bas-droite: none
        ; déclarations dans layout
        words: [
            noir [
                new/data: 'noir
                new/effect: jeton-effects/noir
                next args
            ]
            blanc [
                new/data: 'blanc
                new/effect: jeton-effects/blanc
                next args
            ]
            vide [
                new/data: 'vide
                new/effect: jeton-effects/vide
                next args
            ]
        ]
    ]
    ; clic gauche
    [
        ; si le coup est valide
        if essaie-coup face [
            ; case modifiée
            face/data: face/parent-face/joueur
            face/effect: select jeton-effects face/data
            face/parent-face/joueur: select [blanc noir blanc] face/data
            ; affichage pour le joueur suivant
            fenetre/color: 
                select [blanc 255.255.255 noir 0.0.0] plateau/joueur
            show [fenetre face]
            ; pour suivre le déroulement de la partie
            coups: coups + 1
            ; plateau plein => fin
            if coups = 64 [do-face fin 'down return]

            ; si coup joué par la machine
            if plateau/joueur = ordinateur [
                ; attente avant de jouer, pour voir le coup
                wait 0.5
                use [case][
                    ; jouer le meilleur coup, sinon passer le tour
                    either case: meilleur-coup plateau/joueur [do-face case 'down][
                        do-face passer 'down
                        if not meilleur-coup plateau/joueur [do-face fin 'down]
                    ]
                ]
            ]
        ]
    ]
    ; apparence du plateau de jeu (taille: 8x8 cases + bordure)
    grille: box fond.png 602x602 with [
        joueur: 'blanc
        effect: [tile grid 75x75 0x0 34.20.14 2]
        data: array/initial [8 8] 'vide
    ]
]

; ===Fonctions d'accès aux tableaux simulés

; primitives d'accès
x-pos: func [
    "Primitive de conversion linéaire -> table."
    table [any-block!] "Série"
    width [integer!] "Largeur de la table"
][
    (-1 + index? table) // width + 1
]
y-pos: func [
    "Primitive de conversion linéaire -> table."
    table [any-block!] "Série"
    width [integer!] "Largeur de la table"
][
    1 + to-integer (-1 + index? table) / width
]

; copies à partir d'un point

gauche: func [
   "Copie tous les éléments à gauche de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local y
][
   if 1 >= x-pos table size/x [return copy []]
   y: y-pos table size/x
   head reverse copy/part skip head table y - 1 * size/x table
]
droite: func [
   "Copie tous les éléments à droite de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local y
][
   if size/x <= x-pos table size/x [return copy []]
   y: y-pos table size/x
   copy/part next table skip head table y * size/x
]
haut: func [
   "Copie tous les éléments en haut de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local y block b-size sk
][
   if 1 >= y: y-pos table size/x [return copy []]
   block: make block! b-size: y - 1
   table: skip table sk: (- size/x)
   loop b-size [append block table/1 table: skip table sk]
   block
]
bas: func [
   "Copie tous les éléments en bas de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local y block b-size sk
][
   if size/y <= y: y-pos table size/x [return copy []]
   block: make block! b-size: size/y - y
   table: skip table sk: size/x
   loop b-size [append block table/1 table: skip table sk]
   block
]
haut-gauche: func [
   "Copie tous les éléments en haut à gauche de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local x y block b-size sk
][
   if 1 >= x: x-pos table size/x [return copy []]
   if 1 >= y: y-pos table size/x [return copy []]
   block: make block! b-size: min x - 1 y - 1
   table: skip table sk: (-1 - size/x)
   loop b-size [append block table/1 table: skip table sk]
   block
]
haut-droite: func [
   "Copie tous les éléments en haut à droite de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local x y block b-size sk
][
   if size/x <= x: x-pos table size/x [return copy []]
   if      1 >= y: y-pos table size/x [return copy []]
   block: make block! b-size: min size/x - x y - 1
   table: skip table sk: (1 - size/x)
   loop b-size [append block table/1 table: skip table sk]
   block
]
bas-gauche: func [
   "Copie tous les éléments en bas à gauche de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local x y block b-size sk
][
   if      1 >= x: x-pos table size/x [return copy []]
   if size/y <= y: y-pos table size/x [return copy []]
   block: make block! b-size: min x - 1 size/y - y
   table: skip table sk: (size/x - 1)
   loop b-size [append block table/1 table: skip table sk]
   block
]
bas-droite: func [
   "Copie tous les éléments en bas à droite de la case."
   table [any-block!] "Série"
   size [pair!] "Dimensions de la table"
   /local x y block b-size sk
][
   if size/x <= x: x-pos table size/x [return copy []]
   if size/y <= y: y-pos table size/x [return copy []]
   block: make block! b-size: min size/x - x size/y - y
   table: skip table sk: (size/x + 1)
   loop b-size [append block table/1 table: skip table sk]
   block
]

; ===Initialisations de la partie

coups-depart: func [
    "Cases autorisées en début de partie"
    /local p
][
    p: plateau/pane
    p/28/effect: p/29/effect: p/36/effect: p/37/effect: [merge tint 60]
]
; Pas de coup joué
coups: 0
; Mode 2 joueurs
ordinateur: none

; ===Déclaration et initialisation de la fenêtre

fenetre: layout [
    ; Styles prédéfinis plus haut
    styles reversi-style

    ; 'blanc commence
    backcolor white

    across

    ; Sélection de l'adversaire
    mode: choice 178
        locale mode/human-human 
        locale mode/computer-white
        locale mode/computer-black
    [
        if all [
            ; si en mode 1 joueur...
            ordinateur: select reduce [1 none 2 'blanc 3 'noir]
                index? find mode/texts mode/text
            ; ...et tour de l'ordinateur
            plateau/joueur = ordinateur
        ][
            ; Coup de la machine
            use [case][
                ; attente avant de jouer, pour voir le coup
                wait 0.5
                ; jouer le meilleur coup, sinon passer le tour
                either case: meilleur-coup plateau/joueur [do-face case 'down][
                    do-face passer 'down
                    if not meilleur-coup plateau/joueur [do-face fin 'down]
                ]
            ]
        ]
    ]

    ; Sélection du niveau de difficulté en mode 1 joueur
    niveau: choice locale level/min locale level/med locale level/max

    ; Passer le tour
    passer: button locale button/skip 136 [
        plateau/joueur: select [blanc noir blanc] plateau/joueur
        fenetre/color:
            select [blanc 255.255.255 noir 0.0.0] plateau/joueur
        show fenetre
        ; Coup de la machine si en mode 1 joueur
        if plateau/joueur = ordinateur [
            use [case][
                ; attente avant de jouer, pour voir le coup
                wait 0.5
                ; jouer le meilleur coup, sinon passer le tour
                either case: meilleur-coup plateau/joueur [do-face case 'down][
                    do-face passer 'down
                    if not meilleur-coup plateau/joueur [do-face fin 'down]
                ]
            ]
        ]
    ]

    ; Terminer la partie et donner le résultat
    fin: button locale button/end 136 [
        use [total-blanc total-noir][
            ; calcul des totaux
            total-blanc: total-noir: 0
            foreach p plateau/pane [
                if p/data = 'blanc [total-blanc: total-blanc + 1]
                if p/data = 'noir  [total-noir: total-noir + 1]
            ]

            ; égalité
            either total-blanc = total-noir [
                inform layout [
                    backdrop effect [gradient 1x0 255.255.255 0.0.0]
                    banner green locale score/draw font [shadow: 1x1] feel none
                ]
            ][
                ; blanc gagnant
                either total-blanc > total-noir [
                    inform layout [
                        backcolor white
                        banner red locale score/white font [shadow: 1x1] feel none
                    ]
                ][
                    ; noir gagnant
                    inform layout [
                        backcolor black
                        banner locale score/black font [shadow: 1x1] feel none
                    ]
                ]
            ]

            ; réinitialisation du plateau et des drapeaux
            foreach p plateau/pane [p/data: 'vide p/effect: none]
            coups: 0
            plateau/joueur: 'blanc
            ordinateur: none
            mode/text: first find mode/texts locale mode/human-human
            fenetre/color: white
            ; positions de départ
            coups-depart

            show [fenetre mode] show plateau/pane
        ]
    ]
    ; aide du jeu
    aide: button "?" 20 [
        inform layout [
            backcolor rebolor
            banner locale doc/usage-title
            text as-is locale doc/usage
            text locale doc/usage-close
        ]
    ]
    return

    ; plateau de jeu
    plateau: grille with [
        ; initialisation par des cases vides
        pane: get in (layout append copy [
            styles reversi-style
            origin 1x1 space 1x1 across
        ] head insert/dup copy [] append insert/dup copy [] [jeton vide] 8 'return 8) 'pane
        init: [
            ; déclaration des références entre les cases
            use [x y p][
                x: y: 1
                p: pane
                forall p [
                    p/1/coords: to-pair reduce [x y]
                    p/1/gauche: gauche p 8x8
                    p/1/droite: droite p 8x8
                    p/1/haut: haut p 8x8
                    p/1/bas: bas p 8x8
                    p/1/haut-gauche: haut-gauche p 8x8
                    p/1/haut-droite: haut-droite p 8x8
                    p/1/bas-gauche: bas-gauche p 8x8
                    p/1/bas-droite: bas-droite p 8x8
                    x: x + 1
                    if x = 9 [x: 1 y: y + 1]
                ]
                pane: head pane
            ]
        ]
    ]
]

; ===Moteur logique du jeu

; validité d'un coup
essaie-coup: func [
    "Vérifie si un coup est valide."
    face "Case jouée"
    /local f-l c ok b
][
    ; place occupée -> faux
    if 'vide <> face/data [return false]

    ; coups d'introduction, seulement au centre
    if coups < 4 [
        use [p][
            p: face/parent-face/pane
            return either any [p/28 = face p/29 = face p/36 = face p/37 = face][true][false]
        ]
    ]

    ; cherche la présence voisine de jetons de l'adversaire suivis d'un jeton de même couleur
    ok: false
    c: face/parent-face/joueur
    foreach f-l [gauche droite haut bas haut-gauche haut-droite bas-gauche bas-droite][
        if all [face/:f-l/1 face/:f-l/1/data <> c][
            b: false
            foreach f face/:f-l [
                if any ['vide = f/data b: c = f/data][break]
            ]
            if b [ok: true foreach f face/:f-l [
                if c = f/data [break]
                f/data: c
                f/effect: select jeton-effects f/data
                show f
           ]]
        ]
    ]
    ok
]

; Table de décision du joueur machine
; tactique: 1) prendre les coins du plateau
;           2) ne pas laisser l'adversaire les prendre
;           3) contrôler les bords
;           4) retourner un maximum de jetons
valeurs: [
    [
        36
        (either ordinateur = plateau/pane/1/data [24][-18])
        5.5 5.5 5.5 5.5
        (either ordinateur = plateau/pane/8/data [24][-18])
        36
    ][
        (either ordinateur = plateau/pane/1/data [24][-18])
        (either ordinateur = plateau/pane/1/data [2][-29])
        -11 -11 -11 -11
        (either ordinateur = plateau/pane/8/data [2][-29])
        (either ordinateur = plateau/pane/8/data [24][-18])
    ][
        5.5 -11 1 1 1 1 -11 5.5
    ][
        5.5 -11 1 1 1 1 -11 5.5
    ][
        5.5 -11 1 1 1 1 -11 5.5
    ][
        5.5 -11 1 1 1 1 -11 5.5
    ][
        (either ordinateur = plateau/pane/57/data [24][-18])
        (either ordinateur = plateau/pane/57/data [2][-29])
        -11 -11 -11 -11
        (either ordinateur = plateau/pane/64/data [2][-29])
        (either ordinateur = plateau/pane/64/data [24][-18])
    ][
        36
        (either ordinateur = plateau/pane/57/data [24][-18])
        5.5 5.5 5.5 5.5
        (either ordinateur = plateau/pane/64/data [24][-18])
        36
    ]
]

; intérêt/risque actuel de prendre une case
valeur-case: func [
    "Valeur actuelle d'une case"
    offset "Position sur le plateau"
    /local x y
][
     x: offset/x y: offset/y
     do valeurs/:y/:x
]

; Détermination du meilleur coup pour le joueur actuel, à l'aide de la table de valeurs
meilleur-coup: func [
    "Recherche du meilleur coup"
    joueur "Joueur en cours"
    /local liste-coups p valeur b
][
    ; liste des coups possibles
    liste-coups: copy []

    ; en début de partie, une des case du centre
    if coups < 4 [
        p: plateau/pane
        foreach case random [28 29 36 37] [
            if 'vide = p/:case/data [return p/:case]
        ]
    ]
    
    ; construit la liste des coups possibles accompagnés de leur pondération
    foreach p plateau/pane [
        if 'vide = p/data [
            foreach f-l [
                gauche droite haut bas
                haut-gauche haut-droite bas-gauche bas-droite
            ][
                valeur: valeur-case p/coords
                if all [p/:f-l/1 p/:f-l/1/data <> joueur][
                    b: false
                    foreach f p/:f-l [
                        if any ['vide = f/data b: joueur = f/data][break]
                        valeur: valeur + valeur-case f/coords
                    ]
                    if b [repend liste-coups [valeur p]]
                ]
            ]
        ]
    ]
    ; pas de coup possible
    either empty? liste-coups [
        none
    ][
        ; tri avec les meilleurs coups en premier
        sort/reverse/skip liste-coups 2
        
        ; suivant le niveau, on prend un des 3 meilleurs/des 2 meilleurs/le meilleur
        either 6 <= length? liste-coups [
            pick liste-coups 2 * random select reduce [
                locale level/min 3 locale level/med 2 locale level/max 1
            ] first niveau/data
        ][
            second liste-coups
        ]
    ]
]

; ===Redimensionnement de la fenêtre

; référence de base
last-size: base-size: fenetre/size

; sauvegarde des dimensions et des positions de départ
base-sizes: copy []
foreach face [mode niveau passer fin aide plateau][
    face: get face
    repend base-sizes [face face/size face/offset]
    append base-sizes either face/font [face/font/size][none]
]
; sauvegarde des coordonnées des cases
jetons-offsets: copy []
foreach jeton plateau/pane [repend jetons-offsets [jeton jeton/offset]]

; adaptation de la fenêtre à l'écran actuel
fenetre/size: fenetre/size * (system/view/screen-face/size/y / 768)

; fonction de redimensionnement, lancée la 1ère fois avant l'affichage
do resize-all: insert-event-func [
    if event/type = 'resize [
        use [delta-x delta-y facteur taille][
            ;facteur de redimensionnement
            delta-x: abs fenetre/size/x - last-size/x
            delta-y: abs fenetre/size/y - last-size/y
            facteur: either delta-x > delta-y [
                fenetre/size/x / base-size/x
            ][
                fenetre/size/y / base-size/y
            ]
            if facteur < 0.014 [return event]

            ;redimensionnement des contrôles
            foreach [face size offset font] base-sizes [
                face/size: size * facteur
                face/offset: offset * facteur
                if font [face/font/size: to-integer font * facteur]
            ]

            ;redimensionnement des cases et des jetons
            taille: 74x74 * facteur
            foreach [jeton offset] jetons-offsets [
                jeton/size: taille
                jeton/offset: offset * facteur
            ]

            ;redimensionnement de la grille
            taille: 75x75 * facteur
            plateau/size: plateau/size / taille * taille + 2x2
            change find plateau/effect pair! taille

            last-size: fenetre/size
            if (abs delta-x - delta-y) > 2 [
            fenetre/size: base-size * facteur ]
            show fenetre
        ]
    ]
    event
] fenetre context [type: 'resize]

; ===Lancement du jeu

; initialisation du générateur aléatoire
random/seed now

; cases de départ
coups-depart

; affichage fenêtre principale
view/options fenetre 'resize

; ===Fin

quit
