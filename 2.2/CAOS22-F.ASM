CF22    ASM                                                                                                                      
;**	CAOS 2.2 ROM F		**
 
	ORG	0F000H
;
POWER	JP	PWRON
	JP	PV1	;m. DEFB nr
	JP	PV2	;(ARGC)=nr
	JP	PV3	;E=nr
	JP	PV4	;E=nr, IRM e/a
	JP	RCALL	;m. DEFW offset
 
PV4	PUSH	AF
	IN	A,88H
	SET	2,A
	OUT	88H	;IRM ein
	POP	AF
	CALL	PV3
	PUSH	AF
	IN	A,88H
	RES	2,A
	OUT	88H	;IRM aus
	POP	AF
	RET
 
PV1	DI
	PUSH	HL
	POP	HL
	POP	HL
	INC	HL	;nr }bergehen
	PUSH	HL
	DEC	HL	;(HL)=nr
	DEC	SP
	DEC	SP
	EI
	PUSH	AF
	PUSH	DE
	LD	E,M
PV22	LD	D,0
	LD	HL,(SUTAB)
	ADD	HL,DE
	ADD	HL,DE	;HL=Pos. in Tab
	LD	E,M
	INC	HL
	LD	D,M
	EX	DE,HL
	POP	DE
	POP	AF
	EX	(SP),HL
	RET		;UP anspringen
 
PV2	AND	A	;VR: F
PV21	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	HL
	LD	HL,POP3	;Returnadresse
	EX	(SP),HL	;kellern
	PUSH	HL
	PUSH	AF
	PUSH	DE
	JR	C,PV22	;falls PV3
	LD	A,(ARGC);sonst E
	LD	E,A	;beschaffen
	JR	PV22
 
PV3	SCF		;VR: F
	JR	PV21
 
RCALL	EX	(SP),HL	;VR: DE
	LD	E,M
	INC	HL
	LD	D,M
	INC	HL	;DE=offset
	EX	DE,HL
	ADD	HL,DE	;zur Absolut-
	EX	DE,HL	;adr. addieren
	EX	(SP),HL
	PUSH	DE
	RET		;wie JP (DE)
 
PWRON	;Einschalt-Init
	LD	SP,1D4H	;System-Stack
	LD	HL,0
	LD	B,L
	LD	C,L	;BC=0
	XOR	A
PWR1	LD	M,A	;Speicher
	CPI		;l|schen
	JP	PE,PWR1
	LD	BC,0FF80H
	OTIR		;Module aus
	LD	B,8
	IN	A,(C)
	CP	0F4H	;M022 in 08?
	JR	NZ,PWR2
	LD	A,2
	LD	L,B
	LD	D,43H	;als RAM4
	CALL	MODU	;zuschalten
	CALL	ERAM4	;RAM4 l|schen
PWR2	CALL	SYSI	;IRM init
	LD	BC,880H	;ROM-Modul mit
	IN	A,(C)	;Strukturbyte
	DEC	A	;01?
	JR	NZ,MEN0	;nein
	LD	L,B
	LD	D,43H	;auf 4000H
	LD	A,2	;zuschalten
	CALL	MODU
	JP	4000H	;anspringen
 
	DW	7F7FH
	DB	'MENU',1
MEN0	CALL	OSTR
	DB	0CH
	DB	'* HC-CAOS 2.2 *'
	DB	LF,CR,0
	LD	HL,0
	LD	C,L
	LD	B,H
MENU	CALL	OSTR
	DB	2,CR,'>',0
	LD	A,7FH	;Prolog (fest!)
MEN2	CPIR
	JP	PO,LOOP1
	CPI		;2. Mal?
	JR	NZ,MEN2
MEN3	LD	A,M
	CP	2	;Epilog?
	JR	C,MEN4
	CP	30H	;<30h?
	JR	C,MENU
	CP	5FH	;>5Fh, Kleinb.?
	JR	NC,MENU
	CALL	OCHR
	INC	HL
	DEC	BC
	JR	MEN3
MEN4	CALL	CRLF
	JR	MENU
 
LOOP	CALL	OSTR		;**12**
	DB	'>',0	;Prompt
LOOP1	CALL	INLIN
	INC	DE	;Zeichen danach
	LD	A,(DE)
	CP	' '
	JR	Z,LOOP	;Leerzeile
	AND	A
	JR	Z,LOOP	;Nullzeile
	LD	A,7FH	;Prolog (fest!)
	CALL	MSUCH
	JR	NC,LOOP2;nicht gef.
	PUSH	HL
	CALL	GARG	;Argumente
	JR	NC,LOOP3
	POP	HL
LOOP2	CALL	ERRM	;Fehler
	JR	LOOP
LOOP3	LD	HL,LOOP	;R}ckkehradr.
	EX	(SP),HL	;kellern
	PUSH	HL
	CALL	LARG
	EX	(SP),HL
	LD	A,M	;Epilog
	AND	A
	JR	NZ,LOOP4
	IN	A,88H
	RES	2,A	;IRM off
	OUT	88H
LOOP4	INC	HL	;Epilog
	EX	(SP),HL	;}bergehen
	RET
 
MSUCH	LD	BC,0
	LD	HL,0
ZSUCH	PUSH	AF		;**1D**
ZS1	POP	AF
	PUSH	AF
ZS2	CPIR
	JP	PO,ZS6	;ausgesucht
	CPI
	JR	NZ,ZS2	;falsch
	PUSH	DE
ZS3	LD	A,(DE)
	INC	DE
	CP	'!'	;keine SPC und
	JR	C,ZS4	;Steuerzeichen
	CPI
	JR	Z,ZS3
	POP	DE
	JR	ZS1
ZS4	LD	A,1
	CP	M	;Epilog?
	JR	NC,ZS5
	POP	DE
	JR	ZS1
ZS5	POP	AF
	POP	AF
	SCF		;CY=1
	RET
ZS6	POP	AF
	AND	A	;CY=0
	RET
 
OSTR	EX	(SP),HL		;**23**
OSTR1	LD	A,M
	INC	HL
	OR	A
	JR	NZ,OSTR2
	EX	(SP),HL
NOT	RET
OSTR2	CALL	OCHR
	JR	OSTR1
 
NORM	CALL	NIN		;**13**
NOUT	LD	HL,ZEI0		;**20**
SOUT	PUSH	HL		;**1E**
	LD	HL,(OUTAB)
	EX	(SP),HL
	LD	(OUTAB),HL
	POP	HL
	RET
 
NIN	LD	HL,ZEI4		;**21**
SIN	PUSH	HL		;**1F**
	LD	HL,(INTAB)
	EX	(SP),HL
	LD	(INTAB),HL
	POP	HL
	RET
 
INTB	PUSH	HL		;**16**
	LD	HL,(INTAB)
	JR	INTA1
	;
OCHR	PUSH	HL		;**24**
	LD	HL,(OUTAB)
INTA1	PUSH	DE	;s.a. PV1
	PUSH	BC	;(sehr {hnlich)
	PUSH	AF
	LD	A,M
	LD	(ARGC),A
	POP	AF
	CALL	PV2
POP3	POP	BC
	POP	DE
	POP	HL
	RET
 
WTUP	DEC	A	;UP f}r WAIT
	RET	Z
	PUSH	AF
	POP	AF
	JR	WTUP
 
WAIT	LD	B,A		;**14**
	XOR	A
WAIT1	CALL	WTUP
	DJNZ	WAIT1
	RET
 
KBD	CALL	CUCP		;**04**
	BIT	6,(IX+8);F-Taste aktiv?
	JR	NZ,KBD5	;ja
KBD1	CALL	KBDZ
	JR	NC,KBD1
	CP	0F1H	;F-Taste?
	JR	C,KBD4
	SET	6,(IX+8);ja - merken
	SUB	0F0H
	LD	B,A
	LD	HL,0B900H
KBD2	LD	A,M	;Pos. in F-
	AND	A	;Puffer best.
	INC	HL
	JR	NZ,KBD2
	DJNZ	KBD2
KBD3	LD	(FTAST),HL;Zeiger
KBD4	JP	CUCP
	;
KBD5	CALL	BRKT	;Abbruch?
	JR	NC,KBD7
KBD6	RES	6,(IX+8);F-Taste inaktiv
	JR	KBD4
	;
KBD7	LD	HL,(FTAST);Zeiger auf
	LD	A,M	;n{chstes CHR
	INC	HL
	AND	A	;Ende?
	JR	NZ,KBD3
	JR	KBD6
 
KCTAB	;IRM-Defaulttabelle
	DW	NOT	;Hardcopy
	DB	1	;WINNR
	DW	0100H	;WINON
	DW	1E28H	;WINLG
	DW	0	;CURSO
	DB	0	;STBT
	DB	39H	;COLOR
	DW	SCRLPG	;WEND
	DW	0E600H	;CCTL0
	DW	0E600H	;1
	DW	0E600H	;2
	DW	0E600H	;3
	DW	1D4H	;SYSP
	DW	SUTB	;SUTAB
	DW	CRTTAB	;CTAB
	OUT	88H	;BJUMP
	JP	0F012H
	DW	ZEI0	;OUTAB
	DW	ZEI4	;INTAB
	JP	NOT	;UOUT1	;**02**
	JP	NOT	;UIN1	;**06**
	JP	NOT	;UOUT2	;**03**
	JP	NOT	;UIN2	;**07**
 
INLIN	PUSH	HL		;**17**
INL1	CALL	INTB
	CALL	OCHR
	CP	CR	;Enter?
	JR	NZ,INL1
	CALL	CRLF
	LD	DE,(CURSO)
	CALL	DABR
	LD	DE,-40
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	RET
 
HLHX	LD	A,H		;**1A**
	CALL	AHEX
	LD	A,L
	CALL	AHEX
SPACE	LD	A,20H		;**2B**
	JR	SPAC0
 
	RET		;???
 
ERRM	CALL	OSTR		;**19**
	DB	'ERROR',7,0
CRLF	LD	A,CR		;**2C**
	CALL	OCHR
	LD	A,LF
SPAC0	JP	OCHR
 
HOME	LD	A,10H		;**2D**
	JR	SPAC0
 
AHEX	PUSH	AF		;**1C**
	RRA		;Tetradentausch
	RRA
	RRA
	RRA
	CALL	AHEX0	;erst rufen,
	POP	AF	;dann reinlaufen
AHEX0	AND	0FH	;Maske
	ADD	30H
	CP	3AH
	JR	C,AHEX1	;0..9
	ADD	7
AHEX1	JR	SPAC0	;A..F
 
	RET		;???
 
HLDE	CALL	HLDE1		;**1B**
HLDE1	CALL	HLHX
	EX	DE,HL
	RET
 
RHEX	LD	A,(DE)		;**18**
	CP	' '	;Trennzeichen
	INC	DE	;}bergehen
	JR	Z,RHEX
	DEC	DE
	LD	HL,0
	LD	(NUMVX),HL
	XOR	A
	LD	HL,NUMNX
	LD	M,A
RH1	LD	A,(DE)
	OR	A	;Ende-Dummy?
	RET	Z
	CP	' '	;Ende-Space?
	RET	Z
	SUB	'0'
	RET	C
	CP	10
	JR	C,RH2
	SUB	7
	CP	10
	RET	C
	CP	10H
	JR	C,RH2
	SCF
	RET
RH2	INC	DE
	INC	M	;NUMNX erh|hen
	INC	HL
	RLD		;Tetrade
	INC	HL	;durchschieben
	RLD
	DEC	HL
	DEC	HL	;RLD setzt auch
	JR	Z,RH1	;Z-Flag!
	DEC	DE
	SCF		;Zahl zu gro~
	RET
 
GARG	;bis 10 Arg. erfassen	;**22**
	LD	BC,ARGN
	XOR	A
	LD	(BC),A	;(ARGN)=0
GARG1	CALL	RHEX
	RET	C	;Fehler
	LD	A,M
	OR	A
	RET	Z	;Ende-Dummy
	INC	HL
	INC	BC
	LD	A,M	;L(NUMVX)
	LD	(BC),A	;L(Argument)
	INC	HL
	INC	BC
	LD	A,M	;H(NUMVX)
	LD	(BC),A	;H(Argument)
	LD	HL,ARGN
	INC	M
	LD	A,M
	CP	11	;10 Argumente?
	JR	C,GARG1
	SCF		;zu viele
	RET
 
SYSI	LD	DE,HCADR
	LD	HL,KCTAB
	LD	BC,30H
	LDIR		;IRM init
	LD	A,1
	;
SIXD	LD	HL,ISRTAB	;**31**
	LD	(MIXIT),A
	LD	E,0E4H
	LD	D,A
	LD	A,E
	LD	BC,12	;Interrupttab.
	LDIR		;kopieren
	ADD	12
	LD	E,A
	PUSH	DE	;IX-Arbeitsber.
	POP	IX
	LD	(IX+8),88H
	LD	(IX+9),7
	LD	(IX+14),KTAB	;Low
	LD	(IX+15),KTAB/256;High
INIT	DI
	PUSH	AF
	PUSH	DE
	PUSH	HL
	IM	2
	LD	A,(MIXIT)
	LD	I,A
	LD	D,7
	LD	HL,IOTAB
	CALL	INIME
	POP	HL
	POP	DE
	POP	AF
	EI
	;
KPUFF	LD	(IX+5),CASS	;Low
	LD	(IX+6),CASS/256	;High
	RET
 
IOTAB	DB	8AH	;PIO-A-Steuerw.
	 DB	2
	  DB	0E4H	;Int-Vektor
	  DB	4FH	;Byte-IN
	DB	88H	;PIO-A-Daten
	 DB	1
	  DB	9FH	;IRM ein...
	DB	8AH	;PIO-A-Steuerw.
	 DB	2
	  DB	0FH	;Byte-OUT
	  DB	3	;DI
	DB	8BH	;PIO-B-Steuerw.
	 DB	3
	  DB	0FH	;Byte-OUT
	  DB	83H	;EI
	  DB	0E6H	;Int-Vektor
	DB	89H	;PIO-B-Daten
	 DB	1
	  DB	0FFH	;Daten
	DB	8CH	;CTC0
	 DB	1
	  DB	0E8H	;Int-Vektor
	DB	8EH	;CTC2 (blinken)
	 DB	2
	  DB	47H	;DI,Z{hler,RES
	  DB	14H	;Zeitkonstante
 
	DW	7F7FH
	DB	'SAVE',1
	CALL	OSTR
	DB	'NAME :',0
	CALL	INLIN
	LD	HL,6	;'NAME :'
	ADD	HL,DE	;}bergehen
SAVE	LD	DE,CASS		;**36**
	LD	BC,11
	LDIR		;Name -> Puffer
	EX	DE,HL
	LD	M,0	;Abschlu~-Null
	LD	HL,ARGN
	LD	A,M
	CP	2	;mind 2 Arg!
	RET	C
	LD	DE,CASS+10H
	LD	C,15H	;alle Argumente
	LDIR		;nach Puffer
	CALL	ISRO
	LD	HL,(ARG1)
SAV1	LD	(IX+5),L
	LD	(IX+6),H
	LD	A,(IX+2)
	CALL	AHEX	;Blocknummer
	CALL	OSTR
	DB	'  ',0
	CALL	BRKT
	LD	BC,0A0H
	JR	C,SAV2
	LD	DE,80H
	ADD	HL,DE
	LD	DE,(ARG2)
	AND	A
	SBC	HL,DE	;Ende erreicht?
	JR	NC,SAV2
	CALL	MBO
	JR	SAV1
	;
SAV2	CALL	CRLF
	JP	CSRO
 
BRKT	CALL	KBDS		;**2A**
	RET	NC
	CP	3	;Break?
	SCF
	RET	Z
	AND	A
	RET
 
LARG	LD	BC,(ARG3)	;**15**
	LD	DE,(ARG2)
	LD	HL,(ARG1)
	RET
 
	DW	7F7FH
	DB	'VERIFY',1
VERIF	RES	0,(IX+7)	;**11**
	JR	LOAD0
 
	DW	7F7FH
	DB	'LOAD',1
LOAD	SET	0,(IX+7)	;**10**
LOAD0	CALL	ISRI
LOAD1	LD	A,(IX+2)
	JR	NC,LOAD3
LOAD2	CALL	AHEX
	CALL	OSTR
	DB	'* ',19H,LF,0
	CALL	MBI0
	JR	LOAD1
	;
LOAD3	CP	2	;Block 0 oder 1?
	JR	NC,LOAD2
	INC	A
	LD	E,A
	LD	HL,CASS
	LD	B,11
LOAD4	LD	A,M	;Name anzeigen
	INC	HL
	CALL	CRT
	DJNZ	LOAD4
	LD	(IX+3),E;erwarteter Blk
	LD	A,(CASS+10H)
	BIT	0,(IX+7)
	JR	Z,LOAD6	;VERIFY
	LD	(IX+4),A;Anz. Arg.
	CP	2
	JR	C,NOMC	;zu wenig Arg.
	CP	11
	JR	NC,NOMC	;zu viel Arg.
	LD	DE,(CASS+13H)
	LD	HL,(CASS+11H)
	LD	A,(ARGN)
	AND	A	;Ladeoffset?
	JR	Z,LOAD5
	LD	BC,(ARG1)
	ADD	HL,BC	;AAdr, EAdr
	EX	DE,HL	;umrechnen
	ADD	HL,BC
	EX	DE,HL
	BIT	2,(IX+4);4..7 Args?
	JR	NZ,LOAD5
	PUSH	HL
	LD	HL,(CASS+15H)
	ADD	HL,BC	;SAdr umrechnen
	LD	(CASS+15H),HL
	POP	HL
LOAD5	LD	BC,(CASS+15H)
	LD	(ARG2),BC;SAdr merken
	CALL	SPACE
	CALL	HLDE	;AAdr, EAdr
LOAD6	CALL	CRLF
	;Load-Hauptschleife
LOAD7	CALL	BRKT
	BIT	7,(IX+7);COM-File?
	JR	Z,LOAD8
	JP	C,POWER	;BRK -> POWER
LOAD8	JR	C,CLCP	;BRK -> Abbruch
	CALL	MBI0
	LD	A,(IX+2);Blocknr.
	PUSH	AF
	CP	(IX+3)
	JR	Z,LOAD9	;erwarteter Blk.
	INC	A
	JR	Z,LOAD9	;letzter Blk.
	POP	AF
	CALL	AHEX	;Blocknummer
	CALL	OSTR
	DB	'* ',0
	JR	LOAD7
	;
NOMC	CALL	OSTR
	DB	'???',19H,LF,0
CLCP	JR	CSRI
	;
LOAD9	POP	AF
	JR	C,LOAD13;Fehler
	PUSH	AF
	CALL	AHEX
	CALL	OSTR
	DB	'> ',0
	POP	AF
LOAD10	INC	A
	JR	Z,LOAD15	;letzter
	BIT	0,(IX+7)
	JR	Z,LOAD11;VERIFY
	LD	BC,80H
	PUSH	DE
	LD	DE,CASS	;ganzen Block
	EX	DE,HL	;in Speicher
	LDIR		;kopieren
	EX	DE,HL
	POP	DE
LOAD11	INC	(IX+3)	;n{chster Block
LOAD12	JR	LOAD7
	;
LOAD13	BIT	7,(IX+7)
	JR	NZ,LOAD7;COM-File!
	CALL	AHEX	;Blocknummer
	CALL	OSTR
	DB	'? ',19H,LF,0
	BIT	0,(IX+7)
	JR	Z,LOAD7	;VERIFY
	CALL	OSTR
	DB	'REPEAT (N)?',LF,CR,0
	RES	6,(IX+8)
LOAD14	CALL	KBD
	JR	Z,LOAD14;keine Taste
	CP	'N'
	JR	NZ,LOAD12
	LD	(IX+4),2;kein Start
	LD	A,(IX+2)
	JR	LOAD10
	;
LOAD15	EX	DE,HL
	SBC	HL,DE
	LD	C,L	;Blockrest
	LD	B,0	;berechnen
	BIT	0,(IX+7)
	JR	Z,CSRI	;VERIFY
	LD	HL,CASS
	LDIR		;kopieren
CSRI	LD	HL,(ZWOUT)	;**0B**
	LD	(OUTAB),HL
	LD	HL,(ZWEND)
	LD	(WEND),HL
	CALL	INIT
	CALL	CRLF
	BIT	0,(IX+7)
	RET	Z	;VERIFY
	LD	A,(IX+4)
	CP	3
	LD	(IX+4),2
	RET	C
	LD	HL,(ARG2);SAdr
	JP	(HL)	 ;Programmstart
 
	DW	7F7FH
	DB	'COLOR',1
COLR	LD	A,1FH		;**0F**
	AND	L
	RLA
	RLA
	RLA
	LD	L,A
	LD	A,(ARGN)
	CP	2
	JR	NC,COLR2
	LD	A,(COLOR)
COLR1	AND	7
	OR	L
	LD	(COLOR),A
	RET
	;
COLR2	LD	A,E
	JR	COLR1
 
SUTB	;Unterprogrammtabelle
	DW	CRT	;00
	DW	MBO	;01
	DW	UOUT1	;02
	DW	UOUT2	;03
	DW	KBD	;04
	DW	MBI	;05
	DW	UIN1	;06
	DW	UIN2	;07
	DW	ISRO	;08
	DW	CSRO	;09
	DW	ISRI	;0A
	DW	CSRI	;0B
	DW	KBDS	;0C
	DW	BYE	;0D
	DW	KBDZ	;0E
	DW	COLR	;0F
	DW	LOAD	;10
	DW	VERIF	;11
	DW	LOOP	;12
	DW	NORM	;13
	DW	WAIT	;14
	DW	LARG	;15
	DW	INTB	;16
	DW	INLIN	;17
	DW	RHEX	;18
	DW	ERRM	;19
	DW	HLHX	;1A
	DW	HLDE	;1B
	DW	AHEX	;1C
	DW	ZSUCH	;1D
	DW	SOUT	;1E
	DW	SIN	;1F
	DW	NOUT	;20
	DW	NIN	;21
	DW	GARG	;22
	DW	OSTR	;23
	DW	OCHR	;24
	DW	CUCP	;25
	DW	MODU	;26
	DW	JUMP	;27
	DW	LDMA	;28
	DW	LDAM	;29
	DW	BRKT	;2A
	DW	SPACE	;2B
	DW	CRLF	;2C
	DW	HOME	;2D
	DW	MODI	;2E
	DW	PUDE	;2F
	DW	PUSE	;30
	DW	SIXD	;31
	DW	DABR	;32
	DW	TCIF	;33
	DW	PADR	;34
	DW	TON	;35
	DW	SAVE	;36
 
LDMA	LD	M,A		;**28**
	RET
 
LDAM	LD	A,M		;**29**
	RET
 
	DW	7F7FH
	DB	'MODIFY',1
MODI1	CALL	LARG
MODI	LD	A,0BFH		;**2E**
	CP	H
	RET	C	;ab C000h gesp.
	LD	(ARG1),HL
	CALL	HLHX	;Adresse
	LD	A,M
	CALL	AHEX	;Datenbyte
	CALL	OSTR
	DB	' ',8,8,8,0
	CALL	INLIN
	CALL	RHEX	;Adresse
	JR	C,MODI9	;Fehler
	LD	A,M
	OR	A
	JR	Z,MODI9	;kein Zeichen
	INC	HL
	PUSH	DE
	LD	E,M
	INC	HL
	LD	D,M
	EX	DE,HL	;HL=Adresse
	POP	DE
	LD	B,0
MODI2	PUSH	HL
	CALL	RHEX	;Datenbyte
	LD	A,M
	OR	A
	JR	Z,MODI4	;kein Zeichen
	INC	HL
	LD	A,M
	POP	HL
MODI3	LD	M,A	;eintragen
	INC	B
	INC	HL
	PUSH	HL
MODI4	POP	HL
	LD	A,(DE)
	CP	'.'	;Abschlu~?
	RET	Z
	CP	','	;1 Zeichen?
	JR	NZ,MODI5
	INC	DE
	LD	A,(DE)	;vom VIDEO-RAM
	INC	DE
	JR	MODI3	;eintragen
	;
MODI5	LD	A,B
	OR	A
	JR	NZ,MODI6
	INC	HL
MODI6	LD	A,(DE)
	CP	':'	;R}ckschritt?
	JR	NZ,MODI7
	DEC	HL
	DEC	HL
	JR	MODI
	;
MODI7	CP	'/'	;neue Adresse?
	JR	NZ,MODI8
	INC	DE
	CALL	RHEX	;Adresse
	JR	C,MODI9	;Fehler
	LD	HL,(NUMVX)
	JR	MODI
	;
MODI8	OR	A	;Ende-Dummy?
	JR	Z,MODI
	CP	' '
	JR	Z,MODI2	;noch ein Byte
MODI9	CALL	ERRM
	JR	MODI1
 
JPTAB	;Sprungtabelle f}r CRT-Routinen
	DW	CLR	;01
	DW	BEEP	;07
	DW	HCOPY	;0F
	DW	CBL	;0D
	DW	CLS	;0C
	DW	CUL	;08
	DW	DEL	;1F
	DW	CUD	;0A
	DW	INS	;1A
	DW	CBL	;19
	DW	CLLN	;02
	DW	CUU	;0B
	DW	CUR	;09
	DW	HOMEPG	;10
	DW	SCROL	;12
	DW	PAGE	;11
 
CCTAB:	;CCTL-Tabelle
	;Aufbau: Zeichen, Offset, CCTL
	DB	0E0H,0C0H,CCTL3
	DB	0A0H,0A0H,CCTL2
	DB	080H,080H,CCTL3
	DB	060H,040H,CCTL1
	DB	020H,020H,CCTL0
	DB	000H,000H,CCTL1
 
TCIF	LD	A,(WINLG)	;**33**
	DEC	A
	SUB	E	;Cursor-Spalte
	RET	C
	LD	A,(WINLG+1)
	DEC	A
	SUB	D	;Cursor-Zeile
	RET
 
CRT	PUSH	AF		;**00**
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	AF
	LD	A,(STBT)
	LD	DE,(CURSO)
	LD	L,A
	POP	AF
	CP	20H	;Steuerfunktion?
	JR	NC,CRT1
	BIT	3,L	;darstellen?
	JR	NZ,CRT1
	LD	HL,(CTAB)
	LD	BC,16
	CPIR		;Funktion def.?
	JR	NZ,CRT3	;nein
	LD	HL,JPTAB
	ADD	HL,BC
	ADD	HL,BC
	LD	C,M
	INC	HL
	LD	H,M
	LD	L,C	;HL=Sprungadr.
	CALL	JPHL
	JR	CRT2
	;
CRT1	CALL	PCHR
CRT2	LD	(CURSO),DE
CRT3	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
	;
PCHR	PUSH	AF
	CALL	DABR
	POP	AF
	LD	M,A	;ASCII eintragen
	CALL	WPIX	;darstellen
CUR	INC	E
	LD	A,(WINLG)
	CP	E
	RET	NZ
	LD	E,0
CUD	INC	D
	LD	A,(WINLG+1)
	CP	D
	RET	NZ
	LD	HL,(WEND)
JPHL	JP	(HL)	;PAGE o SCROLL
 
HCOPY	LD	HL,(HCADR)
	JP	(HL)	;ShCLR
 
SCRLPG	LD	DE,0	;Cursol li/oben
	CALL	DABR
	INC	D
	PUSH	HL
	CALL	DABR	;n{chste Zeile
	POP	DE
	JR	C,SCRL9
	LD	A,(WINLG)  ;Spalten
	LD	C,A
	LD	A,(WINLG+1);Zeilen
	DEC	A
	LD	B,0
SCRL1	PUSH	HL
	PUSH	BC
	LDIR		;im VRAM eine
	POP	BC	;Zeile rollen
	POP	DE
	LD	HL,40	;1 Zeile tiefer
	ADD	HL,DE
	DEC	A
	JR	NZ,SCRL1
	LD	A,(WINON+1)
	RLCA
	RLCA
	RLCA
	LD	H,A	;Zeile*8
	LD	A,(WINLG+1)
	DEC	A
	RLCA
	RLCA
	RLCA		;L{nge*8
	PUSH	AF
	LD	A,(WINON);Spalte
	CP	32
	LD	C,A
	LD	A,(WINLG);Breite
	JR	NC,SCRL2 ;rechter Teil
	ADD	C
	CP	32
	JR	C,SCRL3
	LD	B,32
	SUB	B
	LD	D,C
	LD	C,A
	LD	A,B
	JR	SCRL4
	;
SCRL2	LD	B,C
	LD	C,A
	LD	DE,0
	JR	SCRL5
	;
SCRL3	LD	D,C
	LD	BC,0
SCRL4	SUB	D
	LD	E,A
SCRL5	POP	AF
SCRL6	PUSH	AF
	LD	A,E
	AND	A
	JR	Z,SCRL7
	LD	L,D
	CALL	SCRLUP
SCRL7	LD	A,C
	AND	A
	JR	Z,SCRL8
	LD	L,B
	CALL	SCRLUP
SCRL8	INC	H
	POP	AF
	DEC	A
	JR	NZ,SCRL6
SCRL9	LD	A,(WINLG+1)
	DEC	A
	LD	D,A
	JR	CLLN
 
CLR	PUSH	DE
	CALL	DABR
	LD	A,' '	;Leerzeichen
	LD	M,A
	CALL	WPIX
	POP	DE
CUL	LD	A,E	;Cursor links
	SUB	1
	JR	C,CUL1
	LD	E,A
	RET
	;
CUL1	LD	A,D	;Zeile hoch
	SUB	1
	RET	C
	LD	D,A
	LD	A,(WINLG)
	DEC	A
	LD	E,A
	RET
 
CLLN	LD	E,0	;ShDEL
	PUSH	DE
	CALL	DABR
	LD	A,(WINLG)
	LD	B,A	;Spalten
CLLN1	LD	M,0	;VRAM l|schen
	LD	A,' '
	CALL	WPIX	;Space anzeigen
	INC	HL
	DJNZ	CLLN1
	POP	DE
	RET
 
CLS	LD	D,0	;ShHOME
	LD	A,(WINLG+1)
CLS1	PUSH	AF
	PUSH	DE
	CALL	CLLN	;Zeile f}r
	POP	DE	;Zeile l|schen
	POP	AF
	INC	D
	DEC	A
	JR	NZ,CLS1
HOMEPG	LD	D,0
CBL	LD	E,0
	RET
 
CUU	LD	A,D
	SUB	1
	RET	C
	LD	D,A
	RET
 
SCROL	LD	HL,SCRLPG	;ShCUD
WADR	LD	(WEND),HL
	RET
 
PAGE	LD	HL,HOMEPG	;ShCUU
	JR	WADR
 
DEL	CALL	DABR
	LD	A,M
	AND	A	;Ende?
	RET	Z
	PUSH	DE	;Cursor
	PUSH	HL	;VRAM
DEL1	INC	E	;n{chste Spalte
	CALL	DABR	;raus?
	JR	NC,DEL2	;nein
	LD	E,0	;Spalte 0 in
	INC	D	;neuer Zeile
	CALL	DABR	;raus?
	JR	C,DEL3	;ja, Ende
DEL2	LD	A,M
	AND	A	;Ende?
	JR	Z,DEL3
	EX	(SP),HL
	LD	M,A	;eintragen
	CALL	WPIX	;zeichnen
	JR	DEL1	;von vorn
	;
DEL3	POP	HL
	LD	M,0	;letztes CHR
	LD	A,' '	;l|schen
	CALL	WPIX
	POP	DE
	RET
 
INS	PUSH	DE	;Cursor
	LD	A,' '
	CALL	DABR
INS1	LD	B,M	;altes
	LD	M,A	;neues Zeichen
	CALL	WPIX	;zeichnen
	LD	A,B
	AND	A	;Dummy?
	JR	Z,INS2
	INC	E	;CUR
	CALL	DABR	;raus?
	JR	NC,INS1	;nein
	LD	E,0	;Spalte 0 in
	INC	D	;neuer Zeile
	CALL	DABR	;raus?
	JR	NC,INS1	;nein
	POP	DE
	RET
	;
INS2	PUSH	HL
	INC	E	;CUR
	CALL	DABR	;raus?
	JR	NC,INS3	;nein
	LD	E,0
	INC	D
	CALL	DABR
	JR	C,INS4
INS3	LD	A,M
	AND	A	;Dummy?
	JR	NZ,INS4
	POP	HL
	POP	DE
	RET
	;
INS4	POP	HL
	LD	M,0	;Zeichen
	LD	A,' '	;l|schen
	CALL	WPIX
	POP	DE
	RET
 
	DB	'KDK'	;???
	DB	0FFH	;frei
 
	END
��
INS4:��
INS3:��
INS2:��
INS1:��
INS:��
DEL3:��
DEL2:��
DEL1:��
DEL:��
PAGE:��

 
	DB	'KDK'	;???
	DB	0FFH	;frei
 
	END
��
INS4:��
INS3:��
INS2:��
INS1:��
INS:��
DEL3:��
DEL2:��
DEL1:��
DEL:��
PAGE:��
