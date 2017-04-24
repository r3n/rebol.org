
REBOL [
    Title: "edit-tools + little editor" 
    Note: [
        "redefines 'unfocus"] 
    Author: "Volker Nitsch" 
    Date: 14-Apr-2005 
    Version: 1.0.5 
    License: BSD 
    See: [] 
    Purpose: {
 Various stuff to implement an editor.
 Main features:
  Tools to plug an area with find/replace in a few lines.
  And a little editor with plugins.
} 
    File: %install-edit-tools.r 
    Library: [
        level: 'intermediate 
        platform: 'all 
        type: [demo module tool] 
        domain: [extension gui text text-processing vid] 
        tested-under: [linux 1.2.48.4.2] 
        support: none 
        license: 'BSD 
        see-also: none] 
    History: [
        14-Apr-2005 1.0.5 
        {bugfix, different behavior on windows minimized window} 
        1.0.4 "includes proto-coloriser as plugin" 
        1.0.3 "my-wait works now with requesters too" 
        1.0.2 "can be encapped together with plugins" 
        12-Apr-2005 "skimmed through code and made small edits" 
        11-Apr-2005 "published"]
] 
make-dir/deep %edit-tools/et/plug/ 
make-dir/deep %edit-tools/et/lib/ 
make-dir/deep %edit-tools/et/doc/ 
change-dir %edit-tools/ 
write 
%edit-tools.r {REBOL [
^-Title: "edit-tools + little editor"
^-Note: [
^-^-"redefines 'unfocus"
^-]
^-Author: "Volker Nitsch"
^-Date: 14-Apr-2005
^-Version: 1.0.5
^-License: 'BSD
^-See: []
^-Purpose: {
 Various stuff to implement an editor.
 Main features:
  Tools to plug an area with find/replace in a few lines.
  And a little editor with plugins.
}
^-File: %edit-tools.r
^-Library: [
^-^-level: 'intermediate
^-^-platform: 'all
^-^-type: [demo module tool]
^-^-domain: [extension gui text text-processing vid]
^-^-tested-under: [linux 1.2.48.4.2]
^-^-support: none
^-^-license: 'BSD
^-^-see-also: none
^-]
^-History: [
^-^-14-apr-2005 1.0.5
^-^-"bugfix, different behavior on windows minimized window"
^-^-1.0.4 "includes proto-coloriser as plugin"
^-^-1.0.3 "my-wait works now with requesters too"
^-^-1.0.2 "can be encapped together with plugins"
^-^-12-Apr-2005 "skimmed through code and made small edits"
^-^-11-Apr-2005 "published"
^-]
]

do edit-tools: [

^-;;;
^-;;; some debug-tools
^-;;;

^-; i want to load a script multiple times while debugging, 
^-; but use protect-system.
^-; so i call it the first time and then disable it

^-protect-system system/words/protect-system: none

^-; a little dump-utility

^-???: func ['word value] [
^-^-print [mold word mold :value]
^-^-set word :value
^-]

^-; i like to use comment for logging. 
^-; without redefinition its an inbuild nop.

^-unprotect 'comment
^-comment: func [val] [
^-^-if not system/options/quiet [
^-^-^-print ["Comment:" mold compose val]
^-^-]
^-]

^-; on windows i want the console to stay open, so want halt.
^-; on linux it stays open anyway, so i prefer quit

^-stop: does [
^-^-comment join "stopped " now
^-^-either system/version/4 = 3 [halt] [quit]
^-]

^-; continue after going to console. 
^-; i use that name in every script, often viewing the window too.

^-cont: func [] [my-do-events]

^-;;;
^-;;; some organisation-things
^-;;;

^-; some things should be encap-smart. 
^-; define sdk?: true in your encap-script, else its false:

^-if not value? 'sdk? [
^-^-sdk?: false
^-]

^-; base for files, in case something changes dir

^-et-root: any [
^-^-if link? [
^-^-^-clean-path link-root
^-^-]
^-^-if sdk? [
^-^-^-clean-path first split-path system/options/boot
^-^-]
^-^-what-dir
^-]

^-; what-dir <> et-root makes trouble

^-change-dir et-root

^-; inline-files are a repository for encapping
^-if sdk? [
^-^-fix-inline-files
^-]

^-; shorter than system/words and more clear IMHO

^-global: system/words

^-; i terminate scripts/actions with 'done.
^-; by default it quits. i redefine it before calling sub-pages
^-; to show the main-menu.

^-done: :quit

^-; the bye-button. its the "quit" or "back" on every page. 
^-; by default it quits. i redefine it before calling sub-pages
^-; to show the main-menu.

^-if not get-style 'bye-button [
^-^-stylize/master [
^-^-^-bye-button: button "Quit" [quit]
^-^-]
^-]

^-; instead of view layout[] i use a main-window 
^-; and put each layout there.

^-if not value? 'main-window [
^-^-main-window: center-face make face [
^-^-^-size: 720x520
^-^-^-effect: [gradient 0x1 66.120.192 44.80.132]
^-^-]
^-]

^-; my way of 'layout. shows layout in the main window.. 
^-; if you pass it a block, it layouts automatically. 
^-; and it removes timers of the old layout.
^-; todo: add resizing-support and titlebar-close.

^-window: func [
^-^-lay [object! block!]
^-^-/extend "make window at least layout-size"
^-^-/local old
^-] [
^-^-comment "Window changed"
^-^-if main-window/pane [hide main-window/pane]
^-^-if block? lay [lay: layout lay]
^-^-main-window/pane: lay
^-^-lay/offset: 0x0
^-^-lay/color: none
^-^-if extend [
^-^-^-old: main-window/size
^-^-^-main-window/size: max main-window/size lay/size
^-^-^-if old <> main-window/size [center-face main-window]
^-^-]
^-^-show main-window
^-^-main-window
^-]

^-;;;
^-;;; some patches
^-;;;

^-if not value? 'rebol-wait [
^-^-rebol-wait: :wait
^-]
^-my-wait: func ["workaround for old linux-call" arg /local awoken p] [
^-^-while [
^-^-^-awoken: rebol-wait append reduce [system/ports/system] arg
^-^-^-pick system/ports/system 1
^-^-] []
^-^-awoken
^-]

^-my-launch: func [file /args a] [
^-^-either not a [
^-^-^-if system/version/4 <> 3 [file: clean-path file]
^-^-^-launch/secure-cmd file
^-^-] [
^-^-^-call rejoin [
^-^-^-^-"" to-local-file system/options/boot " " file " " a
^-^-^-]
^-^-]
^-]

^-; scoll-para + resize scrollbar

^-my-scroll-para: func [ta sl] [
^-^-scroll-para ta sl
^-^-sl/redrag ta/size/y / max 1 second size-text ta
^-]

^-; traps errors and offers to ignore them.

^-recover: func ["error-handler for my-do-events" error [error!]] [
^-^-either confirm "Error! Ignore?" [
^-^-^-if not sdk? [
^-^-^-^-probe disarm error
^-^-^-]
^-^-^-change-dir et-root
^-^-] [
^-^-^-error
^-^-]
^-]

^-my-do-events: func [/local error] [
^-^-forever [
^-^-^-if error? set/any 'error try [my-wait [] break] [
^-^-^-^-recover error
^-^-^-]
^-^-]
^-]

^-; my version of 'new-line. less efficient, uses mold.
^-; but runs on linux, and i prefer the syntax.

^-reline: func [val /pairs /pos /skip size /local src] [
^-^-if pairs [
^-^-^-return reline/skip val 2
^-^-]
^-^-either pos [
^-^-^-either skip [
^-^-^-^-forskip val size [
^-^-^-^-^-change/only val reline first val
^-^-^-^-]
^-^-^-^-head val
^-^-^-] [
^-^-^-^-change/only val reline first val
^-^-^-]
^-^-] [
^-^-^-first load/all head either not block? val [
^-^-^-^-insert mold/all val newline
^-^-^-] [
^-^-^-^-if skip [
^-^-^-^-^-val: reline/pos/skip copy val size
^-^-^-^-]
^-^-^-^-src: mold/all val
^-^-^-^-insert next find src "[" newline
^-^-^-^-insert next insert find/last src "]" newline newline
^-^-^-]
^-^-]
^-]

^-; /link-compatibility

^-; todo: add some faces, 'field, 'area etc

^-if not value? 'set-face [
^-^-set-face: func [face value] [
^-^-^-switch/default face/style [
^-^-^-^-slider [face/data: value]
^-^-^-^-edit [face/text: value face/line-list: none]
^-^-^-^-raw-slider [face/data: value]
^-^-^-^-fine-slider [face/data: value]
^-^-^-] [make error! join "unknown set-face-style " face/style]
^-^-^-show face
^-^-]
^-]

^-; not perfect, but works. security-hole, executes code!

^-if not value? 'construct [
^-^-construct: func [block /with base] [
^-^-^-either with [
^-^-^-^-make base block
^-^-^-] [
^-^-^-^-context block
^-^-^-]
^-^-]
^-]

^-;;;
^-;;; A key part:
^-;;; before unfocus saves caret and highlight in face itself.
^-;;; needed for find-fields and such, 
^-;;; which want caret of the main text.
^-;;;

^-if not value? 'rebol-unfocus [
^-^-rebol-unfocus: :unfocus
^-^-unprotect 'unfocus
^-^-unfocus: func [/local sv*] [
^-^-^-sv*: system/view
^-^-^-save-focus sv*/focal-face
^-^-^-rebol-unfocus
^-^-]
^-]

^-save-focus: func [
^-^-"saves caret in focused edit-face." face /local f sv*
^-] [
^-^-sv*: system/view
^-^-if all [f: sv*/focal-face in f 'caret same? f face sv*/caret] [
^-^-^-f/caret: sv*/caret
^-^-^-f/highlight-start: sv*/highlight-start
^-^-^-f/highlight-end: sv*/highlight-end
^-^-]
^-]

^-caret?: func [
^-^-"returns caret of edit-face, even if not focused. "
^-^-face
^-] [
^-^-save-focus face
^-^-any [face/caret face/text]
^-]

^-; a focus for edit-faces which restores caret.
^-; should maybe called by focus implicitely?

^-refocus-edit: func [edit /local sv*] [
^-^-sv*: system/view
^-^-save-focus sv*/focal-face
^-^-sv*/focal-face: edit
^-^-sv*/caret: edit/caret
^-^-sv*/highlight-start: edit/highlight-start
^-^-sv*/highlight-end: edit/highlight-end
^-^-show edit
^-]

^-; the edit-area which remembers its caret and highlight.
^-; also fixed-font, tabs adjusted to 4 chars.

^-stylize/master [
^-^-edit: area wrap font-name font-fixed with [
^-^-^-caret: highlight-start: highlight-end: none
^-^-^-size: 520x435
^-^-^-deflag-face self 'tabbed
^-^-] para [
^-^-^-tabs: 28
^-^-]
^-]

^-; this processes the highlighted region.
^-; if nothing highlighted, returns none
^-; if user-code returns a string, region is replaced.

^-process-highlight: func [
^-^-"replace highlighted region. returns code-result, or none without highlight."
^-^-'var edit code /local sv* old-string new-string
^-] [
^-^-sv*: system/view
^-^-save-focus edit
^-^-if edit/highlight-start [
^-^-^-refocus-edit edit
^-^-^-old-string: copy/part sv*/highlight-start sv*/highlight-end
^-^-^-new-string: do func compose [(var)] code old-string
^-^-^-if string? new-string [
^-^-^-^-change/part
^-^-^-^-sv*/highlight-start new-string sv*/highlight-end
^-^-^-^-sv*/highlight-end:
^-^-^-^-skip sv*/highlight-start length? new-string
^-^-^-^-show edit
^-^-^-]
^-^-^-new-string
^-^-]
^-]

^-; use like this:

^-replace-in-edit: func [edit old new /local done?] [
^-^-done?: process-highlight region edit [
^-^-^-if region = old [
^-^-^-^-return new
^-^-^-]
^-^-]
^-^-if not done? [
^-^-^-alert join mold old " not selected"
^-^-]
^-]

^-;;;
^-;;; scroll the text arround
^-;;;

^-; (based on inbuild editor)

^-scroll-to: func ["scroll to caret" t1 s1 txt /local xy] [
^-^-xy: (caret-to-offset t1 txt) - t1/para/scroll
^-^-t1/para/scroll/y: second min 0x0 t1/size / 2 - xy
^-^-s1/data: (second xy) / max 1 second size-text t1
^-^-show [s1 t1]
^-]

^-goto-line: func [
^-^-edit-area edit-slider number [number! string!]
^-^-/local sv*
^-] [
^-^-sv*: system/view
^-^-focus edit-area
^-^-sv*/caret: edit-area/text
^-^-loop -1 + to-integer number [
^-^-^-if not sv*/caret: find/tail sv*/caret newline [
^-^-^-^-sv*/caret: tail edit-area/text
^-^-^-^-break
^-^-^-]
^-^-]
^-^-scroll-to edit-area edit-slider sv*/caret
^-]

^-; finds in edit-area, inbuild find/next and cycling 

^-find-in-edit: func [area slider string /local sv* text] [
^-^-sv*: system/view
^-^-refocus-edit area
^-^-if all [
^-^-^-not text: find next sv*/caret string
^-^-^-not text: find area/text string
^-^-] [unfocus return none]
^-^-sv*/caret: text
^-^-sv*/highlight-start: sv*/caret
^-^-sv*/highlight-end: skip sv*/highlight-start length? string
^-^-scroll-to area slider sv*/caret
^-^-show area
^-^-sv*/caret
^-]

^-;;;
^-;;; a crazy dual slider. the right one steps a fixed amount.
^-;;; confuses some people, 
^-;;; but enables scrolling with thousands of lines.
^-;;; (if you can live with scroll-speed)
^-;;; right click centers it, so you can continue scrolling
^-;;;

^-stylize/master [
^-^-raw-slider: slider with [
^-^-^-base: 0
^-^-^-size: 16x435
^-^-]
^-^-fine-slider: slider with [
^-^-^-data: 0.5
^-^-^-size: 16x435
^-^-] feel [
^-^-^-; detect, not engage. detects right-click for dragger too :)
^-^-^-detect: func [face event /local e] [
^-^-^-^-either 'alt-down = e: event/1 [
^-^-^-^-^-do-face-alt face none
^-^-^-^-^-none
^-^-^-^-] [event]
^-^-^-]
^-^-]
^-]

^-scroll-raw: func [ta slr slf /no-scroll] [
^-^-slr/base: slr/data
^-^-set-face slf 0.5
^-^-if not no-scroll [scroll-para ta slr]
^-]

^-scroll-fine: func [ta slr slf /no-scroll] [
^-^-set-face slr
^-^-slf/data - 0.5
^-^-* 3000 / (second size-text ta)
^-^-+ slr/base
^-^-if not no-scroll [scroll-para ta slr]
^-]

^-center-fine: func [ta slr slf] [
^-^-scroll-raw/no-scroll ta slr slf
^-^-set-face slf 0.5
^-^-scroll-fine ta slr slf
^-]

^-;;;
^-;;; a little config-tool. saves caret and scroll of files.
^-;;; stores info about the current file in global 'file-info,
^-;;; and its text in 'file-text !
^-;;;

^-reg-file: et-root/edit-tools-reg.r

^-; infos about currently edited file

^-file-text: 'unset ; text of current file

^-file-info!: context [
^-^-scroll: 0
^-^-caret: 0
^-^-name: et-root/et/doc/readme.txt
^-^-modified: none
^-^-checksum: none
^-]

^-; the info for the current file

^-file-info: 'unset

^-; infos about all files

^-reg!: context [
^-^-file: file-info!/name
^-^-last-dir: what-dir
^-^-last-host: read dns://
^-^-files: reduce [file make file-info! []]
^-]

^-; load reg on start.

^-if not value? 'reg [
^-^-reg: make reg! []
^-^-if exists? reg-file [
^-^-^-reg: construct/with load/all reg-file reg
^-^-]
^-]

^-; saves registry. modifies global file-info

^-save-reg: func [ta "edit-area" sr "scroller" /local hdr] [
^-^-file-info/scroll: sr/data
^-^-file-info/caret: index? caret? ta
^-^-file-info/checksum: checksum/secure ta/text
^-^-file-info/modified: modified? file-info/name
^-^-file-text: ta/text
^-^-hdr: reline/pairs compose [
^-^-^-Title: "Edit-tools-registry" Date: (now)
^-^-]
^-^-save/all/header reg-file reline/pairs third reg hdr
^-]

^-; changes global 'file-text and 'file-info

^-read-file: func [file /local info-pos] [
^-^-file: clean-path file
^-^-reg/file: file
^-^-; read global 'file-text
^-^-file-text: any [
^-^-^-attempt [read file]
^-^-^-reform ["File" file "does not exist."]
^-^-]
^-^-; set global 'file-info
^-^-; insert file in history, if new
^-^-; move selected file to front, for history-top
^-^-either info-pos: find reg/files file [
^-^-^-file-info: info-pos/2
^-^-^-remove/part info-pos 2
^-^-^-insert insert reg/files file-info/name file-info
^-^-] [
^-^-^-file-info: make file-info! [name: file]
^-^-^-insert insert reg/files file file-info
^-^-]
^-^-file-text
^-]

^-; reads name from global 'file-info

^-save-file: func [
^-^-"save file and reg, if modified"
^-^-ta sr /? "ask before saving"
^-] [
^-^-if not ta/text == attempt [read file-info/name] [
^-^-^-if any [not ? confirm join "save " file-info/name] [
^-^-^-^-write file-info/name ta/text
^-^-^-]
^-^-]
^-^-; want some way to edit the reg-file itself.
^-^-; without check the handmade changes would be overwritten.
^-^-if file-info/name <> reg-file [
^-^-^-save-reg ta sr
^-^-]
^-]

^-open-file: func [/local file] [
^-^-if file: request-file/only/file reg/file [
^-^-^-read-file file
^-^-]
^-]

^-; sets edit-area and slider to file-info's data

^-set-edit: func ["scroll, set caret etc" ta sr] [
^-^-focus ta
^-^-system/view/caret: at ta/text file-info/caret
^-^-set-face sr file-info/scroll
^-^-do-face sr none
^-]

^-; shortens filenames if in subdir.

^-make-files-relative: func [files dir] [
^-^-forall files [
^-^-^-if parse files/1 [thru dir copy file to end] [
^-^-^-^-files/1: to-file file
^-^-^-]
^-^-]
^-^-head files
^-]

^-;;;
^-;;; demo and little editor
^-;;;

^-if not value? 'load-only [

^-^-; some config

^-^-; this scripts are listed in plugin-list

^-^-make-dir/deep plugin-dir: dirize et-root/et/plug

^-^-; library-scripts for use by plugins

^-^-make-dir/deep lib-dir: dirize et-root/et/lib

^-^-; place for docu

^-^-make-dir/deep lib-dir: dirize et-root/et/doc

^-^-; override some hooks

^-^-done: func [] [change-dir et-root refresh]

^-^-stylize/master [
^-^-^-bye-button: button #"^^q" "cancel/q" [done]
^-^-]

^-^-; main editor

^-^-do-text: func [] [
^-^-^-if sdk? [
^-^-^-^-alert "Sorry, no License to execute user-code."
^-^-^-^-exit
^-^-^-]
^-^-^-save-file/? ta sr
^-^-^-unset [load-only]
^-^-^-do file-info/name
^-^-]

^-^-refresh: func [] [
^-^-^-history: extract reg/files 2
^-^-^-make-files-relative history et-root
^-^-^-h: 0x435 ;edit-area hight
^-^-^-tls: 100x124 ;text-list size
^-^-^-window [

^-^-^-^-; horizontal tool-bar
^-^-^-^-across
^-^-^-^-button "quit" [save-file/? ta sr quit]

^-^-^-^-; a find-field
^-^-^-^-tf: field [find-in-edit ta sr face/text] 65
^-^-^-^-btn "find/f" #"^^f" [do-face tf none]

^-^-^-^-; a replace-field
^-^-^-^-btn "replace/r" #"^^r" [
^-^-^-^-^-replace-in-edit ta tf/text tr/text
^-^-^-^-]
^-^-^-^-tr: field 65

^-^-^-^-; our filename
^-^-^-^-h3 reform [reg/file]

^-^-^-^-; vertical toolbar
^-^-^-^-below guide
^-^-^-^-button "save/s" #"^^s" [save-file ta sr refresh]
^-^-^-^-button "open" [save-file/? ta sr open-file refresh]
^-^-^-^-button "do/d" #"^^d" [do-text]

^-^-^-^-; little joke ;)
^-^-^-^-button "this button" [
^-^-^-^-^-save-file/? ta sr
^-^-^-^-^-read-file %edit-tools.r
^-^-^-^-^-refresh
^-^-^-^-^-find-in-edit ta sr join "this " "button"
^-^-^-^-]

^-^-^-^-label "history"
^-^-^-^-text-list data head history tls [
^-^-^-^-^-save-file/? ta sr
^-^-^-^-^-read-file value
^-^-^-^-^-refresh
^-^-^-^-]

^-^-^-^-; plugins
^-^-^-^-label "execute plugin"
^-^-^-^-text-list tls data any [
^-^-^-^-^-attempt [sort read dirize plugin-dir]
^-^-^-^-^-[]
^-^-^-^-] [
^-^-^-^-^-file-text: ta/text
^-^-^-^-^-save-reg ta sr
^-^-^-^-^-do plugin-dir/:value
^-^-^-^-]

^-^-^-^-; edit-area and sliders
^-^-^-^-return
^-^-^-^-ta: edit 520x0 + h file-text
^-^-^-^-return
^-^-^-^-sr: raw-slider 16x0 + h [scroll-raw ta sr sf]
^-^-^-^-return
^-^-^-^-sf: fine-slider 16x0 + h
^-^-^-^-[scroll-fine ta sr sf] [center-fine ta sr sf]
^-^-^-^-do [
^-^-^-^-^-set-edit ta sr ;scroll, set caret etc.
^-^-^-^-]
^-^-^-]
^-^-]

^-^-; and now we really go.

^-^-read-file either all [sdk? system/options/args] [
^-^-^-to-rebol-file system/options/args/1
^-^-] [
^-^-^-reg/file
^-^-]
^-^-refresh
^-^-unprotect [do-events wait]
^-^-do-events: :my-do-events
^-^-wait: :my-wait
^-^-view main-window
^-]
]
} 
write 
%et/plug/sub-mini-edit.r {REBOL [
^-Title: "sub-mini-edit"
^-Purpose: "demo/template for a sub-page with an editor"
    Date: 11-Apr-2005 
    Version: 1.0.0 
    License: 'BSD 
]

window [
^-across
^-title "Sub-mini-edit"
^-below guide
^-bye-button
^-button "ok" [
^-^-file-text: ta/text
^-^-save-reg ta sr
^-^-refresh
^-]
^-return
^-ta: edit copy file-text ; copy! we need undo on cancel
^-return
^-sr: slider [my-scroll-para ta sr] 0x1 * ta/size + 16x0
^-do [set-edit ta sr] ;scroll, caret etc
]} 
write 
%et/plug/clean-script.r {rebol [
^-Title: "sub-mini-edit"
^-Purpose: "gui-wrapper for clean-script"
^-Author: "Volker Nitsch"
    Date: 11-Apr-2005 
    Version: 1.0.0 
    License: 'BSD 
]

window [
^-across
^-title "Clean script"
^-below guide
^-bye-button
^-button "ok" [file-text: ta/text save-reg ta sr refresh]
^-button "clean" [
^-^-do et-root/et/lib/clean-script.r
^-^-ta/text: clean-script ta/text
^-^-set-edit ta sr
^-]
^-return
^-ta: edit copy file-text ; copy! we need undo on cancel
^-return
^-sr: slider [my-scroll-para ta sr] 0x1 * ta/size + 16x0
^-do [set-edit ta sr] ;scroll, caret etc
]
} 
write 
%et/plug/pack-me.r {REBOL [
^-Title: "pack me"
^-Purpose: "packs this editor in an self-extracting script"
^-Author: "Volker Nitsch"
^-Date: 11-Apr-2005
^-Version: 1.0.0
^-License: 'BSD
]

out: copy [
^-REBOL []
^-make-dir/deep %edit-tools/et/plug/
^-make-dir/deep %edit-tools/et/lib/
^-make-dir/deep %edit-tools/et/doc/
^-change-dir %edit-tools/
]
out/2: second load/all et-root/edit-tools.r
out/2: reline/pairs third make construct out/2 [
^-File: %install-edit-tools.r
]

foreach file [
^-%edit-tools.r
^-%et/plug/sub-mini-edit.r
^-%et/plug/clean-script.r
^-%et/plug/pack-me.r
^-%et/plug/color-rebol.r
^-%et/lib/clean-script.r
^-%et/doc/readme.txt
] [
^-append out compose [
^-^-write (file) (read et-root/:file)
^-]
]

append out [
^-do %edit-tools.r
]

window [
^-across
^-title "pack me"
^-below guide
^-bye-button
^-button "save" [
^-^-if f: request-file/title/only/file
^-^-"Where to store the archive?" "Save" et-root/install-edit-tools.r
^-^-[
^-^-^-write f ta/text
^-^-^-read-file f
^-^-^-save-reg ta sr
^-^-]
^-^-refresh
^-]
^-return
^-ta: edit mold/only out ; copy! we need undo on cancel
^-return
^-sr: slider [my-scroll-para ta sr] 0x1 * ta/size + 16x0
^-do [set-edit ta sr] ;scroll, caret etc
]


} 
write 
%et/plug/color-rebol.r {rebol []

lay: layout [
^-bye-button
pad 320
^-button "ok" [file-text: ta/text save-reg ta sr refresh]
^-return
at ta/offset guide ; of main page
^-ta: edit with [pane: copy []] copy file-text with [
^-^-feel: get in get-style 'info 'feel
^-]
^-return
^-sr: raw-slider [my-scroll-para ta face]
]

markup-face: func [text-face markup-face start end] [
^-ext: markup-face/edge/size
^-p0: caret-to-offset text-face start
^-p1: caret-to-offset text-face end
^-markup-face/offset: p0 - text-face/edge/size
^-markup-face/size: 0x1 * face/font/size + p1 - p0 + (2 * ext)
^-markup-face/text: copy/part start end
^-markup-face/font: text-face/font
^-markup-face/tx-offset: markup-face/offset
^-markup-face/tx-pos: start
^-append text-face/pane markup-face
]

markup-face!: make face [
^-edge: make edge [
^-^-size: 1x1
^-]
^-para: none
^-tx-offset: 'unset
^-tx-pos: 'unset
^-feel: make feel [
^-^-redraw: func [face] [
^-^-^-face/offset: face/parent-face/para/scroll + face/tx-offset
^-^-]
^-^-engage: func [f a e] [
^-^-^-if 'down = a [
^-^-^-^-alert mold copy/part f/tx-pos find f/tx-pos newline
^-^-^-]
^-^-]
^-]
]

colors: reduce [
^-char! 0.120.40
^-date! 0.120.150
^-decimal! 0.120.150
^-email! 0.120.40
^-file! 0.120.40
^-integer! 0.120.150
^-issue! 0.120.40
^-money! 0.120.150
^-pair! 0.120.150
^-;string! 0.120.40
^-tag! 0.120.40
^-time! 0.120.150
^-tuple! 0.120.150
^-url! 0.120.40
^-refinement! 160.120.40
^-;cmt 10.10.160

^-word! gold
^-lit-word! gold
^-set-word! gold
^-get-word! gold
^-path! yellow
^-set-path! yellow
^-lit-path! yellow
]

blanks: charset [#" " #"^^/" #"^^-"]
emit: func [val start end /local color] [
^-; val could be tuple, so we need skip
^-if local: find/skip colors type? val 2 [
^-^-parse/all start [any blanks start: to end]
^-^-markup-face ta make markup-face! [color: local/2] start end
^-]
]

parse ta/text blk-rule: [
^-some [
^-^-str:
^-^-newline |
^-^-#";" [thru newline | to end] new: |

^-^-[#"[" | #"("] |
^-^-[#"]" | #")"] |

^-^-skip (set [value new] load/next str emit value str new) :new
^-]
]
set-edit ta sr
window lay
;unfocus

;probe length? ta/pane


} 
write 
%et/lib/clean-script.r {REBOL [
^-Title: "REBOL Script Cleaner (Pretty Printer)"
^-Date: 29-May-2003
^-File: %clean-script.r
^-Author: "Carl Sassenrath"
^-Purpose: {
        Cleans (pretty prints) REBOL scripts by parsing the REBOL code
        and supplying standard indentation and spacing.
    }
^-History: [
^-^-"Volker Nitsch" 1.2.0 13-Apr-2005
^-^-"Applied romanos patch to work recursion- and 'break - less"
^-^-"Carl Sassenrath" 1.1.0 29-May-2003 "Fixes indent and parse rule."
^-^-"Carl Sassenrath" 1.0.0 27-May-2000 "Original program."
^-]
^-library: [
^-^-level: 'intermediate
^-^-platform: all
^-^-type: [tool]
^-^-domain: [text text-processing]
^-^-tested-under: none
^-^-support: none
^-^-license: none
^-^-see-also: none
^-]
]
script-cleaner: make object! [
^-out: none
^-spaced: off
^-indent: ""
^-emit-line: func [] [append out newline]
^-emit-space: func [pos] [
^-^-append out either newline = last out [indent] [
^-^-^-pick [#" " ""] found? any [
^-^-^-^-spaced
^-^-^-^-not any [find "[(" last out find ")]" first pos]
^-^-^-]
^-^-]
^-]
^-emit: func [from to] [emit-space from append out copy/part from to]
^-set 'clean-script func [
^-^-{Returns new script text with standard spacing (pretty printed).}
^-^-script "Original Script text"
^-^-/spacey "Optional spaces near brackets and parens"
^-^-/local str new
^-] [
^-^-spaced: found? spacey
^-^-clear indent
^-^-out: append clear copy script newline
^-^-parse script blk-rule: [
^-^-^-some [
^-^-^-^-str:
^-^-^-^-newline (emit-line) |
^-^-^-^-#";" [thru newline | to end] new: (emit str new) |

^-^-^-^-;does not work with break-less link
^-^-^-^-;[#"[" | #"("] (emit str 1 append indent tab) blk-rule |
^-^-^-^-;[#"]" | #")"] (remove indent emit str 1) break |
^-^-^-^-;but we do not need recursion
^-^-^-^-[#"[" | #"("] (emit str 1 append indent tab) |
^-^-^-^-[#"]" | #")"] (remove indent emit str 1) |

^-^-^-^-skip (set [value new] load/next str emit str new) :new
^-^-^-]
^-^-]
^-^-remove out
^-^-if (load script) <> load out [
^-^-^-make error! "script-semantic changed"
^-^-]
^-^-out
^-]
]
} 
write 
%et/doc/readme.txt "todo.." 
do %edit-tools.r