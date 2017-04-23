REBOL [
    Title: "Win-Registry-Control"
    Date: 21-Aug-2001
    Version: 1.1.0
    File: %registry.r
    Author: "Frank Sievertsen"
    Usage: {
^-^-USE THIS SCRIPT ON YOUR OWN RISK!

^-^-read registry:HKEY_CURRENT_USER\
^-^-^-you will receive a block of all subkeys and
^-^-^-values of the key.
^-^-^-IMPORTANT: use Backslash instead of Slash !!!!

^-^-read registry:HKEY_CURRENT_USER\Software\
^-^-^-Same as above

^-^-read registry:HKEY_CURRENT_USER\Software\Rebol\View\\HOME
^-^-^-Reads the value "Home"
^-^-^-IMPORTANT: double backslash before value

^-^-NEW: registry:computer_name:HKEY_LOCAL_MACHINE\....

^-^-When reading Text/binary/dword - Values, you will get
^-^-string/binary/integer - Values.

^-^-Example:

^-^->> read registry:current_user\software\rebol\
^-^-== [%Console\ %View\ %\test-value %\]
^-^-    ^--------------- ^--------------
^-^-     keys             values

^-^-The last result is the "standard value" of the registry-key
^-^-"Rebol". I set it.

^-^-To find out, if a result is a key or a value, use:

^-^-registry-value?: func [file [file!]] [
^-^-^-(first file) = #"\"
^-^-]

^-^-write registry:HKEY_CURRENT_USER\Software\Test\ none
^-^-^-Creates the Key "Test"

^-^-write registry:CURRENT_USER\Software\Test\\example "Hallo"
^-^-^-Writes text "Hallo" to value "example" in key "test"

^-^-write registry:CURRENT_USER\Software\Test\\example #{aa}
^-^-^-Writes binary-val to value "example" in key "test"

^-^-write registry:CURRENT_USER\Software\Test\\example 881
^-^-^-Writes DWORD 881 to value "example" in key "test"


^-^-registry-delete registry:CURRENT_USER\Software\Test\
^-^-^-Deletes key "Test"

^-^-registry-delete registry:CURRENT_USER\Software\Test\\example
^-^-^-Deletes value "example"
^-}
    Purpose: "View and modify data of windows registry."
    History: [
        1.1.0 {
^-^-^-Now you can connect to other computers with
^-^-^-registry:computer_name\HKEY_...
^-^-} 
        1.0.0 {
^-^-^-First release
^-^-}
    ]
    Email: fsievert@uos.de
    library: [
        level: 'advanced 
        platform: [windows win] 
        type: 'tool 
        domain: 'win-api 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

if any [
    not system/user-license/id
    system/version/4 <> 3
] [
    either system/view [
        inform layout [backdrop 200.200.200
            h1 "You need Rebol/Command or Rebol/Pro"
            h1 "and a Windows Computer"
            button "Ok" [unview/all]
        ]
    ] [
        print "You need Rebol/Command or Rebol/Pro"
        print "and a Windows Computer"
    ]
    quit
]

context [
registry: make object! [
    lib: load/library %Advapi32.dll

    long-holder: make struct! [val [long]] [0]


    RegOpenKeyEx: make routine! [
        hkey [long]
        lpsubkey [string!]
        uloptions [long]
        samDesired [long]
        phkResult [struct! [val [long]]]
        return: [long]
    ] lib "RegOpenKeyExA"

    RegQueryValueEx: make routine! [
        hKey [Long]
        lpValueName [String!]
        lpReserved [Long]
        lpType [struct! [val [long]]]
        lpData [string!] ; returns any-type
        lpcbData [struct! [val [long]]]
        return: [long]
    ] lib "RegQueryValueExA"

    RegCloseKey: make routine! [
        hkey [long]
        return: [long]
    ] lib "RegCloseKey"

    RegCreateKey: make routine! [
        hkey [long]
        lpSubKey [string!]
        phkResult [struct! [val [long]]]
        return: [long]
    ] lib "RegCreateKeyA"

    RegSetValueEx: make routine! [
        hkey [long]
        lpValueName [string!]
        reserved [long]
        dwType [long]
        lpData [string!]
        cbData [long]
        return: [long]
    ] lib "RegSetValueExA"

    RegEnumValue: make routine! [
        hkey [long]
        dwIndex [long]
        lpValueName [string!] ; Returns name
        length [struct! [val [long]]] ; in: size out: length
        lpReserved [long]       
        lpType [struct! [val [long]]]
        lpData [long]
        lpcdData [long]
        return: [long]
    ] lib "RegEnumValueA"

    RegEnumKey: make routine! [
        hkey [long]
        dwIndex [long]
        lpName [string!] ; Returns name
        length [struct! [var [long]]]
        return: [long]
    ] lib "RegEnumKeyA"

    RegEnumKeyEx: make routine! [
        hkey [long]
        dwIndex [long]
        lpName [string!] ; Returns name
        length [struct! [var [long]]]
        reserved [long] ; 0
        lpClass [long] ; 0
        lpcClass [long] ; 0
        lpftLastWriteTime [string!]
        return: [long]
    ] lib "RegEnumKeyExA"

    RegDeleteKey: make routine! [
        hKey [long]
        lpSubKey [string!]
        return: [long]
    ] lib "RegDeleteKeyA"

    RegDeleteValue: make routine! [
        hKey [long]
        lpValueName [string!]
        return: [long]
    ] lib "RegDeleteValueA"

    RegConnectRegistry: make routine! [
        lpMachineName [string!]
        hKey [long] ; LOCAL_MACHINE OR USERS
        phkResult [struct! [val [long]]]
        return: [long]
    ] lib "RegConnectRegistryA"

    ; HOTKEYS
    HKEY_CLASSES_ROOT: to-integer #{80000000}
    HKEY_CURRENT_CONFIG: to-integer #{80000005}
    HKEY_CURRENT_USER: to-integer #{80000001}
    HKEY_DYN_DATA: to-integer #{80000006}
    HKEY_LOCAL_MACHINE: to-integer #{80000002}
    HKEY_PERFORMANCE_DATA: to-integer #{80000004}
    HKEY_USERS: to-integer #{80000003}

    ; ACCESS-VALUES
    KEY_READ: to-integer    #{020019}
    KEY_WRITE: to-integer   #{020006}

    ; DATATYPES
    D_Problem: -1
        D_No-data: 0
        D_Text: 1
        D_Binary: 3
        D_Double: 4
    

    key: make struct! long-holder [0]
    type: make struct! long-holder [0]
    data: make struct! long-holder [0]

    open-key: func [
        hkey [word!]
        path [string!]
        /write
        /remote computer [string! none!]
        /local k
    ] [
        k: get in self hkey
        if computer [
            if not zero? RegConnectRegistry
                computer
                k
                k: make struct! long-holder [0] [
                make error! "RegConnectRegistry"
            ]
            k: k/val
        ]
        if not zero? RegOpenKeyEx
        k
        path
        0
        either write [KEY_WRITE] [KEY_READ]
        key
        [
        make error! "RegOpenKey"
        ]
        if computer [
        RegCloseKey k
        ]
    ]

    get-value: func [
        hkey [word!]
        path [string!]
        value [string!]
        /remote computer [none! string!]
    ] [
        open-key/remote hkey path computer
        RegQueryValueEx
        key/val
        value
        0
        type
        ""
        data

        if not zero? RegQueryValueEx
        key/val
        value
        0
        type
        mem: head insert/dup copy "" to-char 0 data/val
        data
        [
        make error! "RegQueryValueEx"
        ]
    
        RegCloseKey key/val

        switch/default type/val reduce [
        D_Text [remove back tail mem]
        D_Binary [mem: to-binary mem]
        D_Double [
            change third long-holder mem
            mem: long-holder/val
        ]
        ] [
        make error! "Unknown Datatype"
        ]
        mem
    ]
    set-value: func [hkey [word!] path [string!] value [string!]
        data [string! binary! integer!]
        /remote computer
        /local out-data
    ] [
        open-key/write/remote hkey path computer
        switch type?/word data [
            binary! [out-data: to-string data]
            string! [out-data: rejoin [data to-char 0]]
            integer! [
                long-holder/val: data
                out-data: to-string third long-holder
            ]
        ]
        if not zero? RegSetValueEx
            key/val
            value
            0
            get select [
                binary! D_Binary
                string! D_Text
                integer! D_Double
            ] type?/word data
            out-data
            length? out-data
        [
            make error! "Unable to set value"
        ]
    ]

    create-key: func [hkey [word!] path [string!] /local key] [
        if not zero? RegCreateKey
            get in self hkey
            path
            key: make struct! long-holder [0]
        [
            make error! "Unable to create key"
        ]
        RegCloseKey key/val
    ]

    get-keys: func [
        hkey [word!] path [string!]
        /remote computer
        /local out count buf length type time
    ] [
        out: copy []
        count: 0
        buf: head insert/dup copy "" to-char 0 1024
        open-key/remote hkey path computer
        time: head insert/dup copy "" to-char 0 100
        forever [
            length: make struct! long-holder [1024]
            type: make struct! long-holder [0]
            if not zero? RegEnumKeyEx
                key/val
                count
                buf
                length
                0
                0
                0
                time
            [
                break
            ]
            count: count + 1
            append out copy/part buf length/val
        ]
        
        RegCloseKey key/val
        out
    ]       
    get-values: func [
        hkey [word!] path [string!]
        /remote computer
        /local out count buf length type
    ] [
        out: copy []
        count: 0
        buf: head insert/dup copy "" to-char 0 1024
        open-key/remote hkey path computer
        forever [
            length: make struct! long-holder [1024]
            type: make struct! long-holder [0]
            if not zero? RegEnumValue
                key/val
                count
                buf
                length
                0
                type
                0
                0
            [
                break
            ]
            count: count + 1
            append out copy/part buf length/val
        ]
        
        RegCloseKey key/val
        out
    ]

    delete-key: func [hkey [word!] path [string!]] [
        if not zero? RegDeleteKey
            get in self hkey
            path
        [
            make error! "Unable to delete key"
        ]
    ]
    delete-value: func [hkey [word!] path [string!] value [string!] /remote computer] [
        open-key/write/remote hkey path computer
        RegDeleteValue
            key/val
            value
        RegCloseKey key/val
    ]
]

comment {
    registry:HKEY_CURRENT_USER\
    registry:HKEY_CURRENT_USER\Rebol\View
    registry:HKEY_CURRENT_USER\Rebol\View\\HOME

    Later:
    registry:host.domain.com:HKEY_CURRENT_USER\Rebol\View\\HOME
}

registry-url: context [
    base-out: make object! [
        host: none
        top-key: none
        path: none
        value: none
    ]
    out: none

    t1: t2: t3: t4: none

    init: [(
        out: make base-out []
    )]

    key-names: [
        "CLASSES_ROOT"
        | "CURRENT_USER"
        | "LOCAL_MACHINE"
        | "USERS"
        | "CURRENT_CONFIG"
        | "DYN_DATA"
    ]

    computer-chars: complement charset ":\"
    computer-name: [
        copy t1 some computer-chars ":"
        (out/host: t1)
    ]

    top-key: [
        opt "HKEY_"
        copy t1 key-names
        ["\" | end]
        (
            out/top-key: to-word rejoin [
                "HKEY_" uppercase t1
            ]
        )
    ]

    non-bslash: complement charset "\"
    key: [
        some non-bslash
        ["\" | end]
    ]

    key-path: [
        copy t1 any [key]
        (
            out/path: any [t1 copy ""]
        )
    ]

    value: [
        "\" copy t1 to end
        (
            out/value: any [t1 copy ""]
        )
    ]

    start: [
        init
        "registry:"
        opt computer-name
        top-key
        key-path
        opt value
    ]
    
    parser: func [url [url!]] [
        if not parse/all url start [
            make error! "REGISTRY URL error"
        ]
        out
    ]
]

make root-protocol [
    scheme: 'REGISTRY
    port-id: checksum "REGISTRY"
    init: func [port spec /local data] [
        if not url? spec [
            make error! "only urls are supported by registry-scheme"
        ]
        port/locals: make object! [
            data: none
        ]
        port/locals/data: data: registry-url/parser spec
        port/host: data/host
        port/path: data/path
        port/target: data/value
    ]
    open: func [port] [
        port/state/flags: system/standard/port-flags/pass-thru
    ]
    copy: func [port /local out] [
        either none? port/target [
            out: registry/get-keys/remote port/locals/data/top-key port/path port/host
            forall out [
                out/1: to-file append out/1 "\"
            ]
            append out registry/get-values/remote port/locals/data/top-key port/path port/host
            forall out [
                out/1: to-file head system/words/insert out/1 "\"
            ]
            head out
        ] [
            registry/get-value/remote port/locals/data/top-key port/path port/target port/host
        ]
    ]
    insert: func [port data] [
        registry/create-key/remove port/locals/data/top-key port/path port/host
        if found? port/target [
            registry/set-value/remote port/locals/data/top-key port/path port/target data port/host
        ]
        port
    ]
    close: func [port] [
    ]

    net-utils/net-install :scheme self 0
]

system/words/registry-delete: func [url [url!] /local data] [
    data: registry-url/parser url
    either found? data/value [
        registry/delete-value/remote data/top-key data/path data/value data/host
    ] [
        registry/delete-key/remote data/top-key data/path data/host
    ]
]
]

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        