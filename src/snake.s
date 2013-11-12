[org 0x7c00]

main:
	mov esp, 0x9000

	; Clear video memory
	mov ecx, 0xfa0
	mov edi, 0xb8000
	.clear_vidmem:
		mov byte [edi + ecx], 0x0
		mov byte [edi + ecx + 1], 0x0
		loop .clear_vidmem

	mov ecx, 0x80
	mov edi, 0x9000
	.clear:
		mov byte [edi + ecx], 0xff ; Clear the snake x buffer
		mov byte [edi + 0x90 + ecx], 0xff ; Clear the snake y buffer
		loop .clear

	; Now, setup the snake
	mov byte [current_node], 0x0
	mov byte [edi], 0x28
	mov byte [edi + 0x90], 0xC
	call print_snake


	.gameloop:
		; Get input character
			xor ah, ah
			int 0x16
		; Parse input
			cmp al, 'd'
			jne .check_w
			; Ok, we pressed D
				xor eax, eax
				mov al, [current_node]
				mov edi, 0x9000
				mov bh, [edi + eax] ; X pos
				mov bl, [edi + 0x90 + eax]; Y pos
				inc bh
				inc al
				mov [current_node], al
				mov byte [edi + eax], bh
				mov byte [edi + eax + 0x90], bl
			jmp .next_stuff

		.check_w:
			cmp al, 'w'
			jne .check_s
			; Ok, we pressed D
				xor eax, eax
				mov al, [current_node]
				mov edi, 0x9000
				mov bh, [edi + eax] ; X pos
				mov bl, [edi + 0x90 + eax]; Y pos
				dec bl
				inc al
				mov [current_node], al
				mov byte [edi + eax], bh
				mov byte [edi + eax + 0x90], bl
			jmp .next_stuff

		.check_s:
			cmp al, 's'
			jne .check_a
			; Ok, we pressed D
				xor eax, eax
				mov al, [current_node]
				mov edi, 0x9000
				mov bh, [edi + eax] ; X pos
				mov bl, [edi + 0x90 + eax]; Y pos
				inc bl
				inc al
				mov [current_node], al
				mov byte [edi + eax], bh
				mov byte [edi + eax + 0x90], bl
			jmp .next_stuff

		.check_a:
			cmp al, 'a'
			jne .next_stuff
			; Ok, we pressed D
				xor eax, eax
				mov al, [current_node]
				mov edi, 0x9000
				mov bh, [edi + eax] ; X pos
				mov bl, [edi + 0x90 + eax]; Y pos
				dec bh
				inc al
				mov [current_node], al
				mov byte [edi + eax], bh
				mov byte [edi + eax + 0x90], bl
			jmp .next_stuff


		.next_stuff:
		; See where we are, and add new snake node
		; finally print snake
			call print_snake
		jmp .gameloop

; ##########################
; #
; # Print snake
; # Trashes: 
; ##########################
print_snake:
	push ecx
	xor ecx, ecx
	mov edi, 0x9000
	.print_loop:
		cmp ecx, 0x80
		je .exit
		; Print the character
			; Move cursor
				xor bh, bh
				mov ah, 0x02
				mov dh, [edi + ecx + 0x90]
				mov dl, [edi + ecx]
				int 0x10
			; Print char
				mov ah, 0x09
				mov al, '#'
				mov bl, 0xC1
				push ecx
				mov cx, 1
				int 0x10
				pop ecx
		; Go to next character
		inc ecx
		cmp byte [edi + ecx], 0xff
		jne .print_loop
	.exit:
	pop ecx
	ret

current_node: db 0

%assign mysize 510-($-$$)
%warning my size is mysize
times 510-($-$$) db 0
db 0x55
db 0xAA
