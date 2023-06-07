; testing timers
org 0x0
ljmp init

org 0xb
mov 20h, #20d ;debug



; mode 1

; set timer mode
init:
mov tmod, #0000001b
; activate interrupt
setb ea
setb et0

; start timer
setb TR0

wait:
	ljmp wait

end