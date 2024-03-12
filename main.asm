.model small
.stack 200h
.386

include mopl1.inc    
include mopl1.mac

.data    
    sline     db 78 dup(CHSEP), 0
    req       db "Фамилия И.О.: ", 0FFh
    minis     db "Министерство образования Российской Федерации", 0
    ulstu     db "Ульяновский государственный технический университет", 0
    dept      db "Кафедра вычислительной техники", 0
    mop       db "Машинно-ориентированное программирование", 0
    labr      db "Лабораторная работа №1", 0
    req1      db "Замедлить время работы в тактах(-), ускорить время работы в тактах (+),", 0
	req2      db "вычислить функцию (f), выйти(ESC)?", 0FFh
	tacts     db "Время работы в тактах: ", 0FFh
    emptys    db 0
    buflen    =  70
    buf       db buflen
    lens      db ?
    sname     db buflen dup(0)
    pause     dw 0, 0
    ti        db LENNUM+LENNUM/2 dup(?), 0
;------------- Новые переменные ------------------------------------
    req3    db    "Введите 20 бит числа X", 0
    req31   db   "Введите 20 бит числа Y", 0
    req4    db    "f8 = x1x2 | x3x4 | !x1!x2x3 | x2!x3!x4 | x2x3", 0

    bitlen dw 20
    bits_array db 20 dup(?)
    result_x dd ?
    result_y dd ?

    x1 db ?
    x2 db ?
    x3 db ?
	x4 db ?

    c1 db ?
    c2 db ?
    c3 db ?
    c4 db ?
	c5 db ?

    f db ?
    z dd ?
;-------------------------------------------------------------------


;========================= Программа =========================
.code
FUNC_EVAL:
	PUTCRLF
	PUTL req3

	COLLECT bits_array, bitlen
	CONVERT bits_array, bitlen
	mov result_x, ebx

	mov al, ' '
	call PUTC

	PRINT result_x, 10
	
	PUTCRLF
	PUTL req4

;----------------------------------------------------
	EXTRACT_BIT result_x, x4, 3
	call PUTD
	
	EXTRACT_BIT result_x, x3, 2
	call PUTD

	EXTRACT_BIT result_x, x2, 1
	call PUTD

	EXTRACT_BIT result_x, x1, 0
	call PUTD

;----------------------------------------------------
	mov al, x1
	mov bl, x2
	and bl, al
	mov c1, bl

	mov al, x3
	mov bl, x4
	and bl, al
	mov c2, bl

	mov al, x1
	mov bl, x2
	mov cl, x3
	not al
	and al, 1
	not bl
	and bl, 1
	and al, bl
	and al, cl
	mov c3, al

	mov al, x2
	mov bl, x3
	mov cl, x4
	not bl
	and bl, 1
	not cl
	and cl, 1
	and al, bl
	and al, cl
	mov c4, al

	mov al, x2
	mov bl, x3
	and bl, al
	mov c5, bl

	mov al, ' '
	call PUTC

	mov al, c1
	call PUTD

	mov al, c2
	call PUTD

	mov al, c3
	call PUTD

	mov al, c4
	call PUTD

	mov al, c5
	call PUTD

	mov al, c1
	mov bl, c2
	mov cl, c3
	mov dl, c4
	mov ah, c5

	or al, bl
	and al, 1
	or al, cl
	and al, 1
	or al, dl
	and al, 1
	or al, ah
	and al, 1
	mov f, al

	mov al, ' '
	call PUTC

	mov al, f
	call PUTD

;----------------------------------------------------
	PUTCRLF
	PUTL req31

	COLLECT bits_array, bitlen
	CONVERT bits_array, bitlen
	mov result_y, ebx

	mov al, ' '
	call PUTC

	PRINT result_y, 10

	PUTCRLF

;----------------------------------------------------
	cmp f, 1
	jne false

true:
	mov al, '+'
	call PUTC
	
	shl result_x, 2
	
	mov eax, result_x
	mov ebx, result_y
	sub eax, ebx

	jmp get_z

false:
	mov al, '-'
	call PUTC

	shr result_x, 2
	shr result_y, 1

	mov eax, result_x
	mov ebx, result_y
	add eax, ebx



get_z:
	mov z, eax

	mov al, ' '
	call PUTC

	PRINT z, 10

	PUTCRLF

;----------------------------------------------------
; z3 = !z8
	mov ebx, z
	shr ebx, 8
	and ebx, 1

	not ebx
	and ebx, 1

	shl ebx, 2

	mov eax, z
	and eax, 0FFFFFFFBh
	or eax, ebx
	mov z, eax

	
;----------------------------------------------------
; z15 &= z16
	mov ebx, z
	shr ebx, 16
	and ebx, 1

	mov ecx, z
	shr ecx, 15
	and ecx, 1

	and ebx, ecx
	shl ebx, 15

	mov eax, z
	and eax, 0FFFF7FFFh
	or eax, ebx
	mov z, eax
;----------------------------------------------------
; z11 |= z8
	mov ebx, z
	shr ebx, 8
	and ebx, 1

	mov ecx, z
	shr ecx, 11
	and ecx, 1

	or ebx, ecx
	shl ebx, 11

	mov eax, z
	and eax, 0FFFFF7FFh
	or eax, ebx
	mov z, eax

	PRINT z, 10
;----------------------------------------------------
	mov ah, 4ch              ; завершение программы
	int 21h
	
;----------------------------------------------------
	; Макрос заполнения строки LINE от позиции POS содержимым CNT объектов,
	; адресуемых адресом ADR при ширине поля вывода WFLD
BEGIN LABEL NEAR
	; инициализация сегментного регистра
	MOV AX, @DATA
	MOV DS, AX

	; инициализация задержки
	MOV pause, pause_L
	MOV pause+2, pause_H
	PUTLS req    ; запрос имени

	; ввод имени
	LEA DX, buf
	CALL GETS

; циклический процесс повторения вывода заставки
; вывод заставки
; ИЗМЕРЕНИЕ ВРЕМЕНИ НАЧАТЬ ЗДЕСЬ
@@L:
	FIXTIME
	PUTL emptys
	PUTL sline    ; разделительная черта
	PUTL emptys
	PUTLSC minis    ; первая 
	PUTL emptys
	PUTLSC ulstu    ;  и  
	PUTL emptys
	PUTLSC dept    ;   последующие 
	PUTL emptys
	PUTLSC mop    ;    строки  
	PUTL emptys
	PUTLSC labr    ;     заставки
	PUTL emptys
	; приветствие
	PUTLSC sname   ; ФИО студента
	PUTL emptys
	; разделительная черта
	PUTL sline
	; ИЗМЕРЕНИЕ ВРЕМЕНИ ЗАКОНЧИТЬ ЗДЕСЬ 
	DURAT        ; подсчет затраченного времени
	; Преобразование числа тиков в строку и вывод
	LEA DI, ti
	CALL UTOA10    
	PUTL tacts
	PUTL ti      ; вывод числа тактов
	; обработка команды
	PUTL req1
	;------Вывод своих строк с действиями -------------------
	PUTL req2
	;--------------------------------------------------------
	CALL GETCH
	;--------------------------------------------------------
	CMP AL, 'f'
	JE FUNC_EVAL
	;--------------------------------------------------------
	CMP AL, '-'    ; удлиннять задержку?
	JNE CMINUS
	INC pause+2        ; добавить 65536 мкс
	JMP @@L

CMINUS:
	CMP AL, '+'    ; укорачивать задержку?
	JNE CEXIT
	CMP WORD PTR pause+2, 0        
	JE BACK
	DEC pause+2        ; убавить 65536 мкс

BACK: 
	JMP @@L

CEXIT: 
	CMP AL, CHESC    
	JE @@E
	TEST AL, AL
	JNE BACK
	CALL GETCH
	JMP @@L

; Выход из программы
@@E:
	EXIT
	
	EXTRN PUTSS: NEAR
	EXTRN PUTC: NEAR
	EXTRN PUTD: NEAR
	EXTRN GETCH: NEAR
	EXTRN GETS: NEAR
	EXTRN SLEN: NEAR
	EXTRN UTOA10: NEAR
	EXTRN COLLECTOR: NEAR
	EXTRN CONVERTER: NEAR
	EXTRN PRINTER: NEAR
END BEGIN
