[org 0x7c00]

main:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
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
	call add_fruit
	call print_snake


	.gameloop:
		cmp byte [snake_size], 0xfe
		je won
		; Get input character
			xor ah, ah
			int 0x16
			inc byte [moves]
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
				call add_fruit
		.next_stuff_2:
		call save_pos
		; add fruit
			call clear_vidmem
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

won:
	xor bh, bh
	mov ah, 0x02
	mov dh, 10
	mov dl, 10
	int 0x10
	mov si, cong_msg
	.won_loop:
		lodsb
		or al, al
		jz .won_end
		mov ah, 0x0e
		int 0x10
		jmp .won_loop
	.won_end:
	cli
	hlt

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

r_next db 0

rng:
	; AH = RAND_MAX
	push ebx
	push ecx
	push eax
		cmp byte [moves], ah
		jge .reset
		jmp .rest
		.reset:
			.loop:
				cmp byte [moves], ah
				jle .rest
				sub byte [moves], ah
			jmp .loop
		.rest:
			mov eax, [moves]
		mov dh, al
	pop eax
	pop ecx
	pop ebx
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
	push eax
	push edx
		call rng
		mov [fruit_x], dh
		call rng
		mov [fruit_y], dh
	pop edx
	pop eax
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

moves: db 0

fruit_x: db 0
fruit_y: db 0

cong_msg db "Congratulations, you won!", 0

%assign mysize 510-($-$$)
%warning my size is mysize
times 510-($-$$) db 0
db 0x55
db 0xAA
