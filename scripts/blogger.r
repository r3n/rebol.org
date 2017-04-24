REBOL [
    title: "Blogger"
    date: 22-Apr-2010
    file: %blogger.r
    author:  Nick Antonaccio
    purpose: {

        This program allows users to create and add entries to an online blog page.
        The GUI has text fields which allow the user to enter a title, link, and blog text,
        as well as a button to select an image file which will be uploaded and included
        in the blog entry. When the "Upload" button is clicked, an HTML file is created
        and uploaded to the user's web server, along with the image. Be sure to edit
        the ftp-url and html-url variables to represent actual user account information.

        A line by line explanation of this code is available at http://re-bol.com

    }
]

page: "blog.html"
ftp-url: ftp://user:pass@site.com/public_html/folder/
html-url: join http://site.com/folder/ page
save/png %dot.png to-image layout/tight [box white 1x1]  ; blank image

view center-face gui: layout [
    h2 (form html-url)
    text "Title:"       t: field 400
    text "Link:"        l: field 400
    text "Image:"       i: btn 400 [i/text: request-file show i]
    text "Text:"        x: area  400x100
    across
    btn "Upload" [
        if error? try [existing-text: read html-url] [
            make-dir ftp-url
            write (join ftp-url page) ""
            existing-text: copy ""
        ]
        picture: last split-path to-file i/text
        write/binary (join ftp-url picture) (read/binary to-file i/text)
        write (join ftp-url page) rejoin [
            {<h1>} t/text {</h1>}
            {<img src="} picture {"><br><br>}
            now/date { } now/time { &nbsp; &nbsp; }
            {<a href="} l/text {">} l/text {</a><br><br>}
            {<center><table width=80%><tr><td><pre><strong>}
                x/text 
            {</strong></pre></td></tr></table></center><br><hr>}
            existing-text
        ]
        browse html-url
    ]
    btn "View" [browse html-url]
    btn "Edit" [editor (join ftp-url page)]
]