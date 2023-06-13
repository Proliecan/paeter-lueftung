; Steuerung einer Lüftung mit zwei Lüftern. (Echtes Szenario in meiner Wohnung.)
; Lüftung hat Geschwindigkeiten 1-4,
; beide Rotoren können vorwärts und rückwärts laufen.
; Außerdem Pausenmodi 30min, 1h, 1h30min, 2h.
; Pinbelegung:
;    Eingabe:
;	p0.0:		Pausentaste
;	p0.1:		Playtaste -> beendet die Pause 
;	p0.2 - p0.5:	Geschwindigkeiten 1-4 (geringste zählt)
;    Ausgabe:
;	p1.0:		Pause LED
;	p1.3 - p1.6:	Geschwindigkeits LEDs  1-4
;	p2.5 - p2.7:	Geschwindigkeiten 0-4 an Motorsteuerung (binary))

org 00h
start:
	ljmp init
org 0xb
	call timerInterrupt
	reti

org 20h
init:
	ipb equ p0.0 ;input pause button
	imb equ p0.1 ;input mode button (play)
	i1b equ p0.2 ; input 1 button (speed 1)
	i2b equ p0.3 ; input 2 button (speed 2)
	i3b equ p0.4 ; input 3 button (speed 3)
	i4b equ p0.5 ; input 4 button (speed 4)
	
	ppb equ p3.0 ;pressed pause button

	op equ p1.0
	o1 equ p1.3
	o2 equ p1.4
	o3 equ p1.5
	o4 equ p1.6
	od equ p1.7
	
	og1 equ p2.5
	og2 equ p2.6
	og3 equ p2.7

	speed1 equ 0x51
	speed2 equ 0x52
	speed3 equ 0x53
	speed4 equ 0x54

	mov p0, #00h
	mov p1, #00h
	mov p2, #00h

	; init second timer
	call initialize_timer

	; init timer
	mov tmod, #0000010b	; set mode
	mov th0, #55d 		; run for 2ms untill interrupt
	; activate interrupt
	setb ea
	setb et0
	call set1


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
	;is play pressed?
	mov A, p0
	anl A, #00000010b
	cjne A, #0, stop_timer
	;set speed
	call speed_validation
	ret

start_timer:
	;stop fans
	clr og1
	clr og2
	clr og3
	;clear leds 
	clr o1
	clr o2
	clr o3
	clr o4
	;start timer
	setb op
	setb TR0
	ret

initialize_timer:
	mov r0, #50d	; 50 * 2ms = 1s
	mov r1, #60d	; 60s = 1m
	mov r2, #30d	; 30m = 1 pauseninkrement
	mov r3, #0b	; No pause time yet
	ret


timerinterrupt:		; 2ms have passed
	djnz r0, endTimerInterrupt
second:			; 1s has passed
	mov r0, #32h		; #50d auf einmal = #50h?!?!?!?! BUGS GO BRRRR (^o^)
	djnz r1, endTimerInterrupt
minute:			; 1min has passed
	mov r1, #60d
	djnz r2, endTimerInterrupt
halfhour:		; 30min have passed
	mov r2, #30d
	; half an hour has passed
	;pause time decrease and timer stop when necesssary
	djnz r3, endtimerinterrupt
stop_timer:
	call initialize_timer
	clr op
	clr TR0
	;activate the speed led one 
	setb o1
	;start the fans with saved speed
	mov A, speed1
	cjne A, #0, set1
	mov A, speed2
	cjne A, #0, set2
   	mov A, speed3
	cjne A, #0, set3
	mov A, speed4
	cjne A, #0, set4
stop_timer2:
	;stop without starting fans
	call initialize_timer
	clr op
	clr TR0
	
	endTimerInterrupt:
	ret

speed_validation:
	mov A, p0
	anl A, #00000100b
	cjne A, #0, set1
	mov A, p0
	anl A, #00001000b
	cjne A, #0, set2
        mov A, p0
	anl A, #00010000b
	cjne A, #0, set3
	mov A, p0
	anl A, #00100000b
	cjne A, #0, set4
	ret
	set1:
	;stop timer
	call stop_timer2
	;set fan binary to one 
	setb og1
	clr og2
	clr og3
	;set speed led one 
	setb o1
	clr o2
	clr o3
	clr o4
	;save speed
	mov speed1, 1 
	clr speed2
	clr speed3
	clr speed4
	;return
	ret
	set2:
	;stop timer
	call stop_timer2
	;set fan binary to two 
	clr og1
	setb og2
	clr og3
	;set speed led two 
	clr o1
	setb o2
	clr o3
	clr o4
	;save speed
	mov speed2, 1
	clr speed1
	clr speed3
	clr speed4
	;return
	ret
	set3:
	;stop timer
	call stop_timer2
	;set fan binary to three 
	setb og1
	setb og2
	clr og3
	;set speed led three 
	clr o1
	clr o2
	setb o3
	clr o4
	;save speed
	mov speed3, 1
	clr speed1
	clr speed2
	clr speed4
	;return
	ret
	set4:
	;stop timer
	call stop_timer2
	;set fan binary to four 
	clr og1
	clr og2
	setb og3
	;set speed led four 
	clr o1
	clr o2
	clr o3
	setb o4
	;save speed
	mov speed4, 1
	clr speed1
	clr speed3
	clr speed2
	;return
	ret
end