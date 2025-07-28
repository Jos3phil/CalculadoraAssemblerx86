; ===============================================
; MOTOR MATEMÁTICO - MATHCORE.ASM
; ===============================================
; AGREGAR ESTOS INCLUDES AL INICIO



include		C:\masm32\include\msvcrt.inc
include		C:\masm32\macros\macros.asm

; INCLUIR FPULIB
include     C:\masm32\include\fpu.inc

includelib	C:\masm32\lib\kernel32.lib
includelib	C:\masm32\lib\user32.lib
includelib	C:\masm32\lib\msvcrt.lib

; LIBRERÍA FPULIB
includelib  C:\masm32\fpulib\fpu.lib
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

; Variables temporales para fpulib
temp_angle      real10 ?
temp_result     real10 ?

.data
; Constantes para sprintf
fmt_str         db "%.6f",0
ten_const       real8 10.0
zero_string     db "0", 0
deg_to_rad      real8 0.0174532925199  ; pi/180



.code

; ===============================================
; FUNCIÓN PRINCIPAL DE EVALUACIÓN - CORREGIDA
; ===============================================
EvaluateExpression PROC lpExpression:DWORD
    ; Entrada: puntero a string de expresión
    ; Salida: EAX = 1 (éxito), 0 (error)
    ;         Resultado en result_value
    
    pushad
    mov esi, lpExpression
    mov error_flag, 0
    
    ; PRIMERO: Verificar si es una función científica
    ; Verificar función SIN
    .if byte ptr [esi] == 's'
        ; Comparar con "sin("
        .if byte ptr [esi+1] == 'i' && byte ptr [esi+2] == 'n' && byte ptr [esi+3] == '('
            add esi, 4  ; Saltar "sin("
            call extract_function_parameter
            .if eax != 0
                call calculate_sin
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        ; Comparar con "sqrt("
        .elseif byte ptr [esi+1] == 'q' && byte ptr [esi+2] == 'r' && byte ptr [esi+3] == 't' && byte ptr [esi+4] == '('
            add esi, 5  ; Saltar "sqrt("
            call extract_function_parameter
            .if eax != 0
                call calculate_sqrt
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        .endif
    .endif
    
    ; Verificar función COS
    .if byte ptr [esi] == 'c'
        .if byte ptr [esi+1] == 'o' && byte ptr [esi+2] == 's' && byte ptr [esi+3] == '('
            add esi, 4  ; Saltar "cos("
            call extract_function_parameter
            .if eax != 0
                call calculate_cos
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        .endif
    .endif
    
    ; Verificar función TAN
    .if byte ptr [esi] == 't'
        .if byte ptr [esi+1] == 'a' && byte ptr [esi+2] == 'n' && byte ptr [esi+3] == '('
            add esi, 4  ; Saltar "tan("
            call extract_function_parameter
            .if eax != 0
                call calculate_tan
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        .endif
    .endif
    
    ; Verificar función LN
    .if byte ptr [esi] == 'l'
        .if byte ptr [esi+1] == 'n' && byte ptr [esi+2] == '('
            add esi, 3  ; Saltar "ln("
            call extract_function_parameter
            .if eax != 0
                call calculate_ln
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        ; Verificar función LOG
        .elseif byte ptr [esi+1] == 'o' && byte ptr [esi+2] == 'g' && byte ptr [esi+3] == '('
            add esi, 4  ; Saltar "log("
            call extract_function_parameter
            .if eax != 0
                call calculate_log
                .if error_flag == 0
                    popad
                    mov eax, 1  ; éxito
                    ret
                .else
                    popad
                    mov eax, 0  ; error
                    ret
                .endif
            .else
                popad
                mov eax, 0  ; error en parámetro
                ret
            .endif
        .endif
    .endif
    
    ; Si no es función científica, usar parser normal
    call parse_and_calculate
    
    .if error_flag == 0
        popad
        mov eax, 1          ; éxito
        ret
    .else
        popad
        mov eax, 0          ; Error
        ret
    .endif

EvaluateExpression ENDP

; ===============================================
; EXTRAER PARÁMETRO DE FUNCIÓN
; ===============================================
extract_function_parameter PROC uses ebx ecx edx edi
    LOCAL param_buffer[32]:BYTE
    LOCAL paren_count:DWORD
    
    ; esi ya apunta al inicio del parámetro
    lea edi, param_buffer
    mov paren_count, 1  ; Ya tenemos un '(' abierto
    
    ; Copiar hasta encontrar el ')' correspondiente
    .while paren_count > 0
        mov al, [esi]
        .if al == 0
            mov eax, 0  ; Error: expresión incompleta
            ret
        .endif
        
        .if al == '('
            inc paren_count
        .elseif al == ')'
            dec paren_count
        .endif
        
        .if paren_count > 0
            mov [edi], al
            inc edi
        .endif
        inc esi
    .endw
    
    mov byte ptr [edi], 0  ; Null terminator
    lea eax, param_buffer
    ret
extract_function_parameter ENDP

; ===============================================
; FUNCIONES CIENTÍFICAS CON FPULIB
; ===============================================

; Calcular seno
; Calcular seno
calculate_sin PROC uses ebx ecx edx
    ; eax apunta al string del parámetro
    ; Convertir string a REAL10 usando FpuLib
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    ; Usar FpuSin con valor en grados
    invoke FpuSin, ADDR temp_angle, ADDR temp_result, SRC1_REAL or ANG_DEG or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    ; Convertir REAL10 a REAL8 para result_value
    fld temp_result
    fstp result_value
    
    mov error_flag, 0
    ret
calculate_sin ENDP

; Calcular coseno
calculate_cos PROC uses ebx ecx edx
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    invoke FpuCos, ADDR temp_angle, ADDR temp_result, SRC1_REAL or ANG_DEG or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    fld temp_result
    fstp result_value
    mov error_flag, 0
    ret
calculate_cos ENDP

; Calcular tangente
calculate_tan PROC uses ebx ecx edx
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    invoke FpuTan, ADDR temp_angle, ADDR temp_result, SRC1_REAL or ANG_DEG or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    fld temp_result
    fstp result_value
    mov error_flag, 0
    ret
calculate_tan ENDP

; Calcular logaritmo natural - CORREGIDO
calculate_ln PROC uses ebx ecx edx
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    ; Verificar que el valor sea positivo
    fld temp_angle
    fldz
    fcompp
    fstsw ax
    sahf
    .if CARRY?  ; temp_angle < 0
        mov error_flag, 1
        ret
    .endif
    
    ; Usar FpuLnx (no FpuLn)
    invoke FpuLnx, ADDR temp_angle, ADDR temp_result, SRC1_REAL or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    fld temp_result
    fstp result_value
    mov error_flag, 0
    ret
calculate_ln ENDP

; Calcular logaritmo base 10 - CORREGIDO
calculate_log PROC uses ebx ecx edx
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    ; Verificar que el valor sea positivo
    fld temp_angle
    fldz
    fcompp
    fstsw ax
    sahf
    .if CARRY?  ; temp_angle < 0
        mov error_flag, 1
        ret
    .endif
    
    ; Usar FpuLog10x (no FpuLog10)
    invoke FpuLogx, ADDR temp_angle, ADDR temp_result, SRC1_REAL or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    fld temp_result
    fstp result_value
    mov error_flag, 0
    ret
calculate_log ENDP

; Calcular raíz cuadrada
calculate_sqrt PROC uses ebx ecx edx
    invoke FpuAtoFL, eax, ADDR temp_angle, DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    ; Verificar que el valor sea no negativo
    fld temp_angle
    fldz
    fcompp
    fstsw ax
    sahf
    .if CARRY?  ; temp_angle < 0
        mov error_flag, 1
        ret
    .endif
    
    invoke FpuSqrt, ADDR temp_angle, ADDR temp_result, SRC1_REAL or DEST_MEM
    .if eax == 0
        mov error_flag, 1
        ret
    .endif
    
    fld temp_result
    fstp result_value
    mov error_flag, 0
    ret
calculate_sqrt ENDP

; ===============================================
; PARSER SIMPLE DE EXPRESIONES
; ===============================================
parse_and_calculate PROC
    ; Parser muy básico - mejorar después
    LOCAL num1_str[32]:BYTE
    LOCAL num2_str[32]:BYTE
    LOCAL operator:BYTE
    
    mov error_flag, 0
    lea edi, num1_str
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
    lea esi, num1_str
    call local_string_to_double
    fstp operand1
    
    lea esi, num2_str
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
    ; esi apunta al string
    
    LOCAL sign:DWORD
    LOCAL integer_part:DWORD
    LOCAL decimal_part:DWORD
    LOCAL decimal_places:DWORD
    
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
        fld ten_const
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
    ; Verificar si es cero
    fld result_value
    ftst
    fstsw ax
    sahf
    fstp st(0)      ; Limpiar pila
    
    .if ZERO?
        invoke lstrcpy, lpBuffer, ADDR zero_string
    .else
        invoke crt_sprintf, lpBuffer, ADDR fmt_str, result_value
    .endif
    
    ret
format_result ENDP