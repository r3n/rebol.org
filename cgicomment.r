REBOL [
    Title: "CGI Web Page Comment Poster"
    Date: 14-Sep-1999
    File: %cgicomment.r
    Author: "Carl Sassenrath"
    Purpose: {Allows viewers to add comments to a web page.
        (needs webcomment.r to create example forms file).}
    Note: {
        For each article, in the comment posting form, be sure
        to modify the hidden "file" field value to give it the
        correct name of the HTML file to receive the comments.
        Also, the HTML file must have an HTML comment to note
        where the table insertion is made.  See comments below.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tutorial 
        domain: [cgi other-net markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

;-- Output HTTP header first, just in case an error occurs
;   the user will be able to see it and report it to you.
print "Content-Type: text/html^/"

;-- Uncomment this line for debugging purposes:
;print system/options/cgi/query-string

;-- A function which creates the HTML used for the comments
;   table.  It was created in a visual editor and pasted here.
;   Note that everything except the variables of the function
;   must be written as a tag or as a string.  When called
;   this function creates the table row and returns it as text.
make-comment: func [from date comment] [
    reform [
    <TR><TD WIDTH="10%" VALIGN="MIDDLE" BGCOLOR="navy">
        <P ALIGN="RIGHT"><B><FONT SIZE="2" COLOR="#CDD3ED" FACE="Arial, Helvetica">"From:"</FONT></B>
        </TD>
        <TD WIDTH="46%" VALIGN="MIDDLE" BGCOLOR="#CDD3ED"><I><FONT SIZE="2" FACE="Arial, Helvetica">from</FONT></I></TD>
        <TD WIDTH="45%" BGCOLOR="#CDD3ED"><FONT SIZE="2" FACE="Arial, Helvetica">date</FONT></TD>
    </TR>
    <TR>
        <TD WIDTH="10%" BGCOLOR="navy">
        <P ALIGN="RIGHT"><B><FONT SIZE="2" COLOR="#CDD3ED" FACE="Arial, Helvetica">"Comment:"</FONT></B>
        </TD>
        <TD COLSPAN="2" BGCOLOR="white"><FONT SIZE="2" FACE="Arial, Helvetica">comment</FONT></TD>
    </TR>
    <TR><TD HEIGHT="4" COLSPAN="3" BGCOLOR="navy"></TD></TR>
    newline
    ]
]

;-- Process the CGI query string, making an object from its fields.
cgi: make object! decode-cgi system/options/cgi/query-string

;-- The file name of the article is provided in a hidden input
;   field within the HTML of the article.  Use this string to
;   build the path to the file from CGI dir.  Remember that the
;   file must have write permissions if you want add comments.
file: join %../web/ cgi/file

;-- Create the text of the new comment from the CGI input.
;   If the type is code, then display it as preformated TTY.
new-comment: make-comment cgi/from now either cgi/type = "code" [
    rejoin ["<pre>" cgi/comment </pre>]][cgi/comment]

;-- Read the HTML file, add the newest comment to it, and write
;   it out.  An HTML comment is used to mark where it goes.
page: read file
insert find page <!--comments--> new-comment
write file page

;-- Display the page again:
print page


