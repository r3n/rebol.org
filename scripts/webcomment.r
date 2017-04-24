REBOL [
    Title: "CGI Comment Article"
    Date: 14-Sep-1999
    File: %webcomment.r
    Author: "Carl Sassenrath"
    Purpose: {Run this to create the file used for
        the cgicomment.r script.}
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [cgi file-handling markup] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

write %article.html {
<HTML>
<HEAD>
    <TITLE>Article</TITLE>
</HEAD>

<BODY BGCOLOR="white">

<FORM ACTION="/cgi-bin/comment.r" METHOD="GET">
<H3><FONT FACE="Arial, Helvetica">Article</FONT></H3>

<BLOCKQUOTE>
    <P>Text of the article would go here. This entire page can use whatever type of formatting you prefer. However,
    remember that the comments table below must have an HTML comment to indicate where new messages are placed, and
    the &quot;post&quot; form must have a hidden input field to relay the article's file name.  <I>Do not forget to
    change this field or comments will be posted to the wrong page</I>.</P>

    <P><BR>
    
    <TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="80%">
        <TR>
            <TD COLSPAN="3" BGCOLOR="navy">
                <P ALIGN="CENTER"><B><FONT SIZE="2" COLOR="white" FACE="Arial, Helvetica">COMMENTS</FONT></B>
            </TD>
        </TR>
<!--comments-->
            </TABLE>
</P>

    <P>
    <TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" WIDTH="80%">
        <TR>
            <TD WIDTH="10%" VALIGN="MIDDLE" BGCOLOR="#660000">
                <P ALIGN="RIGHT"><B><FONT SIZE="2" COLOR="white" FACE="Arial, Helvetica">From:</FONT></B>
            </TD>
            <TD WIDTH="86%" VALIGN="MIDDLE" BGCOLOR="#EBC2A7"><INPUT TYPE="TEXT" NAME="from" SIZE="50"></TD>
        </TR>
        <TR>
            <TD WIDTH="10%" BGCOLOR="#660000">
                <P ALIGN="RIGHT"><B><FONT SIZE="2" COLOR="white" FACE="Arial, Helvetica">Comment:</FONT></B>
            </TD>
            <TD WIDTH="86%" VALIGN="MIDDLE" BGCOLOR="#EBC2A7"><TEXTAREA NAME="comment" ROWS="10" COLS="50"></TEXTAREA></TD>
        </TR>
        <TR>
            <TD WIDTH="10%" BGCOLOR="#660000">
                <P ALIGN="RIGHT"><B><FONT SIZE="2" COLOR="white" FACE="Arial, Helvetica">Type:</FONT></B>
            </TD>
            <TD WIDTH="86%" BGCOLOR="#EBC2A7">
                <CENTER>
                <P><INPUT TYPE="RADIO" NAME="type" VALUE="regular"  CHECKED><FONT SIZE="2" FACE="Arial, Helvetica">Regular Text
                &nbsp;<INPUT TYPE="RADIO" NAME="type" VALUE="code">Code Listing (preformatted)</FONT>
</CENTER>
            </TD>
        </TR>
        <TR>
            <TD WIDTH="10%"></TD>
            <TD WIDTH="86%">
                <CENTER>
                <P><INPUT TYPE="SUBMIT" NAME="topic" VALUE="Post Comment">
</CENTER>
            </TD>
        </TR>
    </TABLE>
<INPUT TYPE="HIDDEN" NAME="file" SIZE="-1" VALUE="article.html">
</BLOCKQUOTE>

</FORM>

</BODY>

</HTML>
}
