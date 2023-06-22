MyStack SEGMENT STACK
MyStack ENDS

;=====

MyData SEGMENT
MyData ENDS

;=====

MyCode SEGMENT

myMain PROC
    
    ASSUME DS:MyData, CS:MyCode

    MOV AX, MyData 
    MOV DS, AX          ; DS point to data segment
    MOV AX, 0B800h
    MOV ES, AX          ; ES points to screen memory segment

    CALL myDisplay  ; main control for looping 

    CALL colorChar  ; colors the text

    MOV AH, 4Ch     ; exit
    INT 21h         ;

myMain ENDP

;=====

myDisplay PROC

    PUSH CX SI DI   ; preserve registers

    MOV CX, 25  ; row counter

    MOV SI, 0       ; starting location for SI (first cell of row)
    MOV DI, 158     ; starting location for DI (last cell of row)

    rowLoop: 

        CALL copyRow    ; switch left and right side of row

        ADD SI, 160     ; SI to next row
        ADD DI, 160     ; DI to next row

        LOOP rowLoop    ; loop 25 times

    POP DI SI CX    ; preserve registers
    ret

myDisplay ENDP

;=====

copyRow PROC
    
    PUSH AX BX CX SI DI     ; preserve registers
    MOV CX, 40              ; counter 

    flipLoop:
        MOV AX, ES:[SI]     ; save first cell
        MOV BX, ES:[DI]     ; save last cell
        MOV ES:[SI], BX     ; swap
        MOV ES:[DI], AX     ; swap

        ADD SI, 2           ; SI to next cell
        SUB DI, 2           ; DI to next cell

        LOOP flipLoop       ; loop 40 times
        
    POP DI SI CX BX AX      ; preserve registers
    ret

copyRow ENDP

;=====

colorChar PROC

PUSH AX CX SI DI    ; oreserve registers

MOV SI, 0           ; set SI to first cell
MOV DI, 0           ; set DI to first cell
MOV CX, 2000        ; counter (number cells)

copyLoop:

    MOV AX, ES:[SI]         ; get cell data

    ; next 4 compares are in order to determine if a the text is alphabetic or not
    ; jumps to appropriate color change or moves on to next compare

    CMP AL, 'A'             
    JB symbolColorChange

    CMP AL, 'Z'
    JBE alphaColorChange

    CMP AL, 'a'
    JB symbolColorChange

    CMP AL, 'z'
    JBE alphaCOlorChange
    JMP symbolColorChange
    

alphaColorChange:           ; for alphabetic 
    MOV AH, 01111001b       ; blue on white
    JMP skip                ; skips symbolColorChange

symbolColorChange:             ; for non alphabetic
    MOV AH, 00000111b       ; gray on black

skip:                       ; skip over other colorChange

MOV ES:[DI], AX             ; changes the color on screen

ADD SI, 2                   ; go to next cell
ADD DI, 2                   ; go to next cell

LOOP copyLoop               ; loop until counter (CX) is zero

POP DI SI CX AX             ; preserve registers
ret

colorChar ENDP

;=====

MyCode ENDS

;=====

end myMain