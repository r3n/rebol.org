REBOL [
	Title: "Steganography"
	Description: "Ukrywanie informacji tekstowych w plikach graficznych"
	Purpose: "Functions to hide text data in the noise pixels of an image"
	Date: 2007/01/10
	Version: 1.1.0
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %steganography.r
	Url: http://www.rowery.olsztyn.pl/wspolpraca/rebol/steganography/
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
	License: "GNU Lesser General Public License (Version 2.1)"
	Library: [
		level: 'intermediate
		platform: 'all
		type: [module tool]
		domain: [files graphics]
		tested-under: [
			view 1.3.2 on [Linux WinXP]
		] 
		support: none
		license: 'LGPL
	]
]

ctx-steganography: context [
	greyscale: false

	set 'img-load-or-create func [
		"Wczytuje plik graficzny lub tworzy obrazek o kolorze bialym."
		imgname [string! file!] "nazwa pliku do wczytania"] [
		any [
			attempt [load to-file imgname]
			make image! reduce [300x300 white]
		]
	]

	set 'img-save-png func [
		"Zapisuje dane graficzne do pliku PNG"
		imgname [string! file!] "nazwa pliku"
		img [image!] "dane grafine do zapisania"] [
		
		save/png (to-file imgname) img
	]

	set 'img-encode func [
		"Koduje wiadomosc kluczem i umieszcza w pliku graficznym."
		text [string!] "wiadomosc do zakodowania"
		key [string!]  "klucz prywatny kodowanych danych"
		img [image!] "obrazek w ktorym beda umieszczone dane"
		/local text-len rgb r g b key-len key-index color-index byte k color i] [
		
		text-len: length? text
		
		;; zakoduj d&#322;ugosc wiadomosci w pierwszym pixelu
		pixel: 1
		rgb: to-tuple reduce [ 
			r: to-integer (text-len / power 2 2)
			g: to-integer (text-len - (r * power 2 2)) / power 2 1
			b: to-integer (text-len - (r * power 2 2) - (g * power 2 1))
		]
		poke img pixel rgb
		
		key-len: length? key
		key-index: color-index: i: 1 ;; skladowa rgb w ktorej bedzie umieszczony zakodowany bajt
		
		foreach byte text [
			pixel: pixel + (to-integer key/:key-index)
			rgb: img/:pixel
			
			crypted-value: to-integer (byte xor key/:key-index)
			either greyscale [
				rgb: to-tuple reduce [crypted-value crypted-value crypted-value]
			][
				rgb: poke rgb color-index crypted-value
			]
			poke img pixel rgb
			
			key-index: (i // key-len) + 1
			color-index: (i // 3) + 1
			i: i + 1
		]
		return img
	]

	set 'img-decode func [
		"Rozkodowuje wiadomosc z pliku graficznego na podstawie klucza."
		key [string!] "klucz prywatny zakodowanych danych"
		img [image!] "obrazek zawierajacy zakodowane dane"
		/local text pixel text-len key-len key-index color-index i] [

		;; d&#322;ugosc wiadomosci jest zakodowana w pierwszym pixelu
		pixel: 1
		text: copy ""
		text-len: to-integer ((img/:pixel/1 * power 2 2) + (img/:pixel/2 * power 2 1) + img/:pixel/3)
		key-len: length? key
		key-index: color-index: i: 1 ;; skladowa rgb w ktorej bedzie umieszczony zakodowany bajt
		
		loop text-len [
			pixel: pixel + to-integer key/:key-index
			byte: img/:pixel/:color-index
			append text (to-char byte) xor key/:key-index
			
			key-index: (i // key-len) + 1
			color-index: (i // 3) + 1
			i: i + 1
		]
		return text
	]
]

comment {
message: "steganografia: informacja, ktorej nie widac"
key: "1234"

; tworzenie zakodowanej wiadomocci
img: img-load-or-create %test.png
img-save %crypted.png (img-encode message key img)

; odczytywanie wiadomosci
img: img-load-or-create %crypted.png
print img-decode key img
}
