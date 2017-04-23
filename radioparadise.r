REBOL [
    Title: "Radio Paradise Playlist"
    Date: 25-Jan-2002
    Version: 1.0.0
    File: %radioparadise.r
    Author: "Mike Hansen"
    Purpose: "Shows the playlist from radioparadise.com"
    Email: mh983@yahoo.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [web GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

now-playing: ""
history: copy []

update-playlist: func [
    /local radio song playlist
][
    playlist: copy []
    history: copy []
    now-playing: ""
    radio: read http://www.radioparadise.com:8080/mini_nowplay.php
    song: copy []
    parse radio [any [to "<a href" begin: thru ">" copy song to "</a>" (append playlist trim song)]]
    now-playing: first playlist
    history: copy at playlist 2
]

update-playlist

view layout [
    across
    text "Now Playing"
    return
    now-playing-field: info 320 now-playing
    return
    text "Previous"
    return
    history-list: text-list 320x60 data history
    return
    button "Reload Now" [
        update-playlist
        now-playing-field/text: now-playing
        show now-playing-field
        clear history-list/data
        insert history-list/data history
        show history-list
    ]
]
                                                