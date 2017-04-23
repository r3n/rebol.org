REBOL [
    Title: "UPnP - IGD V1.0"
    Date: 10-Sep-2006
    Name: "UPnP - Internet_Gateway_Device_IGD_V1.0"
    Author:  ["Marco"]
    Version: 0.1
    File: %upnp-igd.r
    Rights: "Public Domain"
    Email:   [marco@ladyreb.org]
    Category: [http internet]
    Library: [
        level: 'beginner
        platform: 'all
        type: [function tool module protocol]
        domain: [game extension http protocol other-net html markup parse protocol tcp xml ]
        tested-under: [win]
        support: marco@ladyreb.org
        license: PD
        see-also: none
    ]
    Comment: {
    	This is script is a pilot to controle a Internet Gateway Device thru UPnP
    }
    Purpose: {
        UPnP-IGD tool to discover and control an Internet Gateway Device via UPnP
    }
    Modified: [
        [0.0.1 10-Sep-2006 marco@ladyreb.org {Fist publication of a pilote}]
    ]
    Defaults: {
    }
    Usage: {
    	... To be documented ... (sorry)
    }
]

; ***********************************************************
; XML Utility
; ***********************************************************

load-xml: func [
    {Loads an XML file and return a nested block/object structure with tag (t) attribute (a) and element (e)
    For example, this XML :
        <ns:tag1 
            xmlns="ns"
        >
            "text tag 1"
            <tag2>
                "text tag 2"
            </tag2>
        </ns:tag1>
    is returned like this :
        [tag1 [
            <ns:tag1>
            [ ; block of attribute name & value
                xmlns "ns"
            ]
            "text tag 1"
            tag2 [
                <tag1>
                []
                "text tag 2"
            ]
        ]]
    }
    source [file! url! string! any-block! binary!]
    /local item result stack att
][
    result: copy []
    stack: reduce [result]
    parse load/markup source [ any [
        set item tag! (
            case [
                #"/" = first item [
                    remove/part stack 1
                ]
                find "/?" last item [
                    remove back tail item
                    att: next item: to-block item
                    if #"?" = first item/1: to-string item/1 [append item/1 #"?"]
                    forskip att 2 [
                        att/1: to-word head remove back tail to-string att/1
                    ]
                    append stack/1 compose/deep/only [
                        (to-word last parse item/1 ":") [
                        (to-tag item/1)
                        (new-line/all/skip copy next item true 2)
                        ]
                    ]
                ]
                true [
                    att: next item: to-block item
                    if #"?" = first item/1: to-string item/1 [append item/1 #"?"]
                    forskip att 2 [
                        att/1: to-word head remove back tail to-string att/1
                    ]
                    item: head item
                    append stack/1 compose/deep/only [
                        (to-word last parse item/1 ":") [
                        (to-tag item/1)
                        (new-line/all/skip copy next item true 2)
                        ]
                    ]
                    new-line skip tail stack/1 -2 true
                    insert/only stack last stack/1
                ]
            ]
        )
    |
        set item string! (
            unless #"^/" = first item [
                append stack/1 item
                new-line back tail stack/1 true
            ]
        )
    ]]
    result
]

save-xml: func [
    "Saves an XML nested block structure (see load-xml)"
    where [file! url! binary!] "Where to save it."
    value [block!] "XML block/object to save."
    /indent tabs
    /local result tag attribute element
][
    result: either binary? where [where][make binary! ""]
    unless tabs [tabs: copy ""]
    parse value rule: [
        opt block! ; ignore first block! of attribute if any
        any [
            word! into [
                set tag tag!
                set attribute block!
                element: (
                    repend result [tabs mold build-tag [(to-word to-string tag) (attribute)] newline]
                    save-xml/indent result element rejoin [tabs tab]
                    repend result [tabs form to-tag mold to-refinement to-string tag newline]
                ) to end
            ]
        |
            set element any-type! (
                repend result [tabs element newline]
            )
        ]
    ]
    unless binary? where [
        save where result
    ]
    return
]

; **************************************************
; UPnP Utility
; **************************************************

upnp-search: func [
    {Search for an UPnP device
        return the root device definition or throw an error}
    /all "Search all device"
    /type
         ST [string!] {Search Target must be one of the following single URI (default ssdp:all):
            ssdp:all 
                Search for all devices and services. 
            upnp:rootdevice 
                Search for root devices only. 
            uuid:device-UUID 
                Search for a particular device. Device UUID specified by UPnP vendor. 
            urn:schemas-upnp-org:device:deviceType:v 
                Search for any device of this type. Device type and version defined by UPnP Forum working committee. 
            urn:schemas-upnp-org:service:serviceType:v 
                Search for any service of this type. Service type and version defined by UPnP Forum working committee.  
}
    /max-wait
        MX [integer!] {Maximum wait in second (default 3).
            Device responses should be delayed a random duration between 0 and this many seconds to balance load for the control point when it processes responses.
            This vue should be increased if a large number of devices are expected to respond or if network latencies are expected to be significant.
            Specified by UPnP vendor.
}
    /local port rule result RC device
][

    unless ST [ST: "ssdp:all"]
    unless MX [MX: 3]
    port: open/binary udp://239.255.255.250:1900
    set-modes port compose/deep [
        multicast-ttl: 4
    ]
    insert port rejoin [
        {M-SEARCH * HTTP/1.1} crlf
        {HOST: 239.255.255.250:1900} crlf
        {MAN: "ssdp:discover"} crlf
        {MX: } MX crlf
        {ST: } ST crlf
        crlf
    ]
    device: copy []
    while [wait [port MX]][
        parse replace/all  copy port crlf newline [
            {HTTP/1.1 } copy RC to newline newline
            result: to end (result: parse-header none result)
        ]
        unless "200 OK" = RC [
            close port
            to-error reform ["UPnP error (search) :" RC]
        ]
        result: load-xml to-url result/LOCATION
        append device compose/only [root (result/root)]
        unless all [break]
    ]
    close port
    device
]

upnp-invoke: func [
    url [url! string!]
    soap-action [string!]
    body [string!]
    /local port result RC
][
    url: decode-url url
    port: open/binary rejoin [tcp:// url/host ":" url/port-id]
    insert port probe rejoin [
        {POST /} url/path url/target { HTTP/1.1} crlf
        {HOST: } url/host ":" url/port-id crlf
        {CONTENT-LENGTH: } length? body crlf
        {CONTENT-TYPE: text/xml; charset="utf-8"} crlf
        {SOAPACTION: "} soap-action {"} crlf
        crlf
        body
    ]
    either port = wait [port 5][
        parse replace/all copy port crlf newline [
            {HTTP/1.1 } copy RC to newline newline
            result: to end
        ]
        close port
    ][
        close port
        to-error reform ["SOAP error (invoke) : No response"]
    ]
    result: load-xml result
    unless "200 OK" = RC [
        to-error reform [
            "UPnP error (invoke):"
            result/envelope/body/Fault/detail/UPnPError/errorCode/3
            result/envelope/body/Fault/detail/UPnPError/errorDescription/3
            "(" soap-action ")"
        ]
    ]
    result
]


upnp-action: func [
    url [url! string!]
    service [block!]
    actionName [string!]
    argument [block!]
    /local port rule result RC body
][
    body: copy ""
    foreach [name value] argument [
        repend body [
            tab tab tab {<} name {>} value {</} name {>} crlf
        ]
    ]
    body: rejoin [
        {<s:Envelope} crlf
        tab {xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"} crlf
        tab {s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"} crlf
        {>} crlf
        tab {<s:Body>} crlf
        tab tab {<u:} actionName { xmlns:u="} service/serviceType/3 {">} crlf
        body
        tab tab {</u:} actionName {">} crlf
        tab {</s:Body>} crlf
        {</s:Envelope>} crlf
    ]
    result: upnp-invoke rejoin [url service/controlURL/3] rejoin [service/serviceType/3 "#" actionName] body
    argument: copy []
    foreach [item1 item2] at result/envelope/body/(to-word rejoin [actionName 'Response]) 3 [
        repend argument [to-word to-string item2/1 item2/3]
    ]
    new-line/all/skip argument true 2
]

upnp-query: func [
    url [url! string!]
    service [block!]
    varName [string! word!]
    /local port rule result RC body
][
    print body: rejoin [
        {<s:Envelope} crlf
        tab {xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"} crlf
        tab {s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"} crlf
        {>} crlf
        tab {<s:Body>} crlf
        tab tab {<u:QueryStateVariable xmlns:u="urn:schemas-upnp-org:control-1-0">} crlf
        tab tab tab {<u:varName>} varName {</u:varName>} crlf
        tab tab {</u:QueryStateVariable">} crlf
        tab {</s:Body>} crlf
        {</s:Envelope>} crlf
    ]
    result: upnp-invoke rejoin [url service/controlURL/3] "urn:schemas-upnp-org:control-1-0#QueryStateVariable" body
    result/envelope/body/QueryStateVariableResponse/return/3
]

; *********************************************************
; IGD Utility
; *********************************************************

igd-GetExternalIPAdress: func [
    {Retrieve the value of the external IP address on this connection instance.}
    url [url! string!] "URL Base"
    service [block!] "UPnP Service"
    /local
][
    to-tuple second upnp-action url service "GetExternalIPAddress" []
]

igd-GetGenericPortMappingEntry: func [
    {
    Retrieve NAT port mappings one entry at a time.
    Control points can call this action with an incrementing array index until no more entries are found on the gateway.
    }
    url [url! string!] "URL Base"
    service [block!] "UPnP Service"
    index [integer!]
    /all {Return all port mapping starting at index}
    /local result item
][
    either all [
        result: copy []
        while [attempt [
            item: upnp-action url service "GetGenericPortMappingEntry" compose [
                NewPortMappingIndex (index)
            ]
        ]][
            append result compose/only [(item)]
            index: index + 1
        ]
        result
    ][
        upnp-action url service "GetGenericPortMappingEntry" compose [
            NewPortMappingIndex (index)
        ]
    ]
]

igd-GetSpecificPortMappingEntry: func [
    {Reports the Static Port Mapping specified by the unique tuple of RemoteHost, ExternalPort and PortMappingProtocol.}
    url [url! string!] "URL Base"
    service [block!] "UPnP Service"
    remote-host [tuple! none!]
    external-port [integer!]
    protocol [word! string!]
    /local
][
    upnp-action url service "GetSpecificPortMappingEntry" compose [
        NewRemoteHost (either remote-host [remote-host][""])
        NewExternalPort (external-port)
        NewProtocol (protocol)
    ]
]

igd-AddPortMapping: func [
    {Creates a new port mapping or overwrites an existing mapping with the same internal client}
    url [url! string!] "URL Base"
    service [block!] "UPnP Service"
    remote-host [tuple! none!]
    external-port [integer!]
    protocol [word! string!]
    internal-port [integer!]
    internal-client [tuple!]
    enabled [integer!]
    description [string!]
    lease-duration [integer!]
    /local
][
    attempt [upnp-action url service "AddPortMapping" compose [
        NewRemoteHost (either remote-host [remote-host][""])
        NewExternalPort (external-port)
        NewProtocol (protocol)
        NewInternalPort (internal-port)
        NewInternalClient (internal-client)
        NewEnabled (enabled)
        NewPortMappingDescription (description)
        NewLeaseDuration (lease-duration)
    ]]
]

igd-DeletePortMapping: func [
    {
    Delete a previously instantiated port mapping.
    As each entry is deleted, the array is compacted, and the evented variable PortMappingNumberOfEntries is decremented.
    }
    url [url! string!] "URL Base"
    service [block!] "UPnP Service"
    remote-host [tuple! none!]
    external-port [integer!]
    protocol [word! string!]
][
    upnp-action url service "DeletePortMapping" compose [
        NewRemoteHost (either remote-host [remote-host][""])
        NewExternalPort (external-port)
        NewProtocol (protocol)
    ]
]

; ***********************************************
; Testing script
; ***********************************************

print [newline "Starting test ..." newline]

r: ask "Searching for all root device (Y/N) ..."
if "Y" = r [either empty? root-device: upnp-search/all/type "upnp:rootdevice" [
    ask "No root device"
    quit
][
    save-xml as-binary z: "" root-device print z
]]

r: ask "Searching for first WANIPConnection service (Y/N) ..."
if "Y" = r [either root: select upnp-search/type "urn:schemas-upnp-org:service:WANIPConnection:1" 'root [
    service: root/device/devicelist/device/deviceList/device/serviceList/service
    print [
        "Found :" newline
        tab "url Base           :" root/urlBase/3 newline
        tab "friendly Name      :" root/device/friendlyName/3 newline
        tab "device Type        :" root/device/deviceType/3 newline
        tab "external IP Adress :" igd-GetExternalIPAdress root/urlBase/3 service newline
    ]
    r: ask "Searching for port mapping (Y/N) ..."
    if "Y" = r [
        print mold/only igd-GetGenericPortMappingEntry/all root/urlBase/3 service 0
    ]
    r: ask "Add & check new mapping port (Y/N) ..."
    if "Y" = r [
        igd-AddPortMapping root/urlBase/3 service none 88 'tcp 88 probe system/network/host-address 1 "test" 0
        print mold igd-GetSpecificPortMappingEntry root/urlBase/3 service none 88 'tcp
    ]
][
    print "No device"
]]
ask "Done (press Enter) ... "
