REBOL [
    Title: "Web Form Widgets"
    Date: 20-Jul-1999
    File: %webwidget.r
    Author: "Andrew Grossman"
    Usage: {
        make-widget/select to make a form select.
        make-widget/select/multiple to make a multiple select.
        make-widget/radio to make radio buttons.
        make-widget/checkbox to make checkboxes.
        Arguments are widget name, widget values, and selected value
        (for select) or line ending (for others).
        Add /number to any of these to number submitted values.
    }
    Purpose: {Generate HTML code quickly and easily for several form elements.}
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Tool 
        domain: [markup html] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

CGI-widget: func [
    "Prints select, radio button, or checkbox CGI Form elements"
    name       [any-string!] "Widget name"
    values     [series!]     "Widget items"
    selectterm [any-type!]   "Item selected and item ending"
    /select/multiple/number/radio/checkbox/number
    /local num
][
    all [select print reform [#<SELECT either multiple ['MULTIPLE][#]
         #NAME= mold name #>]]
    forall values [
        print rejoin [
            any [all [select   {<OPTION VALUE=}] 
                 all [radio    {<INPUT TYPE="RADIO" VALUE=}]
                 all [checkbox {<INPUT TYPE="CHECKBOX" VALUE=}]
            ] mold form either number [num: index? values][first values] 
            any [all [number selectterm = num " SELECTED"] #]
            #> first values selectterm]
    ]
    all [select print </SELECT>]
]


