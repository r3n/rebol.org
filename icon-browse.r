REBOL [
    Title: "Iconic Image Browser"
    Date: 29-May-2004
    Version: 1.1.1
    File: %icon-browse.r
    Author: "Carl Sassenrath"
    Purpose: {
        Browse a directory of images using a scrolling list of icons.
        Displays a progress bar while icons are being created.
    }
    Notes: {
       4-June-2000 - 1.1.0 script orginally written by Carl.
       29-May-2004 - 1.1.1
    	This script broke under later versions of View as it used the 'frame
    	face which was dropped.  Replaced by 'box.
    	Also referenced a missing jpg file, and so replaced that by embedding
    	the image into the script.
    
    	Graham Chiu
    }
    library: [
        level: 'intermediate 
        platform: [all]
        type: [tool]
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

files: []
icons: []
num: 0
selection: none

carlwaves: load #{      
89504E470D0A1A0A0000000D49484452000000670000003808020000006FFB71
8C0000001374455874536F667477617265005245424F4C2F566965778FD91678
0000039B49444154789CCD9BD14E2B310C44F3FFFF521E2AC1C395E00589EF02
5DD8D226713C339EECBD928510A4893D3EF67AB76D7B7E79FEB2D73FAFBDBD1D
36FEEBAF7DBF70FEDABABD0D56F0E1B6E0B6FED7AE81050B2E4F97AF9FED6185
45022048CA2C6920361F1336580B35A63C4E4F12808D378124CE9C81880B186C
14175A1DE9C0C2A2E785B6B64CA62EF6C626330250A932064CB984F3358FA77F
BC7F8CD657685E5FB03415A34B9E3226C1484A1ACA6DB6974597699EFB6C2F4E
C44B92E17454A309F14F348DDD4D5B98195BB2AF6B7E4E545B57FEBAE0415DA0
43EFE62C70B196362285D74C35F0782ECF26A0FC8492E20EAAED6CC35ACE13FC
61646467C69D5715EA4F9D3725B1703BF45AB2768A9D5F59CA6E716E5A747CBF
23D6A7E418C2C53C6EB440FCE803B106E6D94C8AAF4B42694871B9FB237035C8
70E5A0200D4A7E4553E952A6F435BA247DD4B83A5DB18D26AA4D5E39E0CA4107
7B0F86C7F19EC685B5EFE57D28E02E411CC2238C0304B5065D26DCC1DA9A02FC
CE4EBD19A0C58D9BE039179086B6DB20519A1F5C8194071DBB115703B996FF37
4BE0F5AA269B18CFC9C6CC1FC3D5A0D6B62C6AEA112236F38195B88DF12F9C9B
B45B1C6C637B161E1D5BCF6D8807A0437366CB21D90462F2BD3E827C96CB0483
D67B99916407E99E69FD12F46A50C973856268A5DC345259837D8827E00FF890
452D0B5D0D38932F3C65B9614B4F720901B96565DCCBD7236B7C66B650868D08
9BFA26EBB36DCAA5E3B120339E5EBE3B468E6B68FB3041E79229047367ADDC14
F7B376F26B2722024A41998813A04CB91A475C11C9054536473CA3F7365C0D30
9E65A0BA6D5977CFEE030BD626B9E2E5DFE76E51AFF9CADA6308F899C76E756A
03D4796E80532E986D273B71CEA8D81672739E0F1B329F8E999D0D9D04080769
CABC1D21260C2BB8E43D2A9D70BE3A2207D66EA09E5BCAFFB742F9F0A0C37677
222CFE9B7C2865192B3FAC5988E0385747334BD8288041E0DFBF4F2AD44804B4
6DADAF2BE98C5D02458059B3571CA91481B09580A9D6E827B184DD3756D6BF7E
7376F81ED59E46633384296A9A4BA7D4E3B8CBD3E566F1948B754731E0EBC41B
246774BD7BBBCA612D8CA7CC85A7C1ED093B75721DCED1D7E279871668830AE7
B782F5E9FDE4918360C9F666A6F61647F2EDB342A2FA3F6E9B0C8AC2699B9B3F
53847BB992B5707FDE5B6D721EA3EB55E3D8190D8BD998923A68917BE3FEDD32
EE1BDCA216275C1CCFBD0A07F35A40A6CC05A1357E6BF512D26DC470BAC927A3
B0078A42DD22E10000000049454E44AE426082
}


;-- Progress box:
view/new layout [
    ; backtile carlwaves effect [ tile gradcol 1x1 0.0.160 200.0.0]
    text "Iconifying Images..." bold
    filn: text 120x20
    prog: progress 200x14
]

  
;-- Read directory, find image files:
files: read %.
while [not tail? files] [
    either find [%.bmp %.jpg %.gif] find/last first files "." [
        files: next files][remove files]
]
files: head files

;-- Create icons from images:
icons: []
incr: 200 / max 1 length? files
total: 0
foreach f files [
    filn/text: f  show filn
    prog/data: to-integer total: total + incr show prog
    append icons to-image make face [
        size: 40x40
        color: 40.40.80
        image: load-image f
        effect: [aspect]
    ]
]
unview/all

;-- Main display:
view layout [
    ; backtile carlwaves effect [tile gradcol 1x1 0.0.160 200.0.0]
    backtile carlwaves effect [tile]
    
    title reform ["REBOL" system/script/header/title 
        system/script/header/version] font [size: 16]
    across space 0
    vx: list 84x600 200.200.200 [
        size 80x74 space 0
        at 20x4 i: image 40x40 [
            img/image: load selection: i/data show vx show img]
        at 1x44 text 78x32 center font [
            size: 10 color: black shadow: none]
    ] supply [
        face/show?: true
        count: count + num
        if count > length? files [face/show?: false exit]
        either index = 2 [face/text: files/:count][
            face/effect: if selection = files/:count [[invert]]
            face/image: icons/:count
            face/data: files/:count
        ]
    ]
    vv: slider vx/size * 0x1 + 16x0 length? files [
        num: vv/data - 1 show vx]
    pad 20
    img: box 600x600 40.40.80 effect none
    at 638x20
    tgl: toggle 50x24 #"s" "Fit" [
        img/effect: either tgl/state ['aspect][none] show img
    ]
    button "Quit" 50x24 #"^(ESC)" [quit]
]
