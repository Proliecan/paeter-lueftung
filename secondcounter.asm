; to wait 1s we need to wait 2ms .. 50 times
org 0x0
ljmp init

org 0xb
ljmp twoMilliSeconds
reti



; mode 2

; set timer mode
init:
; init second timer
mov r0, #50d	; 50 * 2ms = 1s
mov r1, #60d	; 60s = 1m
mov r2, #30d	; 30m = 1 pauseninkrement

; init timer
mov tmod, #0000010b	; set mode
mov th0, #55d 		; run for 2ms untill interrupt
; activate interrupt
setb ea
setb et0

; start timer
setb TR0

wait:			; sleep (do nothing <lazy meme here>)
	ljmp wait



twoMilliSeconds:		; has a whole second passed
	djnz r0, endTimerInterrupt
second:
	mov r0, #32h		; #50d auf einmal = #50h?!?!?!?! BUGS GO BRRRR (^o^)
	djnz r1, endTimerInterrupt
minute:
	mov r1, #60d
	djnz r2, endTimerInterrupt
halfhour:
	mov r2, #30d
	; half an hour has passed

endTimerInterrupt:
	reti

end

