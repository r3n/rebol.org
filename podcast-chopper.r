rebol [
    Title: "Podcast Chopper"
    Date: 01-Jan-2007
    Name: 'Podcast-Chopper
    Version: 0.1.0
    File: %podcast-chopper.r
    Author: "r vdZee"
    Owner: "r vdZee"
    Rights: "Copyright (C) r vdZee 2007"
    Tabs: 4
    Purpose: {
      - downloads an MP3 podcast as a number of  smaller files, so that 
      listening to the file file  may be resumed at a number of points
   }
    Comment: {
      - script illustrates how to chop a file, but is of limited application - almost all MP3 players will fast forward & reverse
      - note how "copy/part" moves along the file, "skip" by itself, is not used
      - "Seek mode added for random access to large files"  http://www.rebol.net/article/0199.html
      - "Copy and Checksum Large Files"                              http://www.rebol.net/article/0281.html
   }
    History: [
    0.1.0 [1-Jan-2007 "released" ]
]
    Language: 'English
    library: [
        level: 'beginner
        platform: 'all
        type: 'tool
        domain: [sound file-handling]
        tested-under: [view 1.3.2.4.2 on "Mepis Linux"]
        support: none
        license: 'mit
        see-also: none
    ]
]

mp3-file: http://planetquest1.jpl.nasa.gov/podCasts/PlanetQuestPodcast06.mp3
print system/script/title
print join "looking for " reduce mp3-file
either exists? mp3-file [
    print join "file size " size? mp3-file
    ][
    print "url not found"
    print "terminating in 5 seconds"
    wait 5
    quit
]

file-name:       %nasa-
chunk:           2000000
content:         make binary! chunk
part-number:     100
number-of-files: (round/ceiling divide (size? mp3-file) chunk)

print rejoin  ["downloading into "number-of-files " files..."]
print join "writing to " system/script/path
open-port: open/direct/binary  mp3-file
loop number-of-files [
    data: copy/part open-port chunk
    write/binary  rejoin [file-name part-number %.mp3] data
    part-number: part-number + 1
    print rejoin [file-name part-number ".mp3  done"]
]

close open-port
print "done"