; Steuerung einer Lüftung mit zwei Lüftern. (Echtes Szenario in meiner Wohnung.)
; Lüftung hat Geschwindigkeiten 1-4,
; beide Rotoren können vorwärts und rückwärts laufen.
; Außerdem Pausenmodi 30min, 1h, 1h30min, 2h.
; Zwei Lüftungsmodi:
;	Blauer Modus: Beide Lüfter laufen in die default-Richtung vorwärts.
;	Roter Modus: Zur Wärmerückgewinnung mit Tauschkörper kehren beide Lüfter alle 30sec ihre Laufrichtung um.

; Pinbelegung:
;    Eingabe:
;	p0.0:		Pausentaste
;	p0.1:		Modustaste
;	p0.2 - p0.5:	Geschwindigkeiten 1-4 (geringste zählt)
;	p0.6:		default-Richtung (statischer Dipswitch auf dem Board)
;    Ausgabe:
;	p1.0:		Pause LED
;	p1.1:		Modus LED Rot
;	p1.2:		Modus LED Blau
;	p1.3 - p1.6:	Geschwindigkeits LEDs  1-4
;	p1.7:		Laufrichtung an Motorsteuerung
;	p2.5 - p1.7:	Geschwindigkeiten 0-4 an Motorsteuerung (binary))

org 00h
start:
	ljmp init

org 20h
init:
	ipb equ p0.0
	imb equ p0.1
	i1b equ p0.2
	i2b equ p0.3
	i3b equ p0.4
	i4b equ p0.5
	idb equ p0.6

	ppb equ p3.0
	pmb equ p3.1
	p1b equ p3.2
	p2b equ p3.3
	p3b equ p3.4
	p4b equ p3.5
	pdb equ p3.6

	op equ p1.0
	or equ p1.1
	ob equ p1.2
	o1 equ p1.3
	o2 equ p1.4
	o3 equ p1.5
	o4 equ p1.6
	od equ p1.7

	timeInterval equ 40h
	maxTime equ 41h
	waitingStatus equ 42h
	;tmp equ 43h
	mov p0, #00h
	mov p1, #00h
	mov p2, #00h
	;mov p3, #0b
	mov timeInterval, #1eh
	mov maxtime,#78h
	mov waitingStatus, 0

	; initialize timer parameters
	mov ie, #10010010b ; timer freischalten
	mov tmod, #00000010b ; mode des timers 2 = auto reload
	mov r7, #00h ; 0 minutes

cycle:
	call validation

	ljmp cycle

validation:
	mov a, ipb ; bitwise xor by translating into bytes. It sucks.
	anl a, #00000001b
	mov b, ppb
	anl b, #00000001b
	xrl a,b
	jz endpause
		; something has changed
		mov c, ipb
		jnc pausereleased
			; pause newly pressed
			; TODO: Increase pause timer by 30 to a maximum of 120
			setb ppb
			
			mov waitingStatus, 1
			; read value from register r7
			;mov tmp, r7
			mov A, r7
			add A , timeInterval
			cjne A, maxtime, not_equal
			not_equal:
				jc less_than
			greater_than:
				mov r7, 0
				; todo: timer stop
				
			less_than:
				mov r7, A
				; start timer
				Call starttimer
			
			jmp endpause
		pausereleased:
			; pause newly released
			clr ppb
	endpause:
	jnb tf0 , validation
	jmp timerinterrupt
	ret

	timerinterrupt: 
		mov waitingStatus, 0
	        ;was passiert wenn timer vorbei

	startTimer:
	MOV A, R7
   	Mov B, #60h
   	MUL AB ; Minuten * 60 Sekunden = Sekunden
   	MOV B, #0xC3 ; Quarzfrequenz 12 MHz
        MUL AB ; Wert in A * R1
   	MOV R7, A
    	MOV TL0, R7 ; Stelle den Timer-Wert für Minuten und Sekunden ein
	mov th0, #0c0h ; working #0C0h 
   	SETB TR0 ; Starte den Timer
	ajmp validation
	;set speed --> 0
	;jump to next position --> if button is pressed 
end