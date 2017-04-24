REBOL [
 Title: "UUID Generation Example via Windows SDK"
    Date: 10-Sep-2005
    Version: 0.1
    File: %guid.r
    Author: "David McAvenue"
    Purpose: {Command only example of interfacing to Windows SDK to generat UUIDs. Trivial given heavy lifting by others in Rebol community. Acknowledgements to all.}
    History: [
        0.1 [10-Sep-2005 "First Issue" "DMcA"] 
    ]
    library: [
        level: 'intermediate 
        platform: [Windows]
        type: [how-to]
        domain: 'win-api
        product: 'Command 
        tested-under: 'Windows 
        support: none 
        license: none 
        see-also: none
    ]
]

; make-elements function to dynamically build the byte array previously 
; developed by Gregg Irwin with credits to some others
make-elements: func [name count type /local result][
     if not word? type [type: type?/word type]
     result: copy "^/"
     repeat i count [
         append result join name [i " [" type "]" newline]
     ]
     to block! result
 ]

 ; load the lib
 rpclib.dll: load/library %Rpcrt4.dll

; declare the structs and similtaneously variables to be used

 ; UUID struct
 GUID: make struct! GUID-def: compose/deep [
     Data1     [integer!]      ; DWORD
     Data2      [short]      ; SHORT
     Data3      [short]      ; SHORT
     (make-elements 'Data4 8 #"@")  ; dynamically make BYTE(8)
 ] none

 ; CHAR ** for UuidToString
 strguid: make struct! GUIDSTR-def: compose/deep [
   strval [string!] ;
 ] none

; declare the routines

; Bind to win SDK UuidCreate
 UuidCreate: make routine! compose/deep/only [
     guidout    [struct! (GUID-def)]
     return:     [long]  ; RPC_STATUS
 ] rpclib.dll "UuidCreate"

; Bind to win SDK UuidToString
; Could also easily use to-hex to build string UUID direct from the GUID
; struct
 UuidToString: make routine! compose/deep/only [
 guidin [struct! (GUID-def)]
 guidstring [struct! (GUIDSTR-def)]
 return: [long] ; RPC_STATUS
] rpclib.dll "UuidToStringA"

; generate UUID
UuidCreate GUID

; convert to string
UuidToString GUID strguid

; release lib resource
free rpclib.dll

; let's see it
print uppercase strguid/strval
