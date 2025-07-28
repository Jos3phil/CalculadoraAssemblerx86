; ===============================================
; MOTOR MATEM�TICO - MATHCORE.ASM
; Reemplaza md5.asm con funciones de calculadora
; ===============================================

.data?
; Variables para c�lculos
calc_buffer     db 64 dup(?)
result_value    real8 ?
operand1        real8 ?
operand2        real8 ?
current_op      db ?
error_flag      db ?

; Pila para expresiones complejas
expr_stack      real8 32 dup(?)
stack_ptr       dd ?

.data
; Constantes para sprintf
fmt_str         db "%.6f",0
ten_const       real8 10.0
zero_string     db "0", 0

.code

; ===============================================
; FUNCI�N PRINCIPAL DE EVALUACI�N
; ===============================================
EvaluateExpression PROC lpExpression:DWORD
    ; Entrada: puntero a string de expresi�n
    ; Salida: EAX = 1 (�xito), 0 (error)
    ;         Resultado en result_value
    
    pushad
    mov esi, lpExpression
    call parse_and_calculate
    
    .if error_flag == 0
        popad
        mov eax, 1          ; �xito
        ret
    .else
        popad
        mov eax, 0          ; Error
        ret
    .endif
EvaluateExpression ENDP

; ===============================================
; PARSER SIMPLE DE EXPRESIONES
; ===============================================
parse_and_calculate PROC
    ; Parser muy b�sico - mejorar despu�s
    LOCAL num1_str[32]:BYTE
    LOCAL num2_str[32]:BYTE
    LOCAL operator:BYTE
    
    mov error_flag, 0
    lea edi, num1_str       ; CORREGIDO: usar LEA en lugar de MOV OFFSET
    xor ecx, ecx        ; Contador de caracteres
    
    ; Extraer primer n�mero
parse_first_num:
    mov al, [esi]
    .if al >= '0' && al <= '9' || al == '.'
        mov [edi], al
        inc esi
        inc edi
        inc ecx
        jmp parse_first_num
    .endif
    
    mov BYTE PTR [edi], 0   ; Terminar string
    
    ; Verificar que hay operador
    mov al, [esi]
    .if al == '+' || al == '-' || al == '*' || al == '/'
        mov operator, al
        inc esi
    .else
        mov error_flag, 1
        ret
    .endif
    
    ; Extraer segundo n�mero
    lea edi, num2_str
    xor ecx, ecx
    
parse_second_num:
    mov al, [esi]
    .if al >= '0' && al <= '9' || al == '.'
        mov [edi], al
        inc esi
        inc edi
        inc ecx
        jmp parse_second_num
    .endif
    
    mov BYTE PTR [edi], 0   ; Terminar string
    
    ; Convertir strings a n�meros
    lea eax, num1_str
    call local_string_to_double
    fstp operand1
    
    lea eax, num2_str
    call local_string_to_double
    fstp operand2
    
    ; Realizar operaci�n
    mov al, operator
    .if al == '+'
        call math_add
    .elseif al == '-'
        call math_subtract
    .elseif al == '*'
        call math_multiply
    .elseif al == '/'
        call math_divide
    .else
        mov error_flag, 1
    .endif
    
    ret
parse_and_calculate ENDP

; ===============================================
; OPERACIONES MATEM�TICAS B�SICAS
; ===============================================

math_add PROC
    fld operand1
    fadd operand2
    fstp result_value
    ret
math_add ENDP

math_subtract PROC
    fld operand1
    fsub operand2
    fstp result_value
    ret
math_subtract ENDP

math_multiply PROC
    fld operand1
    fmul operand2
    fstp result_value
    ret
math_multiply ENDP

math_divide PROC
    ; Verificar divisi�n por cero
    fld operand2
    ftst
    fstsw ax
    sahf
    fstp st(0)      ; Limpiar pila
    
    .if ZERO?
        mov error_flag, 1
        ret
    .endif
    
    fld operand1
    fdiv operand2
    fstp result_value
    ret
math_divide ENDP

; ===============================================
; FUNCI�N AUXILIAR: CONVERTIR STRING A DOUBLE
; ===============================================
local_string_to_double PROC
    ; Convierte string a n�mero en pila FPU
    ; Implementaci�n simplificada
    
    LOCAL sign:DWORD
    LOCAL integer_part:DWORD
    LOCAL decimal_part:DWORD
    LOCAL decimal_places:DWORD
    
    mov esi, eax
    mov sign, 1
    mov integer_part, 0
    mov decimal_part, 0
    mov decimal_places, 0
    
    ; Verificar signo
    mov al, [esi]
    .if al == '-'
        mov sign, -1
        inc esi
    .elseif al == '+'
        inc esi
    .endif
    
    ; Procesar parte entera
parse_integer:
    mov al, [esi]
    .if al >= '0' && al <= '9'
        sub al, '0'
        movzx eax, al
        mov edx, integer_part
        imul edx, 10
        add edx, eax
        mov integer_part, edx
        inc esi
        jmp parse_integer
    .endif
    
    ; Verificar punto decimal
    .if BYTE PTR [esi] == '.'
        inc esi
        
        ; Procesar parte decimal
parse_decimal:
        mov al, [esi]
        .if al >= '0' && al <= '9'
            sub al, '0'
            movzx eax, al
            mov edx, decimal_part
            imul edx, 10
            add edx, eax
            mov decimal_part, edx
            inc decimal_places
            inc esi
            jmp parse_decimal
        .endif
    .endif
    
    ; Construir n�mero final
    fild integer_part       ; Cargar parte entera
    
    .if decimal_places > 0
        fild decimal_part   ; Cargar parte decimal
        
        ; Dividir por 10^decimal_places
        mov ecx, decimal_places
        fld1
divide_loop:
        fld ten_const       ; CORREGIDO: usar variable en lugar de literal
        fmul
        loop divide_loop
        
        fdiv                ; decimal_part / 10^places
        fadd                ; integer + decimal
    .endif
    
    ; Aplicar signo
    .if sign == -1
        fchs
    .endif
    
    ret
local_string_to_double ENDP

; ===============================================
; FUNCI�N DE FORMATO DE SALIDA
; ===============================================
;==============================================================================
; format_result PROCEDURE
;==============================================================================
; Description:
;   Formats a floating-point result value into a string representation with
;   specified precision. Handles special cases like zero values and uses
;   C runtime sprintf for general formatting.
;
; Parameters:
;   lpBuffer   - DWORD pointer to destination buffer where formatted string 
;                will be stored
;   precision  - DWORD value specifying the decimal precision for formatting
;                (Note: currently not used in implementation)
;
; Returns:
;   None (void procedure)
;   Formatted string is written to the buffer pointed to by lpBuffer
;
; Global Variables Used:
;   result_value - Global floating-point variable containing the value to format
;   zero_string  - Predefined string constant for zero representation
;   fmt_str      - Format string used with sprintf for number formatting
;
; Side Effects:
;   - Modifies the FPU stack (loads and pops result_value)
;   - Writes formatted output to the provided buffer
;   - Uses CPU flags for floating-point status checking
;
; Special Cases Handled:
;   - Zero values: Returns predefined zero string representation
;   - Uses FPU FXAM instruction to examine floating-point value characteristics
;
; Dependencies:
;   - Requires lstrcpy API function for string copying
;   - Requires crt_sprintf C runtime function for number formatting
;==============================================================================
format_result PROC lpBuffer:DWORD, precision:DWORD
    ; Formatear result_value a string
    
    ; Verificar casos especiales
    fld result_value
    fxam
    fstsw ax
    sahf
    fstp st(0)
    
    .if ZERO?
        invoke lstrcpy, lpBuffer, ADDR zero_string
        ret
    .endif
    
    ; Usar crt_sprintf para formatear
    invoke crt_sprintf, lpBuffer, ADDR fmt_str, result_value
    
    ret
format_result ENDP