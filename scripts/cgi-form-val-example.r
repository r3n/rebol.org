#!shebang path to /cgi-bin/rebol -cs
REBOL [
       Title: "CGI with FORM with refilled data"
        Date: 2-aug-2012
        File: %cgi-form-val-example.r
      Author: "Arnold van Hofwegen"
     Version: 0.0.1     
     Purpose: {
         Example of how a webform could be processed by a REBOL script,
         refilling previously filled fields when errors in input are detected.
         For performance it is always better to have some validation (using 
         e.g. Javascript) on the client side first, but for safety the check
         also needs to be (re)done at the server side.
     }
        library: [
            level: 'intermediate
            platform: 'all
            type: [cgi demo]
            domain: [cgi]
            tested-under: [Core 2.7.8 *nix]
            support: "AltMe"
            license: none
            see-also: none
        ]

]

;-------------------------------------------------------------------
; This script uses the safe-cgi-data-read.r script
; At this moment I do not recommend using this script in a place for 
; public use, i.e. to provide webcomments and other services.
; I use an extended version of this script to put articles on my
; website from a protected directory.
; Improvements and suggestions are more than welcome.
;-------------------------------------------------------------------

do %path to your/cgi-bin/safe-cgi-data-read.r
cgi-block: safe-cgi-data-read

print "Content-Type: text/html^/"  ;-- Required Page Header

; Declaration and emit function from the cookbook:
; http://www.rebol.net/cookbook/recipes/0006.html
html: make string! 10000
emit: func [code] [repend html code]

; Start of the webpage holding the form
emit [<html>
    <head>
    <title> "CGI Form processing with validation and field refill" </title>
    <!-- No Flash of Unstyled Content.   -->
    <script type="text/javascript"></script>
    </head>
    newline
    <body onload="window.defaultStatus='Rebol CGI form refilled'; refillfields();" id="css-rebol">
    newline
]

error-field-title: error-field-article: copy ""
title-text: article-text: copy ""
number-of-errors: 0

; Check for valid input, this validation should probably be very much more thorough!
if  0 < length? to-string cgi-block [
    emit [<br /><center><b> "The form was send with some data. Results are shown." 
        </b></center><br /> newline 
    ]
    either not empty? cgi-block/title_text [
        error-field-title: copy "" 
        title-text: cgi-block/title_text
    ][
        number-of-errors: number-of-errors + 1
        error-field-title: "<font color=red > The title field must not be empty. </font>"
    ]
    either not empty? cgi-block/article_text [
        error-field-article: copy "" 
        article-text: cgi-block/article_text
    ][
        number-of-errors: number-of-errors + 1
        error-field-article: "<font color=red > The article field must not be empty. </font>"
    ]
    either 0 = number-of-errors [
        ; Do some processing here, like putting the data into your mysql database.
        ; Depending on that result show an appropriate message. 
        emit [<center><b> "Site updated at " now </b></center>]
    ][
        emit [<center><b>"Error(s) found: Site not updated!" </b></center>]
    ]
]

; There is some fun putting a Javascript in here.
emit [
    newline
    <script type="text/javascript"> 
    "function refillfields() {" newline
    " var changer = document.getElementById('frmtitle');" newline 
    " changer.value = " {"} title-text {"} ";"  newline
    " var changer = document.getElementById('frmarticle');" newline 
    " changer.value = " {"} article-text {"} ";"  newline
    " } "
    </script>
    newline
    <style type="text/css" media="all">
    { @import "path/to/formlayout.css";}
    </style>
    newline
    <form name="Formarticle" action="cgi-form-val-example.r" method="post" target="_self">
    <fieldset>
    <legend> "Add a new article:" </legend>
    <p>
    <label for="title_text" class="article"> "Title" </label>
    <input type="Text" id="frmtitle" name="title_text" maxlength="200" size="40" /> 
    error-field-title </p>
    <p>
    <label for="timelapse" class="article"> "Plus/minus hours" </label>
    <select name="timelapse"> newline
]

; This shows how to be more flexible in your form. It is also possible 
; to use this kind of construction with data retrieved from a database.
for n -12 -1 1 [
    emit ["<option value=" n ">" n </option> newline]
]
emit [<option value="0" selected> 0 </option> newline]
for n 1 12 1 [
    emit [ "<option value=" n ">" n </option> newline]
]
     
emit [
    </select>  
    </p>
    <p><label for="article_text" class="article"> "Article" </label>
    <textarea id="frmarticle" name="article_text" rows="10" cols="80" wrap="virtual"></textarea> 
    error-field-article </p>
    <p><label> " " </label>
    <input class="forminputbutton" type="Submit" name="submit" value="Add the article" /></p>
    </fieldset>
    </form>

    </body>
    </html>
]

print html