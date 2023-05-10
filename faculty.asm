;calculate faculty of @#30h
mov a, #1
mov r0, #30h
mov b, @r0
mov r0,b

loop_start:
	mov b, r0
	mul ab
	djnz r0, loop_start

mov p0, a
end