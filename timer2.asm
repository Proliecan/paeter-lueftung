; testing timers
org 0x0
ljmp init

org 0xb
mov b, #1d
add a,b
reti



; mode 2

; set timer mode
init:
mov tmod, #0000010b
mov th0, #155d ; run for 1ms untill interrupt
; activate interrupt
setb ea
setb et0

; start timer
setb TR0

wait:
	ljmp wait

end
