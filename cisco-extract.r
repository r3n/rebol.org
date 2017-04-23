REBOL [
    	File: %cisco-extract.r
    	Date: 15-June-2009
    	Title: "Cisco config to text file"
    	Purpose: {To read multiple Cisco IOS & CATOS files & create a summary of key information paticularly interface details}
		Use: {The script requests a selection of one or more input text files which should be any 
		      Cisco router or switch configuration files.
			  The script then requests an output file to which a set of tab separated fields will be appended
			  It is my intention to extend the capability of this script to read other sorts of Cisco output,
			  however the current script is very much a work in progress and is also the first thing I have written
			  in REBOL.}
		library: [
			level: 'intermediate
			platform: 'windows
			type: [tool]
			domain: [networking]
			tested-under: windows_XP
			support: none
			license: none
			see-also: none
		]
		History: {
			history 20-Apr-09 original concept version
			0.4.0 15-Jun-09 hsrp output switched on
			0.4.1 15-Jun-09 First published version
			0.4.2 03-Jul-09 HSRP group 0 fixed so HSRP default group 0 is now picked up.. debug code commented out too
			}
    	]

spacer: charset " ^/"
name-char: complement spacer
digit: charset [#"0" - #"9"]
alpha: charset [#"a" - #"z" #"A" - #"Z" ]
ipOnly: false                   ;; set to true if only interfaces with IP addresses are wanted.
kitten: false                   ;; if it is a cat, we set this to true, otherwise skip some routines
debug: false                    ;; controls various outputs

na: 1 us: 2 vl: 3                                    ;; shortcuts for na name us UpState vl vlan
ts: 4 sp: 5 du: 6                                    ;; ts trunkState sp Speed du duplex
maxArray: 6                                          ;; largest size of 3rd part of catos array
CatDat: array/initial reduce [15 50 :maxArray] ""    ;; create array up to 15 x 50 then one for each of the following
blank: array/initial reduce [maxArray] ""            ;; used for comparisons
warnings: ""                                         ;; print warnings at the end of the script

;; get hsrp info referenced in global QualifiedNetworkS related to loop-counter passed
getHsrp: func [count /local output][
	output: copy ""
	unless Kitten [      ;; dont look for HSRP on Catos devices as the data is never going to be there, no secondary addresses & no hsrp
	foreach grp QualifiedNetworkS/(count * 2) [
;;		print ["grp-->" grp]  ;; debug
;;		print reduce ["select->" grp select hsrp grp]  ;; debug this is what we want to print
		insert tail output reduce [grp ":" select hsrp grp]		
	] ]output
]

;; only function that writes to the output file for interface info & others (apart from header)
outInterface: func [] [ 
	if (((length? intIpaddrS) = 0) and (not ipOnly)) [   ;; only try to output IP int if it exists
		write/append outFile reduce[
			either debug [currentFile tab i tab] [""] 
			hostname 
			tab ipVrfForward 
			tab interface 
			tab vlan 
			tab mode 
			tab trunkEncap 
			tab nativeVlan 
			tab allowedVlans 
			tab upState 
			tab intDesc 
			tab speed 
			tab duplex newline]]
		
	repeat count1 (length? intIpaddrS) [                 ;; may be several ip addresses e.g. secondary addresses
		write/append outFile reduce[
			either debug [currentFile tab i tab] [""] 
			hostname 
			tab ipVrfForward 
			tab interface 
			tab vlan 
			tab mode 
			tab trunkEncap 
			tab nativeVlan 
			tab allowedVlans 
			tab upState 
			tab intDesc 
			tab speed 
			tab duplex 
			tab intIpaddrS/:count1 
			tab QualifiedNetworkS/((count1 * 2) - 1 ) 
			tab (getHsrp count1) 
			tab tagMtu newline
		]
	]
]

clearHsrp: does [
	hsrpGrp: copy "" hsrpIP: copy "" hsrpPri: copy "" hsrpTrk: copy "" hsrpName: copy ""
]

;; empty variables used for colecting details
clearInterface: does [
	interface:    copy []
	intDesc:      copy []
	intIpaddr:    copy []
	intIpaddrs:   copy []
	network:      copy []
	QualifiedNetwork:  copy []
	QualifiedNetworkS: copy []
	upState:      copy []
	vlan:         copy []
	tagMtu:       copy []
	mode:         copy []        
	trunkEncap:   copy []  
	nativeVlan:   copy []  
	allowedVlans: copy []
	ipVrfForward: copy []
	speed:        copy []
	duplex:       copy []
	hsrp:         copy []
	clearHsrp
]

;; #################### Supporting functions ####################
;; Generate all IPv4 dotted decimal masks in a block of tuples
allMasks: has [t i allMasks][
	allMasks: [255.255.255.255] t: 255.255.255.255
	if allMasks = [255.255.255.255] [
		for count1 4 1 ( - 1) [ 
			i: 1
			loop 8[
				t/:count1: 256 - i: i + i 
				insert tail allMasks t
			]
		]
	] allmasks
]
;foreach x allmasks [print x]  ;; function-test

;; calculate block of all networks that this ip address could be in
networks: func [ipPassed /local networks i ip][
	ip: to-tuple ipPassed                  ;; in case there is a string passed (which there often is)
	i: 32  networks: copy []
	foreach mask allMasks [
		insert tail networks rejoin[(ip and mask) "/" i]
		i: i - 1
	] networks
]
;networks 172.19.60.172                          ;; function-test
;foreach net networks 172.19.60.172 [print net]  ;; function-test

;; #################### Parse rules ####################
commentRule: [["!" skip to end]]   ;; ignore comments

;; matches a simple string, then does all the stuff we need to do with the interface details
interfaceRule: [ ["interface " h: alpha :h copy temp-interface to end] (  ;;   interface must be followed by only 1 space before letter that starts interface name  
		if IntFlag [outInterface]                   ;; this is the start of a new interface section so we output data collected previously.
		clearInterface                              ;; clear colection variables used with previous int & also may have found coincidental data not in an interface section
		interface: first parse temp-interface none  ;; just first word if more than one so avoid collecting "point to point"
		parse/all interface [any[["Vlan" copy vlan to end] | skip]]     ;; extract vlan number from vlan interface  
;		print["from--" interface "to--" (probe vlan)]                   ;; debug
		IntFlag: true
	)
]

descRule: [ [" description " copy intDesc to end] ]   ;; copy the text from the interface description

;; finds 2 tuples on a line and sets global variables addr & mask for them
to-IpBlock: func [str] [
	parse to-block str [
		(addr: copy [] mask: copy [])
		any [
			set tup tuple! (addr: tup) break
			| skip
		]
		any [
			set tup tuple! (mask: tup) break
		| skip
		]
	]
]

;; this relies on only being passed valid masks ie it will resolve 255.0.123.0 too
to-maskLength: func [mask] [                          ;; we pass the mask to this function  
	ml: func [int][round 8 - (log-2 (256 - int))]     ;; this function is called later to calculate lenth of each octet of the mask
	MaskLength: 0                                     ;; start at zero
	repeat count2 4 [MaskLength: MaskLength + (ml (mask/:count2))]   ;; do it 4 times  (((  cause evaluation of commands within
]

ipAddrRule: [[" ip address " copy intIpaddr to end] (           ;; ip address within interface section is found
		to-IpBlock intIpaddr                                    ;; extract address & mask from intIpaddr, sets global addr & mask 
		if ((tuple? addr) = true) and ((tuple? mask) = true) [  ;; calculate network if we have 2 tuples
			network: (addr and mask)                            ;; easy!
			MaskLength: to-maskLength mask                      ;; calculate mask length with function above
			QualifiedNetwork: rejoin [network "/" MaskLength]   ;; This is the bit we are after, store in the format x.x.x.x/n
		]
		;; found addresses needs adding to a global block as there may be several per interface
		insert intIpaddrS intIpaddr  reduce
		insert QualifiedNetworkS copy/deep reduce [QualifiedNetwork[]]
;;		probe QualifiedNetworkS   ;; debug
		intIpaddr: copy [] QualifiedNetwork: copy []             ;; local addres vars must be cleared
	)
]

;; references global hsrp & changes global QualifiedNetworkS to add reference to hsrp group
insertHsrp: func [hsrpGrp /local a hsrpTarget i][
	hsrpTarget: reduce [hsrpGrp select hsrp hsrpGrp]       ;; local copy of hsrp details we are dealing with
	foreach net networks hsrpTarget/2/1 [                  ;; for each network this hsrp address could be in
		a: find QualifiedNetworkS net                      ;; try to find it so we can establish the position
		unless none? a [                                   ;; no good trying to extract index? from none
			i: index? a                                    ;; get the position of the inteface network
			insert tail QualifiedNetworkS/(i + 1) hsrpTarget/1  ;; put the hsrpTarget group number into the QualifiedNetworkS list
		]
	]
]

;; if hsrpGrp is set add hsrp details to global hsrp & call insertHsrp then clearHsrp
outHsrp: does [
	unless (hsrpGrp = "" ) [
		insert hsrp compose/deep [(hsrpGrp)[ (hsrpIP) (hsrpPri) (hsrpName) (hsrpTrk)] ] ;; put the details in hsrp
;;		print reduce [hsrpGrp select hsrp hsrpGrp]  ;; debug show details for just this group
		insertHsrp hsrpGrp  ;; insert group number in global QualifiedNetworkS so it can reference hrsrp when outputting 
		clearHsrp           ;; 
	]
]

NonZeroGroup: [any[1 3 digit " "]] ;; this allows for zero group which is implied by its absence
hsrpRule: [
	[[" standby " h1: NonZeroGroup :h1 copy hsrpGrpTmp to "ip " "ip " copy hsrpIPTmp to end] (
		outHsrp                                                  ;; store last values as ip is always first except for secondary addresses
		if (find hsrpIPTmp "secondary") [
			append warnings reduce["HSRP contains UNEXPECTED secondary addressing at line " i " for " hostname " hsrp " hsrpGrpTmp " "  hsrpIPTmp newline]
			hsrpIPTmp: first parse hsrpIPTmp none  ;; get just the first part containing the IP address so the script does not crash
		]
		if (none? hsrpGrpTmp) [hsrpGrpTmp: "0"]                  ;; the zero group number case (made as string to be like the others)
		trim hsrpGrpTmp                                          ;; because the zero case has no trailing space we have to trim it from all thr others.
;;		print rejoin[ "-->|" hsrpGrpTmp "|<-- stan:-" h1]        ;; debug
		hsrpGrp: to-integer hsrpGrpTmp hsrpIP: copy hsrpIPTmp    ;; 
	)]
	| [[" standby " h1: NonZeroGroup "priority " copy hsrpPriTmp to end] (hsrpPri: copy hsrpPriTmp) ]
	| [[" standby " h1: NonZeroGroup "name " copy hsrpNameTmp to end] (hsrpName: copy hsrpNameTmp) ]
	| [[" standby " h1: NonZeroGroup "track " copy hsrpTrkTmp to end] (hsrpTrk: copy hsrpTrkTmp) ]
]


;; Problem. default group has no digit  part & one less space 0 3 digit any " " so zero group gets mangled.
hsrpRule_Buggy: [
	[[" standby " h1: 1 3 digit " " :h1 copy hsrpGrpTmp to " ip " " ip " copy hsrpIPTmp to end] (
		outHsrp                                                  ;; store last values as ip is always first except for secondary addresses
		if (find hsrpIPTmp "secondary") [
			append warnings reduce["HSRP contains UNEXPECTED secondary addressing at line " i " for " hostname " hsrp " hsrpGrpTmp " "  hsrpIPTmp newline]
			hsrpIPTmp: first parse hsrpIPTmp none  ;; get just the first part containing the IP address so the script does not crash
		]
		hsrpGrp: to-integer hsrpGrpTmp hsrpIP: copy hsrpIPTmp    ;; 
	)]
	| [[" standby " h1: 1 3 digit " priority " copy hsrpPriTmp to end] (hsrpPri: copy hsrpPriTmp) ]
	| [[" standby " h1: 1 3 digit " name " copy hsrpNameTmp to end] (hsrpName: copy hsrpNameTmp) ]
	| [[" standby " h1: 1 3 digit " track " copy hsrpTrkTmp to end] (hsrpTrk: copy hsrpTrkTmp) ]
]


RouterVlanRule: [ [" encapsulation dot1Q " copy vlan to end] ]

IpAddrRuleFunc: func [CatInt] [                                   ;; function used to extract the addresses from catos managemeent interface
	CatIntAddressAndMask: replace  temp-interface "/" " "         ;; replace  /   as format is sometimes addr/mask broadcast 
	to-IpBlock CatIntAddressAndMask                               ;; same function called as used by IOS.. sets globals for addr & mask 
	if ((tuple? addr) = true) and ((tuple? mask) = true) [        ;; calculate network if we have 2 tupless
		network: (addr and mask)                                  ;; easy!
		MaskLength: to-maskLength mask                            ;; calculate mask length with function above
		QualifiedNetwork: rejoin [network "/" MaskLength]         ;; This is the bit we are after, store in the format x.x.x.x/n
	]
	interface: copy CatInt                                ;; this rule currently dedicated to sc0 & 1 because other interfaces have different formats
	insert intIpaddrS CatIntAddressAndMask                ;; could probably be just an assignment as catos interfaces probably dont support secondary addressing.
	insert QualifiedNetworkS QualifiedNetwork             ;; as above
]

CatIpAddrRule: [ 
	[  "set interface sc0 " 1 3 digit " " copy temp-interface to end]   (IpAddrRuleFunc "sc0" )   ;; sc ints have a number after the interface 
	| ["set interface sc1 " 1 3 digit " " copy temp-interface to end]    (IpAddrRuleFunc "sc1")
	| ["set interface sl0 " here: digit :here copy temp-interface to end]  (IpAddrRuleFunc "sl0") ;; digit is start of IP address
	| ["set interface me1 " here: digit :here copy temp-interface to end]  (IpAddrRuleFunc "me1")
	| [
		["set interface sc0 " copy temp-interface to end]        ;; we are able to do this because the up/down admin state of the interface is defined after  
		| ["set interface sc1 " copy temp-interface to end]      ;; the line containing the IP address & mask.
		| ["set interface sl0 " copy temp-interface to end]
		| ["set interface me1 " copy temp-interface to end]
	](
		upState: temp-interface    ;; stores the actual string from the line
		outInterface               ;; last line in int sc0 etc. interface section so output data collected
		clearInterface             ;; clear variables used to store interface data
	)
]

hostnameRule: [["hostname " copy hostname to end] ]                     ;; for IOS

CatHostnameRule: [["set prompt " copy hostname to end (kitten: true)]]  ;; for CATOS (prompt may have # on the end) systemname is not the same.

SpeedRule: [[" speed " copy speed to end]]                              ;; IOS interface speed - default is auto & not shown

CatSpeedRangeRule: [["set port speed " h: 1 7 " " digit (catSpeedRange: h)] 
(
;;		print reduce ["speedRange-" catSpeedRange]          ;; debug
		speed: last  parse/all catSpeedRange " "             ;; get the last bit which is the speed
		catSpeedRange:   first parse/all catSpeedRange " "   ;; first bit is the range
		split-ranges catSpeedRange speed sp        ;;  again the range is passed to the function  split-range
	)
]

DuplexRule: [[" duplex " copy duplex to end] | [" full-duplex"] (duplex: copy "full") ]      ;; IOS interface duplex - default is auto & not shown

CatDuplexRangeRule: [["set port duplex " h: 1 7 " " digit (CatDuplexRange: h)] 
(
;;		print reduce ["DuplexRange-" CatDuplexRange]          ;; debug
		speed: last  parse/all CatDuplexRange " "             ;; get the last bit which is the speed
		CatDuplexRange:  first parse/all CatDuplexRange " "   ;; first bit is the range
		split-ranges CatDuplexRange speed du        ;;  again the range is passed to the function  split-range
	)
]

shutdownRule: [copy UpState [" shutdown" to end] ]                   ;; IOS interface shutdown

vlanRule: [ [" switchport access vlan " copy vlan to end] ]          ;;  IOS Switchport vlan

tagMtuRule: [ [" tag-switching mtu " copy tagMtu to end] ]           ;; IOS  imtu specified if underlying mtu is less than required, this may reperent misconfiguration

ipVrfForwardRule: [[" ip vrf forwarding " copy ipVrfForward to end]] ;; IOS interface ip vrf name

iprouteRule: [copy iproute ["ip route " to end] ]                     ;; Not yet output as I dont know how to format it. also need to extract vrf name

modeRule:           [[" switchport mode "                 copy mode         to end]]  ;; more switchport details, usefull for checking interface consistency

CatTrunkRule: [["set trunk " h: 1 2 digit "/" 1 2 digit :h copy TrunkPortState to end]  ;; trunk setting follows port number eg "2/34 auto ..."
(
;		print reduce [TrunkPortState]        ;; debug 
		set [m p] parse (first parse TrunkPortState none) "/"   ;; extract elements of module & port only needed for name
		m: to-integer m    p: to-integer p                   ;; type conversion
;		print reduce ["~~>" catDat/:m/:p/:ts]      ;; debug
		catDat/:m/:p/:ts:  copy trim find trunkportstate " "      ;; store the detail in the array for trunk state
	)
]

trunkEncapRule:     [[" switchport trunk encapsulation "  copy trunkEncap   to end]]

nativeVlanRule:     [[" switchport trunk native vlan "    copy nativeVlan   to end]]

allowedVlansRule:   [[" switchport trunk allowed vlan "   copy allowedVlans to end]]


expandRange: func [range detail position][   ;; CATOS ranges are expanded eg 1/2-5  becomes  1/2 1/3 1/4 1/5   -- detail is passed through several functions to get here. it wil be disabled or the vlan number etc.
	parse range [
		any [
			copy modu module #"/" copy start module (endRange: copy start) any [  ;; parse to find aa/bb-cc  modu/ start-endRange  
				#"-" copy endRange module                                         ;; or aa/bb  then end is the same as start
			] (
				for count3 (to-integer start) (to-integer endRange) 1 [           ;; this is the range we extracted for the ports
					m: to-integer modu  p: count3                        ;; for clarity & type conversion
					catDat/:m/:p/:position: copy detail       ;; store detail for UpState in array
			    ]
			)
		]
	]
] 

;; this outputs 1/2  then 1/3-5 etc
split-ranges: func [ranges detail position][                               ;; input e.g   2/4-6,2/13-14   disable
	module: [1 2 digit]                                           ;; any 2 digits
	portOrRange: [1 2 digit opt ["-" 1 2 digit]]                  ;;  22 or 22-33
	target: [module #"/" portOrRange]                             ;; aa/bb-cc  or aa/bb
	parse/all ranges [any [copy range target (expandRange range detail position) | skip]]   ;; sends each range to the expandRange function
]

CatPortNameRule: [["set port name" 1 8 " "  h: 1 2 digit "/" 1 2 digit " " :h copy CatPortName to end]  ;; names follow port number eg "2/34 string 1"
(
;		print reduce [CatPortName]        ;; debug 
		set [m p] parse (first parse CatPortName none) "/"   ;; extract elements of module & port only needed for name
		m: to-integer m    p: to-integer p                   ;; type conversion
		catDat/:m/:p/:na: next (parse CatPortName none)      ;; store the detail in the array for name
	)
]

CatDisableRangeRule: [["set port disable" copy CatDisableRange to end] 
(
;;		print reduce ["Disa-" CatDisableRange]  ;; debug
		split-ranges CatDisableRange "disable" us    ;; the range is passed to the function  split-ranges
	)
]

CatVlanRangeRule: [["set vlan " h: 1 5 digit 1 4 " " digit (catVlanRange: h)] 
(
;;		print reduce ["vlan-" catVlanRange]          ;; debug
		vlanNumber: first  parse catVlanRange none
		split-ranges catVlanRange vlanNumber vl        ;;  again the range is passed to the function  split-range
	)
]

IntFlagRule: [copy tempZZ [name-char to end] ( ;; not space or newline. this must be out of the IOS int section
		if IntFlag [
			outHsrp
			outInterface              ;; end of interface section so output data collected.
			clearInterface
		]              ;; clear variables used to store interface info
		IntFlag: false                         ;; no longer in an interface sub section 
	)
]

;; ################### script execution starts here ######################

;; generic
;;files: request-file/title {Select all files to read} {x}                         ;; get list of files to open
;;outFile: to-file request-file/title {File to which output will be appended} {x}  ;; get file to send output to

;files: request-file/title/file/filter {Select all files to read} {x} %/C/Temp/ "*"     ;; get list of files to open
;outFile: to-file request-file/title/file/save {File to which output will be appended} {x} %/C/Temp/!conf/RebolOut/  ;; get file to send output to

;; Work PC
files: request-file/title/file/filter {Select all files to read} {x} %/C/Temp/!conf/ "*.txt"     ;; get list of files to open
outFile: to-file request-file/title/file/save {File to which output will be appended} {x} %/C/Temp/!conf/RebolOut/  ;; get file to send output to

;; Home PC ones
;;files: request-file/title/file/filter {Select all files to read} {x} %/D/Rebol/X/!conf/ "*.txt"
;;outFile: to-file request-file/title/file/save {File to which output will be appended} {x} %/D/Rebol/X/

;; write header to file when first run
write/append outFile reduce [ either debug ["File" tab "Line" tab] [""] "hostname" tab "ip vrf" tab "interface" tab "vlan" tab "mode" tab "trunk encapsulation" tab "native vlan" tab "allowed vlans" tab "upState" tab "Description or name" tab "speed" tab "duplex" tab "ip address & mask" tab "network" tab "hsrp" tab "mpls mtu" newline]

foreach filename files [
	lines: read/lines filename        ;; read the file line by line to variable called lines
	currentFile: filename             ;; foreach context is local so copy file name for output later
	prin reduce ["Processing: " currentFile " "]   ;; show progress by printing the filename
	hostname: copy []                 ;; copy [] to variables used to record details
	clearInterface                    ;; clear all the variables used collecting interface details
	IntFlag: false

	i: 0
	foreach line lines [i: i + 1 ;; move through lines & track line number
		current-line: line       ;; for debug output as line is local
;;		print line  ;; debug verbose
		parse/all line [         ;; parse only using rules below
			commentRule          ;; ignoe all after !
			| interfaceRule      ;; evaluated if "interface" found preceeded by nothing else this is for IOS
			| descRule           ;; evaluate if " desc" found preceeded by nothing else (IOS)
			| ipAddrRule         ;; " ip address"
			| hsrpRule           ;; " ip address"
			| routerVlanRule     ;; " encapsulation dot1Q "
			| CatIpAddrRule      ;; "set interface Sc0" then ip follows or up/down admin setting
			| hostnameRule       ;; " hostname"
			| CatHostnameRule    ;; " hostname (prompt) from catos"
			| speedRule          ;; " speed" for IOS interfaces, sets Speed with string
			| CatSpeedRangeRule  ;; "set port speed      3/3-16,3/19,3/26,3/29-32  auto" sets Speed with string
			| duplexRule         ;; " speed" for IOS interfaces, sets Speed with string
			| CatDuplexRangeRule ;; "set port speed      3/3-16,3/19,3/26,3/29-32  auto" sets Speed with string
			| shutdownRule       ;; " shutdown" for IOS interfaces, sets UpState with string
			| vlanRule           ;; " switchport access vlan "
			| tagMtuRule         ;; "tag-switching mtu"
			| ipVrfForwardRule   ;; " ip vrf forwarding "
			| iprouteRule        ;; "ip route"
			| modeRule           ;; " switchport mode "
			| CatTrunkRule       ;; "set trunk 1/2  on dot1q 1-1005,1025-4094"
								 ;; "set trunk 2/3  auto dot1q 1-1005"
			| trunkEncapRule     ;; " switchport trunk encapsulation "
			| nativeVlanRule     ;; " switchport trunk native vlan "
			| allowedVlansRule   ;; " switchport trunk allowed vlan "
			| CatPortNameRule     ;; "set port name       2/10 C"
			| CatDisableRangeRule ;;  UpState
			| CatVlanRangeRule   ;; "set vlan " h: 1 5 digit " " digit :h copy catVlanRange to end ;; 
			| IntFlagRule        ;; no longer in interface section (no " ^/") MUST BE LAST in IOS interface rules because it eats everything
		] 
	] print reduce [" Fin" ]     ;; print at the end of processing each file

	if kitten [                  ;; logical kiten if we have been processing a catos switch config we do this bit to output data
		for mm 1 15 1 [                                  ;; mm for each module
			for pp 1 50 1 [                              ;; pp for each port
				unless (catdat/:mm/:pp = blank)[         ;; compare with array that is blank so we dont output unused parts of the array
;;					print rejoin[mm "/" pp tab catdat/:mm/:pp/:na tab catdat/:mm/:pp/:us tab catdat/:mm/:pp/:vl]     ;; debug
					interface: rejoin[mm "/" pp]         ;; the module & port are also the path to the data stored about themselves
					vlan: catdat/:mm/:pp/:vl             ;; vlan data :vl returns the value of vl so accesses the array element for vlan
					mode: catdat/:mm/:pp/:ts			 ;; trunkState is near to mode. maybe refine later
					upState: catdat/:mm/:pp/:us          ;; upState
					intDesc: catdat/:mm/:pp/:na          ;; name
					speed: catdat/:mm/:pp/:sp            ;; name
					duplex: catdat/:mm/:pp/:du           ;; name
					outInterface                         ;; calls my function above to write the data collected to our file
					interface: copy []                   ;; clear the variables
					mode:      copy []
					vlan:      copy []
					upState:   copy []
					intDesc:   copy []
					
				]
			]
		]
		CatDat: array/initial reduce[15 50 maxArray] ""            ;; clear array
		kitten: false                                 ;; we skip the above if not a catos config 
	]
]
print warnings
halt

;; ################################# End of script ##################################################

;; to do
;; Un-numbered addresses dont show loopback used
;
;; descriptions starting with "-" can confuse Excel
;;
;; ~span tree, portfast etc.
;; IP address is always first unless there is an error & no IP is specified
;; 
;; proxy-arp
;; port channel ~how does this work on CATOS~
;; UDLD
;;  what is this " delay 5"  on ios interface

;; add search function to find all networks matching IP address down to 8 bits
;; I want it read the static routes too, but I dont know where to put it in the spreadsheet.
;; read ip int brief & sh cdp nei
;; progress indicator

;secondary hsrp addressing is not catered for (script ptoduces a warning)
