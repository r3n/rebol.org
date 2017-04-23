REBOL [
    Title:   "EASY SERVICE"
    Date:    16-Nov-2005
    Author:  ["Marco"]
    Version: 1.0.2
    Email:   [marco@ladyreb.org]
    File:    %easy-service.r
    Category: [web cgi]
    Library: [
        level: 'beginner
        platform: 'all
        type: [function tool module]
        domain: [cgi web compression encryption extension http protocol other-net ]
        tested-under: [win]
        support: marco@ladyreb.org
        license: PD
        see-also: none
    ]
    Comment: {At the origin was Rugby, next Soccer and easy-soccer, and now easy-service}
    Purpose: {
        Easy-Service is a broker based on REBOL/Service which offer an easy way 
        to write and the deploy distributed Rebol application.
        Easy-Service makes very easy to expose function written in Rebol like REBOL/Services.
        Thus, you can use these functions as if they were defined locally.

        In a distributed environment easy-service uses a simple WEB server
        and CGI to execute Rebol code on the server. HTTP and REBOL/Services are used for the 
        transport layer.

        Easy-service allows not only to publish remote function, but can also provide
        the client part of the application. So you can have in the same Rebol script
        the client and the server part of your program.
        
        Even more, easy-service allows you to run your script as a monolithic application
        without any change and without anything else than your script. In the same spirit,
        if your script use VID, it can be run within REBOL/View or within the REBOL/Plugin
        without any change.
    }
    Modified: [
        [0.0.0 11-Nov-2005 marco@ladyreb.org {Script creation based on easy-soccer 1.1.6}]
        [0.0.1 15-Nov-2005 marco@ladyreb.org {First running version, but very slow}]
        [1.0.0 16-Nov-2005 marco@ladyreb.org {First published version on www.rebol.org}]
        [1.0.1 16-Nov-2005 marco@ladyreb.org {Minor correction & modification}]
        [1.0.2 16-Nov-2005 marco@ladyreb.org {Minor correction}]
    ]
    Defaults: {
        compress: true
        encloak: false
    }
    Usage: {
        In your script:
            - Write the functions you want to use remotly
            - If you want, write in a block also the client part of your application
            - initialize easy-service (do %easy-service.r)
            - invoke the serve function with the liste of the functions you authorize to access remotly
              for example: serve [now]
            - If you publish also the client part of your application, use the refinement /do-script
              for example serve/do-script [now] [print now]
            - You can also encrypt and/or compress the message between the client and the server by using the refinement /encloak and /compress
              for example serve/do-script/compress/encloak [now] [print now] yes no
            
        To run your script in a distributed environnement:
            - within a script or within the console: do http://my.super.server/cgi-bin/my-super-script.cgi
            - to include the stubs in a un context ctx: context load do next load http://my.super.script/cgi-bin/my-super-script.cgi
            - whitin the plugin
                <OBJECT ID="RPluginIE" CLASSID="CLSID:9DDFB297-9ED8-421d-B2AC-372A0F36E6C5" 
                    CODEBASE="http://www.rebol.com/plugin/rebolb5.cab#Version=0,5,0,0"
                    WIDTH="800" HEIGHT="600"
                >
                    <PARAM NAME="LaunchURL" VALUE="cgi-bin/my-super-script.cgi">
                </OBJECT>

        To run your script in a local environnement:
            - within a script or within the console: do %my-super-script.cgi
            - to include the stubs in a un context ctx: context load do next load %my-super-script.cgi
            - whitin the plugin (no change from distributed env. if you use relative URL)
                <OBJECT ID="RPluginIE" CLASSID="CLSID:9DDFB297-9ED8-421d-B2AC-372A0F36E6C5" 
                    CODEBASE="http://www.rebol.com/plugin/rebolb5.cab#Version=0,5,0,0"
                    WIDTH="800" HEIGHT="600"
                >
                    <PARAM NAME="LaunchURL" VALUE="cgi-bin/my-super-script.cgi">
                </OBJECT>
    }
    Sample: {
        REBOL [
        	Title: "Test of easy-service"
        ]

        ; !!! to run this sample, type in the console :
        ;   do http://your.super.server/....
        ;   test-1
        ;   test-2

        do %module/easy-service.r ; !!!! path must be changed to your path !!!!

        path-to-client: %module/client.r ; !!!! path must be changed to your path !!!!
        path-to-server: %module/server.r ; !!!! path must be changed to your path !!!!

        test-1: does [return "test-1 -> a response"]
        test-2: does [to-error "test-2 -> an error"]

        serve [test-1 test-2]
    }
]

; ***************
; Public function
; ***************
serve: none

    
; ******************************
; Context containing easy-service
; ******************************

make object! [
; ************************
; Properties of the object
; ************************

    path: what-dir
    if any [
        not value? 'path-to-client
        none? path-to-client
    ][
        path-to-client: path/client.r
    ]
    if any [
        not value? 'path-to-server
        none? path-to-server
    ][
        path-to-server: path/server.r
    ]
    config: context [
        compress: true
        encloak: false
    ]
    exposed-services: none
    server: none

; ************************************
; The serve function (public function)
; ************************************
    set 'serve func [
        {Exposes a set of function as a remote service and execute the request}
        'services  [word! block!]
            {The functions to expose}
        /do-script script [string! block! file! url!]
            {The script to run at the client}
        /compress compress-flag [logic!]
        /encloak encloak-flag [logic!]
        /local result
    ] [
        script: either script [compose load script][copy[]]
        if none? system/options/cgi/request-method [
            do script
            return
        ]
        exposed-services: services: to-block services
        either equal? "GET" uppercase system/options/cgi/request-method [
            server: rejoin [http:// system/options/cgi/server-name ":" system/options/cgi/server-port system/options/cgi/script-name]
            if error? result: try [build-client server services script] [
                result: disarm result
            ]
            if none? compress-flag [compress-flag: config/compress]
            if none? encloak-flag [encloak-flag: config/encloak]
            send-response result compress-flag encloak-flag
        ][
            do path-to-server
            ctx-services/add-default-service compose/only [
;           save %services/easy-service.r compose/only [ ; for debug purpose (uncomment this ligne, comment the previous one)
                rebol [title: "Easy-Service"]
                name: 'easy-service
                title: "Easy Service"
                description: {Commands generated by easy-service.}
                _func: _args: none
                commands: (build-service services)
            ]
            start-service/options 'cgi [easy-service]
            wait []
        ]
    ]

; ***********************************
; Function which compose the response
; ***********************************
    send-response: func [
        block
        compress-flag
        encloak-flag
        /local key
    ] [
        either any [
            compress-flag
            encloak-flag
        ][
            block: mold/only block
            if compress-flag [
                block: compress block
            ]
            either encloak-flag [
                key: checksum/secure to-string length? block
                block: mold/only compose [
                    decloak (encloak block key) (key)
                ]
            ][
                block: mold/only block
            ]
            if compress-flag [
                insert block "decompress "
            ]
        ][
            block: mold block
        ]
        print "Content-Type: text/text"
        print reform ["content-length:" 13 + length? block]
        print ""
        print ["REBOL []" newline "do" block]
    ]

; ****************************************
; Return the stubs and the client (if any)
; ****************************************
    build-client: func [
        server [url!]
        services [block!]
        script [block!]
        /local
    ] [
        local: copy []
        foreach item services [
            append local to-set-word item
        ]
        local: compose/deep [
            (load path-to-client)
            (local) none
            context [ 
                (build-stubs services server)
            ]
            (script)
        ]
        local
    ]

; ***************
; Build the stubs
; ***************

    build-stubs: func [
        "Build a function stub"
        f [block!] "function to build stub"
        server [url!]
        /local item stubs
    ][
        stubs: copy []
        foreach item to-block f [
            append stubs build-stub item            
        ]
        stubs
    ]

    build-stub: func [
        f [word!]
        /local stub item cpy code ref
    ][
        if not value? f [return copy []]
        either all [any-function? get f] [

            cpy: none
            parse first get f [copy cpy to refinement! | copy cpy to end ]
            item: cpy: any [cpy copy []]
            forall item [
               change item compose [(to-paren to-get-word item/1)]
            ]
            code: compose/deep [
                local: compose/only [(join to-path 'easy-service f) (cpy)]
            ]

            cpy: none
            rule: [
                /local to end |
                set ref refinement! copy cpy to refinement! (build-ref ref cpy code) rule |
                set ref refinement! copy cpy to end (build-ref ref cpy code)
            ]
            parse first get f [to refinement! rule | to end]

            cpy: none
            parse third get f [copy cpy to /local | copy cpy to end ]
            foreach item cpy: any [
                cpy
                copy []
            ][
                if block? item [
                    forall item [
                       item/1: to-word mold item/1
                    ]
                ]
            ]

            stub: compose/deep [
                set (to-lit-word f) func [
                    (cpy)
                    /local
                ][
                    (code)
                    either all [
                        object? local: pick select do-service (server) local 'ok 2
                        equal? [ignore code type id arg1 arg2 arg3 near where] first local
                    ][
                        make error! reduce bind copy/part at first local 3 6 in local 'ignore
                    ][
                        local
                    ]
                ]
            ]
        ][
            compose/only [set (to-lit-word f) (get f)]
        ]
    ]

    build-ref: func [
        ref [refinement!]
        cpy [block! none!]
        code [block!]
    ][
        item: cpy: any [cpy copy []]
        forall item [
           change item compose [(to-paren to-get-word item/1)]
        ]
        append code compose/deep [
            if (to-word ref) [
                append local compose/only [(ref) (cpy)]
            ]
        ]
    ]


; ******************
; Build the services
; ******************

    build-service: func [
        "Build a function command"
        f [block!] "function to build services"
        /local item code
    ][
        code: copy []
        foreach item to-block f [
            either empty? code [
                code: build-command item
            ][
                code: compose [
                    (code)
                    |
                    (build-command item)
                ]
            ]
        ]
        code
    ]

    build-command: func [
        f [word!]
        /local item cpy code ref doc args arg
    ][
        if not value? f [return copy []]
        either all [any-function? get f] [
            args: third get f

; Compose the parsing rules for refinements

            code: []
            cpy: none
            rule: [
                /local to end |
                set ref refinement! copy cpy to refinement! (code: build-srv-ref ref cpy args code) rule |
                set ref refinement! copy cpy to end (code: build-srv-ref ref cpy args code)
            ]
            parse first get f [to refinement! rule | to end]

; Compose the parsing rule for the function and the parameters

            cpy: none
            parse first get f [copy cpy to refinement! | copy cpy to end ]
            code: compose/deep [
                (to-lit-word f)
                #doc [(either string? doc: pick args 1 [doc][copy ""])]
                (to-paren compose [
                    _func: to-lit-path (to-lit-word f)
                    _args: copy []
                ])
                (build-srv-args cpy args)
                (either empty? code [
                    []
                ][
                    compose/deep [
                        any [
                            (code)
                        ]
                    ]
                ])
                (to-paren [
                    if error? result: try compose [(_func) (_args)][
                        result: disarm result
                    ]
                    write/append/lines %log-easy-service.txt remold [now result]
                    result
                ])
            ]
        ][
            compose/only [set (to-lit-word f) (get f)]
        ]
    ]

; Compose parsing rule for refinements

    build-srv-ref: func [
        ref [refinement!]
        cpy [block! none!]
        args [block!]
        code [block!]
        /local block
    ][
        either empty? code [
            code: compose [
                (ref) (to-paren compose [append _func (to-lit-word ref)])
                (build-srv-args cpy args)
            ]
        ][
            code: compose [
                (code)
                |
                (ref) (to-paren compose [append _func (to-lit-word ref)])
                (build-srv-args cpy args)
            ]
        ]
    ]

; Compose parsing rule for arguments

    build-srv-args: func [
        cpy [block! none!]
        args [block!]
        /local code
    ][
        code: []
        foreach item any [cpy []][  
            type: either block? type: select args item [
                type: next copy type
                forall type [if not tail? type [type: insert type '|]]
                head type
            ][
                any-type!
            ]
            code: compose/deep [
                (code)
                set _arg [(type)] (to-paren [
                    append _args either word? _arg [to-lit-word _arg][_arg]
                ])
            ]
        ]
        code
    ]
]
