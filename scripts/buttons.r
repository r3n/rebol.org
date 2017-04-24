REBOL [
    Title: "Piles of Button Styles"
    Date: 20-May-2000
    Version: 1.1.0
    File: %buttons.r
    Author: "Carl Sassenrath"
    Purpose: {Displays 52 button styles out of the hundreds possible.}
    library: [
        level: 'intermediate 
        platform: none 
        type: [Demo How-to] 
        domain: [GUI VID] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

flash "Fetching image..."

pic: load-thru/binary http://www.rebol.com/view/palms.jpg 

unview



group: ["rotary" "test" "button"]

view layout [
    origin 20x10
    backdrop effect [gradient 0x1 100.20.0]
    vh1 "52 Button Click-up - Each with a different click effect..."
    vtext bold "Here is a small sampling of the thousands of button effects you can create. (This is 78 lines of code.)"
    at 20x80 guide
    button "simple"
    button form now/date
    button "colored" 100.0.0
    button "text colored" font [colors: [255.80.80 80.200.80]]
    button with [texts: ["up text" "down text"]]
    button "bi-colored" colors [0.150.100 150.20.20]
    button with [texts: ["up color" "down color"] colors: [0.150.100 150.20.20]]
    button "image" pic
    button "color image" pic 200.100.50
    button "flip color" pic with [effects: [[fit colorize 50.50.200][fit colorize 200.50.50]]]
    button "blink" with [rate: 2 colors: [160.40.40 40.160.40]]
    return
    button "multiply" pic with [effects: [[fit][fit multiply 128.80.60]]]
    button "brighten" pic with [effects: [[fit][fit luma 80]]]
    button "contrast" pic with [effects: [[fit][fit contrast 80]]]
    button "horiz flip" pic with [effects: [[fit][fit flip 1x0]]]
    button "vert reflect" pic with [effects: [[fit][fit reflect 0x1]]]
    button "invert" pic with [effects: [[fit][fit invert]]]
    button "vert grad" with [effects: [[gradient 0x1 0.0.0 0.200.0] [gradient 0x1 0.200.0 0.0.0]]]
    button "horiz grad" with [effects: [[gradient 1x0 200.0.0 200.200.200][gradient 1x0 200.200.200 200.0.0]]]
    button "both grad" with [effects: [[gradient 1x0 140.0.0 40.40.200] [gradient 0x1 40.40.200 140.0.0]]]
    button "blink grad" with [rate: 4 effects: [[gradient 1x0 0.0.0 0.0.200] [gradient 1x0 0.0.200 0.0.0]]]
    button "blink flip" pic with [rate: 8 effects: [[fit][fit flip 0x1]]]
    return
    button "big dull button with several lines" 100x80 0.0.100
    button "dual color" pic 50.50.100 100.50.50 100x80 with [edge: [color: 80.80.80]]
    button "big edge" pic 100x80 with [edge: [size: 5x5 color: 80.80.80] effects: [[fit colorize 50.100.50][fit]]]
    button "oval reflect" pic 50.100.50 100x80 with [effect: [fit reflect 1x0 oval]]
    return
    button "text on top" pic 100x80 with [font: [valign: 'top] effects: [[fit gradcol 1x1 200.0.0 0.0.200] [fit gradcol -1x-1 200.0.0 0.0.200]]]
    button "text on bottom" pic 100x80 50.50.100 with [font: [valign: 'bottom] effects: [[fit][fit invert]]]
    button "big text font" pic 100x80 with [font: [size: 24] effects: [[fit multiply 50.100.200][fit]]]
    button "cross flip" pic 50.100.50 100x80 with [effect: [fit flip 0x1 reflect 0x1 cross]]
    return
    toggle "toggle"
    toggle "toggle red" 100.0.0 
    toggle "toggle up" "toggle down"
    toggle "toggle colored" 0.150.100 150.20.20
    toggle "up color" "down color" 0.150.100 150.20.20
    toggle "toggle multiply" pic with [effects: [[fit][fit multiply 128.80.60]]]
    toggle "toggle contrast" pic with [effects: [[fit][fit contrast 80]]]
    toggle "toggle cross" pic with [effects: [[fit][fit cross]]]
    toggle "toggle v-grad" with [effects: [[gradient 0x1 0.0.0 0.200.0] [gradient 0x1 0.200.0 0.0.0]]]
    toggle "toggle h-grad" with [effects: [[gradient 1x0 200.0.0 200.200.200][gradient 1x0 200.200.200 200.0.0]]]
    toggle "toggle both" with [effects: [[gradient 1x0 140.0.0 40.40.200] [gradient 0x1 40.40.200 140.0.0]]]
    return
    rotary data group
    rotary data reduce [now/date now/time]
    rotary data group 100.0.0 0.100.0 0.0.100
    rotary data group with [font: [colors: [255.80.80 80.200.80]]]
    rotary data group with [colors: [0.150.100 150.20.20]]
    rotary data group pic
    rotary data group pic 200.100.50
    rotary data group pic with [effects: [[fit colorize 50.50.200][fit colorize 200.50.50]]]
    rotary data group with [effects: [[gradient 0x1 0.0.0 0.200.0] [gradient 0x1 0.200.0 0.0.0]]]
    rotary data group with [effects: [[gradient 1x0 200.0.0 200.200.200][gradient 1x0 200.200.200 200.0.0]]]
    rotary data group with [effects: [[gradient 1x0 140.0.0 40.40.200] [gradient 0x1 40.40.200 140.0.0]]]
]
