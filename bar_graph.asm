stack segment para 'stack'
   
stack ends

data segment para 'data'
    curr_time db 0

    line_x dw 20
    line_y dw 180
    line_x_size dw 20
    line_y_size dw 2
    way db 1 ;1=up, 0=down

    curr_random dw 60

             ;way,top
    ;columns dw "1","30", "1","50", "1","110", "1","90"
    
    ; a single drawing segment will increment line_x with the desired drawing offset to draw
    ; randomly generated value from 10 to 180 that everytime it reaches bottom resets

data ends

code segment para 'code'

    main proc far
        assume cs:code,ds:data,ss:stack         ;assume data to their respected registers
        mov ax,data
        mov ds,ax

        mov ah,0                               ;video mode
        mov al,13h                             ;VGA 320x200 256 color
        int 10h                                ;bios int
        
        ;if time has passed

        infloop:
        
        ;check if 1/100 seconds have passed

        mov ah,2Ch                        ;get system time
        int 21h                           ;ch:hour,cl:minute,dh:second,dl:1/100seconds
        cmp dl,curr_time
        je infloop
        mov curr_time,dl                  ;save new time

        ; mov ah, 01h                     ;readkey  
        ; int 16h
        ; jz infloop                      ;if some key is pressed
        ; mov ah,00h                      ;clear key buffer
        ; int 16h

        call draw_line

        jmp infloop

    main endp

    check_line proc near

        ; if the line_y value has reached a border
        ; changes the value of "way" which is the column's direction of expansion
        
        push ax                          ;push al, ah to stack bc we need most of this for int10h
        push bx

        mov al,way

        boundary_check:
        cmp line_y,188                   ;otherwise if y has reached bottom
        jns way_down
        
        mov bx,curr_random               ;load curr random
        cmp line_y,bx                    ;if y has reached the top of the column 
        
        jng way_up
        jmp change_in_way
        way_up:
        mov way,1
        jmp change_in_way
        way_down:
        mov way,0

        change_in_way:
        cmp way,al
        
        pop bx
        pop ax                          ;pop ah, al return to int10h
        
        je new_value_needed
    ret

        new_value_needed:
        call generate_random            ;generate new value and save in curr_random

        move_drawhead:
        cmp way,1                       ;cmp which way the column is expanding
        jne down
        add line_y,2                    ;add/sub theres 1 pixel difference (2bits)
    ret                    
        down:
        sub line_y,2
    ret
    
    check_line endp

    draw_line proc near                 

        push si                         ;push si, we have two calls, pointer would get mixed up
            call check_line
        pop si                          ;pop si

        mov cx,line_x                   ;set x
        mov dx,line_y                   ;set y

        draw_line_hor:
            mov ah,0Ch                  ;write pixel
            
            jmp color_change
            color_change_done:

            mov bh,00h                  ;page
            int 10h
            
            inc cx                      ;increase x
            mov ax,cx                    
            sub ax,line_x                     
            cmp ax,line_x_size          ;if the desired size is reached, continue 
            jng draw_line_hor
            
            mov cx,line_x               ;reset x
            inc dx                      ;increase y
            
            mov ax,dx                   
            sub ax,line_y
            cmp ax,line_y_size          ;if the desired size is reached, return call
            jng draw_line_hor    
        ret

        color_change:
            cmp way,0       
            jne black
            mov al,0Fh                  ;white
            jmp color_change_done
        black:
            mov al,0FFh                 ;black
            jmp color_change_done
    
    draw_line endp

    select_column proc near


    ;placed in infloop
    ;selects column by incrementing line_x resulting in a horizontal shift
    ;checks borders
    ;draws line
    ;saves it back to the data slot

    ;proceeds to the next column until there are no more columns

    select_column endp

    generate_random proc near
    
        push ax
        push dx
        push cx

        mov ah,00h ;get system time
        int 1Ah    ;cx:dx no. clock ticks since midnight

        mov  ax, dx
        xor  dx, dx   ;clear dx
        mov  cx, 180  
        div  cx       ;here dx contains the remainder of the division - from 0 to 9

        mov ax, dx
        
        pop cx
        pop dx        ;return to data stack?

        mov curr_random,ax

        pop ax
    ret
    generate_random endp

code ends

end

