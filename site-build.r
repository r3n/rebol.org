REBOL [
    Title: "site-build"
    Date: 5-May-2001
    Version: 1.0.0
    File: %site-build.r
    Author: "Rishi Oswal"
    Purpose: {site-build basicaly builds/updates a website based on the template I have developed. Requires html 4.0 compliant browser (opera 5 or IE 5).
}
    Email: rishio@mail.com
    Web: http://www.rishio.com/
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'markup 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

on-net: true


g-files: make object! [
    globalcss: %./global.css
    globaljs: %./global.js
    menushift: %./menushift.js
    template: %./template.html
    images: %./images/
    
]

if on-net [
    
    g-files/globalcss: ftp://g-viz.com/pub/myrebol/site-build/global.css  
    g-files/globaljs: ftp://g-viz.com/pub/myrebol/site-build/global.js
    g-files/menushift: ftp://g-viz.com/pub/myrebol/site-build/menushift.js
    g-files/template: ftp://g-viz.com/pub/myrebol/site-build/template.html
    g-files/images: ftp://g-viz.com/pub/myrebol/site-build/images/
]

global-options: make object! [
    background-color: {bgcolor="FAEBD7"}
    background-image: {background="./images/background.gif"}
    folder: %/c/windows/desktop/site-folder/
    door: true
    num-menus: 5;
    menu: ["Menu1" "Menu2" "Menu3" "Menu4" "Menu5"]
]
menu1-options: make object! [
    title: ""
    date-bar: now/date
    num-submenus: 0
]
menu2-options: make object! [
    title: ""
    date-bar: ""
    num-submenus: 0
]

menu3-options: make object! [
    title: ""
    date-bar: ""
    num-submenus: 0
]

menu4-options: make object! [
    title: ""
    date-bar: ""
    num-submenus: 0
]

menu5-options: make object! [
    title: ""
    date-bar: ""
    num-submenus: 0
]




build-menu1: func [
    "builds menu1.html page"
    /local menu1-template menu1 begin ending submenu-top content-visibility submenu-color
][
    menu1-template: read/string g-files/template
    
    ;;;;;;;;;;;;;;;;;;;MENUNAMES
    parse menu1-template [
        
        thru {onmouseout="offMenu1();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/1 ending)

        thru {onmouseout="offMenu2();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/2 ending)
        
        thru {onmouseout="offMenu3();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/3 ending)
        
        thru {onmouseout="offMenu4();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/4 ending)
        
        thru {onmouseout="offMenu5();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/5 ending)        
    ]
    

    ;;;;;;;;;;;;;;;;;;;;BACKGROUND IMAGES
    parse menu1-template [
        thru {<body onload="afterCacheing();" } begin: to {>} ending:
        (change/part begin reform [global-options/background-color global-options/background-image] ending)
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;TITLEBAR
    parse menu1-template [
        thru {<title>} begin: to {</title>} ending:
        (change/part begin menu1-options/title ending)
    ]

    ;;;;;;;;;;;;;;;;;;;DATEBAR
    parse menu1-template [
        thru {<div id="DIVIDERBAR">} begin: to {</div>} ending:
        (change/part begin menu1-options/date-bar ending)
    ]   
    
    ;;;;;;;;;;;;;;;;;;;;;SELECTEDMENUJAVASCRIPT
    parse menu1-template [
        thru {//SELECTEDMENUBEGIN} begin: to {//SELECTEDMENUEND} ending:
        (insert begin {
            g_unidocument.MENU1.style.color = "gold";
            g_unidocument.MENU1.style.background = "black";} ending)
    ]

    ;;;;;;;;;;;;;;;;;;;;;CURRENTMENUHTML
    parse menu1-template [
        thru {<div id="MENU1"} begin: to {>} ending:
        (change/part begin "" ending)   
    ]


    either (menu1-options/num-submenus > 0) [
        submenu-top: 0
        content-visibility: "visible"
        submenu-color: "gold"

        for num 1 menu1-options/num-submenus 1 [
            ;;;;;;;;;;;;stylesheets
            parse menu1-template [
                thru {<style type="text/css">} begin: to {div} ending:

                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num "CONTENT {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: 0px;
                left: 140px;
                font: 10pt Arial;
                color: black;
                visibility: } content-visibility {;}
                "^(line)^(tab)^(tab)^(tab)}"] ending)
                
                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num " {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: } submenu-top {px;
                left: 0px;
                width: 100px;
                height: 15px;
                font: bold 10pt Arial;
                color: } submenu-color {;
                background-color: black;
                text-align: center;
                cursor: hand;} 
                "^(line)^(tab)^(tab)^(tab)}"] ending)
            ]
            ;;;;;;;;;;;;;;html
            parse menu1-template [
                thru {<div id="CONTENT">} begin: to {</div>} ending:
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {CONTENT">
                <div id="CONTENTBAR">Submenu} num {bar</div><br>
                Submenu} num {Content^(line)^(tab)^(tab)^(tab)</div>}])
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {" onclick="if(window.loaded != true) return; inSubMenu} num {();" onmouseover="if(window.loaded != true) return; onSubMenu} num {();" onmouseout="if(window.loaded != true) return; offSubMenu} num {();">Submenu} num {</div>}] ending)
            ]
            ;;;;;;;;;;;;;javascript
                        
            parse menu1-template [
                thru {//SUBMENUSCRIPTBEGIN} begin: to {//SUBMENUSCRIPTEND} ending:
                (insert begin rejoin [{
                    function inSubMenu} num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"$shift.updatePage(^"SUBMENU" num "^",null,null,^"SUBMENU" num "CONTENT^");"{
                        }"}"{
                    }"}"{
                    }"function onSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"black^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"gold^";"{
                        }"}"{
                    }"}"{
                    }"function offSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"silver^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"black^";"{
                        }"}"{
                    }"}"] ending)
            ]
            
            submenu-top: submenu-top + 20
            content-visibility: "hidden"
            submenu-color: "silver"
        ]
        parse menu1-template [
            thru {//NEWMENUSHIFTBEGIN} begin: to {//NEWMENUSHIFTEND} ending:
            (insert begin {^(line)^(tab)var $shift = new Menushift("SUBMENU1",null,null,"SUBMENU1CONTENT");} ending)
        ]
    ][
        parse menu1-template [
            thru {<div id="CONTENT">} begin: to {</div>} ending:
            (change/part begin {Content goes here.} ending)
        ]
    ]
    
    write rejoin [global-options/folder "menu1.html"] menu1-template
]


build-menu2: func [
    "builds menu2.html page"
    /local menu2-template menu1 begin ending submenu-top content-visibility submenu-color
][
    menu2-template: read/string g-files/template
    
    ;;;;;;;;;;;;;;;;;;;MENUNAMES
    parse menu2-template [
        
        thru {onmouseout="offMenu1();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/1 ending)

        thru {onmouseout="offMenu2();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/2 ending)
        
        thru {onmouseout="offMenu3();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/3 ending)
        
        thru {onmouseout="offMenu4();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/4 ending)
        
        thru {onmouseout="offMenu5();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/5 ending)        
    ]
    

    ;;;;;;;;;;;;;;;;;;;;BACKGROUND IMAGES
    parse menu2-template [
        thru {<body onload="afterCacheing();" } begin: to {>} ending:
        (change/part begin reform [global-options/background-color global-options/background-image] ending)
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;TITLEBAR
    parse menu2-template [
        thru {<title>} begin: to {</title>} ending:
        (change/part begin menu2-options/title ending)
    ]

    ;;;;;;;;;;;;;;;;;;;DATEBAR
    parse menu2-template [
        thru {<div id="DIVIDERBAR">} begin: to {</div>} ending:
        (change/part begin menu2-options/date-bar ending)
    ]   
    
    ;;;;;;;;;;;;;;;;;;;;;SELECTEDMENUJAVASCRIPT
    parse menu2-template [
        thru {//SELECTEDMENUBEGIN} begin: to {//SELECTEDMENUEND} ending:
        (insert begin {
            g_unidocument.MENU2.style.color = "gold";
            g_unidocument.MENU2.style.background = "black";} ending)
    ]

    ;;;;;;;;;;;;;;;;;;;;;CURRENTMENUHTML
    parse menu2-template [
        thru {<div id="MENU2"} begin: to {>} ending:
        (change/part begin "" ending)   
    ]

    ;;;;;;;;;;;;;;;;;;;;LINK MYPHOTO
    parse menu2-template [            
        thru {<!-- MYPHOTOBEGIN -->} begin: to {<img} ending:
        (insert begin {^(line)^(tab)^(tab)<a href="./menu1.html">} ending)

        thru {myphoto.jpg">} begin: to {<!-- MYPHOTOEND -->} ending:
        (insert begin {^(line)^(tab)^(tab)</a>} ending)
    ]
    
    either (menu2-options/num-submenus > 0) [
        submenu-top: 0
        content-visibility: "visible"
        submenu-color: "gold"

        for num 1 menu2-options/num-submenus 1 [
            ;;;;;;;;;;;;stylesheets
            parse menu2-template [
                thru {<style type="text/css">} begin: to {div} ending:

                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num "CONTENT {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: 0px;
                left: 140px;
                font: 10pt Arial;
                color: black;
                visibility: } content-visibility {;}
                "^(line)^(tab)^(tab)^(tab)}"] ending)
                
                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num " {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: } submenu-top {px;
                left: 0px;
                width: 100px;
                height: 15px;
                font: bold 10pt Arial;
                color: } submenu-color {;
                background-color: black;
                text-align: center;
                cursor: hand;} 
                "^(line)^(tab)^(tab)^(tab)}"] ending)
            ]
            ;;;;;;;;;;;;;;html
            parse menu2-template [
                thru {<div id="CONTENT">} begin: to {</div>} ending:
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {CONTENT">
                <div id="CONTENTBAR">Submenu} num {bar</div><br>
                Submenu} num {Content^(line)^(tab)^(tab)^(tab)</div>}])
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {" onclick="if(window.loaded != true) return; inSubMenu} num {();" onmouseover="if(window.loaded != true) return; onSubMenu} num {();" onmouseout="if(window.loaded != true) return; offSubMenu} num {();">Submenu} num {</div>}] ending)
            ]
            ;;;;;;;;;;;;;javascript
                        
            parse menu2-template [
                thru {//SUBMENUSCRIPTBEGIN} begin: to {//SUBMENUSCRIPTEND} ending:
                (insert begin rejoin [{
                    function inSubMenu} num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"$shift.updatePage(^"SUBMENU" num "^",null,null,^"SUBMENU" num "CONTENT^");"{
                        }"}"{
                    }"}"{
                    }"function onSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"black^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"gold^";"{
                        }"}"{
                    }"}"{
                    }"function offSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"silver^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"black^";"{
                        }"}"{
                    }"}"] ending)
            ]
            
            submenu-top: submenu-top + 20
            content-visibility: "hidden"
            submenu-color: "silver"
        ]
        parse menu2-template [
            thru {//NEWMENUSHIFTBEGIN} begin: to {//NEWMENUSHIFTEND} ending:
            (insert begin {^(line)^(tab)var $shift = new Menushift("SUBMENU1",null,null,"SUBMENU1CONTENT");} ending)
        ]
    ][
        parse menu2-template [
            thru {<div id="CONTENT">} begin: to {</div>} ending:
            (change/part begin {Content goes here.} ending)
        ]
    ]
    
    write rejoin [global-options/folder "menu2.html"] menu2-template
]

build-menu3: func [
    "builds menu3.html page"
    /local menu3-template menu1 begin ending submenu-top content-visibility submenu-color
][
    menu3-template: read/string g-files/template
    
    ;;;;;;;;;;;;;;;;;;;MENUNAMES
    parse menu3-template [
        
        thru {onmouseout="offMenu1();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/1 ending)

        thru {onmouseout="offMenu2();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/2 ending)
        
        thru {onmouseout="offMenu3();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/3 ending)
        
        thru {onmouseout="offMenu4();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/4 ending)
        
        thru {onmouseout="offMenu5();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/5 ending)        
    ]
    

    ;;;;;;;;;;;;;;;;;;;;BACKGROUND IMAGES
    parse menu3-template [
        thru {<body onload="afterCacheing();" } begin: to {>} ending:
        (change/part begin reform [global-options/background-color global-options/background-image] ending)
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;TITLEBAR
    parse menu3-template [
        thru {<title>} begin: to {</title>} ending:
        (change/part begin menu3-options/title ending)
    ]

    ;;;;;;;;;;;;;;;;;;;DATEBAR
    parse menu3-template [
        thru {<div id="DIVIDERBAR">} begin: to {</div>} ending:
        (change/part begin menu3-options/date-bar ending)
    ]   
    
    ;;;;;;;;;;;;;;;;;;;;;SELECTEDMENUJAVASCRIPT
    parse menu3-template [
        thru {//SELECTEDMENUBEGIN} begin: to {//SELECTEDMENUEND} ending:
        (insert begin {
            g_unidocument.MENU3.style.color = "gold";
            g_unidocument.MENU3.style.background = "black";} ending)
    ]

    ;;;;;;;;;;;;;;;;;;;;;CURRENTMENUHTML
    parse menu3-template [
        thru {<div id="MENU3"} begin: to {>} ending:
        (change/part begin "" ending)   
    ]

    ;;;;;;;;;;;;;;;;;;;;LINK MYPHOTO
    parse menu3-template [            
        thru {<!-- MYPHOTOBEGIN -->} begin: to {<img} ending:
        (insert begin {^(line)^(tab)^(tab)<a href="./menu1.html">} ending)

        thru {myphoto.jpg">} begin: to {<!-- MYPHOTOEND -->} ending:
        (insert begin {^(line)^(tab)^(tab)</a>} ending)
    ]
    
    either (menu3-options/num-submenus > 0) [
        submenu-top: 0
        content-visibility: "visible"
        submenu-color: "gold"

        for num 1 menu3-options/num-submenus 1 [
            ;;;;;;;;;;;;stylesheets
            parse menu3-template [
                thru {<style type="text/css">} begin: to {div} ending:

                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num "CONTENT {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: 0px;
                left: 140px;
                font: 10pt Arial;
                color: black;
                visibility: } content-visibility {;}
                "^(line)^(tab)^(tab)^(tab)}"] ending)
                
                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num " {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: } submenu-top {px;
                left: 0px;
                width: 100px;
                height: 15px;
                font: bold 10pt Arial;
                color: } submenu-color {;
                background-color: black;
                text-align: center;
                cursor: hand;} 
                "^(line)^(tab)^(tab)^(tab)}"] ending)
            ]
            ;;;;;;;;;;;;;;html
            parse menu3-template [
                thru {<div id="CONTENT">} begin: to {</div>} ending:
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {CONTENT">
                <div id="CONTENTBAR">Submenu} num {bar</div><br>
                Submenu} num {Content^(line)^(tab)^(tab)^(tab)</div>}])
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {" onclick="if(window.loaded != true) return; inSubMenu} num {();" onmouseover="if(window.loaded != true) return; onSubMenu} num {();" onmouseout="if(window.loaded != true) return; offSubMenu} num {();">Submenu} num {</div>}] ending)
            ]
            ;;;;;;;;;;;;;javascript
                        
            parse menu3-template [
                thru {//SUBMENUSCRIPTBEGIN} begin: to {//SUBMENUSCRIPTEND} ending:
                (insert begin rejoin [{
                    function inSubMenu} num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"$shift.updatePage(^"SUBMENU" num "^",null,null,^"SUBMENU" num "CONTENT^");"{
                        }"}"{
                    }"}"{
                    }"function onSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"black^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"gold^";"{
                        }"}"{
                    }"}"{
                    }"function offSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"silver^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"black^";"{
                        }"}"{
                    }"}"] ending)
            ]
            
            submenu-top: submenu-top + 20
            content-visibility: "hidden"
            submenu-color: "silver"
        ]
        parse menu3-template [
            thru {//NEWMENUSHIFTBEGIN} begin: to {//NEWMENUSHIFTEND} ending:
            (insert begin {^(line)^(tab)var $shift = new Menushift("SUBMENU1",null,null,"SUBMENU1CONTENT");} ending)
        ]
    ][
        parse menu3-template [
            thru {<div id="CONTENT">} begin: to {</div>} ending:
            (change/part begin {Content goes here.} ending)
        ]
    ]
    
    write rejoin [global-options/folder "menu3.html"] menu3-template
]




build-menu4: func [
    "builds menu4.html page"
    /local menu4-template menu1 begin ending submenu-top content-visibility submenu-color
][
    menu4-template: read/string g-files/template
    
    ;;;;;;;;;;;;;;;;;;;MENUNAMES
    parse menu4-template [
        
        thru {onmouseout="offMenu1();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/1 ending)

        thru {onmouseout="offMenu2();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/2 ending)
        
        thru {onmouseout="offMenu3();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/3 ending)
        
        thru {onmouseout="offMenu4();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/4 ending)
        
        thru {onmouseout="offMenu5();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/5 ending)        
    ]
    

    ;;;;;;;;;;;;;;;;;;;;BACKGROUND IMAGES
    parse menu4-template [
        thru {<body onload="afterCacheing();" } begin: to {>} ending:
        (change/part begin reform [global-options/background-color global-options/background-image] ending)
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;TITLEBAR
    parse menu4-template [
        thru {<title>} begin: to {</title>} ending:
        (change/part begin menu4-options/title ending)
    ]

    ;;;;;;;;;;;;;;;;;;;DATEBAR
    parse menu4-template [
        thru {<div id="DIVIDERBAR">} begin: to {</div>} ending:
        (change/part begin menu4-options/date-bar ending)
    ]   
    
    ;;;;;;;;;;;;;;;;;;;;;SELECTEDMENUJAVASCRIPT
    parse menu4-template [
        thru {//SELECTEDMENUBEGIN} begin: to {//SELECTEDMENUEND} ending:
        (insert begin {
            g_unidocument.MENU4.style.color = "gold";
            g_unidocument.MENU4.style.background = "black";} ending)
    ]

    ;;;;;;;;;;;;;;;;;;;;;CURRENTMENUHTML
    parse menu4-template [
        thru {<div id="MENU4"} begin: to {>} ending:
        (change/part begin "" ending)   
    ]

    ;;;;;;;;;;;;;;;;;;;;LINK MYPHOTO
    parse menu4-template [            
        thru {<!-- MYPHOTOBEGIN -->} begin: to {<img} ending:
        (insert begin {^(line)^(tab)^(tab)<a href="./menu1.html">} ending)

        thru {myphoto.jpg">} begin: to {<!-- MYPHOTOEND -->} ending:
        (insert begin {^(line)^(tab)^(tab)</a>} ending)
    ]
    
    either (menu4-options/num-submenus > 0) [
        submenu-top: 0
        content-visibility: "visible"
        submenu-color: "gold"

        for num 1 menu4-options/num-submenus 1 [
            ;;;;;;;;;;;;stylesheets
            parse menu4-template [
                thru {<style type="text/css">} begin: to {div} ending:

                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num "CONTENT {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: 0px;
                left: 140px;
                font: 10pt Arial;
                color: black;
                visibility: } content-visibility {;}
                "^(line)^(tab)^(tab)^(tab)}"] ending)
                
                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num " {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: } submenu-top {px;
                left: 0px;
                width: 100px;
                height: 15px;
                font: bold 10pt Arial;
                color: } submenu-color {;
                background-color: black;
                text-align: center;
                cursor: hand;} 
                "^(line)^(tab)^(tab)^(tab)}"] ending)
            ]
            ;;;;;;;;;;;;;;html
            parse menu4-template [
                thru {<div id="CONTENT">} begin: to {</div>} ending:
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {CONTENT">
                <div id="CONTENTBAR">Submenu} num {bar</div><br>
                Submenu} num {Content^(line)^(tab)^(tab)^(tab)</div>}])
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {" onclick="if(window.loaded != true) return; inSubMenu} num {();" onmouseover="if(window.loaded != true) return; onSubMenu} num {();" onmouseout="if(window.loaded != true) return; offSubMenu} num {();">Submenu} num {</div>}] ending)
            ]
            ;;;;;;;;;;;;;javascript
                        
            parse menu4-template [
                thru {//SUBMENUSCRIPTBEGIN} begin: to {//SUBMENUSCRIPTEND} ending:
                (insert begin rejoin [{
                    function inSubMenu} num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"$shift.updatePage(^"SUBMENU" num "^",null,null,^"SUBMENU" num "CONTENT^");"{
                        }"}"{
                    }"}"{
                    }"function onSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"black^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"gold^";"{
                        }"}"{
                    }"}"{
                    }"function offSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"silver^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"black^";"{
                        }"}"{
                    }"}"] ending)
            ]
            
            submenu-top: submenu-top + 20
            content-visibility: "hidden"
            submenu-color: "silver"
        ]
        parse menu4-template [
            thru {//NEWMENUSHIFTBEGIN} begin: to {//NEWMENUSHIFTEND} ending:
            (insert begin {^(line)^(tab)var $shift = new Menushift("SUBMENU1",null,null,"SUBMENU1CONTENT");} ending)
        ]
    ][
        parse menu4-template [
            thru {<div id="CONTENT">} begin: to {</div>} ending:
            (change/part begin {Content goes here.} ending)
        ]
    ]
    
    write rejoin [global-options/folder "menu4.html"] menu4-template
]





build-menu5: func [
    "builds menu5.html page"
    /local menu5-template menu1 begin ending submenu-top content-visibility submenu-color
][
    menu5-template: read/string g-files/template
    
    ;;;;;;;;;;;;;;;;;;;MENUNAMES
    parse menu5-template [
        
        thru {onmouseout="offMenu1();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/1 ending)

        thru {onmouseout="offMenu2();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/2 ending)
        
        thru {onmouseout="offMenu3();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/3 ending)
        
        thru {onmouseout="offMenu4();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/4 ending)
        
        thru {onmouseout="offMenu5();">} begin: to {</div>} ending:
        (change/part begin global-options/menu/5 ending)        
    ]
    

    ;;;;;;;;;;;;;;;;;;;;BACKGROUND IMAGES
    parse menu5-template [
        thru {<body onload="afterCacheing();" } begin: to {>} ending:
        (change/part begin reform [global-options/background-color global-options/background-image] ending)
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;TITLEBAR
    parse menu5-template [
        thru {<title>} begin: to {</title>} ending:
        (change/part begin menu5-options/title ending)
    ]

    ;;;;;;;;;;;;;;;;;;;DATEBAR
    parse menu5-template [
        thru {<div id="DIVIDERBAR">} begin: to {</div>} ending:
        (change/part begin menu5-options/date-bar ending)
    ]   
    
    ;;;;;;;;;;;;;;;;;;;;;SELECTEDMENUJAVASCRIPT
    parse menu5-template [
        thru {//SELECTEDMENUBEGIN} begin: to {//SELECTEDMENUEND} ending:
        (insert begin {
            g_unidocument.MENU5.style.color = "gold";
            g_unidocument.MENU5.style.background = "black";} ending)
    ]

    ;;;;;;;;;;;;;;;;;;;;;CURRENTMENUHTML
    parse menu5-template [
        thru {<div id="MENU5"} begin: to {>} ending:
        (change/part begin "" ending)   
    ]

    ;;;;;;;;;;;;;;;;;;;;LINK MYPHOTO
    parse menu5-template [            
        thru {<!-- MYPHOTOBEGIN -->} begin: to {<img} ending:
        (insert begin {^(line)^(tab)^(tab)<a href="./menu1.html">} ending)

        thru {myphoto.jpg">} begin: to {<!-- MYPHOTOEND -->} ending:
        (insert begin {^(line)^(tab)^(tab)</a>} ending)
    ]
    
    either (menu5-options/num-submenus > 0) [
        submenu-top: 0
        content-visibility: "visible"
        submenu-color: "gold"

        for num 1 menu5-options/num-submenus 1 [
            ;;;;;;;;;;;;stylesheets
            parse menu5-template [
                thru {<style type="text/css">} begin: to {div} ending:

                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num "CONTENT {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: 0px;
                left: 140px;
                font: 10pt Arial;
                color: black;
                visibility: } content-visibility {;}
                "^(line)^(tab)^(tab)^(tab)}"] ending)
                
                (insert begin rejoin ["^(line)^(tab)^(tab)^(tab)" "div#SUBMENU" num " {^(line)"
                {^(tab)^(tab)^(tab)^(tab)position: absolute;
                top: } submenu-top {px;
                left: 0px;
                width: 100px;
                height: 15px;
                font: bold 10pt Arial;
                color: } submenu-color {;
                background-color: black;
                text-align: center;
                cursor: hand;} 
                "^(line)^(tab)^(tab)^(tab)}"] ending)
            ]
            ;;;;;;;;;;;;;;html
            parse menu5-template [
                thru {<div id="CONTENT">} begin: to {</div>} ending:
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {CONTENT">
                <div id="CONTENTBAR">Submenu} num {bar</div><br>
                Submenu} num {Content^(line)^(tab)^(tab)^(tab)</div>}])
                
                (insert begin rejoin [{^(line)^(tab)^(tab)^(tab)<div id="SUBMENU} num {" onclick="if(window.loaded != true) return; inSubMenu} num {();" onmouseover="if(window.loaded != true) return; onSubMenu} num {();" onmouseout="if(window.loaded != true) return; offSubMenu} num {();">Submenu} num {</div>}] ending)
            ]
            ;;;;;;;;;;;;;javascript
                        
            parse menu5-template [
                thru {//SUBMENUSCRIPTBEGIN} begin: to {//SUBMENUSCRIPTEND} ending:
                (insert begin rejoin [{
                    function inSubMenu} num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"$shift.updatePage(^"SUBMENU" num "^",null,null,^"SUBMENU" num "CONTENT^");"{
                        }"}"{
                    }"}"{
                    }"function onSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"black^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"gold^";"{
                        }"}"{
                    }"}"{
                    }"function offSubMenu" num "() {"{
                        }"if($shift.getSubMenuItem() != ^"SUBMENU" num "^") {"{
                            }"g_unidocument.SUBMENU" num ".style.color = ^"silver^";"{
                            }"g_unidocument.SUBMENU" num ".style.background = ^"black^";"{
                        }"}"{
                    }"}"] ending)
            ]
            
            submenu-top: submenu-top + 20
            content-visibility: "hidden"
            submenu-color: "silver"
        ]
        parse menu5-template [
            thru {//NEWMENUSHIFTBEGIN} begin: to {//NEWMENUSHIFTEND} ending:
            (insert begin {^(line)^(tab)var $shift = new Menushift("SUBMENU1",null,null,"SUBMENU1CONTENT");} ending)
        ]
    ][
        parse menu5-template [
            thru {<div id="CONTENT">} begin: to {</div>} ending:
            (change/part begin {Content goes here.} ending)
        ]
    ]
    
    write rejoin [global-options/folder "menu5.html"] menu5-template
]







build-globalcss: func [
    {builds the global.css page}
    /local css-template begin ending menu-num
][
    css-template: read/string g-files/globalcss
    if not global-options/door [
        parse css-template [
            thru "img#DOORMENU {" begin: to "position" ending:
            (insert begin "^(line)^(tab)visibility: hidden;" ending)
        ]   
    ]
    if global-options/num-menus < 5 [
        for num (global-options/num-menus + 1) 5 1 [
            menu-num: rejoin ["div#MENU" num " {"]
            parse css-template [
                thru menu-num begin: to "position" ending:
                (insert begin "^(line)^(tab)visibility: hidden;" ending)
            ]
        ]
    ]
    write rejoin [global-options/folder "global.css"] css-template
]

update-pages: func [
    /local image-folder answer
][
    image-folder: rejoin [global-options/folder "images/"]

    if exists? global-options/folder [
        answer: request reform ["Overwriting " global-options/folder]
        if/else (answer = true) [
            if exists? image-folder [
                delete/any rejoin [image-folder "*"]
                delete image-folder
            ]
            delete/any rejoin [global-options/folder "*"]
            delete global-options/folder
        ][
            exit
        ]
    ]
    
    make-dir global-options/folder
    
    make-dir image-folder
    foreach file read g-files/images [
        write/binary rejoin [image-folder file] read/binary rejoin [g-files/images file]
    ]
    write/string rejoin [global-options/folder "global.js"] read/string g-files/globaljs
    write/string rejoin [global-options/folder "menushift.js"] read/string g-files/menushift
    build-globalcss
    build-menu1
    build-menu2
    build-menu3
    build-menu4
    build-menu5
    alert reform ["Built successfully in " global-options/folder]
]

make object! [
    menu-panel: menu-choice: site-folder: num-menus: back-color: back-image: door: bgcolor: none
    menu1-label: menu1-titel: menu1-submenus: none
    menu2-label: menu2-titel: menu2-submenus: none
    menu3-label: menu3-titel: menu3-submenus: none
    menu4-label: menu4-titel: menu4-submenus: none
    menu5-label: menu5-titel: menu5-submenus: none
    
    mainpage: layout [
        size 350x380
        origin 0x0
        box 350x45 black

        at 0x185
        box 350x45 black
        
        at 0x230
        menu-panel: box 350x105 silver

        at 0x335
        box 350x45 black

        across 
        at 10x10 
        label "Project Folder" 100 site-folder: field "/c/windows/desktop/site-folder/" 220
            [ global-options/folder: to-file site-folder/text] return

        at 10x55
        guide at
        tabs 175
        label "Number of Menus" 150 tab num-menus: choice 125 "5" "4" "3" "2" "1" [
            value: to-integer first value
            global-options/num-menus: value
            clear menu-choice/texts
            for num value 1 -1 [insert menu-choice/texts rejoin ["Menu" num] ]
        ] return
        label "Background Color" 150 tab back-color: field 125 "FAEBD7" 
            [global-options/background-color: rejoin ["bgcolor=" {"} back-color/text {"}] ] 
        pad 0   
        button "pick" 35 [
            bgcolor: request-list "Background Colors" [
                ["Antique-White " "FAEBD7"]
                ["Bisque " "FFE4C4"]
                ["Blanched-Almond " "FFEBCD"]
                ["Corn-Silk " "FFF8DC"]
                ["Light-Steel-Blue " "B0C4DE"]
            ]
            if (bgcolor <> none) [
                back-color/text: second bgcolor
                global-options/background-color: rejoin ["bgcolor=" {"} second bgcolor {"} ]
            ]
            show back-color
        ] return
        label "Background Image" 150 tab  back-image: choice "Yes" "No" 125 [
            value: first value
            if/else (value = "Yes") [global-options/background-image: {background="./images/background.gif"}
            ][global-options/background-image: {}]
        ] return
        label "Door" 150 tab door: choice "Visible" "Hidden" 125 [
            value: first value
            if/else (value = "Visible") [global-options/door: true][global-options/door: false] 
        ] return

        at 100x195
        menu-choice: choice 150 "Menu1" "Menu2" "Menu3" "Menu4" "Menu5" [
            if ((first value) = "Menu1") [menu-panel/pane: menu1 show menu-panel] 
            if ((first value) = "Menu2") [menu-panel/pane: menu2 show menu-panel]
            if ((first value) = "Menu3") [menu-panel/pane: menu3 show menu-panel]
            if ((first value) = "Menu4") [menu-panel/pane: menu4 show menu-panel]
            if ((first value) = "Menu5") [menu-panel/pane: menu5 show menu-panel]
            ;menu-panel/pane: to-word first value show menu-panel
        ]

        at 100x345
        guide at 
        button "Create" 150 [
            if (error? try [dir? global-options/folder])[
                alert reform [site-folder/text "is not a valid directory."]
                exit
            ]
            if (#"/" <> last site-folder/text) [
                alert reform [global-options/folder "is not a valid directory. Be sure to end with a ^"/^""]
                exit
            ]
            update-pages
        ]
    ]
    menu1: layout [
        size 350x105
        backcolor silver
        across
        origin 10x10
        tabs 200
        text "Menu1 Label" 150 bold tab menu1-label: field "Menu1" 100 
            [global-options/menu/1: menu1-label/text] return
        text "Title" 150 bold tab menu1-title: field "" 100
            [menu1-options/title: menu1-title/text] return
        text "Number of Submenus" 150 bold tab menu1-submenus: field "0" 25
            [menu1-options/num-submenus: to-integer menu1-submenus/text]
    ]
    menu2: layout [
        size 350x105
        backcolor silver
        across
        origin 10x10
        tabs 200
        text "Menu2 Label" 150 bold tab menu2-label: field 100 "Menu2" 
            [global-options/menu/2: menu2-label/text] return
        text "Title" 150 bold tab menu2-title: field 100 "" 
            [menu2-options/title: menu2-title/text] return
        text "Number of Submenus" 150 bold tab menu2-submenus: field 25 "0"
            [menu2-options/num-submenus: to-integer menu2-submenus/text]
    ]
    menu3: layout [
        size 350x105
        backcolor silver
        across
        origin 10x10
        tabs 200
        text "Menu3 Label" 150 bold tab menu3-label: field 100 "Menu3"
            [global-options/menu/3: menu3-label/text] return
        text "Title" 150 bold tab menu3-title: field 100 "" 
            [menu3-options/title: menu3-title/text] return
        text "Number of Submenus" 150 bold tab menu3-submenus: field 25 "0"
            [menu3-options/num-submenus: to-integer menu3-submenus/text]
    ]
    menu4: layout [
        size 350x105
        backcolor silver
        across
        origin 10x10
        tabs 200
        text "Menu4 Label" 150 bold tab menu4-label: field 100 "Menu4"
            [global-options/menu/4: menu4-label/text] return
        text "Title" 150 bold tab menu4-title: field 100 ""
            [menu4-options/title: menu4-title/text] return
        text "Number of Submenus" 150 bold tab menu4-submenus: field 25 "0"
            [menu4-options/num-submenus: to-integer menu4-submenus/text]
    ]
    menu5: layout [
        size 350x105
        backcolor silver
        across
        origin 10x10
        tabs 200
        text "Menu5 Label" 150 bold tab menu5-label: field 100 "Menu5"
            [global-options/menu/5: menu5-label/text] return
        text "Title" 150 bold tab menu5-title: field 100 ""
            [menu5-options/title: menu5-title/text] return
        text "Number of Submenus" 150 bold tab menu5-submenus: field 25 "0"
            [menu5-options/num-submenus: to-integer menu5-submenus/text]
    ]

    menu1/offset: 0x0
    menu2/offset: 0x0
    menu3/offset: 0x0
    menu4/offset: 0x0
    menu5/offset: 0x0
    
    menu-panel/pane: menu1
    view mainpage
]
