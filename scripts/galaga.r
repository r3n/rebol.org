REBOl [
        Title: "Demo Msx Emulation Galaga"
        Author: "Guest2"
        Date: 26-Feb-2007
        Version: 1.0.1
        File: %galaga.r
        Purpose: "MSX Emulation using rebcode"
        Library: [
                Level: 'advanced
                Type: [demo game fun rebcode]
                Domain: [game]
                Platform: [win]
                Tested-under: none
                Support: none
                License: none
                See-also: none
        ]
        History: [
                [1.0.0 26-Feb-2007 "First version"]
                [1.0.1 28-Feb-2007 "Speed improvement and PSG emulation attempt"]
        ]

 ]


REBOL []

CPVRM: func [
{Address  : #005C Block transfer to VRAM from memory}
	BC "blocklength"
	DE "Start address of VRAM"
	HL "Start address of memory"
	/local txt
][
   ;print ["copy RAM to VRAM: from" to-hex HL "to" to-hex DE "length" BC]
   change at video de + 1  cp/part at mem hl + 1 bc 

]

FILVRM: func [
{Address  : #0056 Function : fill VRAM with value}
	A  "data byte"
	BC "length of the area to be written"
	HL "start address"
][
	;print ["fill VRAM with value: at" to-hex HL "with" A "length" BC]
	change/dup at video HL + 1 to char! A BC 
	
]

WRTVDP: func [
{Address  : #0047 Function : write data in the VDP-register}
	B "data to write"
	C "Number of the register"
	/local v
][
	;prin ["Set VDP:" enbase/base to-binary to-char B 2 "in" C]
	switch c [
		2 [	v: (B and 15) * 1024
			;print [",name table adr" to-hex v]
			;name-offset at video v + 1
		]
		3 [	v: B * 64
			;print [",color table adr" to-hex v]
			;color-offset: at video v + 1
		]
		4 [	v: (B and 7) * 2048
			;print [",pattern table adr" to-hex v]
			;pattern-offset: at video v + 1
			;if mode = 2 [halt]
		]
		5 [	v: (B and 127) * 128
			;print [",sprite attribut adr" to-hex v]
		
		]
		6 [	v: (B and 7) * 2048
			;print [",sprite pattern table adr" to-hex v]
			
		]
	]
	;print ""
]

vdpsts: 159
;galaga: read/binary %mem.bin

modif?: false
RDVDP: does [
{Address  : #013E Function : Reads VDP status register
Output   : A  - Value which was read}
	vdpsts: vdpsts xor 128
	'print ["Reads VDP status register" vdpsts]
	;show-screen
	_a: vdpsts 
]

WRTVRM: rebcode [
{Address  : #004D Function : Writes data in VRAM}
	HL "address write"
	A "value write"
][
	;print ["Write byte in VRAM at" to-hex HL "=" to-hex a to-char a a]
	pokez video hl a

]

RDPSG: func [
{Address  : #0096 Function : Reads value from PSG-register}
	A "PSG-register read"
][
	;print ["Reads value from PSG-register" A]
	_a: to integer! #7F
]

wait 0
sound-port: open sound://

; Set up the sound sample parameters:
sample: make sound [
	rate: 22100 
	channels: 1
	bits: 8
	volume: 0.5
	data: #{}
]
sample-rate: sample/rate
inter: 50
tone: make binary! sample-len: to-integer sample/rate / inter + 0.5
PSG: [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
clock: to-integer 3579545 / 32 
Fa': Fb': Fc': -1
ToneA1: ToneB1: ToneC1: ToneA2: ToneB2: ToneC2: ToneA3: ToneB3: ToneC3: 0
VolA: VolB: VolC: 0
mixer: rebcode [/Local pitch split val1 val2 val3][
	set pitch sample-len
	while [gt.i pitch 0][
		eq.i ToneA2 0 ift [set.i ToneA2 ToneA3 not ToneA1]
		eq.i ToneB2 0 ift [set.i ToneB2 ToneB3 not ToneB1]
		eq.i ToneC2 0 ift [set.i ToneC2 ToneC3 not ToneC1]
		
		set val1 ToneA1
		mul.i val1 VolA
		div.i val1 15
		set val2 ToneB1
		mul.i val2 VolB
		div.i val2 15
		set val3 ToneC1
		mul.i val3 VolC
		div.i val3 15
		
		add.i val1 val2
		add.i val1 val3
		mul.i val1 20
		add.i val1 128
		
		set split ToneA2
		min.i split ToneB2
		min.i split ToneC2
		min.i split pitch
		
		do dummy [insert/dup tone to char! val1 split]
		
		sub.i ToneA2 split
		sub.i ToneB2 split
		sub.i ToneC2 split
		tail tone
		sub.i pitch split
	]
]

WRTPSG: rebcode [
 A 
 E
 /local Fa Pb Pc low
][
   eq.i a 0 ift [
   	;print PSG
   	set tmp 0
   	
	pick Fa PSG 2
	and Fa 15
	lsl Fa 8
	pick low PSG 1
	or Fa low
   	neq.i Fa 0 ift [
   		set.i tmp clock
   		div.i tmp Fa
   		set.i Fa tmp
   	]
   	neq.i Fa' Fa ift [
   	    set.i ToneA1 1 
   	    neq.i Fa 0 either [
   	    	set.i tmp sample-rate
   	    	div.i tmp Fa
   	    	div.i tmp 2
   	    	set.i ToneA2 tmp
   	    	set.i ToneA3 tmp
   	    ][set.i ToneA2 10000 set.i ToneA3 10000]
   	]
   	set.i Fa' Fa
   	
	pick Fb PSG 4
	and Fb 15
	lsl Fb 8
	pick low PSG 3
	or Fb low
   	neq.i Fb 0 ift [
   		set.i tmp clock
   		div.i tmp Fb
   		set.i Fb tmp
   	]
   	neq.i Fb' Fb ift [
   	    set.i ToneB1 1 
   	    neq.i Fb 0 either [
   	    	set.i tmp sample-rate
   	    	div.i tmp Fb
   	    	div.i tmp 2
   	    	set.i ToneB2 tmp
   	    	set.i ToneB3 tmp
   	    ][set.i ToneB2 10000 set.i ToneB3 10000]
   	]
   	set.i Fb' Fb

	pick Fc PSG 6
	and Fc 15
	lsl Fc 8
	pick low PSG 5
	or Fc low
   	neq.i Fc 0 ift [
   		set.i tmp clock
   		div.i tmp Fc
   		set.i Fc tmp
   	]
   	neq.i Fc' Fc ift [
   	    set.i ToneC1 1 
   	    neq.i Fc 0 either [
   	    	set.i tmp sample-rate
   	    	div.i tmp Fc
   	    	div.i tmp 2
   	    	set.i ToneC2 tmp
   	    	set.i ToneC3 tmp
   	    ][set.i ToneC2 10000 set.i ToneC3 10000]
   	]
   	set.i Fc' Fc
   	
   	sett Fa iff [sett Fb] iff [sett Fc]
   	ift [
   	   	pick VolA PSG 9
	   	and VolA 15
	   	pick VolB PSG 10
	   	and VolB 15
	   	pick VolC PSG 11
   		and VolC 15  
   		apply dummy mixer []
   	];[
   		do dummy [
   			if all [not empty? head tone wait [sound-port 0]][
   				sample/data: cp tone: head tone
   				insert sound-port sample
   				clear tone
   			]
   		]
   	;]
   	
   ]
   pokez PSG a e
 ]

_key: 0
SNSMAT: func [
{Address  : #0141 Function : Returns the value of the specified line from the keyboard matrix}
	A "for the specified line"
][
	'print ["line from the keyboard" A]
	_a: FF  ;(the bit corresponding to the pressed key will be 0)
	if all [A = 8 _key <> 0] [_a: _key _key: _key or 1]
	
]

Call_Bios: does compose/deep [
	switch/default pc [
		(to integer! #0138)  [] ;SKIP :Reads the primary slot register
		(to integer! #013b)  [] ;SKIP Writes value to the primary slot register
		(to integer! #0047) [WRTVDP _b _c] ;Writes data in VDP registers
		(to integer! #0093) [WRTPSG _a _e] ; Write data to PSG register
		(to integer! #005c) [CPVRM _b * 256 + _c _d * 256 + _e _h * 256 + _l] ;Block transfer to VRAM from memory
		(to integer! #0056) [FILVRM _a _b * 256 + _c _h * 256 + _l]
		(to integer! #013e) [RDVDP] ;Reads VDP status register
		(to integer! #004d) [WRTVRM _h * 256 + _l _a] ;Writes byte in VRAM
		(to integer! #0096) [RDPSG _a] ;Reads value from PSG-register
		(to integer! #0141) [SNSMAT _a] ;Returns the value of the specified line from the
	][
		print ["Adresse inconnue:" at to-hex pc 5] halt
	]
]

macro: func ['var blk][
	set var func 
		either find blk [(&3)] [['&1 '&2 '&3]]
			[either find blk [(&2)] [['&1 '&2]][['&1]]] 
		reduce ['compose/deep blk]
	[]
]

macro _inc [
	and _f 256 ;keep carry
	add.i (&1) (&2)
	and (&1) 255 
	or _f (&1); 
]
macro _inc16 [
	lsl (&1) 8
	or (&1) (&2)
	add.i (&1) (&3)
	set.i (&2) (&1)
	and (&2) 255
	lsr (&1) 8
	and (&2) 255
]
macro _add [
	add.i (&1) (&2)
	set.i _f (&1)
	and (&1) 255
]
macro _sub [
	sub.i (&1) (&2)
	set.i _f (&1)
	and (&1) 255
]

;memv: make image! 256x256
;go: does [view/new layout [ii: image memv]]
;tup: [0 0 0]
track: [pokez tup 0 (&1) pokez tup 1 255 pokez tup 2 (&1) apply point to [tuple! tup] pokez memv adr point
	;apply dummy show [ii]
] 



err?: false
err: [do dummy [print [at to-hex sv_pc 5 cp/part at mem 1 + sv_pc len op-code ]halt]]
cont: [bra start]
macro set-op [add.i len 1 pickz (&1) mem pc add.i pc 1]
get-decal: [
	add.i len 1 pickz decal mem pc add.i pc 1
	ext8 decal ;gt.i decal 127 ift [sub.i decal 256]
]
macro writem [pokez mem adr (&1)] track
macro readm [pickz (&1) mem adr]
macro x [set.i adr (&1) lsl adr 8 or adr (&2)]
macro _popW [pickz tmp mem _sp add.i _sp 1 pickz (&1) mem _sp lsl (&1) 8 add.i (&1) tmp add.i _sp 1
	;do dummy [print ['pop at to-hex (&1) 5 _sp]]
]	
macro _pop [pickz (&2) mem _sp add.i _sp 1 pickz (&1) mem _sp add.i _sp 1
	;do dummy [print ['pop (&1) (&2) _sp]]
]	
macro _push [ ;do dummy [print ['push (&1) (&2) _sp]] 
	sub.i _sp 1 pokez mem _sp (&1) sub.i _sp 1 pokez mem _sp (&2)
]

code: [
  NOP LD_BC_WORD LD_xBC_A INC_BC INC_B DEC_B LD_B_BYTE RLCA 
  EX_AF_AF ADD_HL_BC LD_A_xBC DEC_BC INC_C DEC_C LD_C_BYTE RRCA 
  DJNZ LD_DE_WORD LD_xDE_A INC_DE INC_D DEC_D LD_D_BYTE RLA 
  JR ADD_HL_DE LD_A_xDE DEC_DE INC_E DEC_E LD_E_BYTE RRA 
  JR_NZ LD_HL_WORD LD_xWORD_HL INC_HL INC_H DEC_H LD_H_BYTE DAA 
  JR_Z ADD_HL_HL LD_HL_xWORD DEC_HL INC_L DEC_L LD_L_BYTE CPL 
  JR_NC LD_SP_WORD LD_xWORD_A INC_SP INC_xHL DEC_xHL LD_xHL_BYTE SCF 
  JR_C ADD_HL_SP LD_A_xWORD DEC_SP INC_A DEC_A LD_A_BYTE CCF 
  LD_B_B LD_B_C LD_B_D LD_B_E LD_B_H LD_B_L LD_B_xHL LD_B_A 
  LD_C_B LD_C_C LD_C_D LD_C_E LD_C_H LD_C_L LD_C_xHL LD_C_A 
  LD_D_B LD_D_C LD_D_D LD_D_E LD_D_H LD_D_L LD_D_xHL LD_D_A 
  LD_E_B LD_E_C LD_E_D LD_E_E LD_E_H LD_E_L LD_E_xHL LD_E_A 
  LD_H_B LD_H_C LD_H_D LD_H_E LD_H_H LD_H_L LD_H_xHL LD_H_A 
  LD_L_B LD_L_C LD_L_D LD_L_E LD_L_H LD_L_L LD_L_xHL LD_L_A 
  LD_xHL_B LD_xHL_C LD_xHL_D LD_xHL_E LD_xHL_H LD_xHL_L HALT LD_xHL_A 
  LD_A_B LD_A_C LD_A_D LD_A_E LD_A_H LD_A_L LD_A_xHL LD_A_A 
  ADD_B ADD_C ADD_D ADD_E ADD_H ADD_L ADD_xHL ADD_A 
  ADC_B ADC_C ADC_D ADC_E ADC_H ADC_L ADC_xHL ADC_A 
  SUB_B SUB_C SUB_D SUB_E SUB_H SUB_L SUB_xHL SUB_A 
  SBC_B SBC_C SBC_D SBC_E SBC_H SBC_L SBC_xHL SBC_A 
  AND_B AND_C AND_D AND_E AND_H AND_L AND_xHL AND_A 
  XOR_B XOR_C XOR_D XOR_E XOR_H XOR_L XOR_xHL XOR_A 
  OR_B OR_C OR_D OR_E OR_H OR_L OR_xHL OR_A 
  CP_B CP_C CP_D CP_E CP_H CP_L CP_xHL CP_A 
  RET_NZ POP_BC JP_NZ JP CALL_NZ PUSH_BC ADD_BYTE RST00 
  RET_Z RET JP_Z PFX_CB CALL_Z CALL ADC_BYTE RST08 
  RET_NC POP_DE JP_NC OUTA CALL_NC PUSH_DE SUB_BYTE RST10 
  RET_C EXX JP_C INA CALL_C PFX_DD SBC_BYTE RST18 
  RET_PO POP_HL JP_PO EX_HL_xSP CALL_PO PUSH_HL AND_BYTE RST20 
  RET_PE JP_HL JP_PE EX_DE_HL CALL_PE PFX_ED XOR_BYTE RST28 
  RET_P POP_AF JP_P DI CALL_P PUSH_AF OR_BYTE RST30 
  RET_M LD_SP_HL JP_M EI CALL_M PFX_FD CP_BYTE RST38
]

codeFD: [
  DB DB DB DB DB DB DB DB
  DB ADD_IY_BC DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB
  DB ADD_IY_DE DB DB DB DB DB DB 
  DB LD_IY_WORD LD_xWORD_IY INC_IY DB DB DB DB 
  DB ADD_IY_IY LD_IY_xWORD DEC_IY DB DB DB DB 
  DB DB DB DB INC_xIY+BYTE DEC_xIY+BYTE LD_xIY+BYTE_BYTE DB 
  DB ADD_IY_SP DB DB DB DB DB DB 
  DB DB DB DB DB DB LD_B_xIY+BYTE DB 
  DB DB DB DB DB DB LD_C_xIY+BYTE DB 
  DB DB DB DB DB DB LD_D_xIY+BYTE DB 
  DB DB DB DB DB DB LD_E_xIY+BYTE DB 
  DB DB DB DB DB DB LD_H_xIY+BYTE DB 
  DB DB DB DB DB DB LD_L_xIY+BYTE DB 
  LD_xIY+BYTE_B LD_xIY+BYTE_C LD_xIY+BYTE_D LD_xIY+BYTE_E LD_xIY+BYTE_H LD_xIY+BYTE_L DB LD_xIY+BYTE_A 
  DB DB DB DB DB DB LD_A_xIY+BYTE DB 
  DB DB DB DB DB DB ADD_xIY+BYTE DB 
  DB DB DB DB DB DB ADC_xIY+BYTE DB 
  DB DB DB DB DB DB SUB_xIY+BYTE DB 
  DB DB DB DB DB DB SBC_xIY+BYTE DB 
  DB DB DB DB DB DB AND_xIY+BYTE DB 
  DB DB DB DB DB DB XOR_xIY+BYTE DB 
  DB DB DB DB DB DB OR_xIY+BYTE DB 
  DB DB DB DB DB DB CP_xIY+BYTE DB 
  DB DB DB DB DB DB DB DB
  DB DB DB PFX_FDCB DB DB DB DB
  DB DB DB DB DB DB DB DB
  DB DB DB DB DB DB DB DB
  DB POP_IY DB DB DB PUSH_IY DB DB 
  DB nop DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB
  DB LD_SP_IY DB DB DB DB DB DB
]

codeDD: [
  DB DB DB DB DB DB DB DB
  DB ADD_IX_BC DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB
  DB ADD_IX_DE DB DB DB DB DB DB 
  DB LD_IX_WORD LD_xWORD_IX INC_IX DB DB DB DB 
  DB ADD_IX_IX LD_IX_xWORD DEC_IX DB DB DB DB 
  DB DB DB DB INC_xIX+BYTE DEC_xIX+BYTE LD_xIX+BYTE_BYTE DB 
  DB ADD_IX_SP DB DB DB DB DB DB 
  DB DB DB DB DB DB LD_B_xIX+BYTE DB 
  DB DB DB DB DB DB LD_C_xIX+BYTE DB 
  DB DB DB DB DB DB LD_D_xIX+BYTE DB 
  DB DB DB DB DB DB LD_E_xIX+BYTE DB 
  DB DB DB DB DB DB LD_H_xIX+BYTE DB 
  DB DB DB DB DB DB LD_L_xIX+BYTE DB 
  LD_xIX+BYTE_B LD_xIX+BYTE_C LD_xIX+BYTE_D LD_xIX+BYTE_E LD_xIX+BYTE_H LD_xIX+BYTE_L DB LD_xIX+BYTE_A 
  DB DB DB DB DB DB LD_A_xIX+BYTE DB 
  DB DB DB DB DB DB ADD_xIX+BYTE DB 
  DB DB DB DB DB DB ADC_xIX+BYTE DB 
  DB DB DB DB DB DB SUB_xIX+BYTE DB 
  DB DB DB DB DB DB SBC_xIX+BYTE DB 
  DB DB DB DB DB DB AND_xIX+BYTE DB 
  DB DB DB DB DB DB XOR_xIX+BYTE DB 
  DB DB DB DB DB DB OR_xIX+BYTE DB 
  DB DB DB DB DB DB CP_xIX+BYTE DB 
  DB DB DB DB DB DB DB DB
  DB DB DB PFX_DDCB DB DB DB DB
  DB DB DB DB DB DB DB DB
  DB DB DB DB DB DB DB DB
  DB POP_IX DB DB DB PUSH_IX DB DB 
  DB nop DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB
  DB LD_SP_IX DB DB DB DB DB DB
]

codeED: [
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  IN_B_xC OUT_xC_B SBC_HL_BC LD_xWORD_BC NEG RETN IM_0 LD_I_A 
  IN_C_xC OUT_xC_C ADC_HL_BC LD_BC_xWORD DB  RETI DB LD_R_A 
  IN_D_xC OUT_xC_D SBC_HL_DE LD_xWORD_DE DB DB IM_1 LD_A_I 
  IN_E_xC OUT_xC_E ADC_HL_DE LD_DE_xWORD DB DB IM_2 LD_A_R 
  IN_H_xC OUT_xC_H SBC_HL_HL LD_xWORD_HL DB DB DB RRD 
  IN_L_xC OUT_xC_L ADC_HL_HL LD_HL_xWORD DB DB DB RLD 
  IN_F_xC DB SBC_HL_SP LD_xWORD_SP DB DB DB DB 
  IN_A_xC OUT_xC_A ADC_HL_SP LD_SP_xWORD DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  LDI CPI INI OUTI DB DB DB DB 
  LDD CPD IND OUTD DB DB DB DB 
  LDIR CPIR INIR OTIR DB DB DB DB 
  LDDR CPDR INDR OTDR DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
  DB DB DB DB DB DB DB DB 
]
codeCB: [
  RLC_B RLC_C RLC_D RLC_E RLC_H RLC_L RLC_xHL RLC_A 
  RRC_B RRC_C RRC_D RRC_E RRC_H RRC_L RRC_xHL RRC_A 
  RL_B RL_C RL_D RL_E RL_H RL_L RL_xHL RL_A 
  RR_B RR_C RR_D RR_E RR_H RR_L RR_xHL RR_A 
  SLA_B SLA_C SLA_D SLA_E SLA_H SLA_L SLA_xHL SLA_A 
  SRA_B SRA_C SRA_D SRA_E SRA_H SRA_L SRA_xHL SRA_A 
  SLL_B SLL_C SLL_D SLL_E SLL_H SLL_L SLL_xHL SLL_A 
  SRL_B SRL_C SRL_D SRL_E SRL_H SRL_L SRL_xHL SRL_A 
  BIT0_B BIT0_C BIT0_D BIT0_E BIT0_H BIT0_L BIT0_xHL BIT0_A 
  BIT1_B BIT1_C BIT1_D BIT1_E BIT1_H BIT1_L BIT1_xHL BIT1_A 
  BIT2_B BIT2_C BIT2_D BIT2_E BIT2_H BIT2_L BIT2_xHL BIT2_A 
  BIT3_B BIT3_C BIT3_D BIT3_E BIT3_H BIT3_L BIT3_xHL BIT3_A 
  BIT4_B BIT4_C BIT4_D BIT4_E BIT4_H BIT4_L BIT4_xHL BIT4_A 
  BIT5_B BIT5_C BIT5_D BIT5_E BIT5_H BIT5_L BIT5_xHL BIT5_A 
  BIT6_B BIT6_C BIT6_D BIT6_E BIT6_H BIT6_L BIT6_xHL BIT6_A 
  BIT7_B BIT7_C BIT7_D BIT7_E BIT7_H BIT7_L BIT7_xHL BIT7_A 
  RES0_B RES0_C RES0_D RES0_E RES0_H RES0_L RES0_xHL RES0_A 
  RES1_B RES1_C RES1_D RES1_E RES1_H RES1_L RES1_xHL RES1_A 
  RES2_B RES2_C RES2_D RES2_E RES2_H RES2_L RES2_xHL RES2_A 
  RES3_B RES3_C RES3_D RES3_E RES3_H RES3_L RES3_xHL RES3_A 
  RES4_B RES4_C RES4_D RES4_E RES4_H RES4_L RES4_xHL RES4_A 
  RES5_B RES5_C RES5_D RES5_E RES5_H RES5_L RES5_xHL RES5_A 
  RES6_B RES6_C RES6_D RES6_E RES6_H RES6_L RES6_xHL RES6_A 
  RES7_B RES7_C RES7_D RES7_E RES7_H RES7_L RES7_xHL RES7_A   
  SET0_B SET0_C SET0_D SET0_E SET0_H SET0_L SET0_xHL SET0_A 
  SET1_B SET1_C SET1_D SET1_E SET1_H SET1_L SET1_xHL SET1_A 
  SET2_B SET2_C SET2_D SET2_E SET2_H SET2_L SET2_xHL SET2_A 
  SET3_B SET3_C SET3_D SET3_E SET3_H SET3_L SET3_xHL SET3_A 
  SET4_B SET4_C SET4_D SET4_E SET4_H SET4_L SET4_xHL SET4_A 
  SET5_B SET5_C SET5_D SET5_E SET5_H SET5_L SET5_xHL SET5_A 
  SET6_B SET6_C SET6_D SET6_E SET6_H SET6_L SET6_xHL SET6_A 
  SET7_B SET7_C SET7_D SET7_E SET7_H SET7_L SET7_xHL SET7_A
]

sv_pc: 0
len: 0
_a: _f: _b: _c: _d: _e: _h: _l: _sp: _i: _j: _x: _y: 0
_a': _f': _b': _c': _d': _e': _h': _l': 0
_tmp: tmp: low: high: tmp1: tmp2: 0
hex: func [v][at to-hex v 7]
trace: 0
_sa: _sf: _sbc: _sde: _shl: _ssp: _s: _p: decal: 0
XXCB?: 0

debug: does [
	if sv_pc <> 0 [
		_bc: _b * 256 + _c _de: _d * 256 + _e _hl: _h * 256 + _l
		bina: next next form cp/part at mem 1 + sv_pc len
		clear back tail bina
		insert tail bina "        " bina: cp/part bina 10
		insert tail op-code: form op-code "              " op-code: cp/part op-code  10
		print [at to-hex sv_pc 5 bina  op-code ";"
			reduce compose [
				(either _a <> _sa [_sa: _a ["A=" hex _a]][[]])
				(either _f <> _sf [_sf: _f ["F=" at to-hex _f 6]][[]])
				(either _bc <> _sbc [_sbc: _bc ["BC=" at to-hex _bc 5]][[]])
				(either _de <> _sde [_sde: _de ["DE=" at to-hex _de 5]][[]])
				(either _hl <> _shl [_shl: _hl ["HL=" at to-hex _hl 5]][[]])
				(either _sp <> _ssp [_ssp: _sp ["SP=" at to-hex _sp 5]][[]])
			]
		]
	]
	input
]


VM: rebcode [] compose/deep [
label start
eq.i XXCB? 1 ift [set.i _h _sh set.i _l _sl set.i XXCB? 0]
eq.i stop pc ift [set.i trace 1]
eq.i trace 1 ift [apply dummy debug []]
set.i sv_pc pc
lt.i pc (16 * 1024) braf continue 
	apply dummy call_bios [] bra RET
label continue
	pickz op mem pc
	eq.i op (to integer! #18) ift [ ;check end-less loop to enable interruptions
		add.i pc 1
		pickz op mem pc
		sub.i pc 1
		eq.i op (to integer! #fe) ift [
			set.i pc (to integer! #404C)  apply dummy show-screen [] 
			;set.i trace 1
			
		]
		pickz op mem pc
	]
	pickz op-code code op
	add.i pc 1
	set.i len 1
	brab [(code)] op

label PFX_ED
	pickz op mem pc
	pickz op-code codeED op
	add.i pc 1
	add.i len 1
	brab  [(codeED)] op

label PFX_FD
	pickz op mem pc
	pickz op-code codeFD op
	add.i pc 1
	add.i len 1
	brab  [(codeFD)] op

label PFX_DD
	pickz op mem pc
	pickz op-code codeDD op
	add.i pc 1
	add.i len 1
	brab  [(codeDD)] op

label PFX_CB
	pickz op mem pc
	pickz op-code codeCB op
	add.i pc 1
	add.i len 1
	brab  [(codeCB)] op

label PFX_FDCB 
	set.i XXCB? 1
	(get-decal) 
	set.i _sh _h set.i _sl _l
	set.i _h _i lsl _h 8 add.i _h _y add.i _h decal
	set.i _l _h and _l 255 lsr _h 8
	bra PFX_CB
label PFX_DDCB 
	set.i XXCB? 1
	(get-decal) 
	set.i _sh _h set.i _sl _l
	set.i _h _j lsl _h 8 add.i _h _x add.i _h decal
	set.i _l _h and _l 255 lsr _h 8
	bra PFX_CB
	
label DB (err) (cont)
label NOP (cont) 

label LD_BC_WORD (set-op _c) (set-op _b) (cont)
label LD_DE_WORD (set-op _e) (set-op _d) (cont)
label LD_HL_WORD (set-op _l) (set-op _h) (cont)
label LD_IY_WORD (set-op _y) (set-op _i) (cont)
label LD_IX_WORD (set-op _x) (set-op _j) (cont)
label LD_SP_WORD (set-op _p) (set-op _sp) lsl _sp 8 add.i _sp _p  (cont)
label LD_SP_HL set.i _sp _h lsl _sp 8 add.i _sp _l (cont)
label LD_SP_IX set.i _sp _j lsl _sp 8 add.i _sp _x (cont)
label LD_SP_IY set.i _sp _i lsl _sp 8 add.i _sp _y (cont)


label LD_xBC_A (x _b _c) (writem _a) (cont)
label LD_xDE_A (x _d _e) (writem _a) (cont)
label LD_xHL_A (x _h _l) (writem _a) (cont)
label LD_xIX+BYTE_A (get-decal) (x _j _x) add.i adr decal (writem _a) (cont)
label LD_xIY+BYTE_A (get-decal) (x _i _y) add.i adr decal (writem _a) (cont)
label LD_A_xBC (x _b _c) (readm _a) (cont)
label LD_A_xDE (x _d _e) (readm _a) (cont)
label LD_A_xHL (x _h _l) (readm _a) (cont)
label LD_xHL_BYTE (set-op tmp) (x _h _l) (writem tmp) (cont)
label LD_xIX+BYTE_BYTE (get-decal) (set-op tmp) (x _j _x) add.i adr decal (writem tmp) (cont)
label LD_xIY+BYTE_BYTE (get-decal) (set-op tmp) (x _i _y) add.i adr decal (writem tmp) (cont)

label LD_A_B set.i _a _b (cont)
label LD_A_C set.i _a _c (cont)
label LD_A_D set.i _a _d (cont)
label LD_A_E set.i _a _e (cont)
label LD_A_H set.i _a _h (cont)
label LD_A_L set.i _a _l (cont)
label LD_A_xHL (x _h _l) (readm _a) (cont)
label LD_A_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _a) (cont)
label LD_A_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _a) (cont)
label LD_A_A (cont)

label LD_B_B (cont)
label LD_B_C set.i _b _c (cont)
label LD_B_D set.i _b _d (cont)
label LD_B_E set.i _b _e (cont)
label LD_B_H set.i _b _h (cont)
label LD_B_L set.i _b _l (cont)
label LD_B_xHL (x _h _l) (readm _b) (cont)
label LD_B_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _b) (cont)
label LD_B_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _b) (cont)
label LD_B_A set.i _b _a (cont)

label LD_C_B set.i _c _b (cont)
label LD_C_C (cont)
label LD_C_D set.i _c _d (cont)
label LD_C_E set.i _c _e (cont)
label LD_C_H set.i _c _h (cont)
label LD_C_L set.i _c _l (cont)
label LD_C_xHL (x _h _l) (readm _c) (cont)
label LD_C_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _c) (cont)
label LD_C_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _c) (cont)
label LD_C_A set.i _c _a (cont)

label LD_D_B set.i _d _b (cont)
label LD_D_C set.i _d _c (cont)
label LD_D_D (cont)
label LD_D_E set.i _d _e (cont)
label LD_D_H set.i _d _h (cont)
label LD_D_L set.i _d _l (cont)
label LD_D_xHL (x _h _l) (readm _d) (cont)
label LD_D_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _d) (cont)
label LD_D_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _d) (cont)
label LD_D_A set.i _d _a (cont)

label LD_E_B set.i _e _b (cont)
label LD_E_C set.i _e _c (cont)
label LD_E_D set.i _e _d (cont)
label LD_E_E (cont)
label LD_E_H set.i _e _h (cont)
label LD_E_L set.i _e _l (cont)
label LD_E_xHL (x _h _l) (readm _e) (cont)
label LD_E_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _e) (cont)
label LD_E_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _e) (cont)
label LD_E_A set.i _e _a (cont)

label LD_H_B set.i _h _b (cont)
label LD_H_C set.i _h _c (cont)
label LD_H_D set.i _h _d (cont)
label LD_H_E set.i _h _e (cont)
label LD_H_H  (cont)
label LD_H_L set.i _h _l (cont)
label LD_H_xHL (x _h _l) (readm _h) (cont)
label LD_H_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _h) (cont)
label LD_H_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _h) (cont)
label LD_H_A set.i _h _a (cont)

label LD_xHL_B (x _h _l) (writem _b) (cont)
label LD_xHL_C (x _h _l) (writem _c) (cont)
label LD_xHL_D (x _h _l) (writem _d) (cont)
label LD_xHL_E (x _h _l) (writem _e) (cont)
label LD_xHL_H (x _h _l) (writem _h) (cont)
label LD_xHL_L (x _h _l) (writem _l) (cont)
label LD_xHL_xHL  (cont)
label LD_xHL_A (x _h _l) (writem _a) (cont)

label LD_xIX+BYTE_B (get-decal) (x _j _x) add.i adr decal (writem _b) (cont)
label LD_xIX+BYTE_C (get-decal) (x _j _x) add.i adr decal (writem _c) (cont)
label LD_xIX+BYTE_D (get-decal) (x _j _x) add.i adr decal (writem _d) (cont)
label LD_xIX+BYTE_E (get-decal) (x _j _x) add.i adr decal (writem _e) (cont)
label LD_xIX+BYTE_H (get-decal) (x _j _x) add.i adr decal (writem _h) (cont)
label LD_xIX+BYTE_L (get-decal) (x _j _x) add.i adr decal (writem _l) (cont)
label LD_xIX+BYTE_A (get-decal) (x _j _x) add.i adr decal (writem _a) (cont)

label LD_xIY+BYTE_B (get-decal) (x _i _y) add.i adr decal (writem _b) (cont)
label LD_xIY+BYTE_C (get-decal) (x _i _y) add.i adr decal (writem _c) (cont)
label LD_xIY+BYTE_D (get-decal) (x _i _y) add.i adr decal (writem _d) (cont)
label LD_xIY+BYTE_E (get-decal) (x _i _y) add.i adr decal (writem _e) (cont)
label LD_xIY+BYTE_H (get-decal) (x _i _y) add.i adr decal (writem _h) (cont)
label LD_xIY+BYTE_L (get-decal) (x _i _y) add.i adr decal (writem _l) (cont)
label LD_xIY+BYTE_A (get-decal) (x _i _y) add.i adr decal (writem _a) (cont)

label LD_L_B set.i _l _b (cont)
label LD_L_C set.i _l _c (cont)
label LD_L_D set.i _l _d (cont)
label LD_L_E set.i _l _e (cont)
label LD_L_H set.i _l _h  (cont)
label LD_L_L (cont)
label LD_L_xHL (x _h _l) (readm _l) (cont)
label LD_L_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm _l) (cont)
label LD_L_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm _l) (cont)
label LD_L_A set.i _l _a (cont)

label inc_a (_inc _a 1) (cont)
label inc_b (_inc _b 1) (cont)
label inc_c (_inc _c 1) (cont)
label inc_d (_inc _d 1) (cont)
label inc_e (_inc _e 1) (cont)
label inc_h (_inc _h 1) (cont)
label inc_l (_inc _l 1) (cont)

label INC_BC (_inc16 _b _c 1) (cont)
label INC_DE (_inc16 _d _e 1) (cont)
label INC_HL (_inc16 _h _l 1) (cont)
label INC_IX (_inc16 _j _x 1) (cont)
label INC_IY (_inc16 _i _y 1) (cont)
label INC_SP add.i _sp 1 (cont)
label INC_xHL (x _h _l) (readm tmp) (_inc tmp 1) (writem tmp) (cont)
label INC_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) (_inc tmp 1) (writem tmp) (cont)
label INC_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) (_inc tmp 1) (writem tmp) (cont)

label DEC_BC (_inc16 _b _c -1) (cont)
label DEC_SP sub.i _sp 1 (cont)
label DEC_DE (_inc16 _d _e -1) (cont)
label DEC_HL (_inc16 _h _l -1) (cont)
label DEC_IX (_inc16 _j _x -1) (cont)
label DEC_IY (_inc16 _i _y -1) (cont)
label DEC_xHL (x _h _l) (readm tmp) (_inc tmp -1) (writem tmp) (cont)
label DEC_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) (_inc tmp -1) (writem tmp) (cont)
label DEC_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) (_inc tmp -1) (writem tmp) (cont)


label dec_A (_inc _a -1) (cont)
label dec_B (_inc _b -1) (cont)
label dec_C (_inc _c -1) (cont)
label dec_D (_inc _d -1) (cont)
label dec_E (_inc _e -1) (cont)
label dec_H (_inc _h -1) (cont)
label dec_L (_inc _l -1) (cont)

label LD_A_BYTE (set-op _a) (cont)
label LD_B_BYTE (set-op _b) (cont)
label LD_C_BYTE (set-op _c) (cont)
label LD_D_BYTE (set-op _d) (cont)
label LD_E_BYTE (set-op _e) (cont)
label LD_H_BYTE (set-op _h) (cont)
label LD_L_BYTE (set-op _l) (cont)

label LD_A_xWORD (xWORD: compose [(set-op low) (set-op high) (x high low)]) (readm _a) (cont)
label LD_xWORD_A (xWORD) (writem _a) (cont)
label LD_xWORD_HL (xWORD) (writem _l) add.i adr 1 (writem _h) (cont)
label LD_xWORD_BC (xWORD) (writem _c) add.i adr 1 (writem _b) (cont)
label LD_xWORD_DE (xWORD) (writem _e) add.i adr 1 (writem _d) (cont)
label LD_xWORD_SP (xWORD) set.i _p _sp and _p 255 set.i _s _sp lsr _s 8 (writem _p) add.i adr 1 (writem _s) (cont)
label LD_xWORD_IX (xWORD) (writem _x) add.i adr 1 (writem _j) (cont)
label LD_xWORD_IY (xWORD) (writem _y) add.i adr 1 (writem _i) (cont)
label LD_BC_xWORD (xWORD) (readm _c) add.i adr 1 (readm _b) (cont)
label LD_HL_xWORD (xWORD) (readm _l) add.i adr 1 (readm _h) (cont)
label LD_DE_xWORD (xWORD) (readm _e) add.i adr 1 (readm _d) (cont)
label LD_SP_xWORD (xWORD) (readm _p) add.i adr 1 (readm _sp) lsl _sp 8 add.i _sp _p (cont)
label LD_IX_xWORD (xWORD) (readm _x) add.i adr 1 (readm _j) (cont)
label LD_IY_xWORD (xWORD) (readm _y) add.i adr 1 (readm _i) (cont)

label LD_BC_WORD (set-op _c) (set-op _b) (cont)

label RLCA ; roation left + carry
	and _f 255 ;reset carry
	lsl _a 1
	gt.i _a 255 ift [add.i _a 1 or _f 256]
	and _a 255
	(cont)
label RRCA ; rotation right + carry
	and _f 255 ;reset carry
	rotr _a 1
	lt.i _a 0 
	and _a 255 ift [or _a 128 or _f 256]
	(cont)
	
label EXX
	set.i tmp _b set.i _b _b' set.i _b' tmp 
	set.i tmp _c set.i _c _c' set.i _c' tmp
	set.i tmp _d set.i _d _d' set.i _d' tmp
	set.i tmp _e set.i _e _e' set.i _e' tmp
	set.i tmp _h set.i _h _h' set.i _h' tmp
	set.i tmp _l set.i _l _l' set.i _l' tmp
	(cont)
label EX_AF_AF 
	set.i _tmp _a set.i _a _a' set.i _a' _tmp 
	set.i _tmp _f set.i _f _f' set.i _f' _tmp (cont)
label EX_DE_HL 
	set.i _tmp _h set.i _h _d set.i _d _tmp 
	set.i _tmp _l set.i _l _e set.i _e _tmp (cont)

label ADD_HL_BC 
	(macro _incHL [
		and _f 255; reset carry
		add.i _h (&1)
		lsl _h 8
		add.i _h _l
		add.i _h (&2)
		set.i _l _h
		and _l 255
		lsr _h 8
		gt.i _h 255 ift [or _f 256]
		and _h 255
	])
	(_incHL _b _c) 	(cont)
label ADD_HL_DE (_incHL _d _e) (cont)
label ADD_HL_SP set.i _p _sp and _p 255 set.i _s _sp lsr _s 8 (_incHL _s _p) (cont)
label ADD_HL_HL (_incHL _h _l) (cont)

label ADD_IX_BC (
	macro _incIX [
		and _f 255; reset carry
		add.i _j (&1)
		lsl _j 8
		add.i _j _x
		add.i _j (&2)
		set.i _x _j
		and _x 255
		lsr _j 8
		gt.i _j 255 ift [or _f 256]
		and _j 255
	])
	(_incIX _b _c) 	(cont)
label ADD_IX_DE (_incIX _d _e) (cont)
label ADD_IX_SP set.i _p _sp and _p 255 set.i _s _sp lsr _s 8 (_incIX _s _p) (cont)
label ADD_IX_IX (_incIX _j _x) (cont)

label ADD_IY_BC (
	macro _incIY [
		and _f 255; reset carry
		add.i _i (&1)
		lsl _i 8
		add.i _i _y
		add.i _i (&2)
		set.i _y _i
		and _y 255
		lsr _i 8
		gt.i _i 255 ift [or _f 256]
		and _i 255
	])
	(_incIY _b _c) 	(cont)
label ADD_IY_DE (_incIY _d _e) (cont)
label ADD_IY_SP set.i _p _sp and _p 255 set.i _s _sp lsr _s 8 (_incIY _s _p) (cont)
label ADD_IY_IY (_incIY _i _y) (cont)

label DEC_BC (_inc16 _b _c -1) (cont)
label DJNZ 
	(_inc _b -1)
	(get-decal)
	eq.i _b 0 iff [add.i pc decal]
	(cont)
label RLA ;rotation left thru carry
	set.i tmp _f
	lsr tmp 8
	and _f 255 ;reset carry
	lsl _a 1
	or _a tmp ;add 1 if carry 
	gt.i _a 255 ift [or _f 256]
	and _a 255
	(cont)
label RRA 
	set.i tmp _f
	and tmp 256
	and _f 255 ;reset carry
	or _a tmp
	rotr _a 1
	lt.i _a 0 ift [or _f 256 and _a 255]
	(cont)
label JR (get-decal) add.i pc decal (cont)

label JR_NZ 
  	(get-decal)
  	(NZ: [
  		set.i tmp _f
  		and tmp 255
  		eq.i tmp 0 brat start
  	])
  	add.i pc decal (cont)
label JR_Z 
	(get-decal)
  	(Z: [
  		set.i tmp _f
  		and tmp 255
  		eq.i tmp 0 braf start
  	])
  	add.i pc decal (cont)
label JR_NC 
	(get-decal)
  	(NC: [
  		set.i tmp _f
  		and tmp 256
  		eq.i tmp 256 brat start
  	])
  	add.i pc decal (cont)
label JR_C 
	(get-decal)
  	(C: [
  		set.i tmp _f
  		and tmp 256
  		eq.i tmp 256 braf start
  	])
	add.i pc decal (cont)

label DAA 
	(cont) ;print 'DAA  (cont)
label CPL xor _a 255 (cont)
label SCF or _f 256 (cont) ; set carry flag
label CCF xor _f 256 (cont); carry inversion

label HALT (err) (cont)

label ADD_B (_add _a _b) (cont)
label ADD_C (_add _a _c) (cont)
label ADD_D (_add _a _d) (cont)
label ADD_E (_add _a _e) (cont)
label ADD_H (_add _a _h) (cont)
label ADD_L (_add _a _l) (cont)
label ADD_xHL (x _h _l) (readm tmp) (_add _a tmp) (cont)
label ADD_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) (_add _a tmp) (cont)
label ADD_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) (_add _a tmp) (cont)
label ADD_A (_add _a _a) (cont)
label ADD_BYTE (set-op tmp) (_add _a tmp) (cont)

label ADC_B lsr _f 8 add.i _a _f (_add _a _b) (cont)
label ADC_C lsr _f 8 add.i _a _f (_add _a _c) (cont)
label ADC_D lsr _f 8 add.i _a _f (_add _a _d) (cont)
label ADC_E lsr _f 8 add.i _a _f (_add _a _e) (cont)
label ADC_H lsr _f 8 add.i _a _f (_add _a _h) (cont)
label ADC_L lsr _f 8 add.i _a _f (_add _a _l) (cont)
label ADC_xHL lsr _f 8 add.i _a _f (x _h _l) (readm tmp) (_add _a tmp) (cont)
label ADC_xIX+BYTE (get-decal) lsr _f 8 add.i _a _f (x _j _x) add.i adr decal (readm tmp) (_add _a tmp) (cont)
label ADC_xIY+BYTE (get-decal) lsr _f 8 add.i _a _f (x _i _y) add.i adr decal (readm tmp) (_add _a tmp) (cont)
label ADC_A lsr _f 8 add.i _a _f (_add _a _a) (cont)
label ADC_BYTE (set-op tmp) lsr _f 8 add.i _a _f (_add _a tmp) (cont)

label SUB_B (_sub _a _b) (cont)
label SUB_C (_sub _a _c) (cont)
label SUB_D (_sub _a _d) (cont)
label SUB_E (_sub _a _e) (cont)
label SUB_H (_sub _a _h) (cont)
label SUB_L (_sub _a _l) (cont)
label SUB_xHL (x _h _l) (readm tmp) (_sub _a tmp) (cont)
label SUB_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) (_sub _a tmp) (cont)
label SUB_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) (_sub _a tmp) (cont)
label SUB_A set.i _a 0 set.i _f 0 (cont)
label SUB_BYTE (set-op tmp) (_sub _a tmp) (cont)


label SBC_B lsr _f 8 sub.i _a _f (_sub _a _b) (cont)
label SBC_C lsr _f 8 sub.i _a _f (_sub _a _c) (cont)
label SBC_D lsr _f 8 sub.i _a _f (_sub _a _d) (cont)
label SBC_E lsr _f 8 sub.i _a _f (_sub _a _e) (cont)
label SBC_H lsr _f 8 sub.i _a _f (_sub _a _h) (cont)
label SBC_L lsr _f 8 sub.i _a _f (_sub _a _l) (cont)
label SBC_xHL lsr _f 8 sub.i _a _f (x _h _l) (readm tmp) (_sub _a tmp) (cont)
label SBC_xIX+BYTE (get-decal) lsr _f 8 sub.i _a _f (x _j _x) add.i adr decal (readm tmp) (_sub _a tmp) (cont)
label SBC_xIY+BYTE (get-decal) lsr _f 8 sub.i _a _f (x _i _y) add.i adr decal (readm tmp) (_sub _a tmp) (cont)
label SBC_A lsr _f 8 sub.i _a _f (_sub _a _a) (cont)
label SBC_BYTE (set-op tmp) lsr _f 8 sub.i _a _f (_sub _a tmp) (cont)

label SBC_HL_DE 
	(macro _sbcHL [
		sub.i _h (&1) mul.i _h 256
		add.i _h _l sub.i _h (&2)
		lsr _f 8 sub.i _h _f
		set.i _f 0
		lt.i _h 0 ift [set.i _f 256]
		set.i _l _h and _l 255
		lsr _h 8 and _h 255
		or _f _h 
	])
	(_sbcHL _d _e) (cont)
label SBC_HL_BC  (_sbcHL _b _c) (cont)
label SBC_HL_HL  (_sbcHL _h _l) (cont)
label SBC_HL_SP  (err) (cont)

label AND_B and _a _b  set.i _f _a (cont)
label AND_C and _a _c  set.i _f _a (cont)
label AND_D and _a _d  set.i _f _a (cont)
label AND_E and _a _e  set.i _f _a (cont)
label AND_H and _a _h  set.i _f _a (cont)
label AND_L and _a _l  set.i _f _a (cont)
label AND_xHL (x _h _l) (readm tmp) and _a tmp  set.i _f _a (cont)
label AND_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) and _a tmp  set.i _f _a (cont)
label AND_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) and _a tmp  set.i _f _a (cont)
label AND_A set.i _f _a (cont)
label AND_BYTE (set-op tmp) and _a tmp  set.i _f _a (cont)

label XOR_B xor _a _b  set.i _f _a (cont)
label XOR_C xor _a _c  set.i _f _a (cont)
label XOR_D xor _a _d  set.i _f _a (cont)
label XOR_E xor _a _e  set.i _f _a (cont)
label XOR_H xor _a _h  set.i _f _a (cont)
label XOR_L xor _a _l  set.i _f _a (cont)
label XOR_xHL (x _h _l) (readm tmp) xor _a tmp  set.i _f _a (cont)
label XOR_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) xor _a tmp  set.i _f _a (cont)
label XOR_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) xor _a tmp  set.i _f _a (cont)
label XOR_A set.i _a 0 set.i _f _a (cont)
label XOR_BYTE (set-op tmp) xor _a tmp  set.i _f _a (cont)

label OR_B or _a _b  set.i _f _a (cont)
label OR_C or _a _c  set.i _f _a (cont)
label OR_D or _a _d  set.i _f _a (cont)
label OR_E or _a _e  set.i _f _a (cont)
label OR_H or _a _h  set.i _f _a (cont)
label OR_L or _a _l  set.i _f _a (cont)
label OR_xHL (x _h _l) (readm tmp) or _a tmp  set.i _f _a (cont)
label OR_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) or _a tmp  set.i _f _a (cont)
label OR_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) or _a tmp  set.i _f _a (cont)
label OR_A set.i _f _a (cont)
label OR_BYTE (set-op tmp) or _a tmp  set.i _f _a (cont)

label CP_B set.i _f _a sub.i _f _b (cont)
label CP_C set.i _f _a sub.i _f _c (cont)
label CP_D set.i _f _a sub.i _f _d (cont)
label CP_E set.i _f _a sub.i _f _e (cont)
label CP_H set.i _f _a sub.i _f _h (cont)
label CP_L set.i _f _a sub.i _f _l (cont)
label CP_xHL (x _h _l) (readm tmp) set.i _f _a sub.i _f tmp (cont)
label CP_xIX+BYTE (get-decal) (x _j _x) add.i adr decal (readm tmp) set.i _f _a sub.i _f tmp (cont)
label CP_xIY+BYTE (get-decal) (x _i _y) add.i adr decal (readm tmp) set.i _f _a sub.i _f tmp (cont)
label CP_A set.i _f 0 (cont)
label CP_BYTE (set-op tmp) set.i _f _a sub.i _f tmp (cont)

label RET_NZ (NZ) (_popW pc) (cont)
label RET_Z (Z) (_popW pc) (cont)
label RET_C (C) (_popW pc) (cont)
label RET_NC (NC) (_popW pc) (cont)
label RET_PO (err) (cont)
label RET (_popW pc) (cont)
label RET_M (M: [set.i _tmp _f and _tmp 128 eq.i _tmp 128 braf start]) (_popW pc) (cont)
label RET_P (P: [set.i _tmp _f and _tmp 128 eq.i _tmp 128 brat start]) (_popW pc) (cont)

label POP_BC (_pop _b _c) (cont)
label POP_DE (_pop _d _e) (cont)
label POP_HL (_pop _h _l) (cont)
label POP_AF (_pop _a _f) (cont)
label POP_IX (_pop _j _x) (cont)
label POP_IY (_pop _i _y) (cont)

label JP_NZ add.i len 2 add.i pc 2 (NZ) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_Z add.i len 2 add.i pc 2 (Z) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_C add.i len 2 add.i pc 2 (C) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_NC add.i len 2 add.i pc 2 (NC) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_PO (err) (cont)
label JP_PE (err) (cont)
label JP (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_HL set.i pc _h lsl pc 8 add.i pc _l (cont)
label JP_M add.i len 2 add.i pc 2 (M) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)
label JP_P add.i len 2 add.i pc 2 (P) sub.i pc 2 (set-op tmp) (set-op pc) sub.i pc 1 lsl pc 8 add.i pc tmp (cont)


label CALL_NZ (set-op low) (set-op high) (NZ) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL_Z (set-op low) (set-op high) (Z) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL_C (set-op low) (set-op high) (C) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL_NC (set-op low) (set-op high) (NC) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL_PO (err) (cont)
label CALL_M (set-op low) (set-op high) (M) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL_P (set-op low) (set-op high) (P) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)
label CALL (set-op low) (set-op high) set.i _tmp pc and _tmp 255 lsr pc 8 (_push pc _tmp) set.i pc high lsl pc 8 add.i pc low (cont)

label PUSH_BC (_push _b _c) (cont)
label PUSH_DE (_push _d _e) (cont)
label PUSH_HL (_push _h _l) (cont)
label PUSH_IX (_push _j _x) (cont)
label PUSH_IY (_push _i _y) (cont)
label PUSH_AF (_push _a _f) (cont) ;carry not saved (beware)

label EI (cont) 
label DI (cont)

label LDIR 
	lsl _b 8 add.i _b _c
	eq.i _b 0 ift [set.i _b (256 * 255)]
	lsl _h 8 add.i _h _l
	lsl _d 8 add.i _d _e
	loop _b [
		pickz tmp mem _h
		pokez mem _d tmp 
			;pokez tup 0 tmp pokez tup 1 255 pokez tup 2 tmp apply point to [tuple! tup] pokez memv _d point
		add.i _h 1
		add.i _d 1
	]
	set.i _b 0 set.i _c 0
	set.i _l _h and _l 255 lsr _h 8
	set.i _e _d and _e 255 lsr _d 8
	(cont)

label SET0_B or _b 1 (cont)
label SET0_C or _c 1 (cont)
label SET0_D or _d 1 (cont)
label SET0_E or _e 1 (cont)
label SET0_H or _h 1 (cont)
label SET0_L or _l 1 (cont)
label SET0_xHL (x _h _l) (readm _tmp) or _tmp 1 (writem _tmp) (cont)
label SET0_A or _a 1 (cont)

label SET1_B or _b 2 (cont)
label SET1_C or _c 2 (cont)
label SET1_D or _d 2 (cont)
label SET1_E or _e 2 (cont)
label SET1_H or _h 2 (cont)
label SET1_L or _l 2 (cont)
label SET1_xHL (x _h _l) (readm _tmp) or _tmp 2 (writem _tmp) (cont)
label SET1_A or _a 2 (cont)

label SET2_B or _b 4 (cont)
label SET2_C or _c 4 (cont)
label SET2_D or _d 4 (cont)
label SET2_E or _e 4 (cont)
label SET2_H or _h 4 (cont)
label SET2_L or _l 4 (cont)
label SET2_xHL (x _h _l) (readm _tmp) or _tmp 4 (writem _tmp) (cont)
label SET2_A or _a 4 (cont)

label SET3_B or _b 8 (cont)
label SET3_C or _c 8 (cont)
label SET3_D or _d 8 (cont)
label SET3_E or _e 8 (cont)
label SET3_H or _h 8 (cont)
label SET3_L or _l 8 (cont)
label SET3_xHL (x _h _l) (readm _tmp) or _tmp 8 (writem _tmp) (cont)
label SET3_A or _a 8 (cont)

label SET4_B or _b 16 (cont)
label SET4_C or _c 16 (cont)
label SET4_D or _d 16 (cont)
label SET4_E or _e 16 (cont)
label SET4_H or _h 16 (cont)
label SET4_L or _l 16 (cont)
label SET4_xHL (x _h _l) (readm _tmp) or _tmp 16 (writem _tmp) (cont)
label SET4_A or _a 16 (cont)

label SET5_B or _b 32 (cont)
label SET5_C or _c 32 (cont)
label SET5_D or _d 32 (cont)
label SET5_E or _e 32 (cont)
label SET5_H or _h 32 (cont)
label SET5_L or _l 32 (cont)
label SET5_xHL (x _h _l) (readm _tmp) or _tmp 32 (writem _tmp) (cont)
label SET5_A or _a 32 (cont)

label SET6_B or _b 64 (cont)
label SET6_C or _c 64 (cont)
label SET6_D or _d 64 (cont)
label SET6_E or _e 64 (cont)
label SET6_H or _h 64 (cont)
label SET6_L or _l 64 (cont)
label SET6_xHL (x _h _l) (readm _tmp) or _tmp 64 (writem _tmp) (cont)
label SET6_A or _a 64 (cont)

label SET7_B or _b 128 (cont)
label SET7_C or _c 128 (cont)
label SET7_D or _d 128 (cont)
label SET7_E or _e 128 (cont)
label SET7_H or _h 128 (cont)
label SET7_L or _l 128 (cont)
label SET7_xHL (x _h _l) (readm _tmp) or _tmp 128 (writem _tmp) (cont)
label SET7_A or _a 128 (cont)

label RES0_B and _b 254 (cont)
label RES0_C and _c 254 (cont)
label RES0_D and _d 254 (cont)
label RES0_E and _e 254 (cont)
label RES0_H and _h 254 (cont)
label RES0_L and _l 254 (cont)
label RES0_xHL (x _h _l) (readm _tmp) and _tmp 254 (writem _tmp) (cont)
label RES0_A and _a 254 (cont)

label RES1_B and _b 253 (cont)
label RES1_C and _c 253 (cont)
label RES1_D and _d 253 (cont)
label RES1_E and _e 253 (cont)
label RES1_H and _h 253 (cont)
label RES1_L and _l 253 (cont)
label RES1_xHL (x _h _l) (readm _tmp) and _tmp 253 (writem _tmp) (cont)
label RES1_A and _a 253 (cont)

label RES2_B and _b 251 (cont)
label RES2_C and _c 251 (cont)
label RES2_D and _d 251 (cont)
label RES2_E and _e 251 (cont)
label RES2_H and _h 251 (cont)
label RES2_L and _l 251 (cont)
label RES2_xHL (x _h _l) (readm _tmp) and _tmp 251 (writem _tmp) (cont)
label RES2_A and _a 251 (cont)

label RES3_B and _b 247 (cont)
label RES3_C and _c 247 (cont)
label RES3_D and _d 247 (cont)
label RES3_E and _e 247 (cont)
label RES3_H and _h 247 (cont)
label RES3_L and _l 247 (cont)
label RES3_xHL (x _h _l) (readm _tmp) and _tmp 247 (writem _tmp) (cont)
label RES3_A and _a 247 (cont)

label RES4_B and _b 239 (cont)
label RES4_C and _c 239 (cont)
label RES4_D and _d 239 (cont)
label RES4_E and _e 239 (cont)
label RES4_H and _h 239 (cont)
label RES4_L and _l 239 (cont)
label RES4_xHL (x _h _l) (readm _tmp) and _tmp 239 (writem _tmp) (cont)
label RES4_A and _a 239 (cont)

label RES5_B and _b 223 (cont)
label RES5_C and _c 223 (cont)
label RES5_D and _d 223 (cont)
label RES5_E and _e 223 (cont)
label RES5_H and _h 223 (cont)
label RES5_L and _l 223 (cont)
label RES5_xHL (x _h _l) (readm _tmp) and _tmp 223 (writem _tmp) (cont)
label RES5_A and _a 223 (cont)

label RES6_B and _b 191 (cont)
label RES6_C and _c 191 (cont)
label RES6_D and _d 191 (cont)
label RES6_E and _e 191 (cont)
label RES6_H and _h 191 (cont)
label RES6_L and _l 191 (cont)
label RES6_xHL (x _h _l) (readm _tmp) and _tmp 191 (writem _tmp) (cont)
label RES6_A and _a 191 (cont)

label RES7_B and _b 127 (cont)
label RES7_C and _c 127 (cont)
label RES7_D and _d 127 (cont)
label RES7_E and _e 128 (cont)
label RES7_H and _h 127 (cont)
label RES7_L and _l 127 (cont)
label RES7_xHL (x _h _l) (readm _tmp) and _tmp 127 (writem _tmp) (cont)
label RES7_A and _a 127 (cont)

label BIT0_B and _f 256 set.i _tmp _b and _tmp 1 or _f _tmp (cont)
label BIT0_C and _f 256 set.i _tmp _c and _tmp 1 or _f _tmp (cont)
label BIT0_D and _f 256 set.i _tmp _d and _tmp 1 or _f _tmp (cont)
label BIT0_E and _f 256 set.i _tmp _e and _tmp 1 or _f _tmp (cont)
label BIT0_H and _f 256 set.i _tmp _h and _tmp 1 or _f _tmp (cont)
label BIT0_L and _f 256 set.i _tmp _l and _tmp 1 or _f _tmp (cont)
label BIT0_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 1 or _f _tmp (cont)
label BIT0_A and _f 256 set.i _tmp _a and _tmp 1 or _f _tmp (cont)

label BIT1_B and _f 256 set.i _tmp _b and _tmp 2 or _f _tmp (cont)
label BIT1_C and _f 256 set.i _tmp _c and _tmp 2 or _f _tmp (cont)
label BIT1_D and _f 256 set.i _tmp _d and _tmp 2 or _f _tmp (cont)
label BIT1_E and _f 256 set.i _tmp _e and _tmp 2 or _f _tmp (cont)
label BIT1_H and _f 256 set.i _tmp _h and _tmp 2 or _f _tmp (cont)
label BIT1_L and _f 256 set.i _tmp _l and _tmp 2 or _f _tmp (cont)
label BIT1_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 2 or _f _tmp (cont)
label BIT1_A and _f 256 set.i _tmp _a and _tmp 2 or _f _tmp (cont)

label BIT2_B and _f 256 set.i _tmp _b and _tmp 4 or _f _tmp (cont)
label BIT2_C and _f 256 set.i _tmp _c and _tmp 4 or _f _tmp (cont)
label BIT2_D and _f 256 set.i _tmp _d and _tmp 4 or _f _tmp (cont)
label BIT2_E and _f 256 set.i _tmp _e and _tmp 4 or _f _tmp (cont)
label BIT2_H and _f 256 set.i _tmp _h and _tmp 4 or _f _tmp (cont)
label BIT2_L and _f 256 set.i _tmp _l and _tmp 4 or _f _tmp (cont)
label BIT2_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 4 or _f _tmp (cont)
label BIT2_A and _f 256 set.i _tmp _a and _tmp 4 or _f _tmp (cont)

label BIT3_B and _f 256 set.i _tmp _b and _tmp 8 or _f _tmp (cont)
label BIT3_C and _f 256 set.i _tmp _c and _tmp 8 or _f _tmp (cont)
label BIT3_D and _f 256 set.i _tmp _d and _tmp 8 or _f _tmp (cont)
label BIT3_E and _f 256 set.i _tmp _e and _tmp 8 or _f _tmp (cont)
label BIT3_H and _f 256 set.i _tmp _h and _tmp 8 or _f _tmp (cont)
label BIT3_L and _f 256 set.i _tmp _l and _tmp 8 or _f _tmp (cont)
label BIT3_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 8 or _f _tmp (cont)
label BIT3_A and _f 256 set.i _tmp _a and _tmp 8 or _f _tmp (cont)

label BIT4_B and _f 256 set.i _tmp _b and _tmp 16 or _f _tmp (cont)
label BIT4_C and _f 256 set.i _tmp _c and _tmp 16 or _f _tmp (cont)
label BIT4_D and _f 256 set.i _tmp _d and _tmp 16 or _f _tmp (cont)
label BIT4_E and _f 256 set.i _tmp _e and _tmp 16 or _f _tmp (cont)
label BIT4_H and _f 256 set.i _tmp _h and _tmp 16 or _f _tmp (cont)
label BIT4_L and _f 256 set.i _tmp _l and _tmp 16 or _f _tmp (cont)
label BIT4_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 16 or _f _tmp (cont)
label BIT4_A and _f 256 set.i _tmp _a and _tmp 16 or _f _tmp (cont)

label BIT5_B and _f 256 set.i _tmp _b and _tmp 32 or _f _tmp (cont)
label BIT5_C and _f 256 set.i _tmp _c and _tmp 32 or _f _tmp (cont)
label BIT5_D and _f 256 set.i _tmp _d and _tmp 32 or _f _tmp (cont)
label BIT5_E and _f 256 set.i _tmp _e and _tmp 32 or _f _tmp (cont)
label BIT5_H and _f 256 set.i _tmp _h and _tmp 32 or _f _tmp (cont)
label BIT5_L and _f 256 set.i _tmp _l and _tmp 32 or _f _tmp (cont)
label BIT5_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 32 or _f _tmp (cont)
label BIT5_A and _f 256 set.i _tmp _a and _tmp 32 or _f _tmp (cont)

label BIT6_B and _f 256 set.i _tmp _b and _tmp 64 or _f _tmp (cont)
label BIT6_C and _f 256 set.i _tmp _c and _tmp 64 or _f _tmp (cont)
label BIT6_D and _f 256 set.i _tmp _d and _tmp 64 or _f _tmp (cont)
label BIT6_E and _f 256 set.i _tmp _e and _tmp 64 or _f _tmp (cont)
label BIT6_H and _f 256 set.i _tmp _h and _tmp 64 or _f _tmp (cont)
label BIT6_L and _f 256 set.i _tmp _l and _tmp 64 or _f _tmp (cont)
label BIT6_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 64 or _f _tmp (cont)
label BIT6_A and _f 256 set.i _tmp _a and _tmp 64 or _f _tmp (cont)

label BIT7_B and _f 256 set.i _tmp _b and _tmp 128 or _f _tmp (cont)
label BIT7_C and _f 256 set.i _tmp _c and _tmp 128 or _f _tmp (cont)
label BIT7_D and _f 256 set.i _tmp _d and _tmp 128 or _f _tmp (cont)
label BIT7_E and _f 256 set.i _tmp _e and _tmp 128 or _f _tmp (cont)
label BIT7_H and _f 256 set.i _tmp _h and _tmp 128 or _f _tmp (cont)
label BIT7_L and _f 256 set.i _tmp _l and _tmp 128 or _f _tmp (cont)
label BIT7_xHL and _f 256 (x _h _l) (readm _tmp) and _tmp 128 or _f _tmp (cont)
label BIT7_A and _f 256 set.i _tmp _a and _tmp 128 or _f _tmp (cont)

label RLC_B 
	(macro _rlc [lsl (&1) 1 gt.i (&1) 255 ift [add.i (&1) 1] set.i _f (&1) and (&1) 255])
	(_rlc _b)(cont)
label RLC_C (_rlc _c)(cont)
label RLC_D (_rlc _d)(cont)
label RLC_E (_rlc _e)(cont)
label RLC_H (_rlc _h)(cont)
label RLC_L (_rlc _l)(cont)
label RLC_xHL (x _h _l) (readm tmp) (_rlc tmp) (writem tmp) (cont)
label RLC_A (_rlc _a)(cont)

label RRC_B 
	(macro _rrc [rotr (&1) 1 lt.i (&1) 0 and (&1) 255 set.i _f (&1) ift [or (&1) 128 or _f 384] ])
	(_rrc _b) (cont)
label RRC_C (_rrc _c) (cont)
label RRC_D (_rrc _d) (cont)
label RRC_E (_rrc _e) (cont)
label RRC_H (_rrc _h) (cont)
label RRC_L (_rrc _l) (cont)
label RRC_xHL (x _h _l) (readm tmp) (_rrc tmp) (writem tmp) (cont)
label RRC_A (_rrc _a) (cont)

label SLA_B
	(macro _sla [lsl (&1) 1 set.i _f (&1) and (&1) 255])
	(_sla _b) (cont)
label SLA_C (_sla _c) (cont)
label SLA_D (_sla _d) (cont)
label SLA_E (_sla _e) (cont)
label SLA_H (_sla _h) (cont)
label SLA_L (_sla _l) (cont)
label SLA_xHL (x _h _l) (readm tmp) (_sla tmp) (writem tmp) (cont)
label SLA_A (_sla _a) (cont)

label SRL_B
	(macro _srl [set.i _f (&1) and _f 1 lsl _f 8 lsr (&1) 1 or _f (&1)])
	(_srl _b) (cont)
label SRL_C (_srl _c) (cont)
label SRL_D (_srl _d) (cont)
label SRL_E (_srl _e) (cont)
label SRL_H (_srl _h) (cont)
label SRL_L (_srl _l) (cont)
label SRL_xHL (x _h _l) (readm tmp) (_srl tmp) (writem tmp) (cont)
label SRL_A (_srl _a) (cont)

label SRA_B
	(macro _sra [set.i _f (&1) and _f 1 lsl _f 8 set.i tmp (&1) and tmp 128 lsr (&1) 1 or (&1) tmp or _f (&1) ])
	(_sra _b) (cont)
label SRA_C (_sra _c) (cont)
label SRA_D (_sra _d) (cont)
label SRA_E (_sra _e) (cont)
label SRA_H (_sra _h) (cont)
label SRA_L (_sra _l) (cont)
label SRA_xHL (x _h _l) (readm tmp) (_sra tmp) (writem tmp) (cont)
label SRA_A (_sra _a) (cont)

label RR_B
	(macro _rr [and _f 256 or (&1) _f set.i _f (&1) and _f 1 lsl _f 8 lsr (&1) 1 or _f (&1)])
	(_rr _b) (cont)
label RR_C (_rr _c) (cont)
label RR_D (_rr _d) (cont)
label RR_E (_rr _e) (cont)
label RR_H (_rr _h) (cont)
label RR_L (_rr _l) (cont)
label RR_xHL (x _h _l) (readm tmp) (_rr tmp) (writem tmp) (cont)
label RR_A (_rr _a) (cont)
 
label RL_B
	(macro _rl [and _f 256 lsr _f 8 lsl (&1) 1 or (&1) _f set.i _f (&1) and (&1) 255])
	(_rl _b) (cont)
label RL_C (_rl _c) (cont)
label RL_D (_rl _d) (cont)
label RL_E (_rl _e) (cont)
label RL_H (_rl _h) (cont)
label RL_L (_rl _l) (cont)
label RL_xHL (x _h _l) (readm tmp) (_rl tmp) (writem tmp) (cont)
label RL_A (_rl _a) (cont)

label NEG set.i _f 0 sub.i _f _a set.i _a _f and _a 255 (cont)

label SLL_B
label SLL_C
label SLL_D
label SLL_E
label SLL_H
label SLL_L
label SLL_xHL
label SLL_A

label RST00 
label RST08 
label RST10 
label RST18 
label RST20 
label RST28 
label RST30 
label RST38

label OUTA 


label INA 

label EX_HL_xSP 

label RET_PE 
label CALL_PE 

label IN_B_xC 
label OUT_xC_B 


label RETN 
label IM_0 
label LD_I_A 
label IN_C_xC 
label OUT_xC_C 
label ADC_HL_BC 
label RETI  
label LD_R_A 

label IN_D_xC 
label OUT_xC_D 

label IM_1 
label LD_A_I 

label IN_E_xC 
label OUT_xC_E 
label ADC_HL_DE 
label IM_2 
label LD_A_R 

label IN_H_xC 
label OUT_xC_H 
label RRD 
  
label IN_L_xC 
label OUT_xC_L 
label ADC_HL_HL 
label RLD 
label IN_F_xC 
label IN_A_xC 
label OUT_xC_A 
label ADC_HL_SP 

label LDI 
label CPI 
label INI 
label OUTI 
label LDD 
label CPD 
label IND 
label OUTD 

label CPIR 
label INIR 
label OTIR 
label LDDR 
label CPDR 
label INDR 
label OTDR 

(err) (cont)
]

zoom: 1 FF: 255
video: make binary! (32 * 1024) ; video space adressing 16Ko
change/dup video to-char 254 (32 * 1024) ; allocate 32Ko of video RAM
coord: 0x0
mode: 1 ; screen mode= 1 or 2
;change at video 1 + to-integer #1c00 #{606060606060F0F0F0F0F0F0707070707070C040404040404040}
patterns: make block! 256 * 3
loop 256 * 3 [append patterns make image! 8x8]
dirty-patterns: make binary! 256 * 3
insert/dup dirty-patterns to-char 1 256 * 3
colors: make block! 16
colorig: reduce [black 1.1.1 leaf forest blue navy red cyan 200.0.0 180.0.0 yellow olive green magenta gray white]
foreach color colorig [
	i: make image! 8x1 i/rgb: color append colors i
]

map: make image! 256x192 + 0x8
mask: make block! 256
for i 0 255 1 [
	append mask make image! reduce [8x1 load join join "#{" replace/all replace/all replace/all 
		enbase/base to-binary to-char i 2 
	"1" "FFFFFF" "0" "2" "2" "000000" "}"
	]
]

quality: 'nearest
effect: [anti-alias off image-filter quality scale zoom zoom image map translate 0x8]
loop 32 [insert tail effect [image 1 0x0 black]] ;sprites shape
draw-sprite: at effect 13
do-names: rebcode [/local mapi offset pos sav] [
	head patterns
	head dirty-patterns
	do  dummy [dirty-names: dirty-names xor sav: cp/part name-offset 256 * 3]
	set offset name-offset
	set mapi map
	skip mapi 2048 ;mapi: at map 0x8
	loop 3 [
		loop 8 [
			loop 32 [
				pick tmp dirty-names 1
				sett tmp 
				pick tmp offset 1
				iff [
					pickz cond dirty-patterns tmp
					eq.i cond 1
				]
				ift [
					pickz tmp patterns tmp
					apply tmp change [mapi tmp]
				]
				skip mapi 8
				next offset
				next dirty-names
			]
			skip mapi 1792
		]
		eq.i mode 2 ift [skip patterns 256 skip dirty-patterns 256]
	]
	set dirty-names sav
]

do-patterns: rebcode [/local color offset image val posn ] [
	set offset pattern-offset
	head dirty-patterns
	head offset-cache
	head patterns
	set avoid 0
	set color color-offset
	do dummy [n: either mode = 1 [1][8] build: either mode = 2 [3][1]]
	loop build [
		loop 32 [
				
				eq.i mode 1 ift [
					;fg: pick colors color/1 and 240 / 16 + 1
					;bg: pick colors color/1 and 15 + 1
					pick idx color 1
					and idx 240
					div.i idx 16
					pickz fg colors idx
					pick idx color 1
					and idx 15
					pickz bg colors idx
				]
				loop 8 [
					copy str offset 8
					copy col color n
					apply str xor~ [col str]
					copy str2 offset-cache 8
					apply res equal? [str str2]
					sett res
					either 	[
						add.i avoid 1
						skip offset 8
						eq.i mode 2 ift [skip color 8]
						poke dirty-patterns 1 0
					][
						change offset-cache str 8
						pick image patterns 1
						poke dirty-patterns 1 1
						loop 8 [
							eq.i mode 2 ift [
								pick idx color 1
								and idx 240
								div.i idx 16
								pickz fg colors idx
								pick idx color 1
								and idx 15
								pickz bg colors idx

								next color
							]
							;val: 1 + val2: offset/1 val2: val2 + 1
							pick val offset 1
							pickz val mask val
							apply val and~ [fg val]
							apply dummy change [image val]
							;change image (fg and pick mask val) or (bg and pick mask val2)

							skip image 8
							next offset
							

						]
					]
					
					skip offset-cache 8
					next patterns
					next dirty-patterns
				]
				

			eq.i mode 1 ift [next color]
		]
	]
	;print avoid
]

;draw-sprite: make block! 32 * 4 + 3
empty-sprite: make image! 16x16
sprite-colors: make block! 16
repeat i 16 [empty-sprite/rgb: pick colorig i append sprite-colors cp empty-sprite]
do-sprites: rebcode [/local attribut xy val color sprite shape x y idx] [
	set shape draw-sprite
	set attribut sprite-att-off
	loop 32 [
		pick y attribut 1
		add.i y 1
		pick x attribut 2
		apply xy as-pair [x y]
		;do dummy [xy: 0x1 * attribut/1 + (1x0 * attribut/2) + 0x1]
		lt.i y 192
		either [ 
			;sprite: at pattern (to-integer attribut/3 / 4) * 4 * 8 + 1
			pick idx attribut 3
			div.i idx 4
			mul.i idx 32
			set sprite sprite-pat-off
			skip sprite idx
			pick color attribut 4 
			and color 15
			pickz color sprite-colors color
			pick image shape 1
			sett image iff [apply image make [image! 16x16]]
			;* build sprite in 4 parts (4 parts = 4 * 8 bytes)
			loop 2 [ 
				loop 16 [
					;val: 1 + sprite/1
					pick val sprite 1
					pickz val mask val
					change image val -1
					skip image 16
					next sprite
				]
				;image: skip image 8x-16
				head image
				skip image 8
			]
			head image
			apply image and~ [image color]
			poke shape 1 image 
			poke shape 2 xy
		][
			; ben ! on le voit pas, donc on le redessine pas, c'est toujours ça de gagné
			poke shape 1 false 
			poke shape 2 xy 
		]
		skip attribut 4
		skip shape 4
	]
]

clear-stack: has [ad] [
	foreach ad stack [poke get ad 3 0]
]
name-offset: at head video 1 + to-integer #1800
dirty-names: cp/part name-offset 256 * 3
pattern-offset: head video
offset-cache: cp/part pattern-offset 2048 * 3
color-offset: at head video 1 + to-integer #1c00 ;#2000 for mode=2
pattern-save: cp/part pattern-offset 256 * 32
sprite-pat-off: at video 1 + to-integer #3800
sprite-att-off: at video 1 + to-integer #1B00

skiper: 1 pattern?: false

view/new lay2: layout [across
	btn "zoom" [lay2/size: lay2/size - screen/size screen/size: screen/size / zoom
		zoom: select [1 1.5 2 2.5 1] zoom
		screen/size: screen/size * zoom lay2/size: lay2/size + screen/size
		show lay2
	]
	;btn "show patterns" [pattern?: not pattern?] 
	tog: toggle "High quality" "Low quality" [quality: pick [bilinear nearest] tog/state]
	below screen: box (256x192 + 0x8 * zoom) effect [draw effect]
]

key-event: func [face event] [
	if event/type = 'close [quit]
	if event/type = 'key [
		switch event/key [
			#" " [
			_key: FF xor 1 
			 if mode = 1 [
				mode: 2 ;trace: 1
				color-offset: at head video 1 + to-integer #2000
				]
			]
			left [_key: FF xor 16]
			right [_key: FF xor 128]
		]
	]
	event
] 

show-screen: does [
	either 1 <> skiper: select [1 0 1] skiper ['wait 0.0001][
		do-patterns do-names
		if all [mode = 2][do-sprites]
		show screen wait 0.001 
	]
]
insert-event-func :key-event



mem: make binary! 64 * 1024 					;space adressing 64 ko
change/dup mem to-char 0 64 * 1024   				;allocate RAM
;load game rom
change at mem 1 + to integer! #4000 decompress #{		
789CEDBD7D5C1357F6307E272F93096F490075821432066154D41811530A1114
08B60A14DFA8B64A6BAB3EED6EC1BE98A012A32220F5ADB58ADB6FB7956D57B4
5B0BD6AAD876DB204209E9B4620B05B76C2708D12EB245ACAEDA323CE74EC0DA
7D7B7E7FFD3EBFCFF3733273EF3DE79E73EEB96FE79E3B77D094D96392D1DD97
25655E8A258541BC86E00941158FFA6AA6A14B9C89F07E99E50D282D3DC63D40
70471F31D733F3928DAF0D8EFB9FC19F08A28BB3205AC074668220CE003451C9
EBC72979771A4B338E4BB7CCBAE5B18B633363D3631B5A9374D718748996025E
83C6120EC43D8A98C779BB0611AD5C754A421E5F626DE18EA7E8ED1ADD08C63D
D587E3747BCCAA88DDDC5E640EE2F623A38107F0CB119031F087AC668A4B218C
D378855BA350409060E023232B6FFC3CD5A8E3CD729C67E46FACC85255AAB220
AB32ABB412C8B212A6F1953784A9CC383ED36A299C7AD0C8F0661288BD12F310
2B31BF4E991500654DB52444F1072DD441A39E2FBC818C513C13C027E879AF9A
95D9FF4E58ED49CD4B5334A8877B322501F1499F4F28A94F4D6610BABFF796A7
F5960BA71E5B58E4E5F387C11E4D450AE95FD418618D7D213FCC1A1B1266D587
A87F707D9332235D365FEA585A9AB9C07FC9C58CBD9B972FCFC8452808D19220
9D7B16FE6D5D6120427B0BB9F9686323B5FAEEB8D7C5FD58C63D9B92C0F0553A
097D9DAB2C371346C41BB3BB8CB95DC6BC2E2E6229E729636EA671F672A0E37A
B625647755E97EC498DDE58C3C1DF0E4D206C8AA53DFE2523663CCEE72EE1F4B
B9C2A5CC0B7CFC10E468F2702D353A313C28860E31748A61B217B7C10BA0C057
0981BC206D1E98839974DE5F98781FE17F13A04138C4FAB158C695D9823F0E94
103063787B156B8CB324E9944C206F376AF97864136C17BA679B6DC6317CC237
DD55CD0173EA7F331B78DBFCCFFC6676356031A8E6996FBA4F32AFF027CF8899
82BCF937B3EB63C57C23CD27687963209F10C457355BE6DCDD16C36A8B4AD6A9
FBEEB40BC864542259FF2F6475EA6B5CCF764E5ACE1C4F23650D908B9B32FE25
E661ADE6064FC8A55C5639734CABB9359C9ED8CF6F3CC1FA4D1CC0D102EE9197
9890308DC0138404138E0A33EF848E65C684999F81187AD3D9656CEA329EEB22
1029F693D8D772FFC21A5D7FF59D4CE873B17BB7D77F93C2FC807B9B3E8B35FC
EF2D7FA7CD03F9AA330373984752ABAFF760B6FFD04940EAB9FA49A249A6D7EB
81526FD7AFCAFF7E7F552A614D8DA84C4D7C2735F174EAFE6969FD3FA712FAB4
44C067A7251CE40556A7817A947519F774190F7419DFE2EB27A402E26097F170
97B1B6ABDA87617E83D5C68910ADE620B407C1E5A60198F0165FC5EC4C63A54C
1126600EF2769028897F92FB6B2AF33FC33CC010263C69503365DA6ADC7CDBB5
8484A8CF4D63F6A5D5DBCB136A61CC4F4DA8819002717F278C355D584E15AB9E
01C6887B7B1BC8A283AA295A5D8DB3DEC693234109931D935735834E5569948E
F49585070284D2728F07C6524398C6C057B10A4B752311A3FE29B8AE3EAB5CA6
0DB26F2B7AEEC52D319BD6E96C85C55BD3B581216AB95449048C93A88246853C
A8953FB7C9BE6D6B9956FA785EDE4B5A322F0F398AB7BEA4951CA1956A793029
9786C6445CA695E1C1F2905101A121E173B4FE5B6D9B8AB7A275855B5E7CE1AD
9102D0A6750817200D0B82E8A5A2C2AD5BD196B5C5859B82C34890BC33EF9935
5A3FEBDAA217D1D6E2B55B8A8F6815C17242A61D1F7158AB14D19B4A5EDCA2A5
6594524125D0F210A92A58FEBBE118060273EE3219C879CA9987797BA2A03405
6872F8B044416D22AA83ABAD49B7232CA5A5A58C2D635BBE8188EAE9F43C1BFD
83E6DC652200D692A0506550405F4DA79D200382C31313D5B7C980B631BE54C2
C37C929764B65FDC960F2B45DF9CD28B857DA99D258AAC4EBBA471697EF44552
BE3656FD73E7B392E88B4582964AC8E1B3BC0A5862541A6786680D0B05CAA4A2
27699A7E0123C27A99C948ABC822E56EC220993123AC8A95724D9610BDFA87FA
948C5FE7C6C5FD3A3761019F685CC06BD045662E0DB3382CA4B527897D26895D
42DFEF69D1EBEBD4574009CDD0907B052BD31068AA57C1D4FAAA9DE94E611513
775FD48EDB7DD13D17923B21B9F362BD31BD8790A0DE67A27F8065CFA3D1212D
4E030A40FA4FBDCC395CA857C68E82C9A4A755BD4CFB3002CF2E7D4FAB8FD243
E890B2D7A3D7074900AA4FB0D83BDA2821CF2469CBB33490C8B74064413F297B
191A6983A4D0F2CA5EF8E114652029067D0FDDCB20ACBF57A293110E42D9F750
E945656F9DCDABC82ADD0C3D580A4D28B623832EDBBC374BC57A91EAB0909356
BDFA5690AEB7AFA6C3D5892D43A7A773B9B473B10C080927D6AF73B9BC7331C9
889DDED3FA8BC241014AACAF317DF34139926FA62377D6FA39E53BE9C8BA732A
0759474FE52E87262B387A2A71508B0209EDACC0DA086760A07656CA39BD2328
459B35FF329BAC9AAFCD4284949022295190979BF74246415E78405CC0A351E1
017B5E7979EFABFBF7551C78ED77FFF3FA1BBF7F13AF823458C67F8031F31267
0A1E62F6F3F6A4331973611568930BE4F98CB9714CEC4592B557E9FC26AB6F25
1AF7F3F51973F172D995168F82A4B636B9491A40DFE26A1E4C2FF2269696E647
77C7CB6363FB961DE09F8F7DAEA891CA8F47B10509A160108807137680C9241E
84F525A19C4FFAE4022477F171095B207D9E78301E7167CABDD2E88BF9509A72
F28075EE1469BD75EEF51EE665DE1EE799EF252CB01C55B1121235D84AD39890
87C426C7F6B4D756C52A05290C4E90406435CAA856D04854A83100DCA096BAAB
49AC245E2607250A1B1578B2488324D89435B4F6A4515914507B5AEA025969AC
FA7BF07BA01630B91A25566CCF88E6F40713464105F80C6637A85BC67F729ECF
10B58DBEE895B0EA292A50382416269DE9C614393D308506583A99BE95C6ED79
B09ECF4818ED63DE03CC257733BBB358D9142D2D99A2F73AD86060A241C86410
A2A507C4160791861B5362E9816149BF34384C5E835C73E5255AAA697A69A441
DB2111C7A06E7B55F399078B1AD5F9F4F56AF7FD91EEFB0302D6C6423F408FC4
5A636363ABAD1015C093B097B7E28C78A409E60BC5D11C96145CC46CB9E4ED57
A9B6E50716AA542A6BAC267724D3EA9AB283DE510D1E80596A3CC2E3CA812371
86CFD0DB0581BD24FC0C6BF4B96E0D89B4E3CE758326E3CE77E36E6BEDD6BC37
AFD4E193616CEBD6B47703993D581F020F5076C4C5992990C77CDD6DEFB04C7C
83F7F5AC30C41ECCB2790920DFBA22CCA2F9B63BACD6204F0C8662AB833BE23A
EC16BD70D9304AE04D13356DDD6149B75F7F28D8E695669143B45E73980F4B82
111D9C68FC23CF38B1264143A48CF6B329144062F3CEB2E0D69A78BEBB303151
6C84BE65E7BA13BEEE8E3448434242C242ACB1E2F3ABF68A277CAD05389057A4
5225819BBE2D1FB74FE27003D5173C44A1CF56C0EDA050CD0A47CD0AF44B3C82
FFA798824C9C4F89740003F2335F8C497EA17FDD4707B14887917FC1F15F443A
84244822914964B2A19F7F3FF78D07BB3C550BBA3C87170E5D4519BC87784892
C37BA48B86AE5AE6793CE9F31F5EECF1642F19EAEFEA7AFDCDFF39D8D575E8C8
1FDF19EA7FADF2777F78FB4F5D70BDF5EEE521012F67A8BB136A490624FC1126
1F216BE8E1D8F9840C752A3D416A651DAC04C4FC9E418FBDAA29095BC5524A3F
6827354BE6FBDAC362DF63FD76D97C30CE76EF267D2F139C557FB35CA6F00BD2
2FD72F1E9CE1777BD5FCB1612116F726DD327DA65BE956EADD56DDD823EE7CBB
CE2F296BAA57AAF30BA41589599020020ABD91D64976AFC33AE9B949CF4FB279
234B4B4BACFDF1C8D533FF6FF37F982FCC273343338D999332E7643E98B932F3
B7994733EB32BFCCFC2913642ABD9B7A98C3F3A174EFAC41AB1F5DEEC1325C1E
7AF3601C49DF1C9C41D2D7C22CD0EF83CFA9069F0F5A924B770F2E560D2E0FA2
BF05FD06ED32AFA366D02AA39B80488474F2C18240FA5373E49E416B207D2A2C
A4D38AE81AE077CBECAC0CAC87B3D34AD06F02C24AD207EE70918305F2FAAEF9
221B4E2474C2FCE9998F537BF941AB7F678FC7DE68B0E25D814417215A673AD6
FE8BD0B68281D7321BB31B75F5719983762533F9A26FAED02F8BB494C8D8DC35
5FF3F71558E636303D5DF307E34909408C0EBAE94CD7FC78420F2E86551F8F3C
3D45DE7EE3788FA8DB0D2554106C7BADA7FEDBF9837624CAA917E663C1677E98
1F120222E2B23AB26665D765CF7D78DDC3AD597B1F3EF9F0AB395B1F7E37E78B
87071FB6E6ECCD79F6E15E989576BD57CA3E0AB6C3A171BCE91B08258D94E5F6
D22C7083D4DE7E5A724385AFCE1204AD66F3AADA28AB7E4323E58DB46CF0F235
2B7CD465FF424D4093FAA8B1C29B04091B34689727267AC32D94A3D32A718D40
839F04EAC81154A037BC9695CBA0BB5C8333025DD143B4241A0DA607DAF0F092
DB12A1D43071A8C90B219D55B8878DF1460A6A835F6021C6FA07D25480981247
60F0603CB129AA392EABFEB52C48221729D30C758584C15E527D6B83B18AC793
A031C338EDA2AB75103A33E9F3F1D9D051C264434EE36458799643B8B87315EA
7C96E0BECE596DDB6C9281233631B5252C6B0F4BFF9F0AAE8F130BED7C0E753E
4FB4B8B0E53E9D8D0D7BE762702B08AEFC11188D2DAE324931F96546B11C7A31
894D078EB2C1385948487570F445D0255F901BFC3BED5241A693C54B68493C51
044AD9A171876384F99260414D38C784FA8C719C6B301E21B3DCC8E2FDE10CB0
A8600CC130128B76AC05DB88175E87B5A891CCC7C6124CAE0B0FCE513CAC8984
3ECE05CEAB9770022A2BFAA258C42784CEDF57D8274847B8C486AC06B644E361
513E2EAC331EF138C7E91B9D149E7E8AE1BAC0884650976795F1E89F75879209
41790E0632D585E58ADCC08B456DF2890A047058825DF94FECE64463050F6891
9CA9E067B01A715733680FD049131EE53BAD5257F5A0951811EB4375C64B1CBD
3097F27B3407BB0935F8F29EA220755F0DF6341B1DF9D1977A34872F05C9008D
03F390F148B7F174F7C4D7F8717FE89EF83A3FEEFD6EBC1AC5894ABB7A274F5E
3C79F9E4B0D252BC08E1553BB677B8CE2E5782CE53C5CAB172AE5FD5AE75982B
7E536FA71DED1F70E6F4A50AB28E96F330657B61C9C2723A60F86C6CD4AD5EDF
A87BD510D2979AB5619F41D1976A89A6E9504B34A25577106A5A6A89A66CA74D
644A965956BCBA105724DF3DABD6E01FB5ADD6404695D6C2A0D8C84C5AE0333F
2E444864142997A983020328A55F805A131C4A8F1E158A22EE0BA7B561E17825
59B2001C38B0C0F90BDE5B10BF70D7A2B8C58EC5F90BF217C816E62E922EEA5E
C47C70C92EF0ECD77ACD043E410796EBA105821402D585D717D885DAF30F2D08
4B0CF6128925D6FA8700415D184624258918E6C4A57F61FC16E8DEB98B71325C
8D81FF86FF970CF04458BEDAE8F424ACE48D793C2815678F8D15DE62C782744C
2F3D03DCB88C46192C48B1F12A608A47D5C065A479AC8713CCAC8E88AB064B6A
EEF789B00B3676DA0C7D02E3F984254DD2389A0060BC67C5E86ED853ED1C11AC
23EDA24C669C271E81A4D85810D40E663B5E5AD428CFB76B0EF1C121D1DD89D8
A9266EAEC0130F8F7FC8098632343597C0EB87D145058798F96086E5E3FD703D
8C13F84498AFD6FF385D99FE857897FED0826D5AF5BA42ABAD18F6C8CFAF7514
6F835D3333818F03E50D6385089D3F0C4F539731B9CB98D1957088CF8F05677F
13B08DA41116B4BBDC2C83A6C00DA984185868DED8EE31B25D464317F3475E2C
F010169A685282F788DF34B163F014939ED9B08879FF92FD4EB3E62F48F8E092
C0377FB708BC4DB03B9057C5AA44525D948F8C0E9F6C1756B394493A83D6C4D1
4109272E094B750A40BEC586C6C188B00B4BA1A74CB219A0501C568A107B57EC
28B3FF1DA91A9F02D0B1A258C8041179ACDF2F8CA248194E313597341F5C0217
089A9A37D65C127B7ECC88504D151F06661E16DA558BC786DD99FFD0397661CD
F5D8467570B83D36F82A8CC9703B18759FBC1903A2666378D1C0FA061ECEA9E2
973F34FA622F08CB5F3016C476DBC12B3014352AF3EDA7752C3698BF2E21B6CD
27DE273A7F0158A460BA1D5C38320038590A6F0AD4D769954F4273DDE222D80D
A9BB41037BE219F3223CDE203293BE8EFB2336C5712006EF133FB8D4E610D8F3
5F2DF1BD6CFC6A09C3F0303AD57A980A008CC73D1A7AE1AB25D5C6F13C63F0C0
1E8094B8ED2CA955DFAAFF6A0948DBE3E95BD6CF87F42DE8E7414452F33B4BE2
1DFA849397B2549AD796F89C8410EC93E8C370C8D45E92EB64458DB27C68EBB0
703084F869AC1107C6574B8EA34F53D0FC9494F928E55374FCD34FE337EBE38F
EBABAD7AF8FD1BD646D21A6B3E8779B16AB59748494FABDBDE1C9A0BAE0A179D
9B15B63958B8699009B50675C85DA80F2F84E64E1CE0F5E3067833DF120C9392
96B4783634CA569849D1EEA96BEBA92525B7E373B3BC2A6BA1B73F122E57D68D
7E2B2CDB22D097EAC28D17C827B1946F33793B9709C36FD16060DDCE155D2B88
1CBC05E681BDF63CE4BECDDB05834962FEB95166B5681C97C4A64928E0BD892A
5563F6EAB08F3191ACDB565ABA2D1F9C6A608FB55708FE8679783ADB936EDFCE
B582AC382619AC104BC2562596BE114FF4100E521966C1AD91658DEDC97E045C
05215827316B040461509627DE191B1FE4895D2B6E7780BB93715E22A9061022
EFE1B48F7860C02B3BC1E1EFAB4F8366CBD26B9CE0DAF93C35E323E0A98DFA95
5F2738CF173DF25F9CBBA7304BE83F3B77C2C706858FC305F6385E7401A03233
5C0DD886C63EBB1A8F1CDCB78AFC5EF09EEA844083C41C2884B49B835D5C6539
7EA7FCFA3EEEBD035C510A77F61146C2C74BC9083076EA9F18E20792165F3034
EADCC9AC041A3756FD036035CC0FE477B8964A8BF7E72C19EC1F8F0587C7D6A9
AF88E4F9402FCD2AF2F20EB0B98DBAFC40DD4DF565E02A882D7031C843129CA7
5C9CFF8761FEA7E15DB185372B8C193C2CF1E93C93CC579332AB5EFD338CFF54
9E40A86F4E01DF37E739207E111307F15CE152EEF252E6C5A5B089144D8A8B0C
50CAABC1EDF28D65C345520A6568265F64BE5D2A1230C68B4132F37DA49F55DF
A852DF0ED45D33AB4819B3F4222E277E8879988F1FC21348CDC7B3FA78993E5E
AD8F0FD56CBFC8F04B832860775E2603EA3DE519B96B6CF8488B405204F33F9E
D7C7BF88675FBC0A1CB1AFBB8DDF761BBFE936BECC1B0FF2C64A9ED981F54984
8D3FB30BBF33A063E375CC8BBC3D2B51180B63758C1576D15E69F3B6470B13B1
41EA4BDD5C9A55BA99097C549C2685C69778EE1FCBB2BC41AA5E46F1E89DF736
B0F5EF2DF412C6CE6E9BB1B51B53946E3696F2B65287713B66282D35BE2A425B
7DEC94711B5FE85518F51E9BB118A38CFB789B71BF987A075279BC71259FF022
2FEA00FEAB49D626A56F5A4A1DA54CCF32B1549BE6004F90D08A5CE33EA676DE
B83778D76F77ECDDB17FC79F767CB9A36BC7C08E513B27EDB4EB2DF8FD874A45
C158B450AEF879CBE795CC4B46281DC91C1A64D1C90846339339B1D9A8313127
526633106A72C69D66DA5E5939EEC8B4B6648DFA14D116FCA4B16ADAA5BDEB8C
87532E2D10C390D2D947526A5F85F0F1DAEC719A534C6D4859CE6B8FB7BF2A86
0BCB725E7FBC3DE4C013AFAFBDFCEAEF70B8500C994018C5E608E31FF884B5BC
F8E6D2ABB0305F0EB7620354A4CE56CAF83F7677AB32DF3C0A552B1448B3D420
B5C102E10FEDE3929352A4003F6DE867E7F03574D5897C3F488DE0FAFF4D4A18
FBD89CC79E796CEF631F3D76F131FFE5D39753287927DC0E8ACAD989E0C6B123
07C3221EE1D881F3D1D33BE18678F34EB87F8929118F70ECC0F9D4CB3BD16180
D1A73BE176DC8947F0103B0E633CBF13FD05E3859D48C07861A743B80B0F0124
217FEA2E0437452DD98596F86207DCBFE0A7EE724CC5F0FA5D086E0ABDB90B6E
C79D78040FB1633D86FFBC0BFD19C31DBB50872F7674DC8DFFF32EC79F317C7D
17BA8E61E56E04378E1D70FF82BFBECB0137F68777E00302F082F4F6441D9164
AD9E64D56716924888309132C013324D29CFA85670B2159AED3C33192770368B
735EE29987302241CD032AD4A094C9043F0325A3E5428401F25FE599E7C57C58
7ACC14EC5CF6F146072F1FF8663989345B7966AF983906969F65CBC1542414F3
9F5C8054206F4F6A5EB6DC2CB182152BE7EB972D0F73F806D6D860575E767276
B221DB604836E892753A834167D0A97570ABF1B5A720DB91975C909D9C374C63
18A1C197442291E29F78C92096C125C73F895446CAF14F817F042191C08D1FA9
C803A4F0881C985321979232895C2AD94E9550A5056580FF2CC3252B6F926DF9
FB0A11E7C0B8DC5C47AE4BB1B9BC4981D1AA92ECD2AB6592EC33A4DFD9EC7277
8C0F978C71B9F5644356F9E751802A966C43C544B1B4585E1C1451460026E59F
CEFF15F7CEFFEF9DFFDF3BFFBF77FE7FEFFCFFDEF9FFBDF3FF7BE7FFF7CEFFEF
9DFFDF3BFFBF77FE7FEFFCFFDEF9FFBDF3FF7BE7FFF7CEFFEF9DFFDF3BFFBF77
FE7FEFFCFFDEF9FFBDF3FF7BE7FFF7CEFFEF9DFFDF3BFFBF77FEFF7FC9F9FF23
5F3DF2D123171F99B4F4F9A52C4A3E8292B73B29EAB923BA9CED3A8ACAD9EE80
9BCA10F107A935C9DF3B52771607C89EDD0937C4DB76C2FD4B1C20E265382EC6
F901FB76CADE0558F6E94EB88B719CF8D3F68387A9974F1B0E6FD7B1D4B12335
878F1C6411BFBD00F026F6F61103DC2C7BFBF4C1DB47FA0F031E019E457F39A2
E3B7D750ECA40FD1D45D207FC92ED9125F5C0C7740002045FCD45DC553316CDF
25833B40F6E62EB88BEFC4808FFBA9195119EB9B1DEB9BA19EB7CAD1AD66D494
D1518E3A9A51464647B3A3A31CEA7BBA1C9D063AEA74B9E37433C057CBD1D5E6
642A63EE4B2870379413B8BB18EE8080EBBB64D771B9D77715C3CD3D9B367E47
373EFF4F0C8CB12746C993ACD553AD3199BF25654244223EFF4F94CFB8B59567
FC97B9D0327CFE3F01270A25E8366B229078FE8F11096A1E506A8312A1DB7E06
0AD1C4ED3003E4EFE199E79771B0500576DF670E902922F6758F2EEE96DFF866
39291B55DA3DBE029FFF9BC79CAD6A5C91290FED8E28EEFEE4AF2B968F0FECB6
277DB162B9995C62568CFE58F6D98AE511C5F2FC3879943D7234F7E4C2D485A9
710BE3E252E3A252A3A242E3A2E2A242A3A26451A1F87AF58585C54FA6BEB050
F6A44823039AFF74FE8F20F6D91EF8490024F04F2AFEEE3EFF274905DCF89141
2453E047AE206524043B034A024A17EE00FC67F338D9AECF65257F5F21E28A31
6EDEA3C58F72F8FC5FBAE56FCBB6FB6FC9DE2A9EFF4BFC9CD9E56EBD0F97BC55
3CFF97D43D54DEA4039443B219390887141EBFB03262CBDF2C78D3F2025EAC6F
08436C409255F777E6C5CDE0E1D2DE781B99387202FC5707B3968FD34927C5E9
33F57A7B2311639D64FF02C5804DF44AD950E6B79BF111DC2EADE6399E90E203
4B7A342C076BBA8C055D465B1796682F37DB8C2FE0F99DC568C34852B368B32D
A9B4D4E7149D362958B9FA4A3D72BC0C3B36E07474858459B679D53A0AD6A51B
DAC6E4FC1EEE1387A7C8914F523DC34A79EAD739B83A474858430FF7A5433C5F
A8736571F3913EA0507DD3C568B5B4141745358035ACE616C32E42975FA7BEEA
6282A02AC40CAEC3A109E2C3AA9A0485611273BFD6D2D063DE434AB0AC1E7C2C
637EC507E8F54537F8449D4CB31469EBD4175CCC46ADEF1092D9BEB91E6AFDC1
A5F8B7F4F179BE850564CFA0FF48101F9C9013274FF9496A3F0C957CFC4984C4
79C62839DBB85D2BDF5ABCD6FAE236ADE679DBDA8D1B5FB45B0BED5624E2966A
652194528D8F5959D04A178537066FE9EEC36FB4C0231EA507BF7FBF41023BDE
08036596048BBB0EF0F3B8EECDACB2DA68F080A35E7B49F3314634D717571BE3
31E6E34BF5F5C56102DF448587DDD7B182C2AE6D122B27148896122A09E3B8D4
41A0007C402E17A40642D6B17EFFC0982D5008793E7D4BEC06C7FE81F1004D3E
0D505147409BA3B4147C4EF0D1BD9B8C46BE4D2A483B4C522E670B76C13AE467
545BEADFDDDA01CAF0E28ECD388D17269BE4A02920DA94F9AD3DF6A4666A6B52
F3FB5B929AEF87387DAB99648EF03374D2847778E374EC90F39E0403388C2BB7
C2E23E230104680D0A26989F510F981031EA80B2EC828C5501F54D4FBC0CBCA8
0E4F4B870BC07E0F0CB2301E63C46F0E7481A27405782AD3793AA0C753D41890
6F6F9402E4E94930F2825297092E8ACE435B7C6F66CE798C749751D7051B4B7B
3C12C0C716CF1BF0DE4127C35B07B3524724616113138D973D9E1ED84700A04C
04BDC1279ACE63E575417646E57BA53403D7823908AEEA74707987744AA8A795
3BB0CD2C85C0D3128F3A5A35DF7487250527A83D2B605BA632AA3D1B34C8B375
857928383C613A0FDB9CE0587826B7C4F3AE0E065D5CDFA61AA8DD8A3BC8B0B6
839475C0D6842DEEC16F7670679D879CD3869CA2B6C9E026B3C9D0203DA2061A
7842F919AD0DD5506E5D8BC7F74AA9F5DF961A0EC5DD675605B7D08A7889D8C6
1D011D9ED80EF5DE0E66C545B38C822192502C0E91935072DBD2FC0ED20FF460
9FBCA3C623C5588D05AD3DD4126ABD2698C76FC9A406FF10BDD8C166098DC7C4
65CF8CDE190D581F5145B5C7BE1CEB621DEDF16035AA834545C47756C15863D0
82267C7A403FFAE55349678CC51D85552E3CA46F7714B30A284359BF67337417
D7550CF312420017AF17DE72F6C42EF7BDE1BF33D2D78B93296B43AC18E35794
41A668185A6AAFB829F8D76CCAA417B33DE03C1AF9D85871E41575DC99131D30
0FE8C0C9F1BCC6714B0BCE29F8F41E00603227E94607170935CDDBB6C5BF159B
099B5833F46B9895F613F7C3308D633399D11EDF2EC4AFD403BEED5A5729F3D9
3671082DD62F4FF0E7939A44F79A99C3DBB762DB5B3E62807DA18BC8460E942D
43141A8D883C02C9911A62351A8574C8801252F92427B0731B4AB8074AB83925
09693C93CE7FD29490C23316FE1327C0553AC29A086B80147CFC840CBE24C60A
251EF6186B3C467557FD35076CED2C5E95939998EECE3B632FAFDF5DCE3C426B
089E2699D3B426193C7B696B08B7B0BCC56751832C9A48B0A109608F278135D6
84D1DA5EE6C51230C5F58F229D25272D65213031044FCAC23E69D7C9C363D5FF
70855921BA8DB793627B342F2D4DD4C5C4D3B0E0C87C27DA49C26870C54735E6
61E50E788C073DC6260F33B1B4FE62495292958D17D4300A2896AA5F5ACA2494
D272E6C1521A258CF1AC181D46CA1A7A5A617771D759B40CB67A7F0352687408
7D64CF44FFF0AF944077C5D5F4F9F9E6735FB77DC1B57EF395ABE54B77FBB75D
17F86EEF5F3B7B2E5DECF07CF797CB5706FED6FFE38DBFF75DFFC7B5EFAFFED0
0B7B270D7F49140655192C85B69D023A9AC3C3856076AC10C00609E499C152F3
BBC12130DBE8E7CD877D89A7CD6FFB128FC78F0193234EFF70F3417800371F86
4E2C364D2AC3EC524D4C996FFDAC6267E8B360C5EC6960341E4D3F582BAFD4AA
B7E0E5D5260EA2F8C43A0F34A2D08FBFD01005160687DB827D1B7DFC1AA14E7E
E68952D862058BECB0A9069B8C8B026B10AEFE818EF07D1CF87550BB7FB79F2F
FD6D003C0A5E7E39F08A523C75697EB5447C97A593C44BF19B9817F021495BC0
F0A7087176FD27175E2D9904ABA4DE96C4EAED553A0A0CAFB1D6431333601FB2
99E1B5A2AABD3044B8FDE5F5AF96D82D0269529825D83E1371B6BB896C9AA6E1
AA9324ACD1407C60CFFED7FF70F83DBD1EBFCA8382E2D1A449F152C8E0AE6D67
C6A693D2912FB06E3B5C66196CA3B83D15DCEBE5DCF872268DE6D24B981C9A33
973063B7937EC394AEE8E10F5EA6D114A51C2B26D768831CDBB6DAC66F75AC7D
FE45B4E1C5EDBD5A8A9D307152ECE429539F0C1BBD024DBBDF342D1A82389499
327F4E169AB730F5B143612129F3E6A19CB9968C850B504EDA82B49CC569A96F
D3F4F8CA3FBC858EBD7F1CD58DD7E378043E4BD36FFFF150D50727D029D410AD
FBE044D4A911B89BA60F1F417FAA3DFDE147C815C3E0780496696974F4BDEA8F
FF1CF329E2BEF8F2E33FA34F47606CFA74F13CEE68988B04B185B32006FC6824
C57E114933E8070DA21B5A7B08AD38EAB1A7D462D6892D5CA7BEE4BA4341A851
4F6B0390D479605ADC95F4F956DFB93A82F268694790A123AC8394E0FDE575AF
AA830D0E421D9B3BB06BD67155FD7D4788DAE30ABCBDA69CEE5BAE5FAC2751A6
BE6758900B23324904B310CC04F36139B870EF9713886A480795EBF401EA1B2E
C91672481AAF40680B598020EE98A8E08B4A4BB725E66F74479991658CFB373A
4276B878F5D1710ABEC3D5F7BC9CBFC520D4337CA96FF46D90F3AED23B7BC9EF
AB35EA98BE1C933491BEA5EDA5809420D0FAE32CED4E708F3550459B63F23796
C5AC2EDC1C93652B8BB1D0DD54AF6B623FDFC3495F626EF056FD73FAE73D7DCB
06F8EABE1C8CBAE543B9343FF3CC4D9E3BF05255138110F7F64B26A98CBEC99D
7C29444C07407AD74B4B5220C0CDC408FC737AABCB56D5E4FB5ECCD5D3504DCA
4F4E52FF5CE77141C790B2EAB0376282C7822DF5B4D48D6076FD82D98E8A15DB
64C54419F18544262BF6CFAD97354C75B33BDC6CB17FD34B3BCF666FF9FAA5BB
69B6903B7C37EC026EBE54EC6F3AABCA768DCF3D2BC7E43B766EC5B4654483A4
496628F65FB34D5D4CECDA92BCA358B11D616C83AC3EE41B99D93C71A28F7CCB
C33BB2EBA3EBE55B4C3B766F79704771D0AC7F4357AC06A101C541EA3B7A829A
67FF59CD8DC04DFD33C51936A3588EB947328AFD1736C8B2B3FF85F7D7F98D53
B38BE5BF426DE9DC71B798FFA801F16B8AA953F1C7D3FF82056489ADF48732C9
767543C699599FB35F819A2554691960A833B90D81B9B96E596EAE8BAA073D4A
B27D9467B32323B7DD574CAC986510D1C3E4EE8C6F34AE8CBBC91AA66EA38A89
AC0655D3AFD1AA6D34464F6DBAABB0FA6C8C6C98BAC2CDE662AECF719E6D4BD7
CE920C1FDF0A9CEF96B9A3BE81C72DC39F81AF10D9F760766883ECB351D1D15B
A27765D44FBE133646015A868AE5F5D1B9EEE8DCFAE8AD25793E71190D516E8D
5BE50E74FBBB2937098225D0B165926DE1C365FBF492BB32D4EADC455F92B92A
1AC2C6795F46E74E35A8E9471F059261CDB2B7BCBACB77AFC09AE716CBC57805
1E735B8715241BB35DD090CD512BDCD25CF7B86CAC7EF62F22C4CAADD816504C
7CB618279B1EFEA5651AA06A4D5139B90D540EC40DD90DB25FF83E7BF09BE833
A3BF21CF8CFE853EF7CCD86FA865671E28960FA85A6C65076A0F1F28B3ADC9CD
C0EF88289A356598589A3A5555711DB2F1C366ACB11DA8D54E6873B6F82831D2
9491EB5C632B731E385C0B6CB96B6CCEB203879DB54A2D4020D379B856E9D44E
B87F44C6AF5041E76D196BD80C8A3DD5FFEAEE81A016CAB4E680F2C01A53FF1F
00FA3A83CDB0D54E983001E8BE664F61A0B616A74F590158B3660D16E777E4C7
EDFFEBC7B9137E541E2E5B93C15255A5AB7FB4C4FCA838747DA0E6EF4EE7F581
3D6298DD62B339FB077733617BC0CCDEB787949AFDAF2FD7737BD1D544B0B337
59F43589188727881A8D48E9FAE590119BE80B9714FAE22CCA1DE18EA462D51E
6AAA9757A96E38569815909370C093C48E49D2C5303B3DF6197AE18A41366306
ADB1375256DA9F93EE01347E83EBB7DC4C0235AD48D8E1A93A4BED61F6F85E37
43AC39F07290949C005BC6AAB3C700A490B625047F199F74E6EC9E9E38BD3E5E
D0EBC3AC21F07860CD88B37F78E1C197B173012B48588870EE42D2CBE0ED4CEB
612EEFF1AAEA6F96FFB847F1F2D897C7BF3CF9E5192F7BF42121CFEB9F9B3469
6CD8582A0C36C534E7C17C9326D1677B26C1D576CEEAA14F7B264DC2C7357ABA
1A5250225D05F10C88DFF4687E1A0217DF85BFAFB17BF3C067DEE1991478536F
A7B098B161DE7E81674DCCDF5EF6393F77969A30AFCA9DE8BE2F4977ABB7B0B4
149A56CC0155F4D4126FA4555FED0E1E63C57F24407FD7B2FBEFBB7FDC7D74F7
E9DD2FEF7E135292570CFBC6EE36EF5EB07BCBEE237B635E6DD81DFACA43AF2C
DC67DBA77F65E92B5B5EA97DE5A757CC7BB7ECDDBDF7F5BD0B5E7DF455C9BE0F
5FAD7DA5E695DBBB0FBD72626FD75ECDAB4DAD4DAE173F397BFCE811F6E0C48A
F776BD5B72DFA69FACB3D60E645FA838459DAA285D5D5AB1C4A2A8A8B8DEDA6F
7A65FF49458CC2B2BAB4BBE27A1B061527018C5962A928AD380568183D788452
15A74A2B2C4B621427F7975C6DEDCF7F257DF1AA12CCDA6D0136004B56ED2F19
6105AAEB038122CBEA52CB12450C30AD4ABFDA3610B86F5F7AFAFEFDFBD3A3C9
13FBF69D38718224A3A3D3D3172F4EC7986DFB4E5C1FF06FC3F3AFFFA3570602
DB7CB1AACD6AB5522CCBE6666464E0F880CD66BB0343BA56A984F15F5666CBCD
CD3501BEEAF0E1C34A786CED0772595B060BBAB401A915B22A288AB25654549C
BA1B86D876173B555555C59A4CA65C78A8F65CB6823D558145801698953A0517
4E03EB88161910639611F62A9C3E8C55B0D9308E853803647CC3B24ED6940B10
062A2A9C155558040656AF76AEB656806898D75F5B2BAC15B0B961AF5F1EC83E
65B528BA9C6DA7BAAC6D967685C53A7375C5E525900B385317D556DABE64A6A2
7426D57F62EFE50135D09EC40DB8CE62B128DA4F2A2C8A994B2EC700394652A5
A5A54BDA672A4A96CC2CE9EFDA3B1078F99478594F41B52A4A4B29B65FF3EA40
D0577EA78FFC6E7BE1FF7A64EEFD13B4CA11AB386C0C4BADAB975866C68C519C
3CB41F5BA05AA7CD79E07AEB405646C6B58C8C1F21F8112A748D1D09AFB1AD3F
E6E65ECBCDFD11821F3330D548782D2337D729E2C13AD97EB45DBBF31C38E03C
F0E3816BE2D31F032AB542BDA9FFF60CA869DA49FF485FA34D26A7E947D3B53B
CF4020D43E3797AA5802ADDCAD58E7FBB50EA84B4A9C253F965C2B3974C879E8
C743D7EE3C03AA0B400ED4D96D19F4C8C05F1D3306C6F0FE312763C6586256FF
323702DBE8E151BE7A8C6F94A7EF2F3979870EB830CD9D513FDA37EA478FC6A3
7E151003068FFA4126E0C0A01D0DEAAB9ADF3B60F1CE72DB588A19DCC7DD2CA7
2FBB0B583937663FFD1DC7EEA72F94327DFBEE5819BBF1515EDFD3E9D1A07E6E
FA7E0D4A64503F810870A8E7BFB1FB0DE71B57DF18F7E693BFD7FF7EC19BD3F7
3BF69FDA5FBFBF7F7FC77E63457AC5F28AA72A5EAC28AE202B4804A3C2ADCEEA
ECF1F4D5802C57B48808CDD7F6BACC1228B8D38E1275CA4E3D1870D082E23AF6
9B6577D0B840273EE8E39EDC8FEFD5FB99A621EEEDFDCC3931AC11C35A1CBACC
04703160DD5B7B997E117F13872D8C1A61408DA0406D1045523D6E3252AFBEED
090E09D45DC56CEC7E51115A6E966211C0767D3F73590CDB87E87090D6C379F6
7B307C73484B52EE683DF8D590A6AF8802419EFAA7603D88BBE6E2822B389578
0757B482965AC280BF6F0A22ABA96A92A2DC91EE08BDFA963B72B8E831FB7DE5
FB52F5775280637860A6F0771318CF3D5D811B0FA25ED7E0B3D09383AB2070B5
724F55E04FE51105DB9E1630F8D7C81A7C028A2EBB3A992B15D071B05FED7C16
75EAF157747AEE4C459D1AF65F72DCAE0E027834289C19A820C2F0CB1452D690
AECFD49B29CA969255EDD6182437FAC550151CE2FB5149BA8B75EA0ED782D7F4
AF6D782D4FBCFAC5AB40BC9CC9BEEBA5B2B1AFE551651B7EB7509657F6D1EFE6
41F8D5EBB3B7CDDE361C9523B4DD71A56CECFFA414A714CBB696230AC0ADE295
569C22FE70BCF9AEAB1CA95F2A7BEB7547D94578A27EEF287BEAF70E1DCE70A4
96E0AF084B4ACB91093626DF43E6EC6D921DDB1D7F2B0BF1A5D01520F6E1FACA
168A29A4F11E60902E2CA4AAC9E2DEC4AABD058DEA9EFC68649B302175BE87F6
F716E0BD5462968D445E9502AE06D8DED629E92FDABEFBA6784747C787FBBFFB
66F7BA25AB62D263968C5EB76E5D6B2B602E6C8A1B131F15333A2A266ECCE84D
EBC8A898F8A831D1516320416E8A8A89BE1BC66498F82E0C4EC4FF338D858C9A
192D624687CE8CB26CD85058F8025C4570AD876B235C3FA059B30CE2B5FB4BE7
97DFB57FF7E5973FFCE6CA15B86F0E72F8FA5C101C7009827DA81EAE21FBA64D
01E2E570F8DEC08447AF5CB9D2188E02C231761632AF544424166C42B3C88008
E94A330A8A885FB58924913DCF2EC570B821CFFEF8E366B469251940D3344A7C
E2B9C4AC3966E05B394B4A26A23C9BDD06230331395154F0F8D977FE24343C7E
E5CA4D2B5722FBCA95F84611D3816A7A04DAB80ACA5FB5114135CC06C32CB429
2FCF8EF9230D79AB574E8F442B45B6956856804F3FF15C0CF458B9EA37B68DCF
AE46BEDACF422BAD9B363D03742B9FDFB0297FF54AAC0F5C665CDE4A1028C2F9
AB9230BC1AF325AECA3363393EB90168E5303D0456733805F1339B3659411E40
6688A74F9F1E81E9362982C24DD03E702526FAAAB669D34825A13DE8C4441CA2
C4D9BFAFACFCFDEC448220A4D29090316FBCFEE7A1A11FB8CD77FD952C015B7A
A94EA70E903A4D8A3B589914510A14C4473A0A54A85F7587985620431051C047
622484C3689533510A18DE390B239DB3240496A040918077D814FD8E4D3E3CC8
54AB9099500112D38FE0A190BC085064442CE0419443AC922088F7876DBF31A9
01421BF336066C04D4870B598037D937A63F97677B2E212C48212586849FBD67
0E7CFCC617AB0D63290CFFFCED0EC79E628760DFFF842478B6E41D68177FC0BF
63B3190E3A1D6808C623BE3D05A670CC8F509E3A402E09409AD541F78D1D1B08
C58F9D95F0B4F593CEF3AFBAFE5076DE91CCAA57ABC2EE8BF86CDC7BBF9D725F
42C4AC196127FEB6E89DC34B275F183777FC8308E98295C04F484B7E3B79D5D4
408A8A4A8E34DFBFE27CE8A4ED0B277407FF9B7E5006476F12222315FE21B8B2
12196D2AE09333FAF9A673BCD32191442A155AD3CD178D46131D404A445869BA
59B4F47CCD9E3DFD79880A325BBF387DADDB09AA83685DDCD3578CB302CADA3F
4E7CB6BDDDC083C460E38C99B30222CD0F68716118F1DC8BD659E1B3EC0F50B8
4052151450B4A9C83C59A520C4535EA47366F49FEBCE147EE679CC8F34630215
01AAB08407EE07400E0F83119109EB9F5FEB1B3F042A1ABABD3AD03F481C4B70
9DCBEBCF7ED69907FCBC1391B1BA6539F2A790E4BEF18BE7468C47ABB6AF8C6D
F8703C32FE56F924FDD6AB3E115229410C338F0C2989EC4E5A3DACC9C8959CCC
F3D8C88FC0128942014D2311014A3B616E9192428D13F0D5884C6969F7A7A599
D0813FE2EB00FAB8B2F2F4B66DB5E800C4187E62DFA8F169DB06D0B845F81A87
06463D356AD4BE2770D74B26DE3F76AC422AD52849848600E1386CAAA9E1478C
16924815A45C0AB699A27C33C7A1CBE69BDA3F2E100129AE983C501A19396B3A
C30C572E28722AFEBB786A584253B6AEBD8987B54B0795C16FA3097DCCAC4933
EF0B94FBE8C980F031219191217265C8486571AB767F7CA01F92502829210637
DD470CB79E8C54C15A2115BFEE55FB9ACEF0FA6167FF46FBAC007156934191E1
DAF015F9ABD762FB24952259E07DF717DD6A8F8C54453E604068E3CF3F95567C
7649D888A6FC7CB38077928E6C5D3625974A2337155DAD974A25433AE8D6337F
FDF9A661CFCD8F77E02A630272D3D0D02CD1264AD48682827EE877D31BC2CF38
7F68F623BAF4450FA52CC898DBDD73F9CA95815BA0775068283D363C7C2C1D1A
1A0495B83570E5CAE59EEEF68ECEEEEE2B37A02142C3C3F5312C1BA30F0F0F85
56B971A5BBBBB3A3BDA9F95C7B7BF700346238CB1AE24DA67803CB86072134D0
DDDE7EAEB9C99CFDD5E1FABB868999332287F95923E130A718258EFA7FFADF01
F075EFEFBFEFFDFDF7FF357FFFFDBB5514DAEC44657979070FE2479227111FB5
439D272B973D4D65A3954FA2A756AD568E36AD7E61D7112423CA503F72E289C0
2D9EA389B731289ABB9AAAF90E12244E50855C681AFE20C398EC31BFCCBDB13E
6121CFE96D094B78CDB3EB5BDDB304998E48BA5ECAAC5ACFA9933512A8908490
8C2724538865E2374138FEAD363149B2536B9E25E7702A3149DE0780C43C2B10
8D5DB2E651453E7E1C8F52E7825787254BF0799364615AC643299992790B5357
A0A06DDA395999969C94858BE6A52C9C9B9589E4E5DA747CFE8494655A4BCAFC
3449D6E2B41C24BD45A7188EFDBEFA4FD58F1EFBE8D8C031FE5873F5B9EABEEA
889AC09A8C6344CDE49AB063F26386F7FDDF2F3EB6EE58D1B151EF77BAD1BAA6
86CE4C49DFB2EB070799ED95AD9D6E62DDE7630E4346A64E0180FDF335475AC8
A08040760CB7EF0829830D2CF7E69141BD3E9095AA07646E9D9C6B39A4FEA9A1
67B06790F9C7C1899ACAA021604B67C3B8B3EF2EE09ADE5DDA631702594A7880
9585EAE96B1E4089180CFD0343E33495831E4F1D77F65040E099E477EB5C83CC
AD8383E908ABC04A07D309D866E9D7D79A085B6212EB77DD5EC97D75E82A48B2
BD6290E913753FAFDF331A19A8EBA0C6D544DD4DBBA073EAE95BCCA31FD19399
0BC74195E56C1473E3381D599834B329AC2DA55D089BD5CEF99F0AF1E7128E4A
C7BADC763DFB935EDF624F9CD9D49A12A696B887649FE8BE0FD1ABAF2DD72FBE
D83BE8710952DD984E3BE15E7DA6F13D7716062950EE59E7C6534D5372EB156F
3DE65EA6BBB101D6C01A3AC0DC475345DCCEA31B69C2D6D3C02554EBC7692B31
B58E8670958E9A38B6D2AA1F37B69244D0ECD0E24A6B679CA4CE53EDC2AD66F6
7736704D47EB5CDCBEF7DA85381241F3EE7B8F940946DDB48D354B7A00F064AD
6F1748DD54F75A76525A0320B8F0F7EAB83547750145EE4256DA979A7FE476C1
D13CB39F4B88D705D4E48B3C45EDF5054741EF5B35D745D8A411E35E0FE07AAE
7289EFD197AFBA84649D44EB129C3A695F8E4BD8A2536CF863FEFAB757BB84AD
903C91BFFE83D5AE8766F70A9B7534030B8BE654DFD37DB30D12E5CC59EE1077
7092AEBFD725387415384FED36B9B50642DB3BA137096FC727560BD39A41017F
1D09B56C9CE912A6CF6C120C336739B9C0A366E3398E3A6A969E9B05795EB161
A7E441AB4E545472470EE9C7292A27D96148BCD73AD87371F902FD27AC7494EE
D668A4B56B57D8DD1BDC1F692F0E7A5A5CEAC098A88953274D8E9EC24E782061
5C2C8A8C8D081F1BA6A5C78C260343749A07FC91D4B139D9B9656B1C42D3D0F4
199CFB3D023183DF430C7ADD724D14BBC9DE34E56928BB277D798098C1C6DA6B
75D77A5B0259FDE366E9F8A62873BCCB5E6B3A23184CA384048386DB0C556315
29DC85C3500368E49E16B7FD4CDC9F44EE694DC20C9DCC5E6BB80295301B5C82
52E757E4BDE44C735FE63E82EE70723B8E8A4343D5B74C5B39B32F6763142B19
EF3C7AB3A87E27CEAEDF7614FAD02F240CC6D378DD4D5AC13D79148F2DCCECAF
EB76718B8EF682DA5A186130AAB430A8AA310E62907AC897166B855BF5139D02
239AE56FF54E1C53F9DCA4E7AB5DA316481D14D23C17A32F50AC1D13FC56C841
BF6C39DA778039F8EEB4191F1C4FFC6876DDF9F6EF56763DFD7DFC68D2B224F9
D6B8898C3161DCC45BF184C44FE287360832278C3C6EDD51ACF00641E12CAAB1
709B8FD6EF380A89FA754785279DF4C006ACF18EA35019A060AF431B011FDB07
74B6BF3F6E0166318774E6D1DF82B0F54F3D437F0148FA4B6EFB51AEABA6887E
1BB88EBA792186AD2A8202DDB964FA99754737DC28A0CBA13D74D2A2834EDB09
DC604AF61FA44BF0A735D267962129A9FEFEFBFA3C908D99402302115CA1F040
73458DB0D769F3369EB0F4D6431AFF559F40C2E074FFBEFEC5A382C4E9BE8C99
B0649959B2AF5DF3C8316D7AFD969AF4C5CB0509DB2510CD2F1E0515E2584276
4AB7D4E6FDCC026C120D1A7DFCC15D10A9DE9DFD864CC38C438A40ED9B4AE584
12A8A6A8C03A5C6B2806F71F06FE9C87BBB7D0DBEF742F0074A1570553D1CFDD
0F4DF0D41ADCF17E30F5B71FA507C09B0939760A34BE892BE9D34BB1AFBD089B
1B0B1E097EBA809EDF44BBB96D473D58F3EB6637147195FE4CAA90A19D7BB57F
4946D2027894AAAF52907B01EB575F770C949ADC0C0D5F7054A6793807C9347B
037B2F5E444254F38EA32425FC1D22BAAB7E574DFDA99A6DEFBFF27EC5FB1FBE
7FF1FD1BEFFFE3FD9BEF0BEF8F3D3EEEB8FEB8F9F8ACE319C7D71C7FEEF8F3C7
DF3FFEE5F173C75B8E9F3FFED5F1F6E31DC753EB8D28F5AC01659E0D3E3434F7
EBD1E94329F33E3F8CCE057F32A711CDCAFE1C4DCD76492AB3E79E971CCB3E2B
39929D7A5E727A28AD5EEDFF60E68520754A1D8A71A16B67C2505A3A04DFD010
43F05538C4100CB5C7A2DC76D4E1423F3DDC1A0165C886E04A99F7355A379459
AF9672E3D0175350A64BF2874C28E0FDCCB3927732A1800F87CEEFA0CFBD03BB
DDB3D128D52539980AB935A96725875321B7362BE56C14E4659D4328ED3349EA
D0F9E0938BBE8E478B16BA246F2D04CAE38B169E95FC6921907E94F3990E0D2D
5AD0E4D79075CEAF6E6828EDEB32E782AFC9CFD2BE1A5DF279E8E879F5A1E4BC
39754831AF0E8D391F1A91531F1A9403B02AA70E45CE3B2BC9CF392B599D0672
E7A72DFC42923634BB3E0E41B3CC9C57171A9D53173A25E7F35073DAD7A31B17
9D09DE8F6B3694753EF83D88322F20E5054A095554D6D3CAEC2F75CAEC065679
CEA0E44CCA3308D513E8AC04354851930C7D2E47750A34BB1E11A90D1222E373
19B1E01C49A434061173DB3B25733B06252E449DA7A821AEE1F0A41E6DDF82D8
CA71532AA74CE76A0E1B88DE71C6CA16EDB8B84A5842C78554C60FE9C7992A27
26548E4BACE40E7EC0DDFF27EEE90FC09CBC3731B67270A2B1729CA172705C7C
2597F9A74EB7D4CB994E6083F679FF077DCB0C953D13A7549EEACBF13485F4E0
48F703DD322586FBF450DF325365085C2015F0172C27B11E7D4B9B7A269A2AF1
E9590B0EA054BACD24EB9B63A89C68A824474141508E1CBC15B7F41094C3F57F
5047FF0D3B30EC04F36640AED249CC759D56023C1160D06CAF14FFF6A46F81A6
7222E837F55D70325C3DCCCECA1EEEB12313FD214A3BD2E2C104FE951E17975E
CB159DE07E7F82FBEB097D6B0FD61E54EB7C513208CCBD835A4F8BB830713527
AF735D27CD3AEEF6291B17768A6B3D5908913910E0ABAEEB36AEFC84A510822C
584D49A77921A895D9643E08D162A7DE254240E4C4444E2002C4725629243B6D
42B039D9698E73355884836C00A913425992CC1316EAFC80E6AF9D76A997A801
CF082A36B858223CDE24D43509EA26A1B54938D3749DBB7D02CA8BD351448D13
2896BB840256264C030332EF24ADE69E39A993EA97BBB815279DF83C1357A489
B39E6CE75E3A79AE676262650FF8F95CC211939F476CF744688E2969F5A70EE9
47A3E53D507DBDDEBD812546697B3D2E1BF7D4C9A642C1D02414407A2D4E3B9B
8473AE9ED6DEBE6546DC642D26F9C4B84AE86D5CDB55339B1A7AA097FB1E4A84
BCD9CA996C40A63E5DDF8BD3BDBAEF3D75AEEBADB84BC005EC5B069DF4D24933
32F971874F9913A041CD64A795F4B45C75D9841A28A8A6C91C5B7FFB54436B8F
85FBF92478708D2940C4159D0AE85C2BC7DFCC30336BF1FB62AF6A05F60E5CCC
C3EFB7E29416EADCDBE212F9E4B5D7CDECE7C01577EAAA790224305F2B930C9D
39747285B6E5FBA03076B1DFE8A89C986909A7D76C05BFD1068659A18B4EA2F5
8CFF0700608836CBE85026F2033A888911712A152D03671346446D3D5BCB3D7D
CA3CC9BD9E25D7F7A52E314F0625D7D326A89BC16F3DC79FDAC07D7F8A8E33CF
C368486EA0676C10524C638465264A78DCA4123618FCB9CF810AEA1F434FDC20
F819648D069A014E73061D261CBC6E367C0D83ED3A2E951B3875D5AB6ADC13F3
45724C0FB8DEE0586AA0F76CDE7E21BB4948865E82CE6912F29A84832EAFAA69
D8D54DD2DD700521BBFB53282300E37EC47F0B2D952928A57F60904A133C86FB
F369735C3B1E75FD16185076A19395CB84419DCCDDA4B7771648899A1A0D4242
5FF39ED382BB79C96921F982F4B4E0303D27384D0BBD0A7606F86BA793D8FB93
D8F1838CE6C324766A123B66909900A9F149ACD2EE35AD80D951E7229DF404B3
8E9698D7061920745EE7AE9CBEB1C772D505F10AC556EEF9D3D8FDCF94B8B86B
A72D834CCA875CC1698160150262A5C2396706A97009EBCCD94D909D855991C5
EC80EDC3DC0F41878F93D8070699C7A1C8F793585D121B9CC4FA0F32851F26E9
1E0A72D22D665C60DE751FD755971D0F1CF286DA62CE732F6F025F8D339D0E32
981D4D1964A89970E9F1D465E510B6E9ED5EA72E7890D9FC21560A2B3AA8854D
11145BF6A142012A5F1FD606AA78559CF2BA28BDBD2DD91421241A8206991D1F
72CDB5C2E3CE47826A5C6D79266A9049FE4808374183BB4EE129D3C43CF6510F
B690A2E5143FA08329834D1A206619645A983C9EF6994DF405516785CBEE55DC
40AE63EA1A674DCDB1E09A1408436BD62EAC391651E3181DBAD6501357535379
4EF184E25CF2E2D0E4E0D0E93535B36B6A6AD4353A434D4D30CEAD0915C3081C
12A8ED9C843FC8ECA9A9498E889866A829807B8FA1E06543C12B8682BD0647B6
C2A1C876E44098E32808758416380A205DD0E06A6C36EA5BC69D6DAAFFECFC57
715FABCFB43E81522A53D0B950B5A340FD724DCD1735358F3B91C3A17882003C
8100AF2E8012B91A5CAEA34CF18404F09273A1C18E82E03811F9B89370281C4F
48012F45800F2E18C14B1C8AB2276480979D0B0DF5217DF7E735354FC8012F47
BFC6BB4712E742473B0A46DF9DF58402E81508F0A30B3647ADFC431C5C5BA39F
7A1BC75BC63FF9168E8B6356FD7128EDA1B4CCB31F940E0D21F49F9EFF9CF3FF
D293315F8124190BFD20981D0441AA0AC932E2529E18374E9631637688D52659
304D8E240B8C7E805F3C5B8D90E4A16911101881FAA1E93208E2022098414210
0F190BD3A2209806E0C20F4A2198AE84206E704892318D00F9460904D3213723
07A70C81909B1A0DC16C90B2704E2C923C8282912417015B2EE6C835E2200E07
982D078136D9680E92662336B7994A9F77E78DF6C294AD482245A3D0F09F5DFD
DB9FE4AE1FFA17CA911CE9F04F36FCFB674A89F8E07CFCE0940F928B7A64F649
89EB04BA77DDBBFEBF7E3D30F13F5D810F4CD4FDFB6B386B714AA60866A6A4E4
FC3A2BCE6030E8D8E9137426134E4C9BF04BD61D8C8F667EDAFC097704FEA7B2
FEB386815939169DCE609A69326404CECB4A491D49A7CED505662F5A90A1CB98
E78B53D37CF1EC3981F3527529B186943919BA07A61974F89EA6331802B3162D
D4B1861453C684D8144C93312F16EB9881D3A969B15871313D7BCE1DFCDC1CDD
8834807F25203B2B1B9785235C3444A0494EDA42DDB0CA737CE244957D69ACB2
AFD83B45E1620DFFBED807B37506114CCB4CFD35301C65DF8D4BF935C9DD8AFE
2AE3DFC8F97F46FB7F22FE17CA5F4BF2E567422B05FAC2E1DCFF9ACEBE1BB82B
F51FE2FF20EADEDFFFDFFBFBFF7BFFFEFFBD7FFFFFFFA7FFFEFFFF06BA97011B
00800000
} 	

pc: to integer! #4017						;game start at #4017

trace: 0
stop: 0
; GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  !!!!!
VM