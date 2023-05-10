mov a, r0
add a, r1
jc g
jnc se

g:
	mov a, #0ffh ; warum fuehrt 'mov a, #ffh' zu einem fehler?
se:
	mov acc,a

	end