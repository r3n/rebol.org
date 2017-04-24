; This file defines the filters which will be available for use from the
; various front ends to the library system. It is a hand coded file, so
; we can create exactly the combination of rules we want for each filter.

; Each filter consists of a NAME and a [DESCRIPTION ACTION] block. The
; name is how you refer to a filter you want to execute. The description
; could be displayed in a popup tooltip or status bar, and the action is
; the code that will actually execute to produce results for that filter.

Demos ["" [idx-match 'demo library/type]]
Tools ["" [idx-match 'tool library/type]]
Games ["" [idx-match 'game library/type]]
;Games ["" [idx-match 'game library/domain]]

Programs ["Programs and Applications" [idx-match [Demo Tool Game] library/type]]
;    [Demos Tools Games]]


Reference ["" [idx-match 'reference library/type]]
How-to    ["" [idx-match 'how-to    library/type]]
FAQ       ["" [idx-match 'faq       library/type]]
Article   ["" [idx-match 'article   library/type]]
Tutorial  ["" [idx-match 'tutorial  library/type]]
Idiom     ["" [idx-match 'idiom     library/type]]

Docs ["Documentation and other Writings" [idx-match [Reference How-to FAQ Article Tutorial Idiom] library/type]]


Math     ["Math Related scripts" [idx-match [math financial scientific] library/domain]]
Misc     ["Miscellanous scripts" [idx-match [printing AI visualization encryption compression x-file win-api external-lib-access shell] library/domain]]
GUI      ["" [idx-match [UI user-interface GUI VID] library/domain]]
Internet ["" [idx-match [net web http ftp cgi tcp email ldc ssl net-other] library/domain]]
Text     ["Text Processing" [idx-match [text text-processing markup html xml parse dialects] library/domain]]
Files    ["File Handling" [idx-match [files file-handling] library/domain]]
Database ["" [idx-match [DB database odbc mysql sql] library/domain]]
Patches  ["" [idx-match 'patch library/domain]]
Broken   ["Dead and Broken" [idx-match [dead broken] library/domain]]
Advanced ["Advanced Level Scripts" [idx-match [advanced] library/level]]

Code ["Code related scripts" [idx-match [one-liner function module protocol dialect] library/type]]
;[math misc gui internet text files database patches broken advanced]

