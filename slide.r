REBOL [
    Title: "another slider"
    Date: 21-Aug-2001/13:59:11+2:00
    Version: 0.1.0
    File: %slide.r
    Author: "oldes"
    Usage: {
win: make face [size: 320x240 edge: none pane: []]
add-slider win
view center-face win
}
    Purpose: "Adds vertical slider to any face"
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced
        platform: none
        type: 'function
        domain: [GUI VID]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

add-slider: func [
    to-face
    facets
    /local
    slide
    img-colors  imgs-map i1 i2 i3
    esize
][
    img-colors: load rejoin ["#{" decompress #{
789C8D90490EC4200C04EF7E4E10208EDEF8FF93D2C2930C122282521FBBB0DD
FBE6D53FDE07D593572B86A86B57272D5AB5888923598AE428985B47DC041905
909E1A90B70CD2AB30E147042EC9F1F32AA2D97422626367C30A8076239D8828
4C80D97E7B1E8B681D29449CB9709E6FBB8AE87BB75904AEA18BB94EAFBD1351
D3E64D6F9C57886A2B020000
} "}"]

    imgs-map: [
        'i1 13x3 0 117
        'i2 13x1 117 39
        'i3 13x3 156 117
    ]
    foreach [name size st len] imgs-map [
        set :name make image! reduce [
            size  copy/part skip img-colors st len
        ]
    ]
    slide: make face [
        size: 12x100
        edge: make edge [size: 1x0 color: 0.0.0]
        color: 99.113.107
        action: func[][
            if not none? dragging [
            if not none? data [
                dragging/offset/y: 0
                - to-integer  (dragging/size/y - size/y)
                 * data
                dragging/changes: [offset]
                show dragging
            ]
            ]
        ]
        dragging: none
        resize: func[/local dif new-y][
            dif: size/y / dragging/size/y
            new-y: either dif > 1 [size/y][size/y * dif]
            dragger/set-y-size new-y
        ]
        scroll-to: func [/bottom][
            if bottom [
                dragging/offset/y: size/y - dragging/size/y
                dragger/offset/y: size/y - dragger/size/y
            ]
        ]
        dragger: make face [
            offset: -1x0
            old-offset: 0x0
            size: 15x18
            min-y-size: 30
            color: 255.250.200
            colors: [255.250.200 205.200.250]
            set-y-size: func[y][
                if y >= min-y-size [
                    pane/2/size/y: y - 6
                    pane/3/offset/y: y - 3
                    size/y: y + (2 * edge/size/y )
                ]
            ]
            set-x-size: func[][
                foreach f pane [f/size/x: slide/size/x
                 - (2 * slide/edge/size/x)]
                size/x: slide/size/x
            ]
            state: off
            colorize: does[
                either state [
                    color: colors/2
                ][
                    color: colors/1
                ]
                foreach f pane [f/effect/3: color ]
            ]
            pane: reduce [
                make face [size: 13x3 image: i1
                		edge: none effect: [fit colorize color]]
                make face [
                    offset: 0x3
                    size: 13x10 image: i2
                    	 edge: none effect: [fit colorize color]
                ]
                make face [
                    offset: 0x13
                    size: 13x3 image: i3
                    	 edge: none effect: [fit colorize color]
                ]
            ]
            edge: make edge [size: 1x1 color: 0.0.0]
            feel: make object! [
                redraw: none
                detect: none
                over: func [f over? o][
                    ;   if f/state <> over? [
                    ;   f/state: over?
                    ;   colorize
                    ;   show f
                    ;]
                ]
                engage: func [f a e /local t pf][
                    if find [over away] a [
                        svvf/drag-off f/parent-face f f/offset
                        	 + e/offset
                        	 - f/data
                        f/state: on
                        show f/parent-face
                    ]
                    switch a [
                        down [
                            f/data: e/offset f/state: on colorize
                             show f
                        ]
                        up [
                            f/state: off colorize show f
                        ]
                    ]
                ]
            ]
        ]

        init: func[][
            pane: reduce [dragger]
            dragger/set-x-size
            dragger/colorize
            resize
        ]
    ]
    if find facets 'action [
    	slide/action: func[face value] facets/action]
    if find facets 'dragging [
    	slide/dragging: facets/dragging]
    if find facets 'width [slide/size/x: facets/width]
    esize: either error? try [
    	to-face/edge/size ][0x0][ 2 * to-face/edge/size ]
    slide/size/y: to-face/size/y - esize/y
    slide/offset: to-pair reduce [
    		(to-face/size/x - slide/size/x - esize/x) 0]
    if none? to-face/pane [to-face/pane: copy []]
    slide/init
    repend to-face/pane ['vs slide]
    slide
]