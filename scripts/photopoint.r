REBOL [	
	Title: "PhotoPoint"
	Purpose: {Combine GPS tracklog and jpeg/exif files to find out where digital photos were taken}
	Date: 2006-07-10
	Version: 0.4.1
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %photopoint.r
	Url: http://www.rowery.olsztyn.pl/wspolpraca/rebol/photopoint/
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
	License: "GNU General Public License (Version II)"
	Comment: {
		1. place all files (photopoint.r, OZI-explorer PLT tracklog and images) in one directory
 		2. rename tracklog file to "tracklog.plt"
		3. adjust "timezone" variable in photopoint.r (time offset to GMT)
		4. do %photopoint.r
		
		Waypoints are stored in images (as jpeg comment) and in photopoint.wpt file (OZI-explorer WPT format).
 		As long as the GPS was in the same location as the camera this represents the location of the photo.
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [files]
		tested-under: [
			core 2.6.0 on 'Linux
			view 1.3.2 on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
]

; strefa czasowa w zaleznosci od daty tracklogu
timezone: +00:00

ctx-exif: context [
	set 'EXIF-SOI  #{FFD8}
	set 'EXIF-APP0 #{FFE0}
	set 'EXIF-APP1 #{FFE1}
	set 'EXIF-APP2 #{FFE2}
	set 'EXIF-CMT  #{FFFE}
	set 'EXIF-EOI  #{FFD9}

	EXIF-HEADER: #{457869660000}
	TIFF-HEADER-OFFSET: 10

	EXIF-FORMS: [
		#{0001} [1 to-integer]  ;; unsigned byte (1 bajt/komponent)
		#{0002} [1 to-ascii]    ;; ascii napisy koncza sie bajtem zerowym (jest wliczony w wielkosc napisu)
		#{0003} [2 to-integer]  ;; unsigned short (2 bajty/komponent)
		#{0004} [4 to-integer]  ;; unsigned long (4 bajty/komponent)
		#{0005} [8 to-rational] ;; unsigned rational (8 bajtow/komponent)
		#{0006} [1 to-integer]  ;; signed byte (1 bajt/komponent)
		#{0007} [1 to-binary]   ;; undefined (1 bajt/komponent)
		#{0008} [2 to-integer]  ;; signed short (2 bajty/komponent)
		#{0009} [4 to-integer]  ;; signed long (4 bajty/komponent)
		#{000A} [8 to-rational] ;; signed rational (8 bajtow/komponent)
		#{000B} [4 to-binary]   ;; signed float (4 bajty/komponent)
		#{000C} [8 to-binary]   ;; double float (8 bajtow/komponent)
	]

	byte-order: "" ;; MM (Motorola) lub II (Intel)
	dat: none  ;; bufor danych
	debug: false

	range: func [
		"Pobiera fragment danych z bufora (bez weryfikacji zakresu danych); zwraca binary!"
		offset [integer!] "przesuniecie od poczatku bufora"
		length [integer!] "dlugosc danych w bajtach (wzgledem offsetu)"
		/all "dlugosc danych liczona od poczatku bufora"
		/custom "bufor danych" buffer [series!] "opcjonalny bufor z danymi"
		/local d] [

		d: any [buffer dat] ;; albo bufor przekazany jako paramentr albo bufor 'dat'
		copy/part (skip d offset) (either all [length - offset] [length])
	]

	get-content: func [
		"Pobiera size danych znajdujacych sie location bajtow za naglowkiem bufora; zwraca binary!"
		location [integer!] "przesuniecie od poczatku bufora"
		size [integer!] "dlugosc danych bajtach (wzgledem offsetu)"] [

		range (TIFF-HEADER-OFFSET + location) size
	]

	intel?: func [
		"Konwersja zapisu danych binarnych Intel-Motorola (zmiana kolejnosci bajtow)."
		bin [binary!] "dane binarne" ] [
		either (byte-order = "II") [head reverse bin] [bin]
	]

	read-traverse: func [
		"Poszukuje tag w pliku JPEG; zwraca binary! (zawartosc chunk) lub none!"
		file-name [file! string!] "nazwa pliku"
		tag [binary!] "szukany chunk-id"
		/position "zwraca offset pozycji chunk od poczatku pliku"
		/local chunk-id chunk-size offset buffer] [

		file: to-file file-name
		if error? try [
			buffer: read/binary/direct/part file 2
			if not equal? EXIF-SOI (range/custom 0 2 buffer) [return none] ;; jezeli naglowek pliku <> EXIF-SOI to nie jest to plik JPEG
			;; buffer: skip dat 2 ;; pomin SOI

			offset: 2
			forever [
				buffer: read/binary/direct/part file (offset + 4) ;; wczytaj id bloku danch i ich wielkosc
				chunk-id: range/custom offset 2 buffer
				if (chunk-id and #{FF00} <> #{FF00}) [return none]

				chunk-size: to-integer range/custom (offset + 2) 2 buffer

				if debug [print ["znaleziono chunk" chunk-id "offset" offset "wielkosc" (chunk-size + 2) "bajtow"]]

				if (chunk-id = tag) [
					buffer: skip (read/binary/direct/part file (offset + chunk-size + 2)) offset
					return either position [offset] [buffer]
				]
				offset: offset + chunk-size + 2
			]
		] [return none]
	]

	set 'exif-file? func [
		"Bada czy plik jest w formacie JPEG i zawiera dane EXIF-APP1; zwraca logic!"
		file-name [file! string!] "nazwa pliku"
		/debug "dodatkowe informacje o dzialaniu programu"
		/local size] [

		self/debug: any [(not none? debug) false]
		not none? all [
			not none? dat: read-traverse file-name EXIF-APP1
			equal? EXIF-APP1 range 0 2 ;; bajty 02:04 = FFE1
			not zero? size: to-integer range 2 2 ;; wielkosc chunk APP1
			not empty? byte-order: to-string range 10 2
		]
	]
	set 'good-file? :exif-file? ;; synonim

	set 'exif-tag func [
		"Przeszukuje katalogi struktury EXIF; zwraca block!, binary! lub none!"
		tag [binary! block!] "poszukiwane znaczniki"
		/local ifd-first ifd-next search-ifds ifds rcs tags offset] [

		if none? dat [return none]
		;; offsety sa licznone wzgledem poczatku naglowka APP1 #{FFE1}
		ifd-first: does [TIFF-HEADER-OFFSET + to-integer (intel? range 14 4)] ;; IFD0
		ifd-next: func [
			"Zwraca integer! offset do nastepnego IFD lub none!"
			offset "aktualna pozycja katalogu"
			/local elements next] [

			;; kazdy katalog zawiera nastepujace dane
			;; 00-02 liczba elementow (tagow) w katalogu
			;; ..... 12 bajtow na kazdy element w katalogu
			;; ..... 4-ro bajtowy wskaznik do nastepnego IFD lub 0

			elements: to-integer (intel? range offset 2)
			next: to-integer (intel? range (offset + 2 + (elements * 12)) 4)
			either equal? 0 next [none] [TIFF-HEADER-OFFSET + next]
		]
		search-ifds: func [
			"Szuka znacznika tag we wszystkich katalogach APP1."
			ifds [block!] "block! offsetow do katalogow APP1"
			tag [binary!] "szukany znacznik EXIF"
			/local offset rc] [

			foreach offset ifds [if not none? (rc: ifd-content offset tag) [break]]
			return rc
		]

		ifds: copy [] tags: copy [] rcs: copy []

		;; tworznie tablicy z pozycjami wszystkich katalogow EXIF v2.1
		append ifds offset: ifd-first ;; IFD0
		while [not none? (offset: ifd-next offset)] [append ifds offset] ;; IFD1,...

		;; foreach tag [#{8769} #{A005} #{8825}] [ ;; SUBIFD0 Interoperability GPSIFD
		foreach tag [#{8769} #{A005}] [ ;; SUBIFD0 Interoperability
			offset: search-ifds ifds tag
			if not none? offset [append ifds (TIFF-HEADER-OFFSET + (to-integer offset))]
		]
		ifds: sort ifds ;; znaczniki najczesciej uzywane sa przewaznie w poczatkowych katalogach

		if debug [print ["znalezione katalogi" mold ifds CRLF "rozpoczynam poszukiwania" CRLF]]

		;; traktuj przekazany parametr (tag) jako block! danych
		;; zapisuj wartosc kazdego paramtru lub none! gdy nie znaleziony
		;; pojedyncze wartosci sa zwracane bez bloku (brana jest pierwsza wartosc z listy)

		either block? tag [tags: tag][append tags tag]
		foreach tag tags [append rcs (search-ifds ifds tag)]
		either (block? tag) [rcs] [first rcs]
	]
	set 'exif-ifd :exif-tag

	ifd-content: func [
		"Wyszukuje okreslony parametr w katalogu EXIF; zwraca jego wartosc lub none!"
		offset [integer!] "lokalizacja (offset) katalogu"
		tag [binary!] "poszukiwany znacznik"
		/local items tag-format tag-length tag-value tag-components] [

		items: to-integer intel? range offset 2 ;; liczba parametrow w biezacym katalogu EXIF

		if debug [print ["szkukam" tag "w katalogu" offset "(" items "elementy/ow )"]]

		offset: offset + 2 ;; pomin 2 bajty z liczba elementow

		loop items [
			;; na kazdy element w katalogu przypada 12 bajtow
			;; 00-02 znacznik
			;; 02-04 format danych (zobacz EXIF-FORM)
			;; 04-08 liczba czesci z ktorych skladaja sie dane (liczba czesci nie oznacza liczby bajtow!)
			;; 08-12 dane znacznika lub offset do danych gdy ich dlugosc przekracza 4 bajty

			if debug [print ["-> znaleziono znacznik" (intel? range offset 2)]]
			if equal? tag (intel? range offset 2) [

				;; znaleziono wlasciwy tag - pobierz jego wartosc
				tag-format: intel? range (offset + 2) 2
				tag-components: to-integer intel? range (offset + 4) 4
				tag-length: tag-components * EXIF-FORMS/:tag-format/1 ;; liczba bajtow przypadajaca na dane jednego znacznika

				tag-value: intel? range offset + 8 4
				if (tag-length > 4) [tag-value: range (TIFF-HEADER-OFFSET + to-integer tag-value) tag-length]

				if debug [print ["-> format" tag-format tag-components "komponent/ow w buforze" tag-value "(" tag-length "bajt/y )" CRLF]]

				;; zamien na rebol datatype
				return to-rebol tag-value tag-format tag-length
			]
			offset: offset + 12 ;; do nastepnego znacznika w biezacym katalogu
		]

		if debug [print ["-> znacznika" tag "nie znaleziono!" CRLF]]
		return none
	]

	to-rebol: func [
		"Konwersja danych binarnych na Rebol datatype."
		bin [binary!] "dane binarne"
		format [binary!] "format danych"
		length [integer!] "bajtow danych (binarnych)"] [

		to-rational: func [bin [binary!] /local a b] [
			a: intel? copy/part bin 4
			b: intel? copy/part skip bin 4 4
			to-string rejoin [(to-integer a) "/" (to-integer b)]
		]
		to-ascii: func  [bin [binary!]] [trim to-string bin]

		;; zwracaj tylko tyle bajtow ile jest danych
		;; zmienna bin ma 4 bajty lub wiecej a np. dla typu "unsigned short" potrzebujemy tylko 2 bajtow
		;; proteza jest potrzebna dla typow "short", "byte" czy "ascii", ktore moga zawierac pojedyncze bajty

		return do EXIF-FORMS/:format/2 copy/part skip bin ((length? bin) - length) length
	]

	set 'jpeg-datetime func [
		"Zwraca date! wykonania zdjecia zwarta w strukturze EXIF (lub none!)."
		[catch]
		file-name [file! string!] "nazwa pliku zdjecia"
		/local date time] [

		if not good-file? to-file file-name [return none]
		attempt [
			set [date time] parse/all trim exif-tag #{0132} " " ;; "DateTime Tag"
			to-date rejoin [replace/all date ":" "-" "/" time] ;; "+" now/zone] ;; mozliwosc dodania strefy czasowej
		]
	]

	set 'jpeg-thumbnail func [
		"Zwraca image! miniaturki zdjecia z pliku EXIF lub none! (obsluguje tylko JPEG EXIF)."
		[catch]
		file-name [file! string!] "nazwa pliku zdjecia"
		/binary "Zwraca zdjecie w formacie binary! (JPEG)"
		/local compression location size thumb] [

		if not good-file? to-file file-name [return none]
		attempt [
			set [compression location size] exif-tag [#{0103} #{0201} #{0202}] ;; Compression, Size, OffsetTag
			if compression = 6 [
				;; 6 oznacza iz mamy do czynienia z miniaturka zdjecia w formacie JPEG
				thumb: self/get-content location size
				either binary [thumb] [load thumb]
			]
		]
	]

	set 'jpeg-size func [
		"Zwraca pair! rozdzielczosci zdjecia EXIF lub none!"
		[catch]
		file-name [file! string!] "nazwa pliku zdjecia"] [

		if not good-file? to-file file-name [return none]
		attempt [to-pair exif-tag [#{a002} #{a003}]]
	]
]

ctx-ozi: context [
	not-valid-altitude: -777 ; znacznik braku wysokosci dla OZI-explorer
	meters: 9.89999976239995E+24
	reference-date: 30-12-1899/00:00

	to-datetime: func [
		"Konwertuje date i czas tracklogu OZI na rebol datetime!"
		ozi [number!] "OZI datetime"] [

		; w pliku PLT daty sa liczone jako liczba dni od 30-12-1899
		; czesc calkowita to liczba dani, ulamkowa to czas
		reference-date + (to-integer ozi) + to-time to-integer ((ozi - (to-integer ozi)) * 86400)
	]
	to-ozitime: func [
		"Zamienia date! na format programu OZI (liczba dni od 30-12-1899)"
		datetime [date!] "data do konwersji"] [

		(datetime/date - reference-date/date) + ((to-integer datetime/time) / 86400)
	]
	to-meters: func [feet [number!]] [either (feet = not-valid-altitude) [feet] [feet / 3.28083931316019]]
	to-feet: func [meters [number!]] [either (meters = not-valid-altitude) [meters] [meters * 3.28083931316019]]

	set 'save-wpt func [
		filename [string! file!]
		waypoints [block!]
		/local compare items lines num name latitude longitude altitude description datetime dat] [


		; porzadkuj waypointy narastajaco wzgledem daty punktu
		compare: func [a b] [attempt [a/datetime < b/datetime]]
		sort/compare waypoints :compare

		items: length? waypoints
		lines: copy {}
		num: 0

		foreach wpt waypoints [
			attempt [
				num: minimum (num + 1) 1000
				name: join "wpt" num
				latitude: wpt/latitude
				longitude: wpt/longitude
				altitude: to-feet wpt/altitude
				description: replace (copy/part reform [wpt/image wpt/image-datetime] 40) "," "_"
				datetime: to-ozitime wpt/datetime

				dat: rejoin [
					num ","			; Number - this is the location in the array (max 1000), must be unique
					name ","		; Name - the waypoint name, use the correct length name to suit the GPS type
					latitude ","	; Latitude - decimal degrees
					longitude ","	; Longitude - decimal degrees
					datetime ","	; Date - if blank a preset date will be used
					"70,"			; Symbol - 0 to number of symbols in GPS
					"1,"			; Status - always set to 1
 					"6,"			; Map Display Format
 					"0,"			; Foreground Color (RGB value)
 					"13158342,"		; Background Color (RGB value)
					description ","	; Description (max 40), no commas
					"2,"			; Pointer Direction
 					"0,"			; Garmin Display Format
					"0,"			; Proximity Distance - 0 is off any other number is valid
					altitude ","	; Altitude - in feet (-777 if not valid)
					"8.25,"			; Font Size - in points
 					"0,"			; Font Style - 0 is normal, 1 is bold
 					"17" CRLF		; Symbol Size - 17 is normal size
				]
				append lines dat
			]
		]
		insert lines join {OziExplorer Waypoint File Version 1.1} [CRLF	"WGS 84" CRLF "Reserved 2" CRLF "garmin" CRLF]
		write/direct (to-file filename) lines
	]

	set 'load-plt func [
		"Wczytuje dane z pliku PLT, zwraca hash! [lat lon date]"
		filename [string! file!] "nazwa pliku PLT"
		/local file items column track point latitude longitude altitude datetime] [
	
		file: attempt [open/lines/direct/read to-file filename]
		if none? file [return none]
		
		skip file 5 ; pomin piec pierwszych linii pliku PLT
		items: to-integer trim pick file 1
		track: make hash! items
		
		; w pliku PLT pola sa rozdzielone znakiem ","; pierwsza kolumna to szerokosc geogr,
		; druga kolumna to dlugosc geogr; piata kolumna zawiera date liczona jako
		; liczba dni od 30-12-1899r; kolumna moze byc pusta (pusty ciag znakow)
		; wysokosc jest w stopach angielskich; 1 stopa to okolo 30,479 cm
		loop items [
			if none? point: attempt [pick file 1] [break]
			column: parse/all point ","

			attempt [
				latitude: (to-decimal trim first column)
				longitude: (to-decimal trim second column)
				altitude: any [
					attempt [to-meters (to-decimal trim fourth column)]
					to-meters not-valid-altitude
				]
				datetime: any [
					attempt [to-datetime (to-decimal trim fifth column)]
					now
				]

				repend/only track ['latitude latitude 'longitude longitude 'altitude altitude 'datetime datetime]
			]
		]
		close file
		return track
	]
]

ctx-photopoint: context [
	byte-order: ""

	to-hex: func [val /local s r] [
		s: make struct! [i [integer!]] none
		s/i: val
		r: copy/part (third s) 2
		either self/byte-order = "II" [reverse r] [r]
	]

	set 'find-location func [
		"Wyszukuje wspolrzedne geograficzne na podstawie daty; zwraca block! [lat lon date] lub none!"
		track [hash! block!] "tracklog"
		datetime [date!] "data poszukiwanego punktu"
		zone [time!] "przesuniecie czasowe dodawane do daty punktu"
		/local i diff delta duration] [

		; oblicz roznice miedzy data punktu trasy i poszukiwanego miejsca
		; szukamy minimum tej roznicy

		diff: make hash! length? track
		foreach point track [
			attempt [
				append diff (abs difference (zone + (point/datetime)) datetime)
			]
		]
		attempt [
			; ignoruj gdy data zdjecia nie pasuje do dat w tracklogu
			duration: abs difference (select last track 'datetime) (select first track 'datetime)
			i: index? delta: minimum-of diff
			if (first delta) < duration [copy track/:i]
		]
	]

	set 'make-comment func [
		"zapis informacji o waypoincie jako komentarz pliku JPEG"
		file [string! file!] "nazwa pliku JPEG"
		location [block!]
		/backup "zapisuj informacje do kopii oryginalow"
		/local new-file dat pos info] [

		file: to-file file
		orig: join file ".orig"

		; zabezpiecz oryginal pliku
		if none? attempt [
				dat: read/binary/direct file
				pos: to-integer ctx-exif/read-traverse/position file EXIF-APP1
				rename file orig
			] [return false]

		; jezeli pojawi sie blad to usun nowy plik i przywroc oryginalna nazwe
		any [
			attempt [
				byte-order: to-string ctx-exif/range/custom (pos + 10) 2 dat
				len: 2 + to-integer ctx-exif/range/custom (pos + 2) 2 dat ;; wielkosc danych w chunk + dwa bajty na sam znacznik
				info: form location

				write/binary file copy/part dat (pos + len)
				write/append/binary file repend #{} [EXIF-CMT (to-hex 2 + length? info) (to-binary info)]
				write/append/binary file (skip dat (pos + len))
				if not value? 'backup [delete orig]
				true
			]
			do [
				attempt [delete file]
				attempt [rename orig file]
				false
			]
		]
	]
]

; sprawdz wszystkie pliki jpg w biezacym katalogu
if none? track: load-plt %tracklog.plt [print "tracklog load error" halt]
files: remove-each file read %. [(suffix? file) <> %.jpg]
if empty? files [print "no files to process" halt]

waypoints: copy []
foreach file files [
	any [
		if none? datetime: jpeg-datetime file [print ["exif metadata not found" file] true]
		if none? location: find-location track datetime timezone [print ["location not found" file] true]
		attempt [
			;; print [file location/latitude location/longitude location/datetime]
			repend location ['image (form file) 'image-datetime datetime]
			append/only waypoints location
			make-comment/backup file location
		]
	]
]

save-wpt %photopoint.wpt waypoints

if (length? files) <> (length? waypoints) [halt]
quit
