mov a, #25h

mov 60h, #46h ; why is parity true here?
mov 63h, 60h

save equ 60h

xch a, save
end