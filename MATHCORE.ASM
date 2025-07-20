; ===============================================
; MOTOR MATEMÁTICO - MATHCORE.ASM
; Reemplaza md5.asm con funciones de calculadora
; ===============================================

.data?
; Variables para cálculos
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
; FUNCIÓN PRINCIPAL DE EVALUACIÓN
; ===============================================
EvaluateExpression PROC lpExpression:DWORD
    ; Entrada: puntero a string de expresión
    ; Salida: EAX = 1 (éxito), 0 (error)
    ;         Resultado en result_value
    
    pushad
    mov esi, lpExpression
    call parse_and_calculate
    
    .if error_flag == 0
        popad
        mov eax, 1          ; Éxito
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
    ; Parser muy básico - mejorar después
    LOCAL num1_str[32]:BYTE
    LOCAL num2_str[32]:BYTE
    LOCAL operator:BYTE
    
    mov error_flag, 0
    lea edi, num1_str       ; CORREGIDO: usar LEA en lugar de MOV OFFSET
    xor ecx, ecx        ; Contador de caracteres
    
    ; Extraer primer número
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
    
    ; Extraer segundo número
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
    
    ; Convertir strings a números
    lea eax, num1_str
    call local_string_to_double
    fstp operand1
    
    lea eax, num2_str
    call local_string_to_double
    fstp operand2
    
    ; Realizar operación
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
; OPERACIONES MATEMÁTICAS BÁSICAS
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
    ; Verificar división por cero
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
; FUNCIÓN AUXILIAR: CONVERTIR STRING A DOUBLE
; ===============================================
local_string_to_double PROC
    ; Convierte string a número en pila FPU
    ; Implementación simplificada
    
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
    
    ; Construir número final
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
; FUNCIÓN DE FORMATO DE SALIDA
; ===============================================
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