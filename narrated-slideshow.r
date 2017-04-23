REBOL [
    Title:   "Narriated Slideshow"
    Date:    18-Oct-2006
    Name:    'Narriated SLIDESHOW  ; For window title bar
    Version: 1.1.0
    File:    %narrated-slideshow.r
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [graphics sound]
        tested-under: [view 1.3.2.3.1 WinXP]
        support: none
        license: 'public-domain
        see-also: none
    ]
    Author:  "Louis A. Turk"
    Rights:  "Public Domain; use at your own risk."
    Needs:   "REBOL/View 1.3.2.3.1 supporting sound"
    Purpose: {To make possible simple, easy to make narrated slide shows.}
    Note: {
        The concept and design originated with Louis A. Turk.
        DideC (Didier Cadieu) helped considerably by answering programming questions and giving bits of code;
        it would not have been possible without his help.
	Josh (Josh Shireman) also answered programming questions. Anton (Anton Rolls) corrected a centering problem.

        You can make wav files using the free program Audacity. http://audacity.sourceforge.net

        Advanced JEPG Compressor does an excellent job compressing graphics files so they load 
        faster, but is not free. http://www.winsoftmagic.com/
    }
    USAGE: {
        You must, of course, supply the slides and sound files.
        Put the slides and their associated sound files in the same directory as this script.
        You must create a data file named %slides.txt containing lines of blocks in the following format:
        Each block must contain: (1) slide-file-name, (2) overlay, (3) caption, (4) sound-file.name.
        Use "" (an empty string) for no overlay or caption.
        Example file for a slide show of only two slides: 

        [%slide1.jpg "A DEMONSTRATION OF REBOL POWER" "The World's Greatest Programming Language." %sound1.wav]
        [%slide2.jpg "" "Carl Sassenrath (left) is creator of the REBOL programming language." %sound2.wav]

        Question? Contact me on the AltME Rebol3 world. My user name is Louis.
    }
    History: [
        1.0.0 [ "First release." "Louis"]
        1.1.0 [ "Centering problem fixed, thanks to Anton." "Louis"]
    ]
    Language: 'English
]
;file: request-file/title/only "Select the slides data file to use." "Select Data File"
file: %slides.txt ;uncomment the above line, and comment this one to select data files with different names.
slides: load file
narrate: func [talk] [ ;--- Manage the sound
    sound-port: open sound://
    insert sound-port load talk
    wait sound-port
    close sound-port
]
view/new win: layout/size [] 650x650 ;<= Set the max size you need
wait 0  ;---Initialize REBOL's internal event handler.
foreach slide  slides [ ;--- Start the slide show
    set [graphic overlay caption narration] slide
    lay: layout [
        origin 0
        banner center bold red "A REBOL Produced Narriated Slide Show" ;<= Change title as needed.
        image graphic overlay 500x400 frame black [unview] [quit]
        text 500 bold caption
        button "Quit" center [quit]
    ]
    lay/offset: max 0x0 win/size - lay/size / 2
    append clear win/pane lay
    show win
    narrate narration
]
do-events