REBOL [Title: "Mirror languages module"
       file:  %mirror-lang.r
       Author: "Arnold van Hofwegen"
       Disclaimer: "Gebruik van dit programma is voor eigen risico."
       Extra-info: {MultiLanguage support}
       date: 06-july-2012
]
;*******************************************************************************
; Functies voor taal
;*******************************************************************************
do-init-lang: func [taal [string!] "Preferred language"][
    switch taal [
        "nl" [do-set-GUI-lang-nl]
        "en" [do-set-GUI-lang-en]
        "de" [do-set-GUI-lang-de]
        "fr" [do-set-GUI-lang-fr]
        "es" [do-set-GUI-lang-es]
        "it" [do-set-GUI-lang-it]
        "pt" [do-set-GUI-lang-pt]
    ]
]

do-set-lang: func [taal [string!] "Preferred language"][
    do-init-lang taal
    do-activate-GUI-main-lang
    do-activate-GUI-pref-lang
    show main
]

;********************************
; setting main layout text values
;********************************
do-activate-GUI-main-lang: func [] [
    lbl-no-mirrors/text:    lbl-no-mirrors-text
    btn-rules/text:         btn-rules-text
    btn-new-game/text:      btn-new-game-text
    btn-quit/text:          btn-quit-text
    btn-preferences/text:   btn-preferences-text
]

do-activate-GUI-pref-lang: func [] [
    lbl-language/text:      lbl-language-text
    lbl-mirror-color/text:  lbl-mirror-color-text
    lbl-grid-bold/text:     lbl-grid-bold-text
    lbl-mirrors-bold/text:  lbl-mirrors-bold-text
    btn-apply/text:         btn-apply-text
    btn-save-pref/text:     btn-save-pref-text
    btn-close-pref/text:    btn-close-pref-text
    rmt0/text:              radio-mirrortype-all
    rmt1/text:              radio-mirrortype-solid
    rmt2/text:              radio-mirrortype-user
]

;*******************************************************************************
; GUI layout in de beschikbare talen
;*******************************************************************************
do-set-GUI-lang-general: func [] [
; no permanent texts to display atm
]
;******************************
; GUI teksten in het Nederlands
;******************************
do-set-GUI-lang-nl: func [] [
; main layout teksten
    lbl-no-mirrors-text:    "Aantal geplaatste spiegels: " 
    btn-rules-text:         "Spelregels"
    btn-new-game-text:      "Nieuw spel"
    btn-quit-text:          "Stoppen"
    btn-preferences-text:   "Instellingen"
; Berichten
    lbl-spelbericht-solid:  "Vaste spiegel kunnen niet verdraaid of verwijderd."
    lbl-spelbericht-seven:  "Er zijn al 7 spiegels geplaatst."
    lbl-spelbericht-solved: "Oplossing gevonden! Gefeliciteerd!!!"
    lbl-spelbericht-exact:  "Bijna, je moet precies 7 spiegels gebruiken!"
; Voorkeurenscherm teksten  
    lbl-language-text:      "Kies je taal"
    lbl-mirror-color-text:  "Kies de kleur van je spiegels"
    lbl-grid-bold-text:     "Raster dikker"
    lbl-mirrors-bold-text:  "Spiegels dikker"
    btn-apply-text:         "Pas toe"
    btn-save-pref-text:     "Bewaar"
    btn-close-pref-text:    "Sluit"
    radio-mirrortype-all:   "Alle"
    radio-mirrortype-solid: "Vaste"
    radio-mirrortype-user:  "Speler"
; Spelregels teksten
    game-name-text:         "Spiegelspel"
    game-rules-text:        {Probeer de gelijke waarden aan de rand van 
                             het veld met elkaar te verbinden door precies 7 
                             spiegels bij te plaatsen. Stel je voor dat je
                             een lichtstraal vanaf de kant afschiet die door  
                             de spiegels van richting verandert.
                             Waardes die verbonden worden worden in wit 
                             getoond, anderen worden zwart weergegeven.}
    good-luck-text:         "Veel plezier en succes!"
]
;**************************
; GUI teksten in het Engels
;**************************
do-set-GUI-lang-en: func [] [
; main layout teksten
    lbl-no-mirrors-text:    "Number of placed mirrors: " 
    btn-rules-text:         "Rules"
    btn-new-game-text:      "New game"
    btn-quit-text:          "Stop"
    btn-preferences-text:   "Preferences"
; Berichten
    lbl-spelbericht-solid:  "Solid mirrors cannot be changed or removed."
    lbl-spelbericht-seven:  "Already 7 mirrors are placed."
    lbl-spelbericht-solved: "Solution found! Congratulations!!!"
    lbl-spelbericht-exact:  "Almost, but there have to be exactly 7 mirrors!"
; Voorkeurenscherm teksten  
    lbl-language-text:      "Choose an other language"
    lbl-mirror-color-text:  "Choose the color of your mirrors"
    lbl-grid-bold-text:     "Grid bold"
    lbl-mirrors-bold-text:  "Mirrors bold"
    btn-apply-text:         "Apply"
    btn-save-pref-text:     "Save"
    btn-close-pref-text:    "Close"
    radio-mirrortype-all:   "All"
    radio-mirrortype-solid: "Solid"
    radio-mirrortype-user:  "User"
; Spelregels teksten             
    game-name-text:         "Mirror Game"
    game-rules-text:        {Try to connect the same values along the borders
                             of the diagram by placing exactly 7 extra mirrors
                             in the field. Imagine that you send beams of
                             light into the grid and your beams should go from
                             one value to the corresponding value. Values that
                             are matching are shown in white, others will
                             appear in black.}
    good-luck-text:         "Have fun, good luck!"
]
;*************************
; GUI teksten in het Duits
;*************************
do-set-GUI-lang-de: func [] [
; main layout teksten        
    lbl-no-mirrors-text:    "Anzahl platzierte Spiegel: "                                
    btn-rules-text:         "Regeln"                                                   
    btn-new-game-text:      "neues Spiel"                                              
    btn-quit-text:          "Stopp"                                                    
    btn-preferences-text:   "Einstellungen"                                            
; Berichten                                                                           
    lbl-spelbericht-solid:  "Feste Spiegeln dürfen nicht verdreht oder entfernt werden"   
    lbl-spelbericht-seven:  "Es sind bereits 7 Spiegeln platziert worden."              
    lbl-spelbericht-solved: "Lösung gefunden! Herzlichen Glückwunsch!"                 
    lbl-spelbericht-exact:  "Fast, Sie müssen genau 7 Spiegeln nützen!"                         
; Voorkeurenscherm teksten                                                            
    lbl-language-text:      "Wählen Sie Ihre Sprache"                                  
    lbl-mirror-color-text:  "Wählen Sie die Farbe Ihrer Spiegel"                       
    lbl-grid-bold-text:     "Grid dicker"                                              
    lbl-mirrors-bold-text:  "Spiegeln dicker"                                          
    btn-apply-text:         "anwenden"                                                 
    btn-save-pref-text:     "sparen"                                                   
    btn-close-pref-text:    "schließen"                                                
    radio-mirrortype-all:   "alle"                                                     
    radio-mirrortype-solid: "behoben"                                                  
    radio-mirrortype-user:  "Spieler"                                                  
; Spelregels teksten                                                                  
    game-name-text:         "Spiegel-Spiel"                                            
    game-rules-text:        {Versuchen auf gleiche Werte an der Kante                 
                             das Feld mit jedem anderen durch genau 7 verbunden werden
                             Spiegel im Raum. Stellen Sie sich vor, dass Sie          
                             ein Lichtstrahl von der Seite Schützen durch             
                             die Spiegel die Richtung ändert.                         
                             Werte, die in weißen angeschlossen sind                  
                             gezeigt, andere sind schwarz.}                            
    good-luck-text:         "Viel Spaß und viel Glück!"                                
]
;*************************
; GUI teksten in het Frans
;*************************
do-set-GUI-lang-fr: func [] [
; main layout teksten        
    lbl-no-mirrors-text:    "Nombre placé miroirs: "                                
    btn-rules-text:         "Règles"                                              
    btn-new-game-text:      "Nouveau jeu"                                         
    btn-quit-text:          "Stop"                                                
    btn-preferences-text:   "Paramètres"                                          
; Berichten                                                                      
    lbl-spelbericht-solid:  "Miroir fixe ne peut pas être tordu ou enlevé"        
    lbl-spelbericht-seven:  "Il a déjà été placé miroirs 7."                      
    lbl-spelbericht-solved: "Solution trouvée! Félicitations!"                    
    lbl-spelbericht-exact:  "Presque, vous devez utiliser exactement 7 niveaux!"  
; Voorkeurenscherm teksten                                                       
    lbl-language-text:      "Choisissez votre langue"                             
    lbl-mirror-color-text:  "Choisissez la couleur de vos rétroviseurs"           
    lbl-grid-bold-text:     "Grille épaisse"                                      
    lbl-mirrors-bold-text:  "Rétroviseurs épais"                                  
    btn-apply-text:         "appliquer"                                           
    btn-save-pref-text:     "sauver"                                              
    btn-close-pref-text:    "fermer"                                              
    radio-mirrortype-all:   "Tous"                                                
    radio-mirrortype-solid: "Jeu"                                       
    radio-mirrortype-user:  "Joueur"                                              
; Spelregels teksten                                                             
    game-name-text:         "jeu de miroir"                                       
    game-rules-text:        {Essayer de valeurs égales à la limite de            
                             le champ à l'autre pour être reliés par exactement 7
                             miroirs dans la chambre. Imaginez que vous          
                             un faisceau de lumière à partir du tireur côte à    
                             les miroirs des changements de direction.           
                             Des valeurs qui sont connectées en blanc            
                             montré, d'autres sont noirs.}                        
    good-luck-text:         "Amusez-vous et bonne chance!"                                                   
]                                                    
;**************************
; GUI teksten in het Spaans
;**************************
do-set-GUI-lang-es: func [] [
; main layout teksten        
    lbl-no-mirrors-text:    "Número de espejos colocados: "                           
    btn-rules-text:         "Reglas"                                                
    btn-new-game-text:      "un nuevo juego"                                        
    btn-quit-text:          "detener"                                               
    btn-preferences-text:   "Configuración"                                         
; Berichten                                                                        
    lbl-spelbericht-solid:  "Espejo fijo no puede ser torcido o eliminado"          
    lbl-spelbericht-seven:  "Ya ha sido colocado espejos 7."                        
    lbl-spelbericht-solved: "Solución encontrado! ¡Felicitaciones!"                 
    lbl-spelbericht-exact:  "Casi, se debe utilizar exactamente 7 niveles!"         
; Voorkeurenscherm teksten                                                         
    lbl-language-text:      "Elija su idioma"                                       
    lbl-mirror-color-text:  "Elige el color de los espejos"                         
    lbl-grid-bold-text:     "más gruesa de cuadrícula"                              
    lbl-mirrors-bold-text:  "Espejos más grueso"                                    
    btn-apply-text:         "aplicar"                                               
    btn-save-pref-text:     "ahorrar"                                               
    btn-close-pref-text:    "cerrar"                                                
    radio-mirrortype-all:   "todo"                                                  
    radio-mirrortype-solid: "Fijo"                                                  
    radio-mirrortype-user:  "jugador"                                               
; Spelregels teksten                                                               
    game-name-text:         "Mirror Game"                                           
    game-rules-text:        {Trata de valores iguales en el borde del              
                             el campo entre sí para ser conectado por exactamente 7
                             espejos en la habitación. Imagínese que usted         
                             un haz de luz desde el lado tirador por               
                             los espejos de los cambios de dirección.              
                             Los valores que están conectados en blanco            
                             mostrado, otros son de color negro.}                   
    good-luck-text:         "¡Diviértete y buena suerte!"                                                      
]                                                       
;*****************************
; GUI teksten in het Italiaans
;*****************************
do-set-GUI-lang-it: func [] [
; main layout teksten        
    lbl-no-mirrors-text:    "Numero posto specchi: "                                      
    btn-rules-text:         "regole"                                                    
    btn-new-game-text:      "Nuovo gioco"                                               
    btn-quit-text:          "Stop"                                                      
    btn-preferences-text:   "Impostazioni"                                              
; Berichten                                                                            
    lbl-spelbericht-solid:  "Specchio fisso non può essere ruotato o rimossi"           
    lbl-spelbericht-seven:  "Ci sono già stati collocati specchi 7."                    
    lbl-spelbericht-solved: "Soluzione trovata! Congratulazioni!"                       
    lbl-spelbericht-exact:  "Quasi, è necessario utilizzare esattamente sette livelli!" 
; Voorkeurenscherm teksten                                                             
    lbl-language-text:      "Scegli la lingua"                                          
    lbl-mirror-color-text:  "Scegli il colore dei tuoi specchi"                         
    lbl-grid-bold-text:     "Griglia più spessa"                                        
    lbl-mirrors-bold-text:  "Specchi più spessa"                                        
    btn-apply-text:         "applicare"                                                 
    btn-save-pref-text:     "salvare"                                                   
    btn-close-pref-text:    "chiudere"                                                  
    radio-mirrortype-all:   "tutti"                                                     
    radio-mirrortype-solid: "Risolto"                                                   
    radio-mirrortype-user:  "giocatore"                                                 
; Spelregels teksten                                                                   
    game-name-text:         "Specchio Gioco"                                            
    game-rules-text:        {Prova a valori pari al bordo                              
                             il campo con l'altro per essere collegati da esattamente 7
                             specchi nella stanza. Immaginate di                       
                             un raggio di luce dal tiratore fianco                     
                             gli specchi cambi di direzione.                           
                             I valori che sono collegati in bianco                     
                             dimostrato, altri sono neri.}                              
    good-luck-text:         "Buon divertimento e buona fortuna!"                        
]
;*****************************
; GUI teksten in het Portugees
;*****************************
do-set-GUI-lang-pt: func [] [
; main layout teksten        
    lbl-no-mirrors-text:    "Número colocado espelhos: "                               
    btn-rules-text:         "regras"                                                 
    btn-new-game-text:      "novo Jogo"                                              
    btn-quit-text:          "Pare"                                                   
    btn-preferences-text:   "configurações"                                          
; Berichten                                                                          
    lbl-spelbericht-solid:  "Espelho fixo não pode ser distorcida ou removidas"      
    lbl-spelbericht-seven:  "Há já foram colocados espelhos 7."                      
    lbl-spelbericht-solved: "Solução encontrada! Parabéns!"                          
    lbl-spelbericht-exact:  "Quase, você deve usar exatamente 7 níveis!"             
; Voorkeurenscherm teksten                                                           
    lbl-language-text:      "Escolha seu idioma"                                     
    lbl-mirror-color-text:  "Escolha a cor de seus espelhos"                         
    lbl-grid-bold-text:     "grade grossa"                                           
    lbl-mirrors-bold-text:  "espelhos grosso"                                        
    btn-apply-text:         "aplicar"                                                
    btn-save-pref-text:     "salvar"                                                 
    btn-close-pref-text:    "fechar"                                                 
    radio-mirrortype-all:   "todos"                                                  
    radio-mirrortype-solid: "corrigido"                                              
    radio-mirrortype-user:  "jogador"                                                
; Spelregels teksten                                                                 
    game-name-text:         "Jogo espelho"                                           
    game-rules-text:        {Tentar para valores iguais na borda do                  
                             o campo com o outro para ser ligado por exactamente 7   
                             espelhos na sala. Imagine que você                      
                             um feixe de luz a partir do atirador lado por           
                             os espelhos mudanças de direcção.                       
                             Valores que estão ligados em branco                     
                             mostrado, os outros são pretos.}                        
    good-luck-text:         "Divirta-se e boa sorte!"                                
]

do-set-GUI-lang-general

;*******************************************************************************
; Einde mirror-lang.r
;*******************************************************************************