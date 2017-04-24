REBOL [
  name: "rem"
  title: "rem REBOL External Modules"
  purpose: "rem REBOL External Modules management, like gem in Ruby"
	author: "RedChronicle"
	url: http://www.red-chronicle.com
  file: %rem.r
  date: 08/07/2011
  version: 0.1.1
  history: [
    0.1.1 08/07/2011 {
    Turn into module and console.
    >> do %rem.r => just load the module
    >> rem => launch console
    Thanks to Didec
    }
    0.1.0 07/07/2011 "Creation of the program"
  ]
  scripts: [http://www.rebol.org/library/public/lds-local.r]
]

foreach script system/script/header/scripts [do script]

rem-ctx: context [
  debug: true
  version: system/script/header/version

  modules: [
    "LDAP"  ["LDAP protocol" "Softinnov" 'Web  http://softinnov.org/dl/ldap-protocol.r %ldap-protocol.r]
    "SQL-PROTOCOL"  ["SQL protocol" "Marco" 'LDS  "sql-protocol.r" %sql-protocol.r]
  ]  

  emit: func [msg] [
    print msg
	]
  
  console-help: {
REBOL External Modules
How to use it ?
Launch rem console, type rem in REBOL Console
>> rem 
Welcome to rem REBOL External Modules
rem>> help
Display this help

Help:
help : display Help
list : display REBOL external modules list
install : install an external module
  }
  
  list-modules: does [
    forskip modules 2 [
      emit rejoin [tab modules/1 tab " {" modules/2/1 "}"]
    ]
  ]
  
  install-module: func [module-name [string!]] [
    if none? module: select modules module-name [
      emit rejoin ["Module " module-name " not found !" newline "Please use : rem/list to get available modules."]
    ]
    switch module/3 [
      'LDS [      
      probe module/4
        s: lds/send-server 'get-script reduce [module/4]
        write module/5 s/data/script
        do module/5
      ]
      'Web [
        write module/5 read module/4
        do module/5
      ]
    ]
    emit rejoin [module-name " has been installed."]
  ]
  
  rules: [
    'install set value [string! | word!] (install-module to-string value) |
    'exit (break) |
    'quit (break) |
    'help (emit console-help) |
    'list (list-modules)
  ]
  
  execute: func [cmd [string!] /local res] [
    res: parse to-block cmd rules
    if not res [emit "Unknown command. Please type help to get some help about rem console."]
  ]
  
  run-console: does [
    emit join "rem Console - version " version
    forever [
      set/any 'err try [
        execute ask "rem>> "
      ]
      if error? get/any 'err [
        if debug [emit mold disarm err]
      ]
    ]
  ]
]

; la fonction de lancement
set 'rem does [
	rem-ctx/run-console
]