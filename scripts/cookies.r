REBOL [
    Title: "Cookie Cleaner"
    Date: 18-Jul-2001/21:56:30-4:00
    Name: "Cookies"
    Version: 1.0.0
    File: %cookies.r
    Author: "A Rebol"
    Purpose: {Removes unwanted cookie files from windows system.. note files are permanently deleted!
     can be used to search and clean files from any folder. Just change line that reads (files: read %/c/windows/cookies/)
    to something like (files: read %/c/windows/temp).Type .txt at the search prompt and search for all text files in temp folder.
    Script is run from the folder you wish to clean. Just started writing scripts haven't got the path thing down yet.
}
    Email: rick_falls@hotmail.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'file-handling 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
word: ""
count: 0

files: read %/c/windows/cookies/         ;location of cookies folder on my system(change to location of your folder if needed)

print join length? files {   cookies in folder ^/
To use enter a search word. 
Example entering (Rebol) could return yourname@www.rebol.com[1].txt.
You will be prompted If you would like to delete this cookie.
If you wish to delete cookie type (yes) then hit enter.
If not just hit enter cookie will not be deleted.
If search word is not found no results will be returned.
Type a new search word or (quit) to exit. ^/}     ;print number of cookies in folder (about 1200 on mine)

while [word <> "quit"] [
 count: count + 1
 print join  "Search number " count
    word: ask  "Enter search word or quit to exit      "
    foreach file files [
        if find file word [
            print file
            testword: ask "To delete type yes or hit enter to continue    ^/"   ;double check before deleteing file
            if testword = "yes" and exists? file [
                delete file change find files file " "]      ;delete file and remove entry from list in variable(word) files
       
        ]
    ]
]
                                           