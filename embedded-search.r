REBOL [
    Title: "Embedded Search"
    Date: 20-Aug-2006
    Name: 'embedded-search
    File: %embedded-search.r
    Version: 1.0.0
    Author: "rwvd.zee"
    Purpose: "The script enables a document search  from within a browser."
    Note: {
        - "call [firefox found.html]" might be changed to "browse %found.html"      
        - requires REBOL browser plugin    
        - script refers to Firefox, but other browsers might be named
    }
  Library: [
     level: 'beginner
     platform: 'all
     type: [reference tool]
     domain: [files html]
     tested-under: none
     support: none
     license: none
     see-also: document-search.r
   ]
]



                               ;the document search script that will be embedded

script-directory: what-dir 
if not exists? %embedded-script.r [
    write %embedded-script.r {
    REBOL [Title: "Plugin Ready" Version: 1.2.0]
    vers: 1.2.46
    view layout [
    size 600x595
    backdrop 187.219.220
    origin 5
    image logo.gif
    space 0
    indent 9 h3 130 "Document Search"
    space 10
    indent 20 directory: h3 450 
    space 3
    indent 30
    searchField: field 208 tan tan font-size 15 bold center 
    across
    indent 60
    btn "Open A Directory To Search"  [
        search-directory: request-dir/offset 350x170 
        if  (search-directory <> none) [
            change-dir search-directory
            directory/text: join "Searching " search-directory
            show directory
        ]
    ]
                                 ;a web page to display the search results

    btn "Search" [
       manualFiles: read %.
       finds: rejoin [
           {<html>
            <body bgcolor=ivory>
            <img src=logo.png><BR> 
            <B>Search Results For  "} searchField/text {"</B>
            <BR>
            <CENTER>
            <TABLE WIDTH=80%>
            <TR><TD WIDTH=10%>&nbsp</TD></TR>
            <TR><TD ALIGN-LEFT>
           }
       ]
       foreach fileIn manualFiles [
            if find read fileIn searchField/text [
                parse read fileIn [thru <title> copy theTitle to </title>]
                append finds rejoin ["<a href=" fileIn ">" theTitle "</a><BR>" ] 
            ]  
        ]
        append finds "</TD></TR></TABLE></CENTER></BODY></HTML>"
        write %found.html finds
        call [firefox found.html]
        ] 
    ]
    }
]
   

                                      ;and the html page that contains the script

page-path: join script-directory %embedded-script.r

if not exists? %webPage.html [ 
    write %webPage.html rejoin [ {
        <HTML>
        <HEAD><TITLE>Document Search</TITLE></HEAD>
        <BODY BGCOLOR="BLACK">
        <OBJECT ID="REBOL_IE" CLASSID="CLSID:9DDFB297-9ED8-421d-B2AC-372A0F36E6C5"
        CODEBASE="http://www.rebol.com/plugin/rebolb7.cab#Version=1,0,0,0"
        WIDTH="200" HEIGHT="40" BORDER="1" ALT="REBOL/Plugin">
        <PARAM NAME="bgcolor" value="#ffffff">
        <PARAM NAME="version" value="1.2.0">
        <PARAM NAME="LaunchURL" value="embedded-script.r">
        <embed name="REBOL_Moz" type="application/x-rebol-plugin-v1"
        WIDTH="600" HEIGHT="400" BORDER="1" ALT="REBOL/Plugin"
        bgcolor="#ffffff"
        version="1.2.0"
        LaunchURL="} page-path  {"> 
       </embed>
       </OBJECT>
       </BODY>
       </HTML>
        }
    ]
]

if (not exists? %logo.gif) [save/png %logo.png logo.gif]

browse %webpage.html




