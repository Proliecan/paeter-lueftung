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
;	p0.2 - p0.5:	Geschwindigkeiten 1-4 (geringste zählt) (setzt Pausendauer wieder auf 0min)
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

	mov p0, #00h
	mov p1, #00h
	mov p2, #00h

	; init second timer
	mov r0, #50d	; 50 * 2ms = 1s
	mov r1, #60d	; 60s = 1m
	mov r2, #30d	; 30m = 1 pauseninkrement
	mov r3, #0b	; No pause time yet

	; init timer
	mov tmod, #0000010b	; set mode
	mov th0, #55d 		; run for 2ms untill interrupt
	; activate interrupt
	setb ea
	setb et0


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
			setb ppb
			; TODO: Increase pause timer by 30 to a maximum of 120 minutes
			inc r3

			call start_timer

			; check if r3 > 4 then set to 4
			cjne r3, #5d, endpause
			; too much pause
			mov r3, #4d

			ljmp endpause


		pausereleased:
			; pause newly released
			clr ppb
			ljmp endpause

		
	endpause:
	ret

start_timer:
	setb TR0
	ret

end