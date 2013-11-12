[org 0x7c00]

main:
	mov 0x9000, esp
	mov 0x80, cx
	.clear:
		mov 0, [0x9001 + cx] ; Clear the snake x buffer
		mov 0, [0x9082 + cx] ; Clear the snake y buffer
		loop .clear

	.gameloop:
		; Get input character
			xor ah, ah
			int 0x16
		; Parse input
		; See where we are, and add new snake node
		; finally print snake
			call print_snake
		jmp gameloop

; ##########################
; #
; # Print snake
; # Trashes: 
; ##########################
print_snake:
	ret

current_node: db 0

times 510-($-$$) db 0
db 0x55
db 0xAA
