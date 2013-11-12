[org 0x7c00]

main:
	mov esp, 0x9000

	call clear_vidmem

	mov ecx, 0xff
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
		call load_pos
		; Parse input
			cmp al, 'd'
			jne .check_w
			; Ok, we pressed D
				inc bh
			jmp .next_stuff

		.check_w:
			cmp al, 'w'
			jne .check_s
			; Ok, we pressed W
				dec bl
			jmp .next_stuff

		.check_s:
			cmp al, 's'
			jne .check_a
			; Ok, we pressed S
				inc bl
			jmp .next_stuff

		.check_a:
			cmp al, 'a'
			jne .next_stuff
			; Ok, we pressed A
				dec bh
			jmp .next_stuff


		.next_stuff:
		cmp bh, [fruit_x]
		jne .next_stuff_2
			cmp bl, [fruit_y]
			jne .next_stuff_2
				.fruit_step:
				add byte [snake_size], 1
		.next_stuff_2:
		call save_pos
		; add fruit
			call clear_vidmem
			call add_fruit
		; finally print snake
			xor eax, eax
			mov al, [current_node]
			sub al, [snake_size]
			mov edi, 0x9000
			mov byte [edi + eax + 0x90], 0xff
			mov byte [edi + eax], 0xff
			call print_snake
			call draw_fruit
		jmp .gameloop

load_pos:
	mov cl, [current_node]
	mov edi, 0x9000
	mov bh, [edi + ecx]
	mov bl, [edi + ecx + 0x90]
	ret
save_pos:
	inc cl
	mov [current_node], cl
	mov byte [edi + ecx], bh
	mov byte [edi + ecx + 0x90], bl
	ret

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
		cmp ecx, 0xff
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
		jmp .print_loop
	.exit:
	pop ecx
	ret

draw_fruit:
	xor bh, bh
	mov ah, 0x02
	mov dh, [fruit_y]
	mov dl, [fruit_x]
	int 0x10
	mov ah, 0x09
	mov al, 'F'
	mov bl, 0xdd
	mov cx, 1
	int 0x10
	ret

add_fruit:
	mov ah, 0x02
	int 0x1A
	mov [fruit_x], dh
	mov [fruit_y], ch
	ret

clear_vidmem:
	; Clear video memory
	mov ecx, 0xfa0
	mov edi, 0xb8000
	.clear_vidmem:
		mov byte [edi + ecx], 0x0
		mov byte [edi + ecx + 1], 0x0
		loop .clear_vidmem
	ret

current_node: db 0
snake_size: db 1

fruit_x: db 0
fruit_y: db 0

%assign mysize 510-($-$$)
%warning my size is mysize
times 510-($-$$) db 0
db 0x55
db 0xAA
