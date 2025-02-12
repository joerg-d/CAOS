CE41    ASM                                                                                                                      
;**	CAOS 4.1 ROM E		**
 
	ORG	0E000H
 
	JP	BYE	;Tasten-RESET
	JP	BEXP1	;BASIC-
	JP	BEXP2	;Expansionen
	JP	BEXP3
	DEFW	TOKTAB
	JP	BASPV
 
	DEFW	7F7FH
	DEFM	'BASIC'
	DEFB	0
	CALL	BASON
	JP	0C00DH
 
	DEFW	7F7FH
	DEFM	'REBASIC'
	DEFB	0
	CALL	BASON
	JP	0C08CH
 
BASON	;BASIC-ROM auftauen
	IN	A,88H
	OR	80H
	OUT	88H
	LD	A,(IX+4)
	OR	60H	;Segment 0
	OUT	86H
	LD	(IX+4),A
	RET
 
;CRT-Treiber
 
PADR0	LD	DE,(CURSO)
PADR1	LD	HL,(WINON)
	ADD	HL,DE
	SLA	H
	SLA	H
	SLA	H
	;
PADR	PUSH	AF		;**34**
	LD	A,L	;Spalte
	LD	L,H	;Pixelzeile
	CP	28H
	JR	NC,IAD2	;zu gro~
	OR	80H
	LD	H,A	;HL=Pixeladr.
	POP	AF
	AND	A	;CY=0
	RET
	;
IAD2	POP	AF
	SCF		;CY=1
	RET
 
TCIF	;Test Cursor im Fenster  **33**
	LD	A,(WINLG)
	DEC	A
	SUB	E	;Cursor-Spalte
	RET	C
	LD	A,(WINLG+1)
	DEC	A
	SUB	D	;Cursor-Zeile
	RET
 
DABR	PUSH	AF		;**32**
	CALL	TCIF
	JR	C,IAD2
	LD	A,(WINON)
	ADD	E	;Cursor-Spalte
	PUSH	DE
	LD	E,A	;absolut
	LD	A,(WINON+1)
	ADD	D	;Cursor-Zeile
	ADD	A
	ADD	A
	ADD	A	;*8
	LD	L,A	;Pixel-Zeile
	LD	H,0
	LD	D,H
	ADD	HL,HL
	ADD	HL,HL	;*4
	ADD	HL,DE	;*5 zus. *40
	LD	DE,(VRAM)
	LD	E,A
	ADD	HL,DE
	POP	DE
	POP	AF
	AND	A
	RET
 
ESC81	;Farbe compeln (V<=>H)
	PUSH	AF
	AND	0C0H
	LD	C,A	;Bit 6,7
	POP	AF
	PUSH	AF
	AND	7	;hFarbe
	RLCA
	RLCA
	RLCA
	OR	C
	LD	C,A
	POP	AF
	RRCA
	RRCA
	RRCA
	AND	7	;vFarbe
	OR	C
	RET
 
WPIX	;Zeichen auf Grafikbildschirm
	;sichtbar machen, PE: DE,A
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	LD	HL,(WINON)
	ADD	HL,DE
	EX	DE,HL	;DE:Absolut-Curs
	LD	HL,CCTL0
	ADD	A
	JR	NC,WPIX1
	LD	L,0AAH	;CCTL2
WPIX1	SUB	40H
	JR	C,WPIX2	;0..1F/80..9F
	CP	80H
	JR	C,WPIX3	;20..40/A0..C0
WPIX2	ADD	40H
	INC	L	;um 1 CCTL
	INC	L	;h|her
WPIX3	LD	C,M
	INC	L	;BC=(CCTL)
	LD	B,M
	ADD	A	;*2
	LD	L,A
	LD	H,0
	ADD	HL,HL	;*4
	ADD	HL,BC	;*8
	LD	A,E	;Absolutspalte
	CP	28H
	JR	NC,POPS4;au~erhalb
	OR	80H
	LD	B,D
	LD	D,A
	LD	A,B	;A:=:D
	ADD	A
	ADD	A
	ADD	A	;*8
	LD	E,A	;DE=Pixeladr.
	LD	A,(STBT)
	BIT	2,A	;invers?
	JR	Z,WPIX5
	LD	C,A	;ja, per
	LD	B,8	;Schleife
	PUSH	DE	;zeichnen
WPIX4	LD	A,M
	CPL		;(Hier kein
	LD	(DE),A	;Test auf
	INC	HL	;Schreiben
	INC	DE	;Pixel aus!)
	DJNZ	WPIX4	;*8
	LD	A,C
	RRCA
	JR	WPIX6
 
WPIX5	RRCA		;Schreiben Pix?
	JR	C,WPIX7
	PUSH	DE	;ja
	LDI		;sehr schnell
	LDI		;per LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
WPIX6	POP	DE
WPIX7	RRCA		;Schreiben Farb?
	JR	C,POPS4
	LD	A,(IX+1);ja
	LD	H,A
	XOR	2
	DI
	OUT	84H	;Farbebene
	LD	A,(COLOR)
	LD	(DE),A	;sehr schnell
	INC	DE	;ohne Schleife
	LD	(DE),A
	INC	DE	;alles im DI
	LD	(DE),A
	INC	DE
	LD	(DE),A
	INC	DE
	LD	(DE),A
	INC	DE
	LD	(DE),A
	INC	DE
	LD	(DE),A
	INC	DE
	LD	(DE),A
	LD	A,H
	OUT	84H
	EI
POPS4	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET
 
MOVELN	;Rolle Fenster f}r Scrolling
	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF
	EX	AF
	PUSH	AF
	LD	A,C	;BC:Pixelzeilen
	EX	AF
	LD	A,(WINLG) ;Spalten
MOLN1	PUSH	HL
	PUSH	DE
MOLN2	LDI		;zeichenweise
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	JP	PE,MOLN2
	POP	DE
	POP	HL
	INC	H	;neue Spalte
	INC	D
	EX	AF
	LD	C,A
	EX	AF
	DEC	A	;Spaltenz{hler
	JR	NZ,MOLN1
	EX	AF
	POP	AF
	EX	AF
	JR	POPS4
 
PCHR	;CRT-Grundprogramm
	LD	DE,(CURSO)
	LD	HL,STBT
	BIT	4,M	;ESC aktiv?
	JR	Z,PCHR3
CRT1	RES	4,M
	CP	'0'
	RET	C
	CP	'9'+1
	JR	NC,PCHR1
	SUB	'0'
	JR	PCHR2
	;
PCHR1	CP	'A'
	RET	C
	RES	5,A
	CP	'Z'+1
	RET	NC
	SUB	'A'-0AH
PCHR2	LD	HL,L3SIZ;Tabelle
	CP	M	;lang genug?
	RET	NC
	ADD	A	;*2
	LD	HL,(L3TAB) ;klar zum
	JR	PCHR4	;Ansprung
	;
PCHR3	CP	20H	;Steuerfunktion?
	JR	NC,PCHR5
	BIT	3,M	;darstellen?
	JR	NZ,PCHR5
	ADD	A	;*2
	LD	HL,(CTAB)
PCHR4	LD	C,A
	LD	B,0
	ADD	HL,BC
	LD	A,M
	INC	HL
	LD	H,M
	LD	L,A
JPHL	JP	(HL)	;anspringen
 
ESC0	LD	A,E	;Tabulator
	AND	0F8H	;8er Step
	ADD	8
	LD	E,A
	JR	CUR1
	;
PCHR5	CALL	DABR
	RET	C	;au~erhalb
	LD	M,A	;ASCII eintragen
	CALL	WPIX	;darstellen
CUR	INC	E
CUR1	LD	A,(WINLG)
	DEC	A
	CP	E
	RET	NC
NL	LD	E,0	;NL f}r 1E
CUD	INC	D
	LD	A,(WINLG+1)
	CP	D
	RET	NZ
	LD	HL,(WEND)
	JP	(HL)	;PAGE o. SCROLL
 
HCOPY	LD	HL,(HCADR) ;ShCLR
	JP	(HL)
 
CUL	LD	A,E
	AND	A
	JR	Z,CUL1
	DEC	E
	RET
 
CUL1	LD	A,D
	AND	A
	RET	Z
	DEC	D
CEL	LD	A,(WINLG)
	DEC	A
	LD	E,A
	RET
 
CUU	LD	A,D
	AND	A
	RET	Z
	DEC	D
	RET
 
PAGE	LD	HL,HOMEPG ;ShCUU
WADR	LD	(WEND),HL
	RET
 
SCROL	LD	HL,SCRLPG ;ShCUD
	JR	WADR
 
CLR	CALL	CUL
DEL	PUSH	DE	;Cursor retten
	CALL	DABR
	LD	A,M
	AND	A	;Ende?
	JR	Z,POPDE
	PUSH	HL	;VRAM
DEL1	PUSH	DE	;Cursor
	INC	E	;n{chste Spalte
	CALL	DABR	;raus?
	JR	NC,DEL2
	LD	E,0	;ja, wie NL
	INC	D
	CALL	DABR	;raus?
	JR	C,DEL3	;ja, wie Ende
DEL2	LD	A,M
	AND	A	;Ende?
	JR	Z,DEL3
	LD	B,D
	LD	C,E	;BC:=DE
	POP	DE	;DE=links davon
	EX	(SP),HL	;HL=VRAM links
	LD	M,A	;eintragen
	CALL	WPIX	;zeichnen
	LD	D,B
	LD	E,C	;DE=BC
	JR	DEL1	;von vorn
 
DEL3	POP	DE
	POP	HL
	LD	M,0
	LD	A,' '
	CALL	WPIX
POPDE	POP	DE
	RET
 
INS	PUSH	DE	;Cursor
	LD	A,' '
	CALL	DABR
INS1	LD	B,M	;VRAM
	LD	M,A	;neues Zeichen
	CALL	WPIX	;zeichnen
	LD	A,B
	AND	A	;Dummy?
	JR	Z,INS2
	INC	E	;CUR
	CALL	DABR	;raus?
	JR	NC,INS1
	LD	E,0	;wie NL
	INC	D
	CALL	DABR	;raus?
	JR	NC,INS1
INS2	POP	DE	;wenn ja Schlu~
	RET
 
CLS	LD	A,(WINLG+1) ;ShHOME
	LD	D,0
CLS1	PUSH	AF
	CALL	CLLN
	POP	AF
	INC	D
	DEC	A
	JR	NZ,CLS1	;A Zeilen
HOMEPG	LD	D,0
CBL	LD	E,0
	RET
 
CLLINE	;L|schen einer Zeile
	;HL: Adr. C: L{nge, A: Byte
	LD	B,C
CLL1	LD	D,L	;L retten
	LD	M,A	;zeichenweise
	INC	L	;ohne Schleife
	LD	M,A
	INC	L
	LD	M,A
	INC	L
	LD	M,A
	INC	L
	LD	M,A
	INC	L
	LD	M,A
	INC	L
	LD	M,A
	INC	L
	LD	M,A
	LD	L,D	;L holen
	INC	H
	DJNZ	CLL1
	RET
 
SCRLPG	LD	A,(WINLG) ;Spalten
	LD	C,A
	LD	B,0
	LD	A,(WINLG+1) ;Zeilen
	DEC	A	;nur 1 Zeile?
	JR	Z,SCRL3	;nur CLLN
	PUSH	DE
	PUSH	AF
	LD	DE,0	;Cursor li/oben
	CALL	DABR
	EX	DE,HL
SCRL1	LD	HL,40	;1 Zeile tiefer
	ADD	HL,DE
	PUSH	HL
	PUSH	BC
	LDIR		;im VRAM eine
	POP	BC	;Zeile rollen
	POP	DE
	DEC	A
	JR	NZ,SCRL1 ;A*
	POP	AF
	ADD	A
	ADD	A
	ADD	A	;*8: Pixelzeile
	LD	C,A
	LD	DE,0
	LD	B,D
	CALL	PADR1
	EX	DE,HL	;DE=PixAdr.
	LD	L,8	;H war 0
	ADD	HL,DE
	LD	A,(STBT)
	RRA
	RRA		;Schreiben Farb?
	JR	C,SCRL2
	PUSH	AF
	CALL	FARBEA
	CALL	MOVELN
	CALL	FARBEA
	POP	AF
SCRL2	RLA		;Schreiben Pix?
	CALL	NC,MOVELN
	POP	DE
SCRL3	DEC	D
	;
CLLN	LD	E,0	;ShDEL
	CALL	DABR	;au~erhalb?
	RET	C	;(Selbstschutz)
	LD	A,(WINLG)
	LD	B,A	;Spalten
	LD	C,A
	XOR	A
CLLN1	LD	M,A	;VRAM l|schen
	INC	HL
	DJNZ	CLLN1
	CALL	PADR1
	RET	C
	PUSH	DE
	LD	A,(STBT)
	RRCA		;Schreiben Pix?
	LD	E,A	;nach E merken
	JR	C,CLLN2
	XOR	A
	PUSH	HL
	CALL	CLLINE	;Pixel
	POP	HL
CLLN2	RRC	E	;Schreiben Farb?
	JR	C,CLLN3
	CALL	FARBEA
	LD	A,(COLOR)
	CALL	CLLINE	;Farbe
	CALL	FARBEA
CLLN3	POP	DE
	RET
 
FARBEA	LD	A,(IX+1) ;wie ESC9
	XOR	2
	DI
	LD	(IX+1),A
	OUT	84H
	EI
	RET
 
BEEP	LD	BC,0A0FH ;CHR(7)
	LD	HL,30H
	PUSH	DE
	LD	E,H	;E=0
	CALL	TON2
	LD	A,1EH
	CALL	WAIT
	LD	A,3
	OUT	8CH
	LD	A,10H
	POP	DE
	JP	WAIT
 
CLIK	LD	HL,30H
	PUSH	DE
	LD	E,H	;E=0
	CALL	TON2
	POP	DE
	RET
 
ESC8	LD	HL,COLOR ;Farbtausch
	LD	A,M
	CALL	ESC81
LDMA	LD	M,A		;**28**
	RET
 
LDAM	LD	A,M		;**29**
	RET
 
CLICK	LD	A,(IX+8) ;ShINS
	XOR	20H
	LD	(IX+8),A
NOT	RET
 
ESC	LD	HL,STBT	;ShSTOP
	SET	4,M
	RET
 
CRT	PUSH	HL		;**00**
	PUSH	DE
	PUSH	BC
	PUSH	AF
	CALL	PCHR
	LD	(CURSO),DE
	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET
 
;KBD-Treiber
 
ISRC3	;ISR CTC Kanal 3 (Tastatur)
	EI
	PUSH	AF
	LD	A,23H	;DI,ZG256,Res
	OUT	8FH	;CTC K3
	SET	3,(IX+8)
	LD	(IX+13),0 ;Zeichen tot
	JR	TST4
 
ISRPB	;ISR PIO Kanal B (Tastatur)
	PUSH	AF
	IN	A,8FH	;gemessene
	PUSH	AF	;Zeit retten
	LD	A,0A7H	;EI,ZG256,Res
	OUT	8FH
	LD	A,8FH	;Zeitkonstante
	OUT	8FH
	POP	AF
	EI
	BIT	3,(IX+8)
	RES	3,(IX+8)
	JR	NZ,TST4
	CP	78H	;zu kurz
	JR	NC,TST4	;(z.B. St|rung)
	CP	65H	;Diskriminator
	JR	NC,TST3
	ADD	0BEH	;Stop-Bit?
	JR	C,TST3
	PUSH	HL
	PUSH	DE
	LD	A,(IX+12)
	RRA		;7bit-Scancode
	XOR	1	;Startbit neg.
	LD	L,(IX+14)
	LD	H,(IX+15)
	LD	D,0
	LD	E,A
	ADD	HL,DE	;Pos. in KTAB
	LD	A,M	;ASCII holen
	POP	DE
	POP	HL
	BIT	7,(IX+8);CAPS aktiv?
	JR	NZ,TST2
	CP	40H
	JR	C,TST2
	CP	80H
	JR	NC,TST2
	XOR	20H	;klein<=>gro~
TST2	CP	(IX+13)	;letzter Code?
	JR	NZ,TST6
	PUSH	AF	;ja
	LD	A,(COUNT)
	CP	(IX+10)	;FastRepeat?
	JR	C,TST5	;ja
	POP	AF	;nein
	INC	(IX+10)	;Zeit abwarten
	JR	TST4
 
TST3	RR	(IX+12)	;Bit rechts
TST4	IN	A,89H	;einschieben
	OUT	89H	;und PIO-Logik
	POP	AF	;freigeben
	RETI
 
TST5	POP	AF
	JR	TST7
 
TST6	LD	(IX+10),0 ;neuer Code
	CP	16H	;CAPS?
	JR	Z,TST8
TST7	LD	(IX+13),A ;eintragen
	SET	0,(IX+8)  ;g}ltig machen
	JR	TST4
 
TST8	LD	A,(IX+8) ;CAPS-Programm
	XOR	80H
	LD	(IX+8),A
	LD	A,16H
	JR	TST7
 
KBDS	;Abfrage ohne Quittung	 **0C**
	OR	A
	BIT	0,(IX+8);Code g}ltig?
	RET	Z
	LD	A,(IX+13)
	SCF		;wenn ja
	RET
 
KBDZ	;Abfrage mit Quittung	 **0E**
	CALL	KBDS
	RET	NC
	RES	0,(IX+8)
	RET
 
BRKT	;Test auf BRK-Anforderung**2A**
	CALL	KBDS
	RET	NC
	CP	3
	SCF
	RET	Z
	AND	A
	RET
 
;SWITCH und JUMP
 
	DEFW	7F7FH
	DEFM	'SWITCH'
	DEFB	1
	LD	D,E
	CALL	MODU
	LD	A,L
	CALL	AHSPC	;Platz
	LD	A,H
	CALL	AHSPC	;Kennbyte
	LD	A,D
	CALL	AHEX	;Steuerbyte
	JP	CRLF
 
MODU	LD	H,0B8H	;H(ModulStSp)
	LD	C,80H	;I/O-Adr.
	LD	B,L
	CP	2	;Parameter?
	JR	NC,MODU1
	LD	D,M	;nur lesen
RSTRB	IN	H,(C)
	RET
 
MODU1	LD	M,D	;eintragen
	LD	A,L
	CP	5	;interne Module?
	JR	C,MODU2
	OUT	(C),D	;Senden Steuerb.
	JR	RSTRB
 
MODU6	AND	0F5H	;f}r RAM0
	BIT	0,D
	JR	Z,OUT88
	SET	1,A
	BIT	1,D
	JR	Z,OUT88
	SET	3,A
	JR	OUT88
 
MODU2	CP	4	;RAM4?
	JR	C,MODU3
	LD	A,(IX+4)
	AND	0FCH
	BIT	0,D
	JR	Z,SRAM4
	SET	0,A
	BIT	1,D
	JR	Z,SRAM4
	SET	1,A
SRAM4	LD	(IX+4),A
	OUT	86H
	JR	STBFF
 
MODU3	CP	3	;RAM8?
	JR	C,MODU4
	IN	A,89H
	AND	9FH
	BIT	0,D
	JR	Z,SRAM8	;wenn aus dann
	SET	5,A
	BIT	1,D	;Schreibschutz
	JR	Z,SRAM8	;unerheblich
	SET	6,A
SRAM8	OUT	89H
	LD	A,(IX+1)
	OR	10H
	BIT	2,D	;RAM8-Segment?
	JR	NZ,SSEG8
	XOR	10H	;(nicht vorbe-
SSEG8	OUT	84H	;reitet f}r
	LD	(IX+1),A;256k-Variante)
	JR	STBFF
 
MODU4	CP	2	;BASIC-ROM?
	JR	C,MODU5
	IN	A,88H
	BIT	0,D
	RES	7,A
	JR	Z,OUT88
	SET	7,A
OUT88	OUT	88H
STBFF	LD	H,0FFH
	RET
 
MODU5	CP	1	;IRM?
	IN	A,88H
	JP	C,MODU6
	BIT	0,D
	RES	2,A
	JR	Z,OUT88
	SET	2,A
	JR	OUT88
 
	DEFW	7F7FH
	DEFM	'JUMP'
	DEFB	1
	LD	A,L
JUMP	LD	B,A		;**27**
	LD	C,80H
	IN	A,(C)
	INC	A	;Kennbyte FF?
	JP	Z,ERRM	;ja-Fehler
	LD	A,0FFH	;Ausgabe FF
	LD	H,0B8H
	LD	L,B
	LD	M,A	;Eintrag
	DI
	OUT	(C),A
	IN	A,88H
	AND	7EH
	JP	BJUMP	;in IRM
 
;TAPE-Treiber
 
ISRI1	DI
	IN	A,88H
	OR	40H	;Motor ein
	AND	0DFH	;LED aus
ISRO1	OUT	88H
	EI
	LD	HL,(WEND)
	LD	(ZWEND),HL
	CALL	NOUT	;kein Drucker!
	LD	(ZOTAB),HL
	CALL	KPUFF
	CALL	PAGE	;Page Mode
TOFF	LD	A,3	;Ton aus
	OUT	8CH
	OUT	8DH
	JR	CSRO2
 
CSRO	;Abschlu~ Bandausgabe	 **09**
	LD	(IX+2),0FEH
	CALL	MBO
CSROI	LD	HL,(ZOTAB) ;intern
	LD	(OUTAB),HL
	LD	HL,(ZWEND) ;gro~es
	LD	(WEND),HL  ;R}cksetzen
	LD	HL,0B780H
	XOR	A
CSRO1	DEC	L	;KassPuff
	LD	M,A	;l|schen
	JR	NZ,CSRO1
	IN	A,88H
	AND	9FH	;Motor, LED aus
	OUT	88H
	CALL	CRLF
	RES	0,(IX+8)
CSRO2	BIT	3,(IX+1);HiRes?
	JR	Z,CSRO3
	IN	A,89H	;nein-
	SET	7,A	;Blinken ein
	OUT	89H
CSRO3	RES	1,(IX+8)
	LD	A,47H	;CTC3 auf
	OUT	8EH	;Blinken
	LD	A,0CH	;stellen
	OUT	8EH
	RET
 
ISRO	;Init. Bandausgabe	 **08**
	DI
	IN	A,88H
	OR	60H	;Motor, LED ein
	CALL	ISRO1
	LD	(IX+2),0
	LD	BC,1000H
	;
MBO	;Ausgabe 1 Block	 **01**
	INC	(IX+2)
	DI
	LD	A,87H	;EI,ZG16,Res.
	OUT	8DH
	LD	A,2FH	;Vorton
	OUT	8DH
	EI
	LD	D,A	;D=2Fh
	LD	E,A	;E=2Fh
MBO1	CALL	BITOUT
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
	LD	A,C
	ADD	M	;Pr}fsumme
	LD	C,A	;nebenher
	INC	HL
	DJNZ	BLKOT
	CALL	BYTOT	;und ausgeben
	LD	A,D
	CALL	HBITOT	;noch ein
	LD	E,L	;Knacks
	LD	D,H
	LD	A,3	;CTC stoppen
	OUT	8DH
	RET
 
BYTOT	;Ausgabe eines Bytes
	PUSH	BC
	LD	C,A
	LD	B,8
BYTOUT	RRC	C	;mit Bit0
	LD	E,17H	;beginnend
	CALL	NC,BITOUT
	LD	E,2FH	;Zeitkonstanten
	CALL	C,BITOUT
	DJNZ	BYTOUT	;8*
	POP	BC
ZTON	LD	E,5DH	;ZK Trennz.
BITOUT	CALL	HBITOT	;aufrufen und
HBITOT	LD	(IX),D	;reinlaufen
HBIT1	LD	A,(IX)	;Warten auf
	AND	A	;Interrupt
	JR	NZ,HBIT1
	LD	D,E
	RET
 
ISRI	;Init. Bandeingabe	 **0A**
	CALL	ISRI1
	;
MBI	;Einlesen 1 Block	 **05**
	LD	A,83H	;EI
	OUT	8AH	;an PIO A
	PUSH	HL
	PUSH	DE
MBI1	LD	B,16H
	LD	(IX+13),0 ;Pr}fsumme=0
MBI2	CALL	STOP1
	JR	C,MBI1
	CP	0BAH
	CALL	LEDOO
	JR	C,MBI1	;16h korrekte
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
	JR	C,MBI5	;St|rung
	LD	(IX+2),A
	LD	B,80H
	LD	L,(IX+5)
	LD	H,(IX+6)
BLKIN	CALL	BYTIN	;Datenbyte
	JR	C,MBI5
	LD	M,A
	LD	A,(IX+13)
	ADD	M	;aufsummieren
	LD	(IX+13),A
	INC	HL
	DJNZ	BLKIN
	CALL	BYTIN	;Pr}fsumme
	JR	C,MBI5	;St|rung
	SUB	(IX+13)	;gleich?
	ADD	0FFH	;CY:=/Z
MBI5	POP	DE
	POP	HL
	DI
	LD	A,3	;DI an PIO A
	OUT	8AH
	EI
LEDOO	IN	A,88H	;LED ein/aus
	SET	5,A	;je nac CY
	JR	NC,MBI6
	RES	5,A
MBI6	OUT	88H
	RET
 
ISRC1	;ISR CTC Kanal 1 (Kassette-Out)
	PUSH	AF
	LD	A,87H
	OUT	8DH
	LD	A,(IX)	;]bergabezelle
	OUT	8DH
	LD	(IX),0	;Quittierung
	JR	ISR1E
 
ISRPA	;ISR PIO Kanal A (Kassette-In)
	PUSH	AF
	IN	A,8EH
	LD	(IX),A	;]bergabezelle
	LD	A,7
	OUT	8EH
	LD	A,0A3H
	OUT	8EH
ISR1E	POP	AF
INTEND	EI
	RETI
 
STOP1	LD	(IX),0	;1 Bit einlesen
STOP11	IN	A,88H	;PIO-Logik
	OUT	88H	;freigeben
	LD	A,(IX)	;Warten auf
	OR	A	;Interrupt
	JR	Z,STOP11
	LD	C,A
	LD	(IX),0
STOP21	IN	A,88H	;dto.
	OUT	88H
	LD	A,(IX)
	OR	A
	JR	Z,STOP21
	ADD	C	;beide 'Zeiten'
	RET		;addieren
 
BYTIN	;Einlesen eines Bytes
	;PA: A:Byte, CY=1: St|rung
	LD	DE,800H
TRN1	CALL	STOP1
	JR	C,TRN2
	CP	0BAH	;zu intolerant
	RET	C
TRN2	CCF
	RR	E	;Bit einschieben
	DEC	D
	JR	NZ,TRN1	;8*
	CALL	STOP1	;Trennzeichen
	LD	A,E	;mit CY-
	RET		;R}ckmeldung
 
ISRC2	;CTC2: Tonlg.
	CALL	INTEND
	PUSH	AF
	CALL	TOFF
	POP	AF
	RET
 
;*** BASIC ***
BEXP1	EQU	$
BEXP2	EQU	$+14H
BEXP3	EQU	$+8CH
 
	ORG	$+78CH	;BASIC-Extension
 
	ORG	$+18H	;frei
 
;	END.
i � � � � � � � � � � � � � � � � � � � � � � 