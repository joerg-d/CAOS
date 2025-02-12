CE22    ASM                                                                                                                      
;*********************************
;**				**
;**	CAOS 2.2 reassembliert	**
;**		 von ML-Soft	**
;**				**
;**	21.01.96 bis 28.01.96	**
;**				**
;*********************************
 
 
;	Speicher}bersicht	**
;	_________________
 
 
 
;E000	RESET
;E015	Bildschirm-Steuercodes CRTTAB
;E025	Farbadresse berechnen FADR
;E03C	VRAM-Adresse berechnen DABR
;E06D	Zeichenausgabe WPIX, Scroll-UP
;E0FC	Cursor komplementieren CUCP
;E11A	Tonausgabe BEEP
;E12F	Pixeladresse berechnen PADR
;E1AA	Punktroutinen PUDE, PUSE
;E1FA	Tastaturtreiber
;E29A	Tastaturtabelle KTAB
;E31A	Interrupt-Tabelle ISRTAB
;E326	KBDZ, KBDS
;E33A	INIEA, INIME
;E34A	RAM4 l|schen ERAM4
;E356	SWITCH und MODUL
;E3C1	JUMP
;E3E4	Tape-Treiber
;E59C	TON-Ausgabe
;E600	Zeichenbildtabelle (nicht in
;	diesem Listing aufgef}hrt)
 
;------------------------------------
 
 
;F000	PWRON und Programmverteiler
;F0A1	Kommandointerpreter (MENU)
;F157	Ein-/Ausgabe, OSTR, INTB, OCHR
;F19A	WAIT
;F1A8	KBD
;F1E6	IRM-Defaultbelegung
;F216	INLIN
;F232	Hexzahlenverarbeitung
;F2CD	Systeminit, SIXD, Portinittab.
;F339	SAVE
;F3A2	BRKT, LARG
;F3B8	VERIFY, LOAD
;F518	COLOR
;F53B	Unterprogrammtabelle SUTAB
;F5A9	LDMA, LDAM
;F5AD	MODIFY
;F62A	Sprungtabelle f}r CRT-Routinen
;F64A	CCTL-Belegungstabelle CCTAB
;F65C	TCIF, CRT-Treiber
 
;------------------------------------
 
 
;**	EQU-Liste		**
 
 
LF	EQU	0AH
CR	EQU	0DH
 
 
VRAM	EQU	0B200H	;VIDEO-RAM
 
 
CASS	EQU	0B700H	;Kass.-Puffer
ARGC	EQU	0B780H	;UP-Nr. (PV2)
ARGN	EQU	0B781H	;Anz. Argumente
ARG1	EQU	0B782H	;1. Argument
ARG2	EQU	0B784H	;2. Argument
ARG3	EQU	0B786H	;3. Argument
 
NUMNX	EQU	0B796H	;Zeichenanzahl
NUMVX	EQU	0B797H	;Wert der Zahl
HCADR	EQU	0B799H	;Hardcopy-Adr.
 
WINON	EQU	0B79CH	;Fensteranfang
WINLG	EQU	0B79EH	;Fensterl{nge
CURSO	EQU	0B7A0H	;Cursorposition
STBT	EQU	0B7A2H	;BS-Steuerbyte
COLOR	EQU	0B7A3H	;Zeichenfarbe
WEND	EQU	0B7A4H	;PAGE/SCROLL
CCTL0	EQU	0B7A6H	;Zeichentab. 0
CCTL1	EQU	0B7A8H	;Zeichentab. 1
CCTL2	EQU	0B7AAH	;Zeichentab. 2
CCTL3	EQU	0B7ACH	;Zeichentab. 3
SYSP	EQU	0B7AEH	;System-Stack
SUTAB	EQU	0B7B0H	;UP-Tabelle
CTAB	EQU	0B7B2H	;Adresse CRTTAB
BJUMP	EQU	0B7B4H	;JUMP-Adresse
OUTAB	EQU	0B7B9H	;Ausgabe-UP
INTAB	EQU	0B7BBH	;Eingabe-UP
UOUT1	EQU	0B7BDH	;USER-out #1
UIN1	EQU	0B7C0H	;USER-in #1
UOUT2	EQU	0B7C3H	;USER-out #2
UIN2	EQU	0B7C6H	;USER-in #2
ZEITB	EQU	0B7C9H	;Zeichentabelle
 
ZWOUT	EQU	0B7CDH	;OUTAB-Merker
ZWEND	EQU	0B7CFH	;WEND-Merker
FTAST	EQU	0B7D1H	;F-Tastenzeiger
HOR	EQU	0B7D3H	;hor. Koordin.
VERT	EQU	0B7D5H	;vert. Koordin.
FARB	EQU	0B7D6H	;Grafikfarbe
MIXIT	EQU	0B7D7H	;IX-Bereich
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
;**	CAOS 2.2 ROM E		**
 
	ORG	0E000H
;
BYE	JP	RESET	;Tasten-RESET
 
RESET	;Tasten-RESET
	BIT	7,(IX+7);RESET-Schutz?
	JR	Z,BYE1
	CALL	ERAM4	;RAM4 l|schen
	JP	POWER
 
BYE1	LD	SP,1D4H
	JP	PWR2
 
CRTTAB	;Bildschirmsteuercodes
	DB	11H	;PAGE
	DB	12H	;SCROL
	DB	10H	;HOME
	DB	09H	;CUR
	DB	0BH	;CUU
	DB	02H	;CLLN
	DB	19H	;CBL
	DB	1AH	;INS
	DB	0AH	;CUD
	DB	1FH	;DEL
	DB	08H	;CUL
	DB	0CH	;CLS
	DB	0DH	;ENTER
	DB	0FH	;HCOPY
	DB	07H	;SHLOK
	DB	01H	;CLR
 
FADR	;Berechnet Farbadresse
	;PE:	HL=VRAM-Adresse
	;PA:	HL=Farbadresse
	LD	BC,-VRAM
	ADD	HL,BC
	LD	B,0
	LD	DE,40	;Zeilenbreite
ZEI0	EQU	$-1	;Zeiger auf 0
ZEI4	EQU	$	;Zeiger auf 4
FADR1	INC	B
	XOR	A
	SBC	HL,DE
	JR	NC,FADR1
	ADD	HL,DE
	ADD	B
	DEC	A
	RLA
	RLA
	RLA
	LD	H,A
	RET
 
DABR	PUSH	DE		;**32**
	PUSH	AF
	CALL	TCIF
	JR	C,IAD2
	LD	A,(WINON+1)
	ADD	D	;Cursor-Zeile
	LD	H,0
	LD	L,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	;*8
	PUSH	BC
	PUSH	HL
	POP	BC
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC	;*40
	LD	A,(WINON)
	ADD	E	;Cursor-Spalte
	ADD	L
	LD	L,A
	LD	A,0
	ADC	H
	LD	H,A
	LD	BC,VRAM
	ADD	HL,BC
	POP	BC
	POP	AF
	AND	A	;CY=0
	POP	DE
	RET
	;
IAD2	POP	AF
	SCF		;CY=1
	POP	DE
	LD	HL,VRAM
	RET
 
WPIX	;Zeichen auf Grafikbildschirm
	;sichtbar machen, PE: DE,A
	PUSH	AF
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	CALL	FADR	;Farbadresse
	POP	AF
	PUSH	HL
	CALL	PADR
	JR	C,POP4	;au~erhalb!
	PUSH	HL	;Pixeladresse
	LD	HL,CCTAB
	LD	C,0B7H	;High(CCTLx)
WPIX1	CP	M
	INC	HL
	JR	NC,WPIX2
	INC	HL
	INC	HL
	JR	WPIX1
WPIX2	SUB	M	;Offset
	INC	HL
	LD	L,M
	LD	H,C	;HL=CCTLx
	LD	C,M
	INC	HL
	LD	H,M
	LD	L,C	;Zeichentabelle
	LD	(ZEITB),HL
	LD	C,A
	LD	A,(STBT)
	LD	B,A
	BIT	1,B
	JR	NZ,WPIX3;Farbe aus
	LD	A,(COLOR)
	LD	(DE),A	;oberes Byte
	SET	5,E
	LD	(DE),A	;unteres Byte
WPIX3	POP	DE	;Pixeladr.
	POP	HL	;Farbadr.
	BIT	0,B
	JR	NZ,POP4	;Pixel aus
	LD	B,0
	LD	A,3
WPIX4	SLA	C
	RL	B	;*8
	DEC	A
	JR	NZ,WPIX4
	LD	HL,(ZEITB)
	ADD	HL,BC	;Zeichanadr.
	PUSH	DE
	CALL	WPIX5	;4 Byte schreib.
	POP	DE
	SET	5,E
	CALL	WPIX5	;4 Byte schreib.
POP4	POP	BC
	POP	DE
	POP	HL
	POP	AF
	RET
 
SCRLUP	PUSH	HL	;Scroll-IP
	PUSH	DE
	PUSH	BC
	PUSH	HL
	CALL	PADR
	POP	BC
	PUSH	HL	;Pixel-neu
	PUSH	DE	;Farbe-neu
	LD	L,A
	LD	A,8
	ADD	B
	LD	H,A
	LD	A,L
	LD	L,C
	CALL	PADR
	EX	(SP),HL	;Pixel-alt
	EX	DE,HL	;Farbe-alt
	LD	C,A
	LD	B,0
	PUSH	BC	;Breite
	LDIR		;Farbscrolling
	POP	BC
	POP	HL
	POP	DE
	LDIR		;Pixelscrolling
	JP	POP3
 
WPIX5	LD	BC,80H	;Offset f}r
	LD	A,4	;n{chstes Byte
WPIX6	LDI
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	INC	BC	;BC korrigieren
	DEC	A
	JR	NZ,WPIX6
	RET
 
CUCP	PUSH	AF		;**25**
	PUSH	BC
	PUSH	HL
	PUSH	DE
	LD	DE,(CURSO)
	CALL	DABR
	JR	C,CUCP1	;au~erhalb!
	CALL	FADR
	CALL	PADR
	LD	A,(DE)
	CPL		;1. Farbbyte
	LD	(DE),A
	SET	5,E	;2. Farbbyte
	LD	(DE),A
CUCP1	POP	DE
	POP	HL
	POP	BC
	POP	AF
	RET
 
BEEP	LD	HL,30H	;CHR(7)
	LD	BC,0A0FH
	PUSH	DE
	LD	E,0
	CALL	TON1	;Ton ein
	LD	L,0
	LD	B,5
	CALL	TON1	;Ton aus
	POP	DE
	RET
 
PADR	;Pixel- und Farbadr. berechnen
	PUSH	AF		;**34**
	LD	A,L	;Spalte
	CP	40
	JR	NC,PADR5;zu gro~
	PUSH	BC
	CP	32
	JR	NC,PADR6;rechte Seite
	LD	A,H
	RLCA
	RLCA
	RLCA
	AND	60H
	OR	L
	BIT	0,H
	JR	Z,PADR1
	SET	7,A
PADR1	LD	C,A
	LD	A,H
	RRA
	RRA
	RRA
	AND	1EH
	BIT	1,H
	JR	Z,PADR2
	SET	0,A
PADR2	OR	80H	;Pixel-RAM I
	LD	B,A
	RRA
	RRA
	AND	7
	OR	0A8H	;Color-RAM I
	LD	D,A
	LD	A,C
	AND	7FH
	BIT	4,H
	JR	Z,PADR3
	SET	7,A
PADR3	LD	E,A
PADR4	LD	L,C
	LD	H,B
	POP	BC
	POP	AF
	OR	A	;CY=0
	RET
	;
PADR5	POP	AF
	SCF		;au~erhalb
	RET
	;
PADR6	AND	7
	LD	L,A
	LD	A,H
	RLCA
	RLCA
	RLCA
	AND	60H
	OR	L
	LD	L,A
	LD	A,H
	RRA
	AND	18H
	BIT	0,H
	JR	Z,PADR7
	SET	7,A
PADR7	OR	L
	LD	C,A
	LD	A,H
	RLCA
	RLCA
	RLCA
	AND	6
	OR	0A0H	;Pixel-RAM II
	BIT	1,H
	JR	Z,PADR8
	SET	0,A
PADR8	LD	B,A
	LD	D,0B0H	;Coler-RAM II
	BIT	2,A
	JR	Z,PADR9
	INC	D
PADR9	LD	A,C
	AND	7FH
	BIT	1,B
	JR	Z,PADR10
	SET	7,A
PADR10	LD	E,A
	JR	PADR4
 
PUDE	;Punkt l|schen		;**2F**
	SCF
	JR	PU1
PUSE	;Punkt setzen		;**30**
	AND	A
PU1	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,(HOR)
	LD	BC,(VERT)
	PUSH	AF
	XOR	A
	LD	B,3
PU2	SRL	H
	RR	L
	RRA
	DJNZ	PU2
	LD	E,A
	LD	A,C
	CPL
	LD	H,A
	LD	C,E
	CALL	PADR
	JR	C,PU5
	SCF
	LD	A,C
	LD	C,0
PU3	RR	C
	SUB	20H
	JR	NC,PU3
	POP	AF
	LD	A,C
	JR	C,PU6
	OR	M	;Punkt setzen
	LD	M,A
	LD	A,(FARB)
	AND	0F8H
	LD	B,A
	LD	A,(DE)
	AND	7
	OR	B
	LD	(DE),A
PU4	POP	BC
	POP	DE
	POP	HL
	RET
	;
PU5	POP	AF
	SCF
	JR	PU4
	;
PU6	PUSH	AF
	LD	B,M
	CPL
	AND	M	;Punkt l|schen
	LD	M,A
	POP	AF
	AND	B
	LD	A,(DE)	;Farbe holen
	JR	PU4
 
;Tastatur-Treiber
 
ISRC3	;ISR CTC Kanal 3 (Tastatur)
	EI
	PUSH	AF
	LD	A,23H	;DI,ZG256,Res
	OUT	8FH	;CTC K3
	SET	3,(IX+8);Timeout
	LD	(IX+13),0 ;Zeichen tot
	JR	TST1
 
ISRPB	;ISR PIO Kanal B (Tastatur)
	EI
	PUSH	AF
	IN	A,8FH	;gemessene
	PUSH	AF	;Zeit retten
	LD	A,0A7H	;EI,ZG256,Res
	OUT	8FH
	LD	A,8FH	;ZK
	OUT	8FH
	POP	AF
	BIT	3,(IX+8);Timeout?
	RES	3,(IX+8);r}cksetzen
	JR	NZ,TST1
	CP	101
	JR	NC,TST6	;0-Bit
	CP	68
	JR	NC,TST7	;1-Bit
	PUSH	HL
	PUSH	DE
	SRL	(IX+12)
	LD	A,(IX+8)
	AND	80H	;CAPS?
	RLCA
	XOR	(IX+12)	;7bit-Scancode
	LD	H,0
	LD	E,(IX+14)
	LD	D,(IX+15)
	LD	L,A
	ADD	HL,DE	;Pos. in KTAB
	LD	A,M	;ASCII holen
	POP	DE
	POP	HL
	CP	16H	;CAPS?
	JR	NZ,TST2
	CP	(IX+13)	;erstes CAPS?
	JR	Z,TST1
	LD	(IX+13),A;eintragen
	LD	A,(IX+8)
	XOR	80H	;CAPS on/off
	LD	(IX+8),A
TST1	POP	AF
	RETI
	;
TST2	CP	(IX+13)	;=letzter Code?
	JR	Z,TST4
	LD	(IX+13),A;eintragen
	RES	4,(IX+8);Repeat r}cks.
TST3	SET	0,(IX+8);g}ltig machen
	LD	(IX+10),0;neuer Code
	JR	TST1
	;
TST4	INC	(IX+10)	;Zeit abwarten
	BIT	4,(IX+8);Fast Repeat?
	JR	NZ,TST5
	BIT	4,(IX+10);16 erreicht?
	JR	Z,TST1
	SET	4,(IX+8);Repeat aktiv
	JR	TST3
	;
TST5	BIT	1,(IX+10);nur jeder 2.
	JR	NZ,TST3	 ;Interrupt!
	JR	TST1
	;
TST6	OR	A	;0-Bit
	JR	TST8
	;
TST7	SCF		;1-Bit
TST8	RR	(IX+12)	;einschieben
	JR	TST1
 
 
KTAB	DB	'Ww'
	DB	'Aa'
	DB	'2"'
	DB	8,19H		;CUL
	DB	10H,0CH		;HOME
	DB	'-='
	DB	0F2H,0F8H	;F2
	DB	'Yy'
	DB	'Ee'
	DB	'Ss'
	DB	'3#'
	DB	'^]'
	DB	1,0FH		;CLR
	DB	':*'
	DB	0F3H,0F9H	;F3
	DB	'Xx'
	DB	'Tt'
	DB	'Ff'
	DB	'5%'
	DB	'Pp'
	DB	1FH,2		;DEL
	DB	'0',40H
	DB	0F5H,0FBH	;F5
	DB	'Vv'
	DB	'Uu'
	DB	'Hh'
	DB	'7',27H
	DB	'Oo'
	DB	1AH,1AH		;INS
	DB	'9)'
	DB	3,3		;BRK
	DB	'Nn'
	DB	'Ii'
	DB	'Jj'
	DB	'8('
	DB	' ['		;SPC
	DB	'Kk'
	DB	',<'
	DB	13H,13H		;STOP
	DB	'Mm'
	DB	'Zz'
	DB	'Gg'
	DB	'6&'
	DB	'  '	;freie Taste
	DB	'Ll'
	DB	'.>'
	DB	0F6H,0FCH	;F6
	DB	'Bb'
	DB	'Rr'
	DB	'Dd'
	DB	'4$'
	DB	'_\'
	DB	'+;'
	DB	'/?'
	DB	0F4H,0FAH	;F4
	DB	'Cc'
	DB	'Qq'
	DB	16H,16H		;CAPS
	DB	'1!'
	DB	LF,12H		;CUD
	DB	0BH,11H		;CUU
	DB	09H,09H		;CUR
	DB	0F1H,0F7H	;F1
	DB	CR,CR		;ENTER
 
ISRTAB	DW	ISRPA	;PIO A:Kassette
	DW	ISRPB	;PIO B:Tastatur
	DW	0	;CTC 0:frei
	DW	ISRC1	;CTC 1:Kassette
	DW	ISRC2	;CTC 2:Tondauer
	DW	ISRC3	;CTC 3:Tastatur
 
KBDZ	CALL	KBDS		;**0E**
	RET	NC
	RES	0,(IX+8)
	RET
 
KBDS	OR	A		;**0C**
	BIT	0,(IX+8);Code g}ltig?
	RET	Z
	LD	A,(IX+13)
	SCF		;wenn ja
	RET
 
INIEA	PUSH	BC
	LD	C,M	;1.Byte=Adr.
	INC	HL
	LD	B,M	;2.Byte=Anz.
	INC	HL
	OTIR
	POP	BC
	RET
 
INIME	CALL	INIEA	;Kanal init
	DEC	D	;D Kan{le
	JR	NZ,INIME
	RET
 
ERAM4	;RAM4 l|schen
	LD	HL,4000H;RAM4
	LD	B,H
	LD	C,L
	LD	A,L
ERA4	LD	M,A	;l|schen
	CPI		;INC HL, DEC BC
	RET	PO	;fertig
	JR	ERA4
 
	DW	7F7FH
	DB	'SWITCH',1
	LD	A,(ARGN)
	LD	D,E
	CALL	MODU
	LD	A,L	;Platz
	CALL	AHEX
	CALL	SPACE
	LD	A,H	;Kennbyte
	CALL	AHEX
	CALL	SPACE
	LD	A,E	;Steuerbyte
	CALL	AHEX
	JP	CRLF
 
MODU	;Lesen und Schalten
	CP	2
	JR	C,MODU5	;nur lesen
	LD	A,L
	CP	2
	JR	NC,MODU4
	LD	C,88H	;interne Module
	IN	H,(C)
	AND	A
	JR	NZ,MODU2
	BIT	0,D	;f}r RAM0
	RES	1,H
	JR	Z,MODU1
	SET	1,H
MODU1	BIT	1,D
	RES	3,H
	JR	Z,MODU3
	SET	3,H
	JR	MODU3
 
MODU2	BIT	0,D	;f}r IRM
	RES	2,H
	JR	Z,MODU3
	SET	2,H
MODU3	OUT	(C),H	;int. schalten
MODU4	LD	A,D
	LD	C,80H
	LD	B,L
	OUT	(C),A	;Senden Steuerb.
MODU5	LD	H,0
	PUSH	HL
	PUSH	AF
	LD	BC,0B800H
	ADD	HL,BC
	POP	AF
	JR	C,MODU6	;nur lesen
	LD	M,A	;eintragen
MODU6	LD	E,M	;R}ckgabe STB
	POP	HL	;(f}r Kommando)
	LD	C,80H
	LD	B,L
	IN	H,(C)	;Modultyp lesen
	RET
 
	DW	7F7FH
	DB	'JUMP',1
	LD	A,L
JUMP	LD	B,A		;**27**
	LD	C,80H
	IN	A,(C)
	INC	A	;Kennbyte FF?
	JP	Z,LOOP2	;ja-Fehler
	LD	A,0FFH
	OUT	(C),A	;Ausgabe FF
	LD	H,0
	LD	DE,0B800H
	ADD	HL,DE
	LD	M,A	;Eintrag
	IN	A,88H
	AND	7EH
	JP	BJUMP	;in IRM
 
;TAPE-Treiber
 
ISRO	;Init Bandausgabe	;**08**
	DI
	IN	A,88H
	OR	60H	;Motor, LED ein
	OUT	88H
	EI
	CALL	NOUT
	LD	(ZWOUT),HL
	LD	HL,(WEND)
	LD	(ZWEND),HL
	CALL	PAGE
	LD	(IX+2),0 ;1. Block
	LD	BC,2000H ;Vortonl{nge
	;
MBO	;Ausgabe 1 Block	;**01**
	INC	(IX+2)
	DI
	XOR	A
	LD	(IX+1),A;Pr}fsumme
	LD	A,87H	;EI,ZG16,Res
	OUT	8DH
	LD	A,2FH	;Vorton
	OUT	8DH
	EI
	LD	D,A	;D=2Fh
MBO1	CALL	HBITOT
	CPI
	JP	PE,MBO1	;BC mal
	CALL	ZTON	;Trennzeichen
	LD	A,(IX+2)
	CALL	BYTOT	;Blocknummer
	LD	L,(IX+5)
	LD	H,(IX+6)
	LD	B,80H
BLKOT	LD	A,M
	CALL	BYTOT	;Datenbyte
	LD	A,(IX+1)
	ADD	M	;Pr}fsumme
	LD	(IX+1),A;berechnen
	INC	HL
	DJNZ	BLKOT
	CALL	BYTOT	;und ausgeben
	LD	A,D
	CALL	BITO1	;noch ein Knacks
	LD	A,3
	OUT	8DH	;CTC stoppen
	RET
 
BYTOT	;Ausgabe eines Bytes
	PUSH	BC
	LD	C,A
	LD	B,8
BYTOUT	RRC	C	;mit Bit0
	PUSH	AF	;beginnend
	CALL	C,HBITOT
	POP	AF
	CALL	NC,LBITOT
	DJNZ	BYTOUT	;8*
	POP	BC
ZTON	LD	E,5DH	;ZK Trennz.
	JR	BITOUT
 
LBITOT	LD	E,17H	;ZK Low-Bit
	JR	BITOUT
 
HBITOT	LD	E,2FH	;ZK High-Bit
BITOUT	LD	A,D
	CALL	BITO1	;aufrufen und
	LD	A,D	;reinlaufen
BITO1	LD	(IX),A
BITO2	LD	A,(IX)	;warten auf
	OR	A	;Interrupt
	JR	NZ,BITO2
	LD	D,E
	RET
 
ISRC1	;ISR CTC Kanal 1 (Kassette-Out)
	PUSH	AF
	LD	A,3	;DI,ZG16,Res
	OUT	8DH
	LD	A,87H	;EI,ZG26,Res
	OUT	8DH
	LD	A,(IX)	;Uebergabezelle
	OUT	8DH	;ZK
	XOR	A
	LD	(IX),A	;Quittierung
	JP	ISR2E
 
CSRO	;Abschlu~ Bandausgabe	;**09**
	LD	(IX+2),0FEH
	CALL	MBO	;Endeblock
	LD	HL,(ZWOUT)
	LD	(OUTAB),HL
	LD	HL,(ZWEND)
	LD	(WEND),HL
	IN	A,88H
	AND	9FH	;Motor, LED aus
	OUT	88H
	JP	KPUFF
 
ISRI	;Init Bandausgabe	;**0A**
	DI
	IN	A,88H
	OR	40H	;Motor ein
	AND	0DFH	;LED aus
	OUT	88H
	CALL	NOUT	;Normalausgabe
	LD	(ZWOUT),HL
	LD	HL,(WEND)
	LD	(ZWEND),HL
	CALL	PAGE	;Page-Modus
	EI
	CALL	MBI0	;Block lesen
	RET	C	;Fehler
	LD	DE,COM
	LD	H,(IX+6)
	LD	A,(IX+5)
	ADD	8
	LD	L,A
	LD	B,4
ISRI1	LD	A,(DE)
	SUB	M
	AND	A
	INC	HL
	INC	DE
	RET	NZ
	DJNZ	ISRI1
	SET	7,(IX+7);COM-File
	RET		;gesch}tzt
 
MBI	;Einlesen 1 Block	;**05**
	BIT	7,(IX+7)
	SCF		;kein COM-File!
	RET	NZ
MBI0	LD	A,5	;DI,ZG16
	OUT	8EH	;CTC K2
	LD	A,83H	;EI
	OUT	8AH	;an PIO A
	PUSH	HL
	PUSH	DE
	LD	A,0A3H	;ZK
	OUT	8EH
	EI
MBI1	LD	B,16H
	XOR	A
	LD	(IX+1),A;Pr}fsumme=0
MBI2	CALL	STOP1
	JR	C,MBI1
	CP	0BAH
	CALL	LEDOO
	JR	C,MBI1	;10h korrekte
	DJNZ	MBI2	;Schwingungen
MBI3	LD	B,2	;erkennen
MBI4	XOR	A
	LD	C,A
	LD	(IX),A
	CALL	STOP21	;2 halbe Trenn-
	CP	5DH	;zeichen er-
	JR	NC,MBI3	;kennen
	DJNZ	MBI4
	CALL	BYTIN	;Blocknummer
	CALL	C,LEDOO
	LD	(IX+2),A
	LD	B,80H
	LD	L,(IX+5)
	LD	H,(IX+6)
BLKIN	CALL	BYTIN	;Datenbyte
	CALL	C,LEDOO
	LD	M,A
	LD	A,(IX+1)
	ADD	M	;aufsummieren
	LD	(IX+1),A
	INC	HL
	DJNZ	BLKIN
	CALL	BYTIN	;Pr}fsumme
	CALL	C,LEDOO
	LD	B,A
	LD	A,(IX+1)
	CP	B	;gleich?
	POP	DE
	POP	HL
	LD	A,3	;DI an PIO A
	OUT	8AH
	JR	Z,LEDOO
	SCF		;St|rung
LEDOO	PUSH	AF
	IN	A,88H
	SET	5,A	;LED ein
	JR	NC,MBI5
	RES	5,A	;LED aus
MBI5	OUT	88H
	POP	AF
	RET
 
COM	DB	'COM',1
 
ISRPA	;ISR PIO Kanal A (Kassette In)
	PUSH	AF
	IN	A,8EH
	LD	(IX),A	;Uebergabezelle
	LD	A,7
	OUT	8EH
	LD	A,0A3H
ISR1E	OUT	8EH
ISR2E	POP	AF
	EI
	RETI
 
STOP1	XOR	A	;1 Bit einlesen
	LD	(IX),A
STOP11	LD	A,(IX)	;warten auf
	OR	A	;Interrupt
	JR	Z,STOP11
	LD	C,A
	XOR	A
	LD	(IX),A
STOP21	LD	A,(IX)
	OR	A
	JR	Z,STOP21
	ADD	C	;beide 'Zeiten'
	RET		;addieren
 
BYTIN	;Einlesen eines Bytes
	LD	D,8	;8 Bit
	XOR	A
	LD	E,A
TRN1	CALL	STOP1	;Bit einlesen
	CCF
	JR	NC,TRN2
	CP	0BAH	;zu intolerant
	RET	C
	SCF
TRN2	RR	E	;Bit einschieben
	DEC	D
	JR	NZ,TRN1	;8*
	CALL	STOP1	;Trennzeichen
	LD	A,E	;mit CY-
	RET		;R}ckmeldung
 
TON	CALL	LARG		;**35**
TON1	BIT	1,(IX+8);alten Ton
	JR	NZ,TON1	;abwarten
	LD	A,L
	AND	A
	LD	A,3
	JR	Z,TON3	;kein Ton1
	LD	A,7
	BIT	0,H
	JR	Z,TON2	;VT16
	OR	20H	;VT256
TON2	OUT	8CH
	LD	A,L	;ZK1
TON3	OUT	8CH
	LD	A,E
	AND	A
	LD	A,3
	JR	Z,TON5	;kein Ton2
	LD	A,7
	BIT	0,D
	JR	Z,TON4	;VT16
	OR	20H	;VT256
TON4	OUT	8DH
	LD	A,E	;ZK2
TON5	OUT	8DH
	LD	A,C	;Lautst{rke
	XOR	1FH	;da nullaktiv
	SET	7,A	;Blinken ein
	LD	C,A
	LD	A,B
	AND	A
	JR	Z,TON6	;Dauerton
	RES	7,C	;Blinken aus
	SET	1,(IX+8);neuer Ton
	LD	A,0C7H	;EI, Z{hler 50Hz
	OUT	8EH	;CTC2
	LD	A,B	;Dauer
	OUT	8EH
TON6	LD	A,C	;Lautst{rke
	OUT	89H	;ausgeben
	RET
 
ISRC2	;ISR CTC Kanal 2 (Tondauer)
	PUSH	AF
	LD	A,3	;Ton aus
	OUT	8CH	;CTC0
	OUT	8DH	;CTC1
	IN	A,89H
	SET	7,A	;Blinken ein
	OUT	89H
	RES	1,(IX+8);Ton ist aus
	LD	A,47H	;CTC2 auf
	OUT	8EH	;Blinken stellen
	LD	A,20H	;ZK
	JP	ISR1E
 
	END
��
PAGE:\�
TCIF:J�
CCTAB:��
LARG:�
KP aus
	LD	A,47H	;CTC2 auf
	OUT	8EH	;Blinken stellen
	LD	A,20H	;ZK
	JP	ISR1E
 
	END
��
PAGE:\�
TCIF:J�
CCTAB:��
LARG:�
KP