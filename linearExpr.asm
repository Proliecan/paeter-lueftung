mem:
	mov r0, #30h ;was ist 'mov data, data?'
	mov @r0, #20
	inc r0
	mov @r0, #00000010b
	inc r0
	mov @r0, #1fh
	mov r0, #0d

init:
	mov R1, #32h ; Was ist in 8...29?
	mov a, @r1
	mov r0, a
	dec r1
	mov b, @r1
	dec r1
	mov a, @r1

calc:
	mul ab
	add a, r0

out:
	mov p1, a
end