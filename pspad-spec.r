REBOL [
    Title: "REBOL Spec Generator for Text Editor PsPAD"
    Date: 06-Jul-2005
    Purpose: {Create PSPAD syntax file from REBOL system words}
    author: cybarite@sympatico.ca
    File: %pspad-spec.r
    Source: {
        Based on rebdoc.r by Carl Sassenrath
        which says "With minor modifications
        you can use this script to create
        docs for your own scripts."
    }
    library: [
        level: 'beginner
        platform: [windows]
        type: [tool]
        domain: 'text-processing
        tested-under: {REBOL/View 1.3.1.3.1 17-Jun-2005 Core 2.6.0}
        support: none
        license: none
        see-also: none
    ]
]


; initialization area

PsPAD-Directory: %/c/pspad/  ; change this to where you installed PsPAD

words: first system/words

;;;; First the .ini file for REBOL


buffer: copy {

; PSPad user HighLighter definition file for REBOL
; See www.rebol.com
; See www.pspad.com


[Settings]
Name=REBOL
HTMLGroup=0
FileType=*.r
CommentString=;
ANSIComment=0
PasComment=0
SlashComment=0
CComment=0
SpecComment=0
BasComment=1
FoxComment=0
REMComment=0
ExclComment=0
ByComment=0
SharpComment=0
SlashComment=0
PerCentComment=0
SinglQComment=0
DblQComment=0
SQLComment=0
FortranComment=0
CStarComment=0
DollarComment=0
LBracketComment=0
SingleQuote=0
DoubleQuote=1
Preprocessors=0
IndentChar=
UnIndentChar=
TabWidth=4
CaseSensitive=0
PocoComment=0
DComment=0
SmartComment=0
HaskellComment=0
PipeComment=0
WebFocusComment=0
KeyWordChars=-
CodeExplorer=ftUnknown
[KeyWords]
}

foreach word sort words [
    append buffer rejoin [
        word
        "="
        newline
    ]
]
write pspad-directory/%syntax/rebol.ini buffer

;;;; Then the .DEF file (context directory) for REBOL

def-buffer: copy {

; PSPad code template for REBOL
; Update: 06-Jul-2005


}

;-- First generate the word list:

words: first system/words
word-list: make block! 200

vals:  second system/words

while [not tail? words] [
    if any-function? first vals [
        append word-list first words
    ]
    words: next words
    vals: next vals
]
clear next find word-list 'what
sort word-list
bind word-list 'system
;
;-- Now generate the definition file based on the rebdoc.r
;-- approach
;

foreach word word-list [
    name: word    ; to get global binding
    args: first get name  ; function's arg list
    arg-list: second parse/all mold args "[]"
    spec: third get name            ; function's specification
    append def-buffer rejoin [
        "[" word " |R "  ; the R makes the text Red
        spec/1
        "]"
        newline
        word " |"   ; the | is where the cursor will be after inserting the text
        arg-list
        newline
    ]
 ]

write pspad-directory/%Context/REBOL.DEF def-buffer

