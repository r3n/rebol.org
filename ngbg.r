REBOL [
    Title: "National Geographic Image of the Day Downloader"
    Date: 17-Jan-2004
    Version: 1.1.0
    File: %ngbg.r
    History: [
	21-Sep-2001 "1.0.0 - First script - Ian Monroe"
	17-Jan-2004 "1.1.0 - Url updated - Charles Mougel"
    ]
    Author: "Charles MOUGEL"
    Email: charles.mougel@spinodo.com
    Web: http://www.spinodo.com
    Purpose: {Downloads the current picture of the day from nationalgeographic.com 
    and saves it to a location of your choice. Directions: Change the 'filename' in the source to the location of your choice. 

The agrument -s causes it to be silent and so not print what step 
it is
at. These directions can be seen by adding a -h agrument.  
}
    Library: [
       level: 'intermediate 
       platform: 'all
       type: [demo tool]
       domain: [markup text-processing web] 
       tested-under: win
       support: johnatemps@yahoo.fr
       License: none
        ]
]

filename: %ngbg.jpg ; change to wanted location

PrintStuff: true

if system/script/args == "-s"
[ PrintStuff: false ]

if system/script/args == "-h"
[

print "Downloads the current picture of the day from nationalgeographic.com and saves it to a location of your choice."

print "Change the 'filename' variable in the source to the location of your choice."

print "The agrument -s causes it to be silent and not print what step it is at."
quit
]

if PrintStuff

[ prin "Downloading National Geographic wallpaper.cgi web page..." ]

ngwebsite: http://magma.nationalgeographic.com/cgi-bin/pod/wallpaper.cgi
 page: read ngwebsite 
if PrintStuff
[ print " Done." ]


parse page [thru "/pod/pictures/lg_wallpaper/" copy NameOfJpg to "^">"]

	;old code

 ; imageloc: join http://magma.nationalgeographic.com/pod/pictures/lg_wallpaper/  NameOfJpg

	;updated code 17/01/2004

imageloc: join http://lava.nationalgeographic.com/pod/pictures/lg_wallpaper/ NameOfJpg
	;end updated code 17/01/2004

if PrintStuff
[ 
prin "Downloading "
prin imageloc
print " ..."
]
image: read/binary imageloc
write/binary filename image
if PrintStuff
[ prin filename 
  print  " saved" ]                                                       