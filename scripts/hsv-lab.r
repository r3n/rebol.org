REBOL [
    title: "HSV Lab"
    author: "Christopher Ross-Gill"
    home: http://www.ross-gill.com/
    file: %hsv-lab.r
    date: 25-Nov-2003
    needs: [1.2.1 'View]
    purpose: {
        Functions that manipulate of REBOL colour values using the
        HSV (Hue Saturation Brightness) model.  Includes example
        functions for use with colour tuple! and image! values.
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [function tool]
        domain: [graphics]
        tested-under: none
        support: none
        license: "http://creativecommons.org/licenses/by-sa/1.0/"
        see-also: none
    ]
]

; example [rgb-hsv 255.0.0]

rgb-hsv: func [
    "Converts an RGB colour into an HSV colour."
    color [tuple!] "The RGB colour to be converted."
    /local r g b a h s v mn mx delta
][
    r: color/1 / 255
    g: color/2 / 255
    b: color/3 / 255
    if not a: color/4 [a: 0]
    mn: first minimum-of reduce [r g b]
    mx: first maximum-of reduce [r g b]
    v: mx

    delta: mx - mn

    either delta = 0 [
        s: 0
        h: 0
    ][
        s: delta / mx
        either r = mx [
            h: (g - b) / delta
        ][
            either g = mx [
                h: 2 + ((b - r) / delta)
            ][
                h: 4 + ((r - g) / delta)
            ]
        ]
        h: h * 60
        if h < 0 [h: h + 360]
    ]

    return reduce [h s v a]
]

; example [hsv-rgb [240 0.5 0.5 0]]

hsv-rgb: func [
    "Converts an HSV colour into an RGB colour."
    color [block!] "The HSV colour to be converted. H: 0-360 S: 0-1 V: 0-1"
    /local h s v r g b i f p q t
][
    h: color/1 s: color/2 v: color/3
    if not a: color/4 [a: 0]
    either s = 0 [
        r: g: b: v
    ][
        h: h / 60
        i: to-integer h
        f: h - i
        p: v * (1 - s)
        q: v * (1 - (s * f))
        t: v * (1 - (s * (1 - f)))

        switch/default i [
            0 [r: v g: t b: p]
            1 [r: q g: v b: p]
            2 [r: p g: v b: t]
            3 [r: p g: q b: v]
            4 [r: t g: p b: v]
        ][r: v g: p b: q]
    ]
    return to-tuple reduce [
        to-integer (r * 255)
        to-integer (g * 255)
        to-integer (b * 255)
        a
    ]
]

; example [adjust-hue 153.255.0 -60]

adjust-hue: func [
    "Modifies an RGB colour only by adjusting the Hue value."
    color [tuple!] "The colour to be manipulated"
    amt [tuple! integer!] {
        Either a colour to provide hue, or an integer to
        increase/decrease hue.
    }
    /local hsv hsv-new
][
    hsv: rgb-hsv color
    either tuple? amt [
        hsv-new: rgb-hsv amt
        if hsv-new/2 <> 0 [hsv/1: hsv-new/1]
    ][
        hsv/1: hsv/1 + amt
    ]
    hsv/1: remainder hsv/1 360
    if negative? hsv/1 [hsv/1: hsv/1 + 360]
    return hsv-rgb hsv
]

; example [apply-hue load %image.jpg 51.204.0]

apply-hue: func [
    "Takes an image and a colour and applies the hue of the colour to an image"
    img [image!] "The image file to colourise"
    col [tuple! integer!] "A colour to provide the hue, or a hue shift (angle)"
    /local hsv hue sz
][
    if not integer? col [
       hsv: rgb-hsv col
       if hsv/2 = 0 [return img]
    ]
    img: copy img
    sz: img/size/x * img/size/y
    repeat pix :sz [poke img pix adjust-hue img/:pix col]
    return img
]

; example [negate-color 153.255.0]

negate-color: func [
    "Creates the negative colour of the supplied colour."
    col [tuple!] "The colour to negate"
    /local hsv
][
    hsv: rgb-hsv col
    hsv/1: either hsv/1 < 180 [hsv/1 + 180][hsv/1 - 180]
    hsv/3: 1 - hsv/3
    return hsv-rgb hsv
]

; example [negate-image load %image.jpg]

negate-image: func [
    "Creates a negative copy of the supplied image."
    img [image!] "The image file to process"
    /local sz
][
    img: copy img
    sz: img/size/x * img/size/y
    repeat pix :sz [poke img pix negate-color img/:pix]
    return img
]

; example [negate-image-byrgb load %image.jpg]

negate-image-byrgb: func [
    "Creates a negative copy of the supplied image."
    img [image!] "The image file to process"
    /local sz
][
    img: copy img
    sz: img/size/x * img/size/y
    repeat pix :sz [poke img pix 255.255.255 - img/:pix]
    return img
]

; example [desaturate load %image.jpg]

desaturate: func [
    {
        Removes saturation from an image.
        Slightly different approach from grayscale.
    }
    img [image!] "The image file to process"
    /local sz hsv
][
    img: copy img
    sz: img/size/x * img/size/y
    repeat pix :sz [
        hsv: rgb-hsv img/:pix
        hsv/2: 0
        poke img pix hsv-rgb hsv
    ]
    return img
]

; example [contrast load %image.jpg contrast/factor load %image.jpg 0.1]

contrast: func [
    "Increases image contrast."
    img [image!] "The image file to process"
    /factor amt /local sz hsv sign
][
    if not factor [amt: 0.5]
    img: copy img
    sz: img/size/x * img/size/y
    repeat pix :sz [
        hsv: rgb-hsv img/:pix
        hsv/3: (hsv/3 * 2) - 1
        sign: sign? hsv/3
        hsv/3: (1 + (((hsv/3 * sign) ** (amt)) * sign)) / 2
        poke img pix hsv-rgb hsv
    ]
    return img
]
