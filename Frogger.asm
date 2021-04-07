BITS 16

        
section .data
        msg DB 10,13,'Ha ganado!$'
        x_frog: dw 120   ; Coordenada x
        y_frog: dw 180  ; Coordenada y
        tam_frog: dw 04h  ;tamaño de frog

        
_start:
	mov ax, 07C0h		; Set up 4K stack space after this bootloader
	add ax, 288		; (4096 + 512) / 16 bytes per paragraph
	mov ss, ax
	mov sp, 4096
	mov ax, 07C0h		; Set data segment to where we're loaded
	mov ds, ax


        call set_pantalla
        call print  ; Llamada para dibujar en la pantalla

        loop1:        
            call set_pantalla
            call print  ; Llamada para dibujar en la pantalla
            call get_input
            
            jmp loop1

	jmp $			; Jump here - infinite loop!

get_input:

            mov Ah, 0 ; Settea la interrupcion para optener entradas del teclado.
            int 16h

            cmp al, 'w'
            je mover_arriba
        
            cmp al, 's'
            je mover_abajo
            
            cmp al, 'a'
            je mover_izq
        
            cmp al, 'd'
            je mover_der
            
            ret
        
mover_arriba:    ; Frogger avanza hacia arriba.
        sub dword [y_frog], 5h
        mov cx, [y_frog]
        cmp cx, 65
        je gane
        call print  ; Llamada para dibujar en la pantalla 
        ret
            
mover_abajo:    ; Frogger avanza hacia abajo.
        add dword [y_frog], 5h
        call print  ; Llamada para dibujar en la pantalla
        ret
        
 mover_izq:    ; Frogger avanza hacia izquierda.
        sub dword [x_frog], 5h
        call print  ; Llamada para dibujar en la pantalla 
        ret
            
mover_der:    ; Frogger avanza hacia derecha.
        add dword [x_frog], 5h
        call print  ; Llamada para dibujar en la pantalla
        ret       

gane: ; Parte del codigo para imprimir fue tomado de https://gist.github.com/RedToor/f45a25a196dbb22a385437c415777bb9

        add dword [y_frog], 115

        XOR AX,AX              ; AX=0
        MOV AL,03h             ; Modo de texto 80x25x16
        INT 10h                ; Llamamos a la INT 10h

        LEA SI,msg              ; Cargamos en SI la dirección de memoria efectiva de la constante
        CALL escribir_cadena   ; Llamamos a la función de escribir la variable en pantalla

        INT 16h                ; Pedimos una tecla (AH=0)
        HLT                    ; Paramos la ejecución

        escribir_cadena: 
            PUSH AX                ; Guardamos los registros AX y SI en la pila
            PUSH SI                ;

        siguiente_caracter: 
            MOV AL,[SI]            ; Movemos la siguiente o primera letra de la variable de SI a AL 
            CMP AL,0               ; ¿Hemos terminado de escribir en pantalla?
            JZ terminado           ; Saltamos si es 0, entonces hemos terminado de escribir

            INC SI                 ; Incrementamos el valor de SI (Siguiente carácter)
            MOV AH,0Eh             ; Función TeleType
            INT 10h                ; Llamamos a la interrupción 10h
            JMP siguiente_caracter ; Hacemos un bucle para escribir el siguiente carácter

       terminado:
            POP SI                 ; Liberamos los registros SI y AX de la pila
            POP AX                 ;
            
            wait1: ; Espera hasta que el usuario pulse espacio para reiniciar.
                mov Ah, 0
                int 16h

                cmp al, ' '
                jne wait1
                
            call _start                    ; Inicia el programa de nuevo.
             
espera:
        mov al, 0    ; Coloca el valor de al en 0
        mov ah, 86h  ; Llama a la funcion de espera.
        mov cx, 1
        mov dx, 2
        int 15h 
        ret

set_pantalla:

        mov ah, 00h  ; Se activa el modo de video.
        mov al, 13h  ; Modo de video en 256 colores, 320x200.
        int 10h	    ; Interrupcion del servicio de pantalla.

        mov ah, 0bh  ; Asigna color de fondo/borde de la pantalla.
        mov bh, 00h  ; Asigna el color al fondo.
        mov bl, 00h  ; Color negro seleccionado.
        int 10h      ; Interrupcion del servicio de pantalla.
        ret             
                                         
print:
        mov cx, 5
        mov dx, 160
        
        linea1: ; Dibuja la linea inferior del carril inferior.
            mov ah, 0ch  ; Escribe pixel en la pantalla.
            mov al, 0fh  ; Asigna el color al pixel.
            mov bh, 00h  ; Valor de la pagina.
            int 10h      ; Interrupcion del servicio de pantalla.
            
            mov dx, dx
            inc cx
            cmp cx, 315
            jne linea1
        
        mov cx, 5
        mov dx, 130
         
        linea2: ; Dibuja la linea entre el carril uno y dos.
            mov ah, 0ch  ; Escribe pixel en la pantalla.
            mov al, 0fh  ; Asigna el color al pixel.
            mov bh, 00h  ; Valor de la pagina.
            int 10h      ; Interrupcion del servicio de pantalla.
            
            mov dx, dx
            inc cx
            cmp cx, 315
            jne linea2
            
            
        mov cx, 5
        mov dx, 100
         
        linea3: ; Dibuja la linea entre el carril dos y tres.
            mov ah, 0ch  ; Escribe pixel en la pantalla.
            mov al, 0fh  ; Asigna el color al pixel.
            mov bh, 00h  ; Valor de la pagina.
            int 10h      ; Interrupcion del servicio de pantalla.
            
            mov dx, dx
            inc cx
            cmp cx, 315
            jne linea3
            
         
        mov cx, 5
        mov dx, 70     
        
        linea4: ; Dibuja la linea superior del carril superior.
            mov ah, 0ch  ; Escribe pixel en la pantalla.
            mov al, 0fh  ; Asigna el color al pixel.
            mov bh, 00h  ; Valor de la pagina.
            int 10h      ; Interrupcion del servicio de pantalla.
            
            mov dx, dx
            inc cx
            cmp cx, 315
            jne linea4

        mov cx, [x_frog]  ; Valor del eje x donde se escribira.
        mov dx, [y_frog] ; Valor del eje y donde se escribira.

        Dibujar_frog:
            
            mov ah, 0ch  ; Escribe pixel en la pantalla.
            mov al, 0fh  ; Asigna el color al pixel.
            mov bh, 00h  ; Valor de la pagina.
            int 10h      ; Interrupcion del servicio de pantalla.
            
            inc cx       ; Busca la siguiente posicion para dibujar otro pixel en "x"
            mov ax, cx   ; Asigna el valor actual de "x" a una varaible auxiliar
            sub ax, [x_frog]  ; Resta el valor actual de "x" con la posicion original.
            cmp ax, [tam_frog]  ; Compara si se alcanzo el tamaño indicado
            jng Dibujar_frog    ; Sigue dibujando si el tamaño es menor al esperado.
            
            mov cx, [x_frog]  ; Establece el eje "x" de nuevo en el inicial.
            inc dx       ; Busca la siguiente posicion para dibujar otro pixel en "y"
            mov ax, dx   ; Asigna el valor actual de "y" a una varaible auxiliar
            sub ax, [y_frog]  ; Resta el valor actual de "y" con la posicion original.
            cmp ax, [tam_frog]  ; Compara si se alcanzo el tamaño indicado
            jng Dibujar_frog    ; Sigue dibujando si el tamaño es menor al esperado.

            ret
         
.repeat:
	lodsb			; Get character from string
	cmp al, 0
	je .done		; If char is zero, end of string
	int 10h			; Otherwise, print it
	jmp .repeat
        
.done:
	ret

	times 510-($-$$) db 0	; Pad remainder of boot sector with 0s
	dw 0xAA55		; The standard PC boot signature