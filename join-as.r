REBOL[
    Title: "join-as"
    Version: 0.1.1
    Date: 18-04-2005
    Author: "Peter WA Wood"
    File: %join-as.r
    Purpose: {A function which combines a set of Rebol values and returns them 
              as one of a number of datatypes specified by refinements. The
              default return datatype is string.
              
              Raises a script error if input not valid for requested datatype
              
              Based on an idea in Carl Sassenrath's weblog and subsequent
              discussions including Geomol & Sunanda on the Rebol3 AltMe World}
    Usage: {As the join-as is designed to give a script error if the input
            cannot be converted to the requested datatype, it is advised to 
            always "wrap" calls to it in an try function unless the input has 
            already been validated.
            
            join-as ["1" <abc> "90" ] ---> "1abc90"
            join-as/tag ["1" <abc> "90"] ---> <1abc90>
            join-as/file ["1" <abc> "90"] ---> %1abc90
                  
             }
    Library: [
        level: 'beginner
        type: 'function
        domain: [extension]
        platform: 'all
        tested-under: [
                        core 2.5.6.3.1 "Windows XP Professional"
                        view 1.2.10.3.1 "Windows XP Professional"
        ]
        support: none
        license: cc-by 
	 {see http://www.rebol.org/cgi-bin/cgiwrap/rebol/license-help.r}
    ]
]

join-as: func [
     {combines a set of values and returns them as a string or as the
     datatype specified by a refinement}
    to-be-joined [block!]
        "The values to be combined"
    /string
        "Output the combined values as a string!"
    /file
        "Output the combined values as a file!"
    /tag
        "Output the combined values as a tag!"
    /local
        it
            "Block containing main function code"
        convert-tags
            "Block that converts tags in the input to strings"
        element
            "Used in convert-tags"
][

;;======================Main Processing==================================
it: [
    do convert-tags
    if string [return to string! reduce to-be-joined]
    if file [return to file! to string! reduce to-be-joined]
    if tag [return to tag! to string! reduce to-be-joined]
    
    return to string! reduce to-be-joined

] ;; end it


;;======================Convert Tags=====================================

convert-tags: [

;; This code scans the input block and converts any tags to strings.
;; It is needed because reduce does not remove the <>s when it encounters a tag

    foreach element to-be-joined [
        if tag! = type? element [
            insert find to-be-joined element to-string element
            remove find to-be-joined element
        ]
    ]

] ;; end convert-tags

;;=============================================================================

    do it                                  ; perform the function

] ; end join-as

;; History
;; 
;; 0.1.0 30-Jan-2005    Pre-release for string!, tag!, file! (no optimisation)
;; 0.1.1 18-Apr-2005    Tested under View 1.2.10.3.1 Windows/XP
;; 