REBOL [ 
 Title: "Unit converter"
 Author: "Massimiliano Vessi"
 Email: maxint@tiscali.it
 Date: 19-Jun-2009 
 version: 1.4.14
 file: %convertitore.r
 Purpose: {"The best unit converter on earth!"}
 
 ;following data are for www.rebol.org library
 ;you can find a lot of rebol script there
 library: [ 
           level: 'beginner 
           platform: 'all 
           type: [tutorial tool] 
           domain: [scientific vid gui] 
           tested-under: [windows linux] 
           support: none 
           license: [gpl] 
           see-also: none 
          ] 
]

header-script: system/script/header

version: "Version: "
append version header-script/version

; We initially set how many digits show
decimali: 0.001       
       
; We define a function to round the values to the specified digits
troncare: func [ misura2 ]
   [
   esatto: round/to misura2 decimali
   return esatto
   ]

; Function to convert in Meter all the leght values and then reconvert all the
; other values


inmetri:  func [ misura  unit ]
   [   
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "Metri" [ conv: 1 ]
   if unit = "cm" [ conv: 0.01]
   if unit = "mm" [conv: 0.001 ]
   if unit = "Pollici" [conv: 0.0254 ] 
   if unit = "Piedi" [ conv: 0.3048 ]
   if unit = "Yards" [ conv: 0.9144 ]
   if unit = "Miglia" [ conv: 1609.344 ]
   if unit = "micron" [ conv: 1e-6 ]

   SImetri: misura * conv
   metri/text: troncare SImetri
   cm/text: troncare ( SImetri * 100 )
   mm/text: troncare ( SImetri * 1000 )
   pollici/text: troncare ( SImetri / 0.0254 )
   piedi/text: troncare ( SImetri / 0.3048 )
   yards/text: troncare ( SImetri / 0.9144 )
   miglia/text: troncare ( SImetri / 1609.344 )
   micron/text: troncare ( SImetri / 1e-6 )
   set-face pannelli []
   ]

; Function to convert in Square Meter all the surface values and then reconvert
; all the other values
inmetri2:  func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "metri2" [ conv: 1 ]
   if unit = "dm2" [conv: 0.01]
   if unit = "cm2" [conv: 0.0001]
   if unit = "mm2" [conv: 1e-6 ]
   if unit = "acres" [conv: 4046.856 ] 
   if unit = "ettari" [ conv: 10000 ]
   if unit = "inches2" [ conv: 0.000645 ]
   if unit = "feet2" [ conv: 9.29030435966113E-2 ]
   if unit = "miles2" [ conv: 2589988 ]
   if unit = "yards2" [ conv: 0.836127 ]
   SImetri: misura * conv
   metri2/text: SImetri
   dm2/text: troncare do [SImetri / 1e-2 ]
   cm2/text: troncare do [SImetri / 1e-4 ]
   mm2/text: troncare do [SImetri / 1e-6 ]
   acres/text: troncare do [ SImetri / 4046.856 ]
   ettari/text: troncare do [ SImetri / 10000 ]
   inches2/text: troncare do [ SImetri / 0.000645 ]
   feet2/text: troncare do [ SImetri / 9.29030435966113E-2 ]
   miles2/text: troncare do [ SImetri / 2589988 ]
   yards2/text: troncare do [ SImetri / 0.83617 ]
   set-face pannelli []
   ]


; Function to convert in Cubic Meter all the volume values and then reconvert
; all the other values   
inmetri3:  func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "metri3" [ conv: 1 ]
    if unit = "dm3" [ conv: 0.001 ]
     if unit = "cm3" [ conv: 0.000001 ]
   if unit = "liters" [conv: 0.001 ] 
    if unit = "cl" [ conv: 0.00001 ]
     if unit = "ml" [ conv: 0.000001 ]
   if unit = "feet3" [ conv: 0.028317 ]
   if unit = "inch3" [ conv: 0.000016 ]
   if unit = "cups" [ conv: 0.000237 ]
   if unit = "gallonsUK" [ conv: 0.004546 ]
   if unit = "gallonsUSA" [ conv:  0.003785411784]
   if unit = "pints" [ conv: 0.000568 ]
   if unit = "quarts" [ conv: 0.001137 ]
   if unit = "tablespoons" [ conv: 0.000015 ]
   if unit = "teaspoons" [ conv: 0.000005 ]
   if unit = "onces" [ conv: 0.000028 ]
   SImetri: misura * conv
   metri3/text: SImetri
   dm3/text: troncare do [ SImetri / 0.001 ]
      cm3/text: troncare do [ SImetri / 0.000001 ]
   liters/text: troncare do [ SImetri / 0.001 ]
      cl/text: troncare do [ SImetri / 0.00001 ]
      ml/text: troncare do [ SImetri / 0.000001 ]
   feet3/text: troncare do [ SImetri / 0.028317 ]
   inch3/text: troncare do [ SImetri / 0.000016 ]
   cups/text: troncare do [ SImetri / 0.000237 ]
   gallonsUK/text: troncare do [ SImetri / 0.004546 ]
   gallonsUSA/text: troncare do [ SImetri /  0.003785411784 ]
   pints/text: troncare do [ SImetri / 0.000568 ]
   quarts/text: troncare do [ SImetri / 0.001137 ]
   tablespoons/text: troncare do [ SImetri / 0.000015 ]
   teaspoons/text: troncare do [ SImetri / 0.000005 ]
   onces/text: troncare do [SImetri / 0.000028]
   set-face pannelli []
   ]
   
; Function to convert in Kilos all the weight values and then reconvert
; all the other values      
inkilos:  func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "kg" [ conv: 1 ]
	if unit = "g" [conv: 0.001]
   if unit = "carats" [conv: 0.0002 ] 
   if unit = "grains" [ conv: 0.000065 ]
   if unit = "ounces" [ conv: 0.02835]
   if unit = "pounds" [ conv: 0.4536 ]
   if unit = "tons" [ conv: 1016.046909 ]
   SI: misura * conv
   kg/text:  SI
	g/text: troncare do [si / 0.001 ]
   carats/text: troncare do [ SI / 0.0002 ]
   grains/text: troncare do [ SI / 0.000065 ]
   ounces/text: troncare  do [ SI / 0.02835 ]
   pounds/text: troncare do [ SI / 0.4536 ]
   tons/text: troncare do [ SI / 1016.046909 ]
   set-face pannelli []
   ]
   

; Function to convert in Kelvin all the Temperature values and then reconvert
; all the other values 
inkelvin:  func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "celsius" [ SI: misura + 273.15 
                         conv: 1 ]
   if unit = "kelvin" [SI: misura ] 
   if unit = "far" [ SI: ( ( misura - 32)  * 5 / 9 ) + 273.15 ]
   kelvin/text:  troncare SI
   celsius/text: troncare do [ SI - 273.15  ]
   far/text: troncare do [  ( SI - 273.15 ) *  9 / 5  + 32  ]
   if SI < 0 [alert "IMPOSSIBLE! TEMPERATURE BELOW ABSOLUTE ZERO!"]
   set-face pannelli []
   ]

; Function to convert in Pascal all the pressure values and then reconvert
; all the other values 

inpascal: func [misura unit]
  [
  if (misura = none) or (misura = "" ) [misura: 0 ]
  conv: 0
  misura: to-decimal misura
  if unit = "pascal" [ conv: 1]
  if unit = "kpascal" [ conv: 1000]
  if unit = "Mpascal" [conv: 1000000]
  if unit = "atm" [conv: 101325]
  if unit = "bar" [conv: 100000]
  if unit = "mbar" [conv: 100]
  if unit = "inHg" [conv: 3386.388]
  if unit = "inW" [conv: 249.08891]
  if unit = "feetW" [conv: 2989.06692]
  if unit = "psi" [conv: 6894.757]
  if unit = "mW" [conv: 9806.22552]
  if unit = "mmHg" [conv: 133.2320229]
  if unit = "mmW"  [conv: 9.806]
  if unit = "kgcm2" [conv: 98066.5]
  SI: misura * conv
  pascal/text: troncare SI
  kpascal/text: troncare (SI / 1000)
  Mpascal/text: troncare (SI /  1000000 )
  atm/text: troncare ( SI / 101325 )
  bar/text: troncare ( SI / 100000 )
  mbar/text: troncare ( SI / 100 )
  inHg/text: troncare (SI / 3386.388 )
  inW/text: troncare (SI / 249.08891)
  feetW/text: troncare (SI / 2989.06692)
  psi/text: troncare (SI / 6894.757)
  mW/text: troncare (SI / 9806.22552)
  mmHg/text: troncare (SI / 133.2320229)
  mmW/text: troncare (SI / 9.806)
  kgcm2/text: troncare (SI / 98066.5)
  set-face pannelli []
]



;Every time user clicks on a dimension the right panel appears
;here are described all the panels

;Leight panel
lunghezze: layout [
        across        
        metri: field  [ inmetri metri/text "Metri"]
        text "m (meters)"
        return
        cm: field [inmetri cm/text "cm"]
        text "cm (centimeters)"
        return
        mm: field [inmetri mm/text "mm"]
        text "mm (millimeters)"
        return
        pollici: field   [ inmetri pollici/text "Pollici"]
        text "^" (inches)"  ; ^" means ''
        return
        piedi: field    [ inmetri piedi/text "Piedi"]
        text "feet"
        return
        yards: field    [ inmetri yards/text "Yards"]
        text "yards"
        return
        miglia: field   [ inmetri miglia/text "Miglia"]
        text "miles"
        return
        micron: field   [ inmetri micron/text "micron"]
        text "micron"
]
lunghezze/offset: 0x0


;Areas panel
aree: layout [
        across
        metri2: field     [ inmetri2 metri2/text "metri2"]
        text "m2 (square meters)"
        return
        dm2: field     [ inmetri2 dm2/text "dm2"]
        text "dm2 (square decimeters)"
        return	
        cm2: field     [ inmetri2 cm2/text "cm2"]
        text "cm2 (square centimeters)"
        return
        mm2: field     [ inmetri2 mm2/text "mm2"]
        text "mm2 (square millimeters)"
        return	
        acres: field  [ inmetri2 acres/text "acres"]
        text "acres"
        return
        ettari: field    [ inmetri2 ettari/text "ettari"]
        text "ettari"
        return
        inches2: field    [ inmetri2 inches2/text "inches2"]
        text "square inches"
        return
        feet2: field    [ inmetri2 feet2/text "feet2"]
        text "square feet"
        return
        miles2: field   [ inmetri2 miles2/text "miles2"]
        text "square miles"
        return
        yards2: field   [ inmetri2 yards2/text "yards2"]
        text "square yards"
        ]
aree/offset: 0x0

;Volume panel
volume: layout [
        across
        metri3: field  [ inmetri3  metri3/text "metri3"]
        text "m3 (cubic meters)"
        return
        dm3: field  [ inmetri3  dm3/text "dm3"]
        text "dm3 (cubuc decimeters)"
        return
        cm3: field  [ inmetri3  cm3/text "cm3"]
        text "cm3 (cubic centimeters)"
        return
        liters: field  [ inmetri3  liters/text "liters"]
        text "l (liters)"
        return
	cl: field  [ inmetri3  cl/text "cl"]
        text "cl (centiliters)"
        return
	ml: field  [ inmetri3  ml/text "ml"]
        text "ml (milliliters)"
        return
        feet3: field  [ inmetri3  feet3/text "feet3"]
        text "feet3 (cubic feet)"
        return 
        inch3: field  [ inmetri3  inch3/text "inch3"]
        text "inch3 (cubic inches)"
        return
        onces: field [inmetri3 onces/text "onces"]
        text "ounces"
        return
        cups: field  [ inmetri3  cups/text "cups"]
        text "cups"
        return
        gallonsUK: field  [ inmetri3  face/text "gallonsUK"]
        text "gallons UK"
	return
        gallonsUSA: field  [ inmetri3  face/text "gallonsUSA"]
        text "gallons USA"
        return
        pints: field  [ inmetri3  pints/text "pints"]
        text "pints"
        return
        quarts: field  [ inmetri3  quarts/text "quarts"]
        text "quarts"
        return
        tablespoons: field  [ inmetri3  tablespoons/text "tablespoons"]
        text "table spoons"
        return
        teaspoons: field  [ inmetri3  teaspoons/text "teaspoons"]
        text "tea spoons"
          ]
volume/offset: -20x-20


;Weight panel
massa: layout [
          across
          kg: field  [ inkilos  kg/text "kg"]
          text "kg"
			return
			g: field [ inkilos g/text "g" ]
			text "g (grams)"
          return
          carats: field  [ inkilos  carats/text "carats"]
          text "carats"
          return
          grains: field  [ inkilos  grains/text "grains"]
          text "grains"
          return
          ounces: field  [ inkilos  ounces/text "ounces"]
          text "ounces"
          return
          pounds: field  [ inkilos  pounds/text "pounds"]
          text "pounds (lbs)"
          return
          tons: field  [ inkilos  tons/text "tons"]
          text "tons (in UK)"         
          ]
massa/offset: 0x0

;Temperature panel
temperatura: layout [
          across   
          kelvin: field  [ inkelvin  kelvin/text "kelvin"]
          text "K"
          return
          celsius: field [ inkelvin  celsius/text "celsius"]
          text "^°C"
          return
          far: field  [ inkelvin  far/text "far"]
          text "^°F"   
          ]
temperatura/offset: 0x0


;Pressure panel
pressione: layout [
      across
      pascal: field  [ inpascal  pascal/text "pascal"]
          text "Pa"
          return
          kpascal: field [ inpascal  kpascal/text "kpascal"]
          text "kPa"
          return
          Mpascal: field [ inpascal  Mpascal/text "Mpascal"]
          text "MPa"
          return
          kgcm2: field [ inpascal kgcm2/text "kgcm2"]
          text "kg/cm2"
          return
          atm: field  [ inpascal  atm/text "atm"]
          text "atm"
          return
          bar: field  [ inpascal  bar/text "bar"]
          text "bar"
          return
          mbar: field  [ inpascal  mbar/text "mbar"]
          text "mbar"
          return
          mmHg: field  [ inpascal  mmHg/text "mmHg"]
          text "millimeters of Hg"
          return
          inHg: field  [ inpascal  inHg/text "inHg"]
          text "inches of Hg"
          return
          mW: field  [ inpascal  mW/text "mW"]
          text "meters of Water"
          return
          mmW: field  [ inpascal  mmW/text "mmW"]
          text "millimeters of Water"
          return
          inW: field  [ inpascal  inW/text "inW"]
          text "inches of Water"
          return
          feetW: field [ inpascal feetW/text "feetW"]
          text "feet of Water"
          return
          psi: field [ inpascal psi/text "psi" ]
          text "psi (pounds / square inch)"
                    
          ]
pressione/offset: -20x-20

;Time panel
tempo: layout [
    across
    sec: field [ insec sec/text "sec" ]
    text "s (seconds)"
    return
    minut: field [insec minut/text "minut"]
    text "min"
    return
    hours: field [insec hours/text "hours"]
    text "hours"
    return
    day: field [insec day/text "day"]
    text "days"
    return
    weeks: field [insec weeks/text "weeks"]
    text "weeks"
    return
    years: field [insec years/text "years"]
    text "years"
]
tempo/offset: 0x0


;Function to convert time in seconds,
;and then reconvert all other values
insec: func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "sec" [ conv: 1]
   if unit = "minut" [ conv: 60]
   if unit = "hours" [ conv: 3600 ]
   if unit = "day" [ conv: 86400 ]
   if unit = "weeks" [ conv: 604800]
   if unit = "years" [ conv: 31536006]
   SI: misura * conv
   sec/text: troncare SI
   minut/text: troncare (SI / 60)
   hours/text: troncare (SI / 3600)
   day/text: troncare (SI / 86400)
   weeks/text: troncare (SI / 604800)
   years/text: troncare ( SI / 31536006)
   set-face pannelli []
   ]

   
;Speed panel
velocita: layout [
    across
    metpersec: field [ inmetpersec metpersec/text "metpersec" ]
    text "m/s  (meters per second)"
    return
    metpermin: field [inmetpersec metpermin/text "metpermin"]
    text "m/min (meters per minute)"
    return
    metperhour: field [inmetpersec metperhour/text "metperhour"]
    text "m/h (meters per hour)"
    return
    kmpersec: field [inmetpersec kmpersec/text "kmpersec"]
    text "km/s"
    return
    kmperh: field [inmetpersec kmperh/text "kmperh"]
    text "km/h"
    return
    feetpersec: field [inmetpersec feetpersec/text "feetpersec"]
    text "fps (feet per second)"
    return
    feetpermin: field [inmetpersec feetpermin/text "feetpermin"]
    text "fpm (feet per minute)"
    return
    feetperhour: field [inmetpersec feetperhour/text "feetperhour"]
    text "fph (feet per hour)"
    return
    milepers: field [inmetpersec milepers/text "milepersec"]
    text "mps (mile per second)"
    return
    mileperh: field [inmetpersec mileperh/text "mileperh"]
    text "mph (mile per hour)"
    return
    knots: field [inmetpersec knots/text "knots"]
    text "knots"
    return
    mach: field [inmetpersec mach/text "mach"]
    text "Mach"
    
]
velocita/offset: 0x0


;Function to convert speed in meters per second,
;and then reconvert all other values
inmetpersec: func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "metpersec" [ conv:  1]
   if unit = "metpermin" [ conv:  0.016667 ]
   if unit = "metperhour" [ conv:  0.000278 ]
   if unit = "kmpersec" [ conv: 1000 ]
   if unit = "kmperh" [ conv: 0.277778]
   if unit = "feetpersec" [ conv: 0.3048]
   if unit = "feetpermin" [ conv: 0.00508]
   if unit = "feetperhour" [ conv: 0.000085]
   if unit = "milepersec" [ conv: 1609.344]
   if unit = "mileperh" [ conv: 0.44704]
   if unit = "knots" [ conv: 0.514444]
   if unit = "mach" [ conv:  340.2933]
   SI: misura * conv
   metpersec/text: troncare SI
   metpermin/text: troncare (SI / 0.016667)
   metperhour/text: troncare (SI / 0.000278)
   kmpersec/text: troncare (SI / 1000 )
   kmperh/text: troncare (SI / 0.277778)
   feetpersec/text: troncare ( SI / 0.3048)
   feetpermin/text: troncare ( SI / 0.00508)
   feetperhour/text: troncare ( SI / 0.000085 )
   mileperh/text: troncare ( SI / 0.44704 )
   milepers/text: troncare ( SI / 1609.344 )
   knots/text: troncare ( SI / 0.514444 )
   mach/text: troncare ( SI / 340.2933 )
   set-face pannelli []
   ]

 
;flow panel
portata: layout [
    across
    m3ps: field [ inm3psec m3ps/text "m3ps" ]
    text "m3/s  (cubic meters per second)"
    return
    m3pmin: field [ inm3psec m3pmin/text "m3pmin" ]
    text "m3/min  (cubic meters per minut)"
    return
    m3ph: field [ inm3psec m3ph/text "m3ph" ]
    text "m3/h  (cubic meters per hour)"
    return
    lps: field [ inm3psec lps/text "lps" ]
    text "l/s  (liters per second)"
    return
    lpmin: field [ inm3psec lpmin/text "lpmin" ]
    text "l/min  (liters per minute)"
    return
    lph: field [ inm3psec lph/text "lph" ]
    text "l/h  (liters per hour)"
    return
    cfh: field [ inm3psec cfh/text "cfh" ]
    text "cfh  (cubic feet per hour)"
    return
    cfmin: field [ inm3psec cfmin/text "cfmin" ]
    text "cfm  (cubic feet per minute)"
    return
    ccpmin: field [ inm3psec ccpmin/text "ccpmin" ]
    text "cc/min  (cubic centimeters per minute)"
    return
    gallh: field [ inm3psec gallh/text "gallh" ]
    text "gal/h  (gallons per hour)"
    return
    gallmin: field [ inm3psec gallmin/text "gallmin" ]
    text "gal/min  (gallons per minute)"
    return
    ]
portata/offset: -20x-20   


;Function to convert flow in cubic meters per second,
;and then reconvert all other values
inm3psec: func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "m3ps" [ conv:  1]
   if unit = "m3pmin" [ conv:  0.01666666666667]
   if unit = "m3ph" [ conv:  0.00027777777778 ]
   if unit = "lps" [ conv:  0.001 ]
   if unit = "lpmin" [ conv:  0.000016667 ]
   if unit = "lph" [conv: 0.00000027777778]
   if unit = "cfh" [ conv: 0.00000786583333 ]
   if unit = "cfmin" [ conv: 0.000471947 ]
   if unit = "ccpmin" [ conv: 0.00000001666667]
   if unit = "gallh" [ conv: 0.000001263 ]
   if unit = "gallmin" [ conv: 0.000075766666667]
   SI: misura * conv
   m3ps/text: troncare SI
   m3pmin/text: troncare (SI / 0.01666666666667)
   m3ph/text: troncare (SI / 0.00027777777778 )
   lps/text: troncare (SI / 0.001)
   lpmin/text: troncare (SI / 0.000016667)
   lph/text: troncare (SI / 0.00000027777778)
   cfh/text: troncare (SI / 0.00000786583333 )
   cfmin/text: troncare (SI /  0.000471947 )
   ccpmin/text: troncare ( SI / 0.00000001666667)
   gallh/text: troncare ( SI /  0.000001263)
   gallmin/text: troncare ( SI / 0.000075766666667 )
   set-face pannelli []
   ]
   
   
;energy panel
energia: layout [
    across
    joule: field [ injoule joule/text "joule" ]
    text "J (Joule)"
    return
    kjoule: field [ injoule kjoule/text "kjoule" ]
    text "kJ (kiloJoule)"
    return
    cal: field [ injoule cal/text "cal" ]
    text "cal (calories)"
    return
    kcal: field [ injoule kcal/text "kcal" ]
    text "kcal (kilocalories)"
    return
    kwh: field [ injoule kwh/text "kwh" ]
    text "kWh (kiloWatt hour)"
    return
    btu: field [ injoule btu/text "btu" ]
    text "btu (British thermal units)"
    return
    ev: field [ injoule ev/text "ev" ]
    text "eV (electron Volts)"
    return
    ergs: field [ injoule ergs/text "ergs" ]
    text "ergs"
    return
    tTNT: field [ injoule tTNT/text "tTNT" ]
    text "tons of TNT"
    
    ]
energia/offset: 0x0   


;Function to convert energy in Joule,
;and then reconvert all other values
injoule: func [ misura  unit ]
   [
   if (misura = none) or (misura = "" ) [misura: 0 ]
   conv: 0 
   misura: to-decimal misura
   if unit = "joule" [ conv:  1]
   if unit = "kjoule" [ conv:  1000 ]
   if unit = "cal" [ conv:  4.187 ]
   if unit = "kcal" [ conv: 4187 ]
   if unit = "kwh" [ conv: 3600000]
   if unit = "btu" [ conv: 1055 ]
   if unit = "ev" [ conv: 1.602e-19]
   if unit = "ergs" [ conv: 1e-7 ]
   if unit = "tTNT" [ conv: 4184000000 ]
   SI: misura * conv
   joule/text: troncare SI
   kjoule/text: troncare (SI / 1000)
   cal/text: troncare (SI / 4.187)
   kcal/text: troncare (SI / 4187 )
   kwh/text: troncare (SI / 3600000 )
   btu/text: troncare ( SI / 1055)
   ev/text: troncare ( SI / 1.602e-19 )
   ergs/text: troncare ( SI / 1e-7)
   tTNT/text: troncare ( SI / 4184000000)
   set-face pannelli []
   ]
   
   

;viscosity panel
viscosita: layout [
    across
    Pas: field [ inpas Pas/text "Pas" ]
    text "Pa*s"
    return
    poise: field [ inpas poise/text "poise" ]
    text "poise"
    return
    cpoise: field [ inpas cpoise/text "cpoise"]
    text "cP (centipoise)"    
    ]
viscosita/offset: -20x-20   
   

;Viscosity functions
inpas: func [misura unit] [
  if (misura = none) or (misura = "" ) [misura: 0 ]
  conv: 0
  misura: to-decimal misura
  if unit = "Pas" [ conv: 1]
  if unit = "poise" [ conv: 0.1]
  if unit = "cpoise" [conv: 0.001]
  SI: misura * conv
  Pas/text: troncare SI
  poise/text: troncare ( SI / 0.1)
  cpoise/text: troncare (SI / 0.001 )  
  set-face pannelli []  
]




   
;***********************************
;***********************************   
;The main window   
view layout  [
 text-list "Lenght" 
           "Area" 
           "Volume" 
           "Mass" 
           "Temperature" 
           "Pressure" 
           "Time" 
           "Speed" 
           "Flow"
           "Energy/Work"
	 "Viscosity"  
	   [
    if value = "Lenght" [   pannelli/pane: lunghezze   show pannelli]
    if value = "Area" [   pannelli/pane: aree   show pannelli]
    if value = "Volume" [   pannelli/pane: volume   show pannelli]
    if value = "Mass" [   pannelli/pane: massa   show pannelli]
    if value = "Temperature" [   pannelli/pane: temperatura   show pannelli]
    if value = "Pressure" [   pannelli/pane: pressione   show pannelli]
    if value = "Time" [ pannelli/pane: tempo   show pannelli]
    if value = "Speed" [pannelli/pane: velocita   show pannelli]
    if value = "Flow" [pannelli/pane: portata   show pannelli]
    if value = "Energy/Work" [pannelli/pane: energia   show pannelli]
    if value = "Viscosity" [pannelli/pane: viscosita   show pannelli]
 ]
 return

 across
 ;Decimals buttons control the number of digits after the dot
 vtext "Digits"
 cifredecimali: vtext "3"

 button 20x20 "+" [ decimali: decimali * 0.1
              if decimali > 0.1 [decimali: 0.1]
              cifra: to-integer cifredecimali/text
              cifra: cifra + 1
              if cifra < 1 [ cifra: 1]
              cifredecimali/text: cifra
              show cifredecimali
             ]
 button 20x20 "-" [ decimali: decimali / 0.1
              if decimali > 0.1 [decimali: 0.1]
              cifra: to-integer cifredecimali/text
              cifra: cifra - 1
              if cifra < 1 [ cifra: 1]
              cifredecimali/text: cifra
              show cifredecimali
             ]
 return
 button "Info" [ 
                view/new/offset/title layout  [
                   
                    vh2 "INFO"  
                    text "This unit converte is open source. Visit:"
                    text "https://sourceforge.net/projects/tbunitconverter/" bold
                    text "or"
                    text "http://www.rebol.org" bold 
                    image logo.gif
                    text " to download the last version." 
                    text "Author: Massimiliano Vessi"
                    across
                    text "email:  "
                    text bold rejoin [ "maxint" "@" "tiscali.it"]
                   	return
                    button "Close" [unview] 
                    
                    
                    ] 100x100 "Info"
                ]
 
 return
 text version
 
 
 below
 
 return
 pannelli: box  400x500
 return 
 logo-bar 24x500

]
