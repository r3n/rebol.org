REBOL [
 File: %call-spellchecker.r
    Date: 06-July-2006
    Title: "Call Spellchecker"
    Version: 1.0.1
    Author: "R. v.d.Zee"
    Rights: {Copyright © R. v.d.Zee 2006}
    Purpose: {The script provides a basic spell check for Rebol text areas.}
    Notes: {
    The Ispell spell checker will be shown in the shell.

    Ispell is often found on Linux system, and Aspell is a more recent spell checker.
    A similar script can be used with Windows XP. 
    See www.projectory.de/ispell/ for Windows Ispell 
    There is a complete Aspell installer for Windows XP:
        http://ftp.gnu.org/gnu/aspell/w32/Aspell-0-50-3-3-Setup.exe 
        - from the web page http://aspell.net/win32/
        Only the one file, the installer, is needed.
    
    The call script for Aspell might be a little different: 
    
        call [%aspell/bin/aspell check %rebol-spellcheck-testFile.txt]
        
    Presenting the spell checker output in a REBOL layout might be the next step....
        refer Spell Correcting Documents Under Linux, by Peter Hiscocks
	http://www.ee.ryerson.ca/~phiscock/papers/using-ispell.pdf
	
	... ispell output can be sent to a file for further work
	
	call [%/linux/usr/bin/ispell cat %rebol-spellcheck-testFile.txt | ispell -a > spelling-work ]
	(path to ispell may vary)
	
	}
    
    library: [
        level: 'beginner
        platform: 'all
        type: [tool how-to]
        domain: [text text-processing]
        tested-under: [XP Linux]
        support: none
        license: none
    ]
]

home: what-dir

spelling: layout [
    backdrop black
    across
    space 0
    typing: area 700x400 wrap font-size 15 orange orange
    scroller1: scroller 16x400 [scroll-para typing scroller1]
    return
    space 2
    indent 200
    button coal "Check" [    
        change-dir home
	write %rebol-spellcheck-testFile.txt typing/text
	oldfile-ID: checksum  read %rebol-spellcheck-testFile.txt
	call [%/linux/usr/bin/ispell  %rebol-spellcheck-testFile.txt]
        
        ;- when finished, Ispell writes the corrected text back to the file
        ;- poll the file every second to see if the file has changed
        ;- if the file has changed, reload and show it, and break out 
        
  	forever [
            wait 1
            newfile-ID: checksum read %rebol-spellcheck-testFile.txt
            if newfile-ID <> oldfile-ID [
                typing/text: read %rebol-spellcheck-testFile.txt
                show typing
                focus typing
                break
                ]
            ]
        ]

    button coal "Script" [typing/text: read %call-spellchecker.r show typing]
    button coal "Quit" [quit]
    indent 50 image 90x25 logo.gif
    ]
    typing/text: {
        Jusst try the spelll checker with the "Ceck" buutton.  
        
        Spell checking the script is not recommended... 
        the spell checker will overwrite the script file.
        }

                        focus typing
                        view spelling