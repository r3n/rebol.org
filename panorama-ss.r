REBOL [
    Title: "'Panoramatic image' style"
    Date: 22-May-2002/22:28:36+2:00
    Version: 1.0.0
    File: %panorama-ss.r
    Author: "Oldes"
    Purpose: "Style for scrolling (panoramatic) images"
    Comment: {
^-^-Make sure you have loaded the 'capsule' style as well!
^-^-(http://www.sweb.cz/r-mud/styles/capsules.r)}
    Email: oliva.david@seznam.cz
    library: [
        level: 'advanced 
        platform: none 
        type: 'module 
        domain: 'VID 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

panorama-ss: stylize [
    panorama: box 320x120 with [
        rate: 30 m-pos: 0 mov: 1
        p-img: w: w2: ofs1: ofs2: old-rate: none
        effect: [draw [image ofs1 p-img image ofs2 p-img]]
        init: [
            p-img: first facets
            switch type?/word p-img [
                file! [p-img: load p-img]
                url!  [p-img: load read-thru p-img]
            ]
            w: p-img/size/x w2: 2 * w
            ofs1: 0x0 ofs2: to-pair reduce [w 0]
        ]
        feel/engage: func [face action event][
            switch action [
                down [face/m-pos: event/offset/x face/mov: 0
                    if face/rate [face/old-rate: face/rate]
                    face/rate: none
                ]
                over [
                    face/mov: event/offset/x - face/m-pos face/rate: face/old-rate
                    show face
                ]
                time [face/my-draw face]
            ]
        ]
        my-draw: func[face][
            ofs1/x: ofs1/x + mov
            ofs2/x: ofs2/x + mov
            either mov > 0 [
                if ofs1/x >= w [ofs1/x: ofs1/x - w2]
                if ofs2/x >= w [ofs2/x: ofs2/x - w2]
            ][
                if (0 - ofs1/x) >= w [ ofs1/x: ofs1/x + w2]
                if (0 - ofs2/x) >= w [ ofs2/x: ofs2/x + w2]
            ]
            show face
        ]
    ]
]
comment {;usage
view layout [
    styles panorama-ss
    origin 0x0
    panorama http://127.0.0.1/img/podlaha.gif 320x95
]
}
                                                              