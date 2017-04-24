REBOL [
    Title: "Read a Remote Payment and Presentation System file"
    Author: "Steven White"
    File: %rpps.r
    Date: 7-Nov-2011
    Purpose: {This is a module for reading and taking apart a modified
    NACHA file used in the Remote Payment and Presentation System.      
    If those terms mean anything, this could be a useful module.            
    If those terms mean nothing, then at least this module could be an    
    example of a way to handle a text file of fixed-format records.
    In 25 words or less, a NACHA file is a file of fixed-format text
    records containing information about bank transfers.  The records
    are of several different types (headers, detail, trailers)
    differentiated by a code in the first character of each record.}
    library: [
        level: 'beginner
        platform: 'all
        type: [tutorial tool]
        domain: [text-processing file-handling]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This module defines a text file in the RPPS format for                    ]
;; [ getting money electronically from the bank.                               ]
;; [ RPPS stands for Remote Payment and Presentment System.                    ] 
;; [ This is a "modified NACHA" format and is not quite the same               ]
;; [ as the file that WE send TO the bank for automatic payments.              ]
;; [---------------------------------------------------------------------------]

;; [---------------------------------------------------------------------------]
;; [ This function accepts a string, a starting position, and an               ]
;; [ ending position, and returns a substring from the starting                ]
;; [ position to the ending position.  If the ending position is -1,           ]
;; [ the procedure returns the substring from the starting position            ]
;; [ to the end of the string.                                                 ]
;; [ This technique was "borrowed" from the REBOL library.                     ]
;; [---------------------------------------------------------------------------]

GLB-SUBSTRING: func [
    "Return a substring from the start position to the end position"
    INPUT-STRING [series!] "Full input string"
    START-POS    [number!] "Starting position of substring"
    END-POS      [number!] "Ending position of substring"
] [
    if END-POS = -1 [END-POS: length? INPUT-STRING]
    return skip (copy/part INPUT-STRING END-POS) (START-POS - 1)
]

;; [---------------------------------------------------------------------------]
;; [ Various data items used in processing the file.                           ]
;; [---------------------------------------------------------------------------]

RPPS-FILE: []                 ;; Holds the whole file in memory
RPPS-FILE-ID: %ACH.txt        ;; Default name of the file
RPPS-EOF: false               ;; End-of-file flag for reading
RPPS-REC: ""                  ;; One record, for reading or writing 
RPPS-REC-COUNT: 0             ;; Counter, upped by 1 as we read or write 

RPPS-CURRENT-TYPE: ""         ;; Type code of record in memory

;; [---------------------------------------------------------------------------]
;; [ When we read a record, we will take it apart in to its                    ]
;; [ fields and store the fields below.  The CURRENT-TYPE field                ]
;; [ indicates which record we currently have our hands on.                    ]
;; [ For those record that contain numbers or amounts, some of the             ]
;; [ numbers or amounts are converted to appropriate data types                ]
;; [ so they can be used in appropriate ways (currency, for example).          ]
;; [---------------------------------------------------------------------------]

RPPS-1-RECORD-TYPE-CODE: ""
RPPS-1-PRIORITY-CODE: ""
RPPS-1-IMMEDIATE-DESTINATION: ""
RPPS-1-IMMEDIATE-ORIGIN: ""
RPPS-1-TRANSMISSION-DATE: ""
RPPS-1-TRANSMISSION-TIME: ""
RPPS-1-FILE-ID-MODIFIER: ""
RPPS-1-RECORD-SIZE: ""
RPPS-1-BLOCKING-FACTOR: ""
RPPS-1-FORMAT-CODE: ""
RPPS-1-DESTINATION-NAME: ""
RPPS-1-ORIGIN: ""
RPPS-1-REFERENCE-CODE: ""

RPPS-5-RECORD-TYPE-CODE: ""
RPPS-5-SERVICE-CLASS-CODE: ""
RPPS-5-BILLER-NAME: ""
RPPS-5-RESERVED: ""
RPPS-5-BILLER-ID-NUMBER: ""
RPPS-5-ENTRY-CLASS: ""
RPPS-5-ENTRY-DESCRIPTION: ""
RPPS-5-DESCRIPTIVE-DATE: ""
RPPS-5-EFFECTIVE-DATE: ""
RPPS-5-SETTLEMENT-DATE: ""
RPPS-5-CONCENTRATOR-STATUS: ""
RPPS-5-RPPS-ID-NUMBER: ""
RPPS-5-BATCH-NUMBER: ""

RPPS-5-EFFECTIVE-DATE-E: ""

RPPS-6-RECORD-TYPE-CODE: ""
RPPS-6-TRANSACTION-CODE: ""
RPPS-6-RPPS-ID-NUMBER: ""
RPPS-6-MERCHANT-ACCOUNT-NBR: ""
RPPS-6-AMOUNT: ""
RPPS-6-CONSUMER-ACCOUNT-NBR: ""
RPPS-6-CONSUMER-NAME: ""
RPPS-6-RPPS-FLAG: ""
RPPS-6-ADDENDUM-RECORD-IND: ""
RPPS-6-TRACE-NUMBER: ""
RPPS-6-SEQUENCE-NUMBER: ""

RPPS-6-AMOUNT-N: ""

RPPS-8-RECORD-TYPE-CODE: ""
RPPS-8-SERVICE-CLASS-CODE: ""
RPPS-8-ENTRY-ADDENDA-COUNT: ""
RPPS-8-ENTRY-HASH: ""
RPPS-8-TOTAL-DEBIT: ""
RPPS-8-TOTAL-CREDIT: ""
RPPS-8-BILLER-ID-NUMBER: ""
RPPS-8-MAC: ""
RPPS-8-FILLER-1: ""
RPPS-8-RPPS-ID-NUMBER: ""
RPPS-8-BATCH-NUMBER: ""

RPPS-8-TOTAL-DEBIT-N: ""
RPPS-8-TOTAL-CREDIT-N: ""

RPPS-9-RECORD-TYPE-CODE: ""
RPPS-9-BATCH-COUNT: ""
RPPS-9-BLOCK-COUNT: ""
RPPS-9-ENTRY-ADDENDA-COUNT: ""
RPPS-9-ENTRY-HASH: ""
RPPS-9-TOTAL-DEBIT: ""
RPPS-9-TOTAL-CREDIT: ""
RPPS-9-FILLER-1: ""

;; [---------------------------------------------------------------------------]
;; [ This procedure reads the whole file into memory and takes off any         ]
;; [ records at the end that might be all "9" (which would be padding          ]
;; [ records).                                                                 ]
;; [---------------------------------------------------------------------------]

RPPS-OPEN-INPUT: does [
    RPPS-FILE: copy []
    RPPS-FILE: read/lines RPPS-FILE-ID
    RPPS-EOF: false
    RPPS-REC-COUNT: 0
    remove-each TEST-STRING RPPS-FILE [= GLB-SUBSTRING TEST-STRING 1 10 "9999999999"]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "reads" the "file," which, in this situation, means that   ]
;; [ it locates the next line in the in-memory copy of the file, and takes     ]
;; [ that fixed-format line apart into its various data items.                 ]
;; [ If there are no more lines to "read," it sets an end-of-file flag.        ]
;; [---------------------------------------------------------------------------]

RPPS-READ: does [
    RPPS-REC-COUNT: RPPS-REC-COUNT + 1
    RPPS-REC: copy ""
    RPPS-CURRENT-TYPE: copy ""
    RPPS-REC: pick RPPS-FILE RPPS-REC-COUNT  
    if none? RPPS-REC [
        RPPS-EOF: true
    ]
    if not RPPS-EOF [
        RPPS-UNSTRING-RECORD
    ]
]

;; [---------------------------------------------------------------------------]
;; [ This procedure "closes" the file, which means it clears out the           ]
;; [ memory area that held the data.                                           ]
;; [---------------------------------------------------------------------------]

RPPS-CLOSE-INPUT: does [
    RPPS-FILE: copy []
    RPPS-REC: copy ""
]

;; [---------------------------------------------------------------------------]
;; [ This module is incomplete.  It does not include any procedure for         ]
;; [ creating a NACHA file.  The Remote Payment and Presentation System        ]
;; [ seems to be for getting money from the bank anyway, and not going         ]
;; [ after it ourselves.                                                       ]
;; [ If one wanted to create a file, one could reverse the reading process     ]
;; [ by converting the data items to strings of appropriate lengths, and       ]
;; [ joining them all together, with a newline at the end of each.             ]
;; [---------------------------------------------------------------------------]

RPPS-OPEN-OUTPUT: does [
    RPPS-FILE: copy []
    RPPS-REC: copy ""
    RPPS-REC-COUNT: 0
]

RPPS-WRITE: does [
    append RPPS-FILE RPPS-REC
    RPPS-REC-COUNT: RPPS-REC-COUNT + 1
]

RPPS-CLOSE-OUTPUT: does [
    write/lines RPPS-FILE-ID RPPS-FILE
    RPPS-FILE: copy []
    RPPS-REC: copy ""
]

;; [---------------------------------------------------------------------------]
;; [ This procedure is performed after reading each record.                    ]
;; [ It takes apart the fixed-format record into individual data items         ]
;; [ that can be used in whatever ways the caller wants.                       ]
;; [ Records are differentiated by a type code in the first character.         ]
;; [---------------------------------------------------------------------------]

RPPS-UNSTRING-RECORD: does [
    RPPS-CURRENT-TYPE: GLB-SUBSTRING RPPS-REC 1 1
    if RPPS-CURRENT-TYPE = "1" [
        RPPS-UNSTRING-1
    ]
    if RPPS-CURRENT-TYPE = "5" [
        RPPS-UNSTRING-5
    ]
    if RPPS-CURRENT-TYPE = "6" [
        RPPS-UNSTRING-6
    ]
    if RPPS-CURRENT-TYPE = "8" [
        RPPS-UNSTRING-8
    ]
    if RPPS-CURRENT-TYPE = "9" [
        RPPS-UNSTRING-9
    ] 
]

RPPS-UNSTRING-1: does [
    RPPS-1-RECORD-TYPE-CODE: copy ""
    RPPS-1-PRIORITY-CODE: copy ""
    RPPS-1-IMMEDIATE-DESTINATION: copy ""
    RPPS-1-IMMEDIATE-ORIGIN: copy ""
    RPPS-1-TRANSMISSION-DATE: copy ""
    RPPS-1-TRANSMISSION-TIME: copy ""
    RPPS-1-FILE-ID-MODIFIER: copy ""
    RPPS-1-RECORD-SIZE: copy ""
    RPPS-1-BLOCKING-FACTOR: copy ""
    RPPS-1-FORMAT-CODE: copy ""
    RPPS-1-DESTINATION-NAME: copy ""
    RPPS-1-ORIGIN: copy ""
    RPPS-1-REFERENCE-CODE: copy ""
    RPPS-1-RECORD-TYPE-CODE: GLB-SUBSTRING RPPS-REC 1 1
    RPPS-1-PRIORITY-CODE: GLB-SUBSTRING RPPS-REC 2 3
    RPPS-1-IMMEDIATE-DESTINATION: GLB-SUBSTRING RPPS-REC 4 13
    RPPS-1-IMMEDIATE-ORIGIN: GLB-SUBSTRING RPPS-REC 14 23
    RPPS-1-TRANSMISSION-DATE: GLB-SUBSTRING RPPS-REC 24 29
    RPPS-1-TRANSMISSION-TIME: GLB-SUBSTRING RPPS-REC 30 33
    RPPS-1-FILE-ID-MODIFIER: GLB-SUBSTRING RPPS-REC 34 34
    RPPS-1-RECORD-SIZE: GLB-SUBSTRING RPPS-REC 35 37
    RPPS-1-BLOCKING-FACTOR: GLB-SUBSTRING RPPS-REC 38 39
    RPPS-1-FORMAT-CODE: GLB-SUBSTRING RPPS-REC 40 40
    RPPS-1-DESTINATION-NAME: GLB-SUBSTRING RPPS-REC 41 63
    RPPS-1-ORIGIN: GLB-SUBSTRING RPPS-REC 64 86
    RPPS-1-REFERENCE-CODE: GLB-SUBSTRING RPPS-REC 87 94
]

RPPS-UNSTRING-5: does [
    RPPS-5-RECORD-TYPE-CODE: copy ""
    RPPS-5-SERVICE-CLASS-CODE: copy ""
    RPPS-5-BILLER-NAME: copy ""
    RPPS-5-RESERVED: copy ""
    RPPS-5-BILLER-ID-NUMBER: copy ""
    RPPS-5-ENTRY-CLASS: copy ""
    RPPS-5-ENTRY-DESCRIPTION: copy ""
    RPPS-5-DESCRIPTIVE-DATE: copy ""
    RPPS-5-EFFECTIVE-DATE: copy ""
    RPPS-5-SETTLEMENT-DATE: copy ""
    RPPS-5-CONCENTRATOR-STATUS: copy ""
    RPPS-5-RPPS-ID-NUMBER: copy ""
    RPPS-5-BATCH-NUMBER: copy ""
    RPPS-5-RECORD-TYPE-CODE: GLB-SUBSTRING RPPS-REC 1 1
    RPPS-5-SERVICE-CLASS-CODE: GLB-SUBSTRING RPPS-REC 2 4
    RPPS-5-BILLER-NAME: GLB-SUBSTRING RPPS-REC 5 20
    RPPS-5-RESERVED: GLB-SUBSTRING RPPS-REC 21 40
    RPPS-5-BILLER-ID-NUMBER: GLB-SUBSTRING RPPS-REC 41 50
    RPPS-5-ENTRY-CLASS: GLB-SUBSTRING RPPS-REC 51 53
    RPPS-5-ENTRY-DESCRIPTION: GLB-SUBSTRING RPPS-REC 54 63
    RPPS-5-DESCRIPTIVE-DATE: GLB-SUBSTRING RPPS-REC 64 69
    RPPS-5-EFFECTIVE-DATE: GLB-SUBSTRING RPPS-REC 70 75
    RPPS-5-SETTLEMENT-DATE: GLB-SUBSTRING RPPS-REC 76 78
    RPPS-5-CONCENTRATOR-STATUS: GLB-SUBSTRING RPPS-REC 79 79
    RPPS-5-ID-NUMBER: GLB-SUBSTRING RPPS-REC 80 87
    RPPS-5-BATCH-NUMBER: GLB-SUBSTRING RPPS-REC 88 94
    RPPS-5-EFFECTIVE-DATE-E: rejoin [
        GLB-SUBSTRING RPPS-5-EFFECTIVE-DATE 3 4
        "/"
        GLB-SUBSTRING RPPS-5-EFFECTIVE-DATE 5 6
        "/"
        "20"
        GLB-SUBSTRING RPPS-5-EFFECTIVE-DATE 1 2
    ]
]

RPPS-UNSTRING-6: does [
    RPPS-6-RECORD-TYPE-CODE: copy ""
    RPPS-6-TRANSACTION-CODE: copy ""
    RPPS-6-RPPS-ID-NUMBER: copy ""
    RPPS-6-MERCHANT-ACCOUNT-NBR: copy ""
    RPPS-6-AMOUNT: copy ""
    RPPS-6-CONSUMER-ACCOUNT-NBR: copy ""
    RPPS-6-CONSUMER-NAME: copy ""
    RPPS-6-RPPS-FLAG: copy ""
    RPPS-6-ADDENDUM-RECORD-IND: copy ""
    RPPS-6-TRACE-NUMBER: copy ""
    RPPS-6-SEQUENCE-NUMBER: copy ""
    RPPS-6-RECORD-TYPE-CODE: GLB-SUBSTRING RPPS-REC 1 1
    RPPS-6-TRANSACTION-CODE: GLB-SUBSTRING RPPS-REC 2 3
    RPPS-6-RPPS-ID-NUMBER: GLB-SUBSTRING RPPS-REC 4 12
    RPPS-6-MERCHANT-ACCOUNT-NBR: GLB-SUBSTRING RPPS-REC 13 29
    RPPS-6-AMOUNT: GLB-SUBSTRING RPPS-REC 30 39
    RPPS-6-CONSUMER-ACCOUNT-NBR: GLB-SUBSTRING RPPS-REC 40 54
    RPPS-6-CONSUMER-NAME: GLB-SUBSTRING RPPS-REC 55 76
    RPPS-6-RPPS-FLAG: GLB-SUBSTRING RPPS-REC 77 78
    RPPS-6-ADDENDUM-RECORD-IND: GLB-SUBSTRING RPPS-REC 79 79
    RPPS-6-TRACE-NUMBER: GLB-SUBSTRING RPPS-REC 80 87
    RPPS-6-SEQUENCE-NUMBER: GLB-SUBSTRING RPPS-REC 88 94
    RPPS-6-AMOUNT-N: to-decimal divide to-decimal RPPS-6-AMOUNT 100
]

RPPS-UNSTRING-8: does [
    RPPS-8-RECORD-TYPE-CODE: copy ""
    RPPS-8-SERVICE-CLASS-CODE: copy ""
    RPPS-8-ENTRY-ADDENDA-COUNT: copy ""
    RPPS-8-ENTRY-HASH: copy ""
    RPPS-8-TOTAL-DEBIT: copy ""
    RPPS-8-TOTAL-CREDIT: copy ""
    RPPS-8-BILLER-ID-NUMBER: copy ""
    RPPT-8-MAC: copy ""
    RPPS-8-FILLER-1: copy ""
    RPPS-8-RPPS-ID-NUMBER: copy ""
    RPPS-8-BATCH-NUMBER: copy ""
    RPPS-8-RECORD-TYPE-CODE: GLB-SUBSTRING RPPS-REC 1 1
    RPPS-8-SERVICE-CLASS-CODE: GLB-SUBSTRING RPPS-REC 2 4
    RPPS-8-ENTRY-ADDENDA-COUNT: GLB-SUBSTRING RPPS-REC 5 10
    RPPS-8-ENTRY-HASH: GLB-SUBSTRING RPPS-REC 11 20
    RPPS-8-TOTAL-DEBIT: GLB-SUBSTRING RPPS-REC 21 32
    RPPS-8-TOTAL-CREDIT: GLB-SUBSTRING RPPS-REC 33 44
    RPPS-8-BILLER-ID-NUMBER: GLB-SUBSTRING RPPS-REC 45 54
    RPPS-8-MAC: GLB-SUBSTRING RPPS-REC 55 73
    RPPS-8-FILLER-1: GLB-SUBSTRING RPPS-REC 74 79
    RPPS-8-RPPS-ID-NUMBER: GLB-SUBSTRING RPPS-REC 80 87
    RPPS-8-BATCH-NUMBER: GLB-SUBSTRING RPPS-REC 88 94
    RPPS-8-TOTAL-DEBIT-N: divide to-decimal RPPS-8-TOTAL-DEBIT 100
    RPPS-8-TOTAL-CREDIT-N: divide to-decimal RPPS-8-TOTAL-CREDIT 100  
]

RPPS-UNSTRING-9: does [
    RPPS-9-RECORD-TYPE-CODE: copy "" 
    RPPS-9-BATCH-COUNT: copy "" 
    RPPS-9-BLOCK-COUNT: copy "" 
    RPPS-9-ENTRY-ADDENDA-COUNT: copy "" 
    RPPS-9-ENTRY-HASH: copy "" 
    RPPS-9-TOTAL-DEBIT: copy "" 
    RPPS-9-TOTAL-CREDIT: copy "" 
    RPPS-9-FILLER-1: copy "" 
    RPPS-9-RECORD-TYPE-CODE: GLB-SUBSTRING RPPS-REC 1 1
    RPPS-9-BATCH-COUNT: GLB-SUBSTRING RPPS-REC 2 7
    RPPS-9-BLOCK-COUNT: GLB-SUBSTRING RPPS-REC 8 13
    RPPS-9-ENTRY-ADDENDA-COUNT: GLB-SUBSTRING RPPS-REC 14 21
    RPPS-9-ENTRY-HASH: GLB-SUBSTRING RPPS-REC 22 31
    RPPS-9-TOTAL-DEBIT: GLB-SUBSTRING RPPS-REC 32 43
    RPPS-9-TOTAL-CREDIT: GLB-SUBSTRING RPPS-REC 44 55
    RPPS-9-FILLER-1: GLB-SUBSTRING RPPS-REC 56 94
]

;; -----------------------------------------------------------------------------

 
