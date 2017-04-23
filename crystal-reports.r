REBOL [
    title:      "Crystal Reports"
    
    name:       'crystal-reports
    file:       %crystal-reports.r
    
    author:     "Christian Ensel"
    date:       6-Apr-2007
    version:    0.1.0
    
    purpose: {
        Provides a basic API to the Crystal-Report® report engine (crpe32.dll) to show, print and export reports.
        Allows for setting formulas and selection criteriae as well as passing parameters when launching reports.
    }  
    
    example: [
        open-report-engine
        ticket: none
        view center-face layout [
            btn "Öffne Report"    [all [none? ticket ticket: show-report/with/only %/C/Reuffel/Reporte/Explore.rpt ["Debugging" "True"] {{RechnungEF_txt.ADRESS_RKNR_KNR} = "24170"}]] 
            btn "Schließe Report" [close-report ticket ticket: none]
            btn "Ende" [unview/all]
            at 20x100 box black 800x600
        ]
        close-report-engine 
    ]
    
    exposes: [
        open-report-engine   "Opens the Crystal-Report® report engine."
        close-report-engine  "Closes the Crystal-Report® report engine."
        show-report          "Shows a Crystal-Report® report."
        print-report         "Prints a Crystal-Report® report."      
        launch-report        "Launches a Crystal-Report® report."
        close-report         "Close a Crystal-Report® report."                                                                                 
    ]
    needs:     [%crpe32.dll]    
    reference: [
        http://database.ittoolbox.com/groups/technical-functional/access-l/how2-generate-crystal-reports-353276#
        http://www.apostate.com/programming/vb-crpe.html
        file://localhost/C:/Reuffel/Reporte/VB_Report_Engine_API.pdf
        file://localhost/C:/Reuffel/Reporte/devmode.pdf
    ]
    
    library: [
        level:          'intermediate
        Platform:       'win
        type:           [module tool function]
        code:           'module
        domain:         [win-api database external-library printing visualization]
        license:        'BSD
        support:        none
        see-also:       none
        tested-under:   [view 1.3.2.3.1 on [WinXP] "CHE"]
    ]
    
    todo: {         
        - EXPORT-REPORT not implemented yet.
        - Utilize PEWINDOWOPTIONS and other options.
        - Refinements get complicated already, better dialect them.     
        - Dewierdify error handling.
    }
    history: [            
        6-Apr-2007 0.1.0 CHE "Initial version"
    ]
]

context [
    crpe32.dll: load/library %crpe32.dll

    &pe: [unchanged -1 sizeof [window_options 32]]              ;-- crpe32.DLL constants
                                                                                                                         
    &ws: [maximize 16777216 maximizebox 65536 sysmenu 524288]   ;-- These are alien to crpe32.dll, they belong to user32.dll. I need them here for PEOutputToWindow to open a maximized    
    &cw: [usedefault -2147483648]                               ;   window with system menu, miximise and close button.    
                                                                               
    PEWindowOptions: make struct! [                                                 
        StructSize            [short] ; initialize to &PE/SIZEOF/WINDOW_OPTIONS
        hasGroupTree          [short] 
        canDrillDown          [short] 
        hasNavigationControls [short] 
        hasCancelButton       [short] 
        hasPrintButton        [short] 
        hasExportButton       [short] 
        hasZoomControl        [short] 
        hasCloseButton        [short] 
        hasProgressControls   [short] 
        hasSearchButton       [short] 
        hasPrintSetupButton   [short] 
        hasRefreshButton      [short] 
        showToolbarTips       [short] ; Default is TRUE (*Show* tooltips on toolbar)
        showDocumentTips      [short] ; Default is FALSE (*Hide* tooltips on document)
        hasLaunchButton       [short]
    ] none
    
    PEOpenEngine:           make routine! [return: [short]] crpe32.dll "PEOpenEngine"
    PECloseEngine:          make routine! [] crpe32.dll "PECloseEngine"
    PEOpenPrintJob:         make routine! [report [string!] return: [short]] crpe32.dll "PEOpenPrintJob"
    PESetSelectionFormula:  make routine! [job [short] formula [string!] return: [short]] crpe32.dll "PESetSelectionFormula"
    PEClosePrintJob:        make routine! [job [short] return: [integer!]] crpe32.dll "PEClosePrintJob"   
    PEOutputToPrinter:      make routine! [job [short] copies [short] return: [integer!]] crpe32.dll "PEOutputToPrinter"
    PEOutputToWindow:       make routine! [job [short] title [string!] left [integer!] top [integer!] width [integer!] height [integer!] style [integer!] window [integer!] return: [integer!]] crpe32.dll "PEOutputToWindow"
    PEStartPrintJob:        make routine! [job [short] wait? [integer!] return: [short]] crpe32.dll "PEStartPrintJob"                               
    PEGetErrorCode:         make routine! [job [short] return: [short]] crpe32.dll "PEGetErrorCode"
    PEGetErrorText:         make routine! compose/deep [job [short] handle [struct! [value [integer!]]] length [struct! [value [integer!]]] return: [integer!]] crpe32.dll "PEGetErrorText"
    PEGetHandleString:      make routine! compose/deep [handle [integer!] buffer [string!] length [short] return: [integer!]] crpe32.dll "PEGetHandleString"
    PEEnableProgressDialog: make routine! [job [short] enable [integer!] return: [integer!]] crpe32.dll "PEEnableProgressDialog"
    PESetFormula:           make routine! [job [short] name [string!] formula [string!] return: [integer!]] crpe32.dll "PESetFormula" 
    
    
    ;----------------------------------------------- open/close-report-engine --
    ;
    report-error: func ["Opens the Crystal-Report® report engine." job [integer! none!] message [string!] /local code handle length error] [
        code: PEGetErrorCode any [job 0]
        handle: make struct! [value [integer!]] [0]
        length: make struct! [value [short]] [0]
        PEGetErrorText job handle length
        error: head change change/dup make string! length + 1 any [byte #"."] length "^@"
        PEGetHandleString handle/value error length/value
        throw make error! rejoin [message " (" code "): " trim/lines error]
    ]
    
    ;----------------------------------------------- open/close-report-engine --
    ;
    set 'open-report-engine  func ["Opens the Crystal-Report® report engine." ] [PEOpenEngine ]
    set 'close-report-engine func ["Closes the Crystal-Report® report engine."] [PECloseEngine]
    
    ;------------------------------------------------------------ show-report --
    ;
    set 'show-report func [
        "Shows a Crystal-Report® report." [catch]
        report [file!] "Report to show" 
        /only "Supplies a selection criteria." selection [string!]
        /with "Supplies a formula(s)." formulas [block!]
        /input "Supplies parameters." parameters [string!]
    ][
        launch-report/options 'show report reduce ['only selection 'with formulas 'input parameters]  
    ]
    
    ;----------------------------------------------------------- print-report --
    ;
    set 'print-report func [
        "Prints a Crystal-Report® report." [catch] 
        report [file!] "Report to print" 
        /only "Supplies a selection criteria." selection [string!]
        /with "Supplies a formula(s)." formulas [block!]
        /input "Supplies parameters." parameters [string!]
    ][
        launch-report/options 'print report reduce ['only selection 'with formulas 'input parameters]  
    ]
    
    ;---------------------------------------------------------- launch-report --
    ;
    set 'launch-report func [
        "Launches a Crystal-Report® report." [catch]
        action [word!] "One of 'SHOW, 'PRINT or 'EXPORT"  
        report [file!] "Report to launch"
        /only "Supplies selection formula(s)." selection [string!] 
        /with "Supplies formula(s)." formulas [block!]
        /input "Supplies parameters." parameters [string!]
        /title "Window title" window [string!]
        /options arguments [block!]
        /local job 
    ][
        if options [
            selection:  select arguments 'only
            formulas:   select arguments 'with
            parameters: select arguments 'input
        ]
        
        if zero? job: PEOpenPrintJob report: join to-local-file report #"^@" [ 
            crystal-error job "Error opening print job"
        ]
        
        foreach [name formula] any [formulas []] [
            if zero? PESetFormula job name formula [
                crystal-error job rejoi ["Error setting formula '" name "' to '" value "'"]
            ]    
        ]
        
        if selection [
            ;selection: join selection #"^@"
            if zero? PESetSelectionFormula job selection [
                crystal-error job "Error specifying selection formula"
            ]
        ]
    
        switch action [
            print [
                if zero? PEOutputToPrinter job 1  [
                    crystal-error job "Error outputting to printer"
                ]
            ]
            show [
                if zero? PEOutputToWindow job any [window system/script/parent/title "REBOL - Crystal-Reports® Report Engine"] &cw/usedefault &cw/usedefault &cw/usedefault &cw/usedefault &ws/maximize or &ws/maximizebox or &ws/sysmenu 0 [
                    crystal-error job "Error outputting to window" 
                ]
            ]
        ;   export [
        ;        Dim Options As PEExportOptions
        ;        Options.StructSize = Len(Options)
        ;        require PEGetExportOptions(iPrintJob, Options)
        ;        require PEExportTo(iPrintJob, Options)
        ;   ]
        ]
        
        if zero? PEStartPrintJob job 1 [
            crystal-error job "Error starting to print report"
        ]
        
        if action <> 'show [
            if zero? PEClosePrintJob job [
                crystal-error job "Error starting to print report"
            ]
        ]
        
        either action = 'show [job] [true]
    ]
    
    ;----------------------------------------------------------- close-report --
    ;
    set 'close-report func [job] [
        if zero? PEClosePrintJob job [
            crystal-error job "Error starting to print report"
        ]
    ] 

]



                  
