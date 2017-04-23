REBOL [
    Title: "translate"
    Date: 23-Aug-2002/18:30:14+2:00
    Version: 1.0.0
    File: %translate.r
    Author: "Volker Nitsch"
    Purpose: "i18n-tool to translate rebol-scripts"
    Email: nc-nitschvo2@netcologne.de
    library: [
        level: 'intermediate
        platform: 'all
        type: 'Tool
        domain: [dialects GUI text-processing]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

prefs: context[
    source: %translate.r
    target: %translate-deutsch.r
    source-language: "english"
    target-language: "german"
    unknown: []
    known: to-hash["english" "englisch" "german" "deutsch" "translate" "uebersetze" "save" "speichern"
"there are doubles in translations." "Diesen String gibt es schon."
        {could be the same word in both languages. can break script. contine?}
{Koennte sein, das es den Text in beiden Sprachen gibt. Der Script koennte dadurch fehlerhaft werden. Trotzdem fortsetzen? }
"really delete this nice translation?" {Ooch. wirkklich diese huebsche uebersetzung loeschen?} ">known" ">bekannte"
 "edit script" "Editiere Script" "no editor installed" "kein Editor installiert." "ok" "Ja" "text missing" "Text fehlt" "delete"
"Loeschen" "this is present in script" "Das gibts schon im Script." "cancel" "Niicht!" ">unknown" ">unbekannte" "Debugger"
"Kammerjaeger"
 ]
    ;known: to-hash["english" "german" "wrong" "wrong"]
    this-file: %translate-prefs.r
    format: [translate-prefs 0.0.0]
]
save-prefs': does[save prefs/this-file make prefs[date: now]]
if exists? prefs/this-file[ prefs: make prefs last load/all prefs/this-file]
;delete prefs/this-file ;save-prefs'

translate: does[
    either found: find prefs/known string: first here [
        change/only here either odd? index? found[ found/2 ][ found/-1 ]
    ][
        append prefs/unknown string
    ]
]

reversible?: does[  equal? length? prefs/known length? unique copy prefs/known  ]

save-all: does[save-prefs' save prefs/target source' parse-and-view last-lay]

parse-and-view: func[lay][
if all[ not reversible?
    not confirm join "there are doubles in translations. "
    "could be the same word in both languages. can break script. contine?"
][return]
source': load/all prefs/source
clear prefs/unknown
parse source' rule: [ some[
    here:
    string! ( translate )
    | into rule
    | skip ()
]]
prefs/unknown: unique prefs/unknown
view center-face layout last-lay: lay
]

unknown-lay: [
    button ">known"[parse-and-view known-lay]
    button "save"[save-all]
    button "Debugger"[either exists? %ed.r[do %ed.r][alert "no editor installed"]]
    return text-list 550x400 data prefs/unknown[
        edit-translation reduce[first face/picked ""]
    ]
]
known-lay: [
    button ">unknown"[parse-and-view  unknown-lay]
    button "save"[save-all]
    return text-list 550x400 data foreach [s d] prefs/known copy/deep[append [] remold[s d] ][
        edit-translation load first face/picked
    ]
]
edit-translation: func[source-target][
view center-face layout [
    label prefs/source-language sf: info 550x100 first source-target
    label prefs/target-language tf: field 550x100  second source-target
    across button "ok"[
        if not any[
            if empty? sf/text[alert "text missing" 'cancel]
            if find prefs/known tf/text [alert "this is present in script" 'cancel]
        ][
            either found: find/tail prefs/known sf/text[
                change found tf/text
            ][
                repend prefs/known [sf/text tf/text]
            ]
        ]
        parse-and-view last-lay
    ]
    button "delete"[
        if confirm "really delete this nice translation?"[
            remove find prefs/known sf/text
            remove find prefs/known tf/text
        ]
        parse-and-view last-lay
    ]
    button "cancel"[parse-and-view last-lay]
]]

parse-and-view  unknown-lay

