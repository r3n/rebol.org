REBOL [
    Title: "ICO view"
    Date: 31-Jul-2001/10:50:26+2:00
    Version: 0.0.1
    File: %ico-view.r
    Author: "oldes"
    Purpose: {To view the image from the ICO file (example what to do with %ico-parser.r)}
    Comment: {This is just an example what to do with the %ico-parser}
    Email: oldes@bigfoot.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
;first of all I include the %ico-parser.r
do load-thru http://sweb.cz/desold/scripts/ico-parser.r

ico: ico-parser/file http://sweb.cz/desold/icons/Icon21.ico
i: ico/icons
print ["Images in file:" i]
;I want to display the last (bigger) img in the ico file
i-size: ico/imgs/:i/size
win: make face compose [size: (2 * i-size + 20x0) edge: none pane: copy []]
;already fliped main icon img:
append win/pane  make face [
    offset: 10x10
    size: i-size
    image: ico/imgs/:i
    edge: none
]
;and the icon's mask:
append win/pane  make face compose [
    offset: (10x10 + to-pair reduce [i-size/x 0])
    size: i-size
    image: ico/masks/:i
    edge: none
    effect: [flip 0x1]
]
view center-face win
                                    