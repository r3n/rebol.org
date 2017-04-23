REBOL [
    Title: "Soundex"
    Date: 17-Jul-1999
    File: %soundex.r
    Author: "Allen Kamp"
    Purpose: {Soundex Encoding returns similar codes for similar sounding words or names. eg Stephens, Stevens are both S315, Smith and Smythe are both S53. Useful for adding Sounds-like searching to databases}
    Comment: {
        This simple Soundex returns a code that is up to 4 characters
        long, the /integer refinement will return an integer code
        value instead.  An example for searching a simple phone number
        database, with Soundex is included.  For improved search
        speed, you could store the soundex codes in the database.

        This is the basic algorithm (There are a number of different
        one floating around)

        1. Remove vowels, H, W and Y
        2. Encode each char with its code value
        3. Remove adjacent duplicate numbers

        4. Return First letter, followed by the next 3 letter's code
           numbers, if they exist.

        Others I will implement soon include, Extended Soundex,
        Metaphone and the LC Cutter table
    }
    Language: "English"
    Email: allenk@powerup.com.au
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: [DB text text-processing] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

soundex: func[
    {Returns the Census Soundex Code for the given string}
    string [any-string!] "String to Encode"
    /local code val letter
][

    code: make string! ""

    ; Create Rules
    set1: [["B" | "F" | "P" | "V"](val: "1")]
    set2: [["C" | "G" | "J" | "K" | "Q" | "S" | "X" | "Z"](val: "2")]
    set3: [["D" | "T"](val: "3")]
    set4: [["L"](val: "4")]
    set5: [["M" | "N"] (val: "5")]
    set6: [["R"](val: "6")]
    ; Append val to code if not a duplicate of previous code val
    soundex-match: [[set1 | set2 | set3 | set4 | set5 | set6 ] 
        (if val <> back tail code [append code val]) ]

    ; If letter not a matched letter its val is 0, but we only care
    ; about it if it is the first letter.
    soundex-no-match: [(if (length? code) = 0 [append code "0"])]

    either all [string? string string <> ""] [
        string: uppercase trim copy string

        foreach letter string [
            parse to-string letter [soundex-match | soundex-no-match]
            if (length? code) = 4 [break] ;maximum length for code is 4
        ]
    ] [
        return string ; return unchanged
    ]
    change code first string ; replace first number with first letter
    return code
]


;*********************************
; Example
;*********************************

; very simple db
PhoneBook: [
   "Smith"       "Michael" #2343-3434 msmith@hotmail.com
   "Cindy"       "Mayne"   #3454-5454 maynec@caravan.org
   "Smythe"      "Jim"     #3454-5454 js45@guess.com.au
   "Jonson"      "Sue"     #3634-4444 sjonson@bingo.net.uk
   "MacDonald"   "Rita"    #3435-5656 mactime@mac.co.uk
   "Main"        "Sarah"   #3454-3444 mainiac@rocket.com
   "McDonal"     "Sam"     #3424-5454 sam@quantum.gov.nz
   "Mac Donnald" "Paul"    #3445-6667 pmac@look.com
   "Maine"       "Tim"     #5666-3434 mainet@smite.com.au
   "Johnsen"     "Stan"    #3733-3434 stanj@freebie.org
   "Smith"       "George"  #4546-2323 george@smithfamily.net
   "Johnson"     "Phillip" #5354-4545 phjonsons@cannon.com
   "Johnstone"   "Cameron" #4545-3334 cam@bondi.com.au
]


example: func[ {Shows how soundex can aid searching names}
    /local info result-count search-result query query-code
][   
 

    print info: {
***********************************************************
*  This phone-book lookup is an example of how to use     *
*  Soundex to find similar sounding words in a database.  *
*  Try searching for Smith or McDonald or Jonson.         *  
*  Just enter the surname to look up.                     *
*                         *                               *
*  To exit type: Quit     *  To view this info type: ?    * 
***********************************************************
}
 
    while [True] [  
        result-count: 0
        search-result: copy make block! []
        print ""
        query: ask ["Phone/Email Database: Enter Surname to look for? "]

        switch/default query [
            "Quit" [break]
            "?"    [print info]
       ][    
            ; Do lookup
            query-code: soundex query
        
            foreach [surname firstname phone email] phonebook [        
                if query-code = soundex surname [
                    result-count: result-count + 1
                    either query = surname [
                        ; Perfect match, add to top of result list
                        insert/only search-result copy reduce [
                            surname firstname phone email
                        ]
                    ][
                        ; Soundslike match, add to end of result list
                        insert/only tail search-result copy reduce [
                            surname firstname phone email
                        ]
                    ]
                ]
            ]
        
            ; Show Results
            print rejoin ["^/Search Results for" query ", using Soundex"]
            print rejoin [result-count " entries were found" newline]
            if result-count > 0 [
                foreach entry search-result [
                    print rejoin [
                        entry/1 ", " entry/2  newline
                        "    Phone: " entry/3 newline
                        "    Email: " entry/4 newline
                    ]
                ]
            ]
        ]    
    ]
    exit
]
        
Example
