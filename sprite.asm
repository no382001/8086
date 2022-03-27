stack segment para 'stack'
   
stack ends

data segment para 'data'
    postion_x db 1
    postion_y db 1
data ends

code segment para 'code'

    main proc far
        assume cs:code,ds:data,ss:stack         ;assume data to their respected registers
        mov ax,data
        mov ds,ax

        mov ah, 0                               ;video mode
        mov al, 13h                             ;VGA 320x200 256 color
        int 10h                                 ;bios int
        
        ; mov ah,5
        ; mov al,curr_page
        ; int 10h

        call ShowSprite                         ;initial drawing
        
    infloop:
        mov ah, 01h                             ;if some key is pressed   
        int 16h
        jz infloop 
        
        mov ah,00h                              ;read buffer to al
        int 16h

        check_up:
            cmp al,69h      ;i
            jnz check_down
            dec postion_y
        check_down:    
            cmp al,6Bh      ;k
            jnz check_right
            inc postion_y
        check_right:
            cmp al,6Ch      ;l
            jnz check_left
            inc postion_x
        check_left:
            cmp al,6Ah
            jnz finish      ;j
            dec postion_x
        finish:
            call ShowSprite ;draw sprite
            


    ; mov ah,5    ;AL = Page Number
    ; mov al,0    ;use paging. paint on one screen (while displaying the other)
    ; int 10h     ;and once your paint is done, you switch. int 10h has a function (AH=5) for switching the active page


                                                ;XOR sprite at (X,Y) pos (DH,DL)
    ShowSprite:   
        mov ah, 0                               ;set video mode
        mov al, 13h                             ;VGA 320x200 256 color
        int 10h                   
                           
                                                ;Calculate Screen pos
        mov ax,0A000h                           ;Screen base 
        mov es,ax
        mov ax, code                            ;Point DS to this segment
        mov ds, ax
        
        mov dh,postion_x
        mov dl,postion_y

        push dx
            mov ax,2                            ;1px step
            mul dh                              ;16 bytes per 16x16 block
            mov di,ax

            mov ax,2*320                        ;1px step    
            mov bx,0                            ;320 bytes per line, 8 lines per block
            add bl,dl
            mul bx
            add di,ax
        pop dx                                  ;ES:DI is VRAM Destination
        
                                                ;draw XOR sprite    
        mov si, offset crosshair                ;DS:SI = source bitmap
        mov cl,16                               ;height of bitmap
    
    remove_bitmap_y:
        push di
        mov ch,16                               ;width of bitmap
    
    remove_bitmap_x:              
        mov al,DS:[SI]
        xor al,ES:[DI]                          ;xor with current screen data.
        mov ES:[DI],al
        inc si
        inc di
        dec ch
        jnz remove_bitmap_x                     ;next horizontal pixel
        pop di
        add di,320                              ;move down 1 line (320 pixels)
        inc bl
        dec cl
        jnz remove_bitmap_y    
        jmp infloop

    crosshair:
        DB 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh     ;  0
        DB 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh     ;  1
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     ;  2
        DB 0Fh,0Fh,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     ;  3
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     ;  4
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     ;  5
        DB 0Fh,0Fh,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     ;  6
        DB 00h,00h,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h     ;  7
        DB 00h,00h,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h 
        DB 0Fh,0Fh,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh      
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     
        DB 0Fh,0Fh,000,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh      
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     
        DB 0Fh,0Fh,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,0Fh,0Fh     
        DB 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh     
        DB 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,00h,00h,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh 

    main endp

code ends

end
