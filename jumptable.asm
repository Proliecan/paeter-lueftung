;using JUMPTABLE (JMP @A+DPTR ) für Verzweigungen
;
; A kann 0,1,2,... sein
; es soll in die Unterroutinen SUB0, SUB1, ... verzweigt werden mit JMP @A+DPTR
; A  zeigt dabei auf den CODE in der DATATABLE
; A wird mit der Rotation mit 2 multipliziert
;
; jede mögliche Verzweigung verlängert den CODE um 2 Bytes: 
; diese stehen in der JUMP-TABLE (die kann irgendwo stehen)
;
; Initialisierung:
mov A, #01h
; mit 2 multiplizieren
RL A
MOV DPTR, #JUMP_TABLE
JMP @A+DPTR
;
JUMP_TABLE:
AJMP SUB0
AJMP SUB1
AJMP SUB2
;

SUB0:
	mov 66h, #66h
SUB1:
	mov 69h, #69h
SUB2:
	mov 42h, #42h
end