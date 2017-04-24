rebol [
    Title: "Document Search"
    Date: 12-Aug-2006
    Name: 'document-search
    File: %document-search.r
    Version: 1.0.0
    Author: "rwvd.Zee"
    Purpose: "Users may open a directory, search files for a phrase, and then review documents in a browser."
    Note: {
        - no error checking
        - maybe useful for searching the manual and, with some minor changes, a directory of library scripts
        - works with some linux distributions
        - Windows  users might change the line  "call [firefox found.html]"
                                            to         "browse %found.html"
          and may also have to supply the path the searched directory
          
        - the script reads all files in a chosen directory
        - if the search string is found in a document, the title of
          the document is added to the html page
        - the browser is called to review the documents
        
    }
  Library: [
     level: 'beginner
     platform: 'all
     type: [reference tool]
     domain: [files]
     tested-under: none
     support: none
     license: none
     see-also: find-file.r
   ]
]



view layout  [
    size 300x595
    backdrop ivory
    space 0
    style infoLine h3 230 
    infoLine "Open the directory to search."
    infoLine {Type a string to search for in the field and click "Search".}
    infoLine  "Documents may be reviewed in the browser."
    space 10
    box 1x1
    directory: h3 250 maroon
    searchField: field tan  snow font-size 15
    across
    indent 35
    
    btn "Directory" [
        change-dir request-dir/offset 100x305
	directory/text: what-dir
	show directory
	]

    btn "Search"  [
       manualFiles: read %.
       finds: rejoin [{<html><body><font size=12> Search Results For  "} searchField/text {" ...</font><P>}]
       foreach fileIn manualFiles [
           if find read fileIn searchField/text [
               parse read fileIn [thru <title> copy theTitle to </title>]
               append finds rejoin ["<a href=" fileIn ">" theTitle "</a><BR>" ] 
               ]
           ]
        append finds "</body></html>"
        write %found.html finds
        call [firefox found.html]
        ]
        
    btn "Quit" [quit]

]