; ===============================================
; CALCULADORA CIENTÍFICA CON MEMORIA DE RESULTADO
; ===============================================
; 
; DESCRIPCIÓN:
; Este módulo implementa una calculadora científica con interfaz gráfica que incluye
; memoria de resultado para operaciones continuas. Permite realizar cálculos básicos
; y funciones trigonométricas/logarítmicas, manteniendo el último resultado para
; continuar operaciones sin necesidad de reingresarlo.
;
; CARACTERÍSTICAS PRINCIPALES:
; - Operaciones aritméticas básicas (+, -, *, /)
; - Funciones científicas (sin, cos, tan, log, ln, sqrt)
; - Sistema de memoria que preserva el último resultado
; - Estados de calculadora para manejo de flujo de operaciones
; - Interfaz gráfica con botones numéricos y de operaciones
; - Manejo de errores de sintaxis y división por cero
;
; ESTADOS DE LA CALCULADORA:
; - CALC_STATE_NEW: Nueva operación iniciada
; - CALC_STATE_RESULT: Mostrando resultado, esperando operador
; - CALC_STATE_OPERATOR: Operador ingresado, esperando número
; - CALC_STATE_ERROR: Estado de error
;
; FUNCIONES PRINCIPALES:
; - DlgProc: Procedimiento principal del diálogo de la calculadora
; - init_calculator_memory: Inicializa las variables de memoria
; - store_last_result: Guarda el último resultado calculado
; - get_last_result: Recupera el último resultado guardado
; - handle_equals: Procesa el botón equals con memoria
; - handle_operator_with_memory: Maneja operadores considerando resultado previo
; - calculate_expression: Evalúa la expresión matemática
; - append_to_input: Agrega texto al campo de entrada
; - clear_all: Limpia todos los campos y reinicia la calculadora
;
; VARIABLES DE MEMORIA:
; - last_result: Último resultado calculado (REAL8)
; - calculator_state: Estado actual de la calculadora
; - has_result: Indica si hay un resultado válido en memoria
; - result_displayed: Indica si se está mostrando un resultado
; - pending_operator: Operador pendiente de aplicar
;
; CONTROLES DE INTERFAZ:
; - IDC_DISPLAY: Campo de visualización del resultado
; - IDC_INPUT: Campo de entrada de la expresión
; - IDC_STATUS: Barra de estado
; - IDB_NUM_0-9: Botones numéricos
; - IDB_ADD/SUB/MUL/DIV: Botones de operadores básicos
; - IDB_SIN/COS/TAN/LOG/LN/SQRT: Botones de funciones científicas
; - IDB_EQUALS: Botón de calcular/equals
; - IDB_CLEAR: Botón de limpiar
;
; DEPENDENCIAS:
; - mathcore.asm: Motor matemático para evaluación de expresiones
; - MASM32: Librerías de Windows API
; - Windows GDI/User32: Para interfaz gráfica
;
; AUTOR: [Sin especificar]
; VERSIÓN: [Sin especificar]
; FECHA: [Sin especificar]
.486
.model flat, stdcall
option casemap :none ; case sensitive

; ===============================================
; INCLUDES - Cambiar rutas seg�n tu instalaci�n
; ===============================================
include		C:\masm32\include\windows.inc
include		C:\masm32\include\kernel32.inc
include		C:\masm32\include\user32.inc
include		C:\masm32\include\gdi32.inc
include		C:\masm32\include\msvcrt.inc
include		C:\masm32\include\masm32.inc
include		C:\masm32\macros\macros.asm

includelib	C:\masm32\lib\kernel32.lib
includelib	C:\masm32\lib\user32.lib
includelib	C:\masm32\lib\gdi32.lib
includelib	C:\masm32\lib\msvcrt.lib
includelib	C:\masm32\lib\masm32.lib


include mathcore.asm

; ===============================================
; PROTOTIPOS DE FUNCIONES PROPIAS
; ===============================================

DlgProc             PROTO :DWORD,:DWORD,:DWORD,:DWORD
calculate_expression PROTO :DWORD
append_to_input     PROTO :DWORD,:DWORD
clear_all           PROTO :DWORD
clean_buffers       PROTO
DoubleToString      PROTO :REAL8,:DWORD,:DWORD

; Nuevos prototipos para memoria
init_calculator_memory PROTO
store_last_result   PROTO :REAL8
get_last_result     PROTO
is_continuing_calculation PROTO :DWORD
handle_equals       PROTO :DWORD
handle_operator_with_memory PROTO :DWORD,:DWORD

; Nuevos prototipos para conversiones
decimal_to_binary   PROTO :DWORD,:DWORD
decimal_to_octal    PROTO :DWORD,:DWORD
decimal_to_hex      PROTO :DWORD,:DWORD
decimal_to_bcd      PROTO :DWORD,:DWORD
binary_to_decimal   PROTO :DWORD
octal_to_decimal    PROTO :DWORD
hex_to_decimal      PROTO :DWORD
bcd_to_decimal      PROTO :DWORD
set_input_mode      PROTO :DWORD
validate_input_for_base PROTO :DWORD,:DWORD
convert_current_to_base PROTO :DWORD,:DWORD
convert_current_to_bcd PROTO :DWORD
validate_and_append PROTO :DWORD,:DWORD

.const
IDC_DISPLAY     equ 1001
IDC_INPUT       equ 1002
IDB_CALCULATE   equ 1003
IDC_GROUPBOX    equ 1004
IDC_STATUS      equ 1005

IDB_NUM_0       equ 1010
IDB_NUM_1       equ 1011
IDB_NUM_2       equ 1012
IDB_NUM_3       equ 1013
IDB_NUM_4       equ 1014
IDB_NUM_5       equ 1015
IDB_NUM_6       equ 1016
IDB_NUM_7       equ 1017
IDB_NUM_8       equ 1018
IDB_NUM_9       equ 1019

IDB_ADD         equ 1020
IDB_SUB         equ 1021
IDB_MUL         equ 1022
IDB_DIV         equ 1023
IDB_EQUALS      equ 1024
IDB_CLEAR       equ 1025
IDB_QUIT        equ 1026

IDB_SIN         equ 1030
IDB_COS         equ 1031
IDB_TAN         equ 1032
IDB_LOG         equ 1033
IDB_LN          equ 1034
IDB_SQRT        equ 1035
IDB_LPAREN      equ 1036  ; NUEVO: Paréntesis izquierdo (
IDB_RPAREN      equ 1037  ; NUEVO: Paréntesis derecho )
IDB_DECIMAL     equ 1038  ; NUEVO: Punto decimal .

; NUEVO: Botones de conversión de sistemas numéricos
IDB_TO_BIN      equ 1040  ; Convertir a binario
IDB_TO_OCT      equ 1041  ; Convertir a octal  
IDB_TO_HEX      equ 1042  ; Convertir a hexadecimal
IDB_TO_BCD      equ 1043  ; Convertir a BCD
IDB_TO_DEC      equ 1044  ; Convertir a decimal
IDB_MODE_BIN    equ 1045  ; Modo entrada binario
IDB_MODE_OCT    equ 1046  ; Modo entrada octal
IDB_MODE_HEX    equ 1047  ; Modo entrada hexadecimal
IDB_MODE_DEC    equ 1048  ; Modo entrada decimal

; Botones hexadecimales
IDB_HEX_A       equ 1050  ; Dígito A (10)
IDB_HEX_B       equ 1051  ; Dígito B (11)
IDB_HEX_C       equ 1052  ; Dígito C (12)
IDB_HEX_D       equ 1053  ; Dígito D (13)
IDB_HEX_E       equ 1054  ; Dígito E (14)
IDB_HEX_F       equ 1055  ; Dígito F (15)


MAXSiZE         equ 256

; Estados de la calculadora
CALC_STATE_NEW      equ 0   ; Nueva operación
CALC_STATE_RESULT   equ 1   ; Mostrando resultado, esperando operador
CALC_STATE_OPERATOR equ 2   ; Operador ingresado, esperando número
CALC_STATE_ERROR    equ 3   ; Estado de error

; Bases numéricas
BASE_BINARY         equ 2   ; Base binaria
BASE_OCTAL          equ 8   ; Base octal
BASE_DECIMAL        equ 10  ; Base decimal
BASE_HEXADECIMAL    equ 16  ; Base hexadecimal

; Modos de entrada
MODE_DECIMAL        equ 0   ; Modo decimal
MODE_BINARY         equ 1   ; Modo binario
MODE_OCTAL          equ 2   ; Modo octal
MODE_HEXADECIMAL    equ 3   ; Modo hexadecimal

.data?


; Variables principales
hInstance           dd ?
szInputBuffer       db 265 dup (?)
szDisplayBuffer     db 265 dup (?)
dInputLength        dd ?
dResult             real8 ?
bHasError           db ?

; NUEVAS VARIABLES PARA MEMORIA
last_result         real8 ?     ; Último resultado calculado
calculator_state    dd ?        ; Estado actual de la calculadora
has_result          dd ?        ; 1 si hay un resultado válido, 0 si no
pending_operator    db ?        ; Operador pendiente
result_displayed    dd ?        ; 1 si se está mostrando un resultado

; NUEVAS VARIABLES PARA SISTEMAS NUMÉRICOS
current_base        dd ?        ; Base actual: 2, 8, 10, 16
input_mode          dd ?        ; Modo de entrada actual
conversion_buffer   db 64 dup(?) ; Buffer para conversiones

.data



szResultBuffer      dd MAXSiZE dup (0)

; Textos de la interfaz
szTitle             db "Calculadora Cientifica",0
szGroupBox          db "CALCULADORA CIENTIFICA",0
szCalculateBtn      db "CALCULAR",0
szClearBtn          db "LIMPIAR",0
szQuitBtn           db "SALIR",0
szStatusText        db "Listo",0

; Textos de botones numericos
szBtn0              db "0",0
szBtn1              db "1",0
szBtn2              db "2",0
szBtn3              db "3",0
szBtn4              db "4",0
szBtn5              db "5",0
szBtn6              db "6",0
szBtn7              db "7",0
szBtn8              db "8",0
szBtn9              db "9",0

; Textos de operadores
szBtnAdd            db "+",0
szBtnSub            db "-",0
szBtnMul            db "*",0
szBtnDiv            db "/",0
szBtnEquals         db "=",0
szBtnClear          db "C",0

; Funciones cientificas
szBtnSin            db "SIN",0
szBtnCos            db "COS",0
szBtnTan            db "TAN",0
szBtnLog            db "LOG",0
szBtnLn             db "LN",0
szBtnSqrt           db "SQRT",0

; Strings para funciones cientificas
szSinFunc           db "sin(",0
szCosFunc           db "cos(",0
szTanFunc           db "tan(",0
szLogFunc           db "log(",0
szLnFunc            db "ln(",0
szSqrtFunc          db "sqrt(",0
szAns               db "Ans",0

; NUEVOS: Textos para paréntesis y decimal
szBtnLParen         db "(",0
szBtnRParen         db ")",0
szBtnDecimal        db ".",0

; NUEVOS: Textos para dígitos hexadecimales
szHexA              db "A",0
szHexB              db "B",0
szHexC              db "C",0
szHexD              db "D",0
szHexE              db "E",0
szHexF              db "F",0

; NUEVOS: Textos para conversiones
szBtnToBin          db "→BIN",0
szBtnToOct          db "→OCT",0
szBtnToHex          db "→HEX",0
szBtnToBcd          db "→BCD",0
szBtnToDec          db "→DEC",0

; NUEVOS: Textos para modos
szBtnModeBin        db "BIN",0
szBtnModeOct        db "OCT",0
szBtnModeHex        db "HEX",0
szBtnModeDec        db "DEC",0

; Cadenas de formato
szOctalFormat       db "%o",0
szHexFormat         db "%X",0
szDecimalFormat     db "%d",0
szBcdSuffix         db " (BCD)",0
; Mensajes de error y estado
szErrorTitle        db "Error",0
szErrorDivZero      db "Error: Division por cero",0
szErrorSyntax       db "Error: Sintaxis incorrecta",0
szTestExpression    db "2+3*4",0
szModified          db "Expresion modificada",0
szCompleted         db "Calculo completado",0
szContinuing        db "Continuando calculo...",0  ; NUEVO
szEmpty             db 0
szZero              db "0",0
                ; NUEVO

.code

; Main entry point for the calculator application
; Initializes the application instance, sets up calculator memory,
; creates the main dialog window, and handles application termination
; 
; Parameters: None
; Returns: Application exit code
; 
; Flow:
; 1. Gets the current module handle and stores it in hInstance
; 2. Initializes calculator memory structures
; 3. Creates and displays the main dialog (resource ID 101)
; 4. Exits the process with the dialog's return value
start:
    invoke GetModuleHandle,NULL
    mov hInstance,eax
    
    ; Inicializar memoria de calculadora
    invoke init_calculator_memory
    
    invoke DialogBoxParam,hInstance,101,0,ADDR DlgProc,0
    invoke ExitProcess,eax

; ===============================================
; INICIALIZAR MEMORIA DE LA CALCULADORA
; ===============================================
init_calculator_memory PROC
    ; Establecer estado inicial
    mov calculator_state, CALC_STATE_NEW
    mov has_result, 0
    mov pending_operator, 0
    mov result_displayed, 0
    
    ; Inicializar sistema numérico
    mov current_base, BASE_DECIMAL
    mov input_mode, MODE_DECIMAL
    
    ; Limpiar último resultado
    fldz
    fstp last_result
    
    ret
init_calculator_memory ENDP

; ===============================================
; GUARDAR ÚLTIMO RESULTADO
; ===============================================
store_last_result PROC value:REAL8
    fld value
    fstp last_result
    mov has_result, 1
    mov calculator_state, CALC_STATE_RESULT
    mov result_displayed, 1
    ret
store_last_result ENDP

; ===============================================
; OBTENER ÚLTIMO RESULTADO
; ===============================================
get_last_result PROC
    ; Retorna resultado en ST(0)
    fld last_result
    ret
get_last_result ENDP

; ===============================================
; VERIFICAR SI ESTÁ CONTINUANDO CÁLCULO
; ===============================================
is_continuing_calculation PROC lpInput:DWORD
    ; Retorna 1 si la entrada sugiere continuación, 0 si no
    
    ; Si no hay resultado previo, no puede continuar
    .if has_result == 0
        mov eax, 0
        ret
    .endif
    
    ; Si está mostrando resultado y se presiona operador, continuar
    .if result_displayed == 1
        mov esi, lpInput
        mov al, [esi]
        .if al == '+' || al == '-' || al == '*' || al == '/'
            mov eax, 1
            ret
        .endif
    .endif
    
    mov eax, 0
    ret
is_continuing_calculation ENDP

; ===============================================
; MANEJAR OPERADOR CON MEMORIA
; ===============================================
handle_operator_with_memory PROC hWin:DWORD, lpOperator:DWORD
    LOCAL temp_str[64]:BYTE
    
    ; Si estamos mostrando un resultado, usar ese resultado
    .if result_displayed == 1
        ; Formatear último resultado
        invoke format_result, ADDR temp_str, 6
        
        ; Limpiar campo de entrada y poner el resultado
        invoke SetDlgItemText, hWin, IDC_INPUT, ADDR temp_str
        
        ; Agregar el operador
        invoke append_to_input, hWin, lpOperator
        
        ; Cambiar estado
        mov calculator_state, CALC_STATE_OPERATOR
        mov result_displayed, 0
        
        ; Guardar operador pendiente
        mov esi, lpOperator
        mov al, [esi]
        mov pending_operator, al
        
        ; Actualizar estado
        invoke SetDlgItemText, hWin, IDC_STATUS, ADDR szContinuing
        
    .else
        ; Comportamiento normal - solo agregar operador
        invoke append_to_input, hWin, lpOperator
    .endif
    
    ret
handle_operator_with_memory ENDP

; ===============================================
; MANEJAR BOTÓN EQUALS CON MEMORIA
; ===============================================
handle_equals PROC hWin:DWORD
    ; Evaluar expresión actual
    invoke calculate_expression, hWin
    
    ; Si fue exitoso, guardar resultado
    .if error_flag == 0
        invoke store_last_result, result_value
    .endif
    
    ret
handle_equals ENDP

; ===============================================
; DIÁLOGO PRINCIPAL MODIFICADO
; ===============================================
;==============================================================================
; DlgProc - Main Dialog Window Procedure
;==============================================================================
; Description: 
;   Handles all window messages for the calculator dialog. Processes 
;   initialization, user input, button clicks, and window events.
;
; Parameters:
;   hWin    - Handle to the dialog window
;   uMsg    - Message identifier (WM_INITDIALOG, WM_COMMAND, WM_CLOSE)
;   wParam  - Additional message information (button IDs, notification codes)
;   lParam  - Additional message information (unused in this procedure)
;
; Returns:
;   EAX = 0 (standard dialog procedure return value)
;
; Messages Handled:
;   WM_INITDIALOG - Initializes dialog controls with text labels
;   WM_COMMAND    - Processes button clicks and edit control changes
;   WM_CLOSE      - Closes the dialog window
;
; Button Operations:
;   - Numeric buttons (0-9): Append digits to input field
;   - Arithmetic operators (+, -, *, /): Handle operator input with memory
;   - Calculate/Equals: Evaluate current expression
;   - Clear: Reset calculator state and memory
;   - Scientific functions (sin, cos, tan, log, ln, sqrt): Append function names
;   - Quit: Close application
;
; Special Behavior:
;   - Tracks input modifications and result display state
;   - Implements calculator memory for chained operations
;   - Handles EN_CHANGE notifications for input field updates
;
; Side Effects:
;   - Updates dialog control text and status
;   - Modifies global calculator state variables
;   - Manages input buffer and calculation memory
;==============================================================================
DlgProc proc    hWin    :DWORD,
                uMsg    :DWORD,
                wParam  :DWORD,
                lParam  :DWORD

    .if uMsg == WM_INITDIALOG
        invoke SetWindowText,hWin,ADDR szTitle
        invoke SetDlgItemText,hWin,IDC_GROUPBOX,ADDR szGroupBox
        invoke SetDlgItemText,hWin,IDB_CALCULATE,ADDR szCalculateBtn
        invoke SetDlgItemText,hWin,IDB_CLEAR,ADDR szClearBtn
        invoke SetDlgItemText,hWin,IDB_QUIT,ADDR szQuitBtn
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szStatusText
        invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szZero
        
        invoke SetDlgItemText,hWin,IDB_NUM_0,ADDR szBtn0
        invoke SetDlgItemText,hWin,IDB_NUM_1,ADDR szBtn1
        invoke SetDlgItemText,hWin,IDB_NUM_2,ADDR szBtn2
        invoke SetDlgItemText,hWin,IDB_NUM_3,ADDR szBtn3
        invoke SetDlgItemText,hWin,IDB_NUM_4,ADDR szBtn4
        invoke SetDlgItemText,hWin,IDB_NUM_5,ADDR szBtn5
        invoke SetDlgItemText,hWin,IDB_NUM_6,ADDR szBtn6
        invoke SetDlgItemText,hWin,IDB_NUM_7,ADDR szBtn7
        invoke SetDlgItemText,hWin,IDB_NUM_8,ADDR szBtn8
        invoke SetDlgItemText,hWin,IDB_NUM_9,ADDR szBtn9
        
        invoke SetDlgItemText,hWin,IDB_ADD,ADDR szBtnAdd
        invoke SetDlgItemText,hWin,IDB_SUB,ADDR szBtnSub
        invoke SetDlgItemText,hWin,IDB_MUL,ADDR szBtnMul
        invoke SetDlgItemText,hWin,IDB_DIV,ADDR szBtnDiv
        invoke SetDlgItemText,hWin,IDB_EQUALS,ADDR szBtnEquals
        invoke SetDlgItemText,hWin,IDB_CLEAR,ADDR szBtnClear
        
        invoke SetDlgItemText,hWin,IDB_SIN,ADDR szBtnSin
        invoke SetDlgItemText,hWin,IDB_COS,ADDR szBtnCos
        invoke SetDlgItemText,hWin,IDB_TAN,ADDR szBtnTan
        invoke SetDlgItemText,hWin,IDB_LOG,ADDR szBtnLog
        invoke SetDlgItemText,hWin,IDB_LN,ADDR szBtnLn
        invoke SetDlgItemText,hWin,IDB_SQRT,ADDR szBtnSqrt

        ; NUEVOS: Inicializar botones de paréntesis y decimal
        invoke SetDlgItemText,hWin,IDB_LPAREN,ADDR szBtnLParen
        invoke SetDlgItemText,hWin,IDB_RPAREN,ADDR szBtnRParen
        invoke SetDlgItemText,hWin,IDB_DECIMAL,ADDR szBtnDecimal

        ; NUEVOS: Inicializar botones de conversión
        invoke SetDlgItemText,hWin,IDB_TO_BIN,ADDR szBtnToBin
        invoke SetDlgItemText,hWin,IDB_TO_OCT,ADDR szBtnToOct
        invoke SetDlgItemText,hWin,IDB_TO_HEX,ADDR szBtnToHex
        invoke SetDlgItemText,hWin,IDB_TO_BCD,ADDR szBtnToBcd
        invoke SetDlgItemText,hWin,IDB_TO_DEC,ADDR szBtnToDec

        ; NUEVOS: Inicializar botones de modo
        invoke SetDlgItemText,hWin,IDB_MODE_BIN,ADDR szBtnModeBin
        invoke SetDlgItemText,hWin,IDB_MODE_OCT,ADDR szBtnModeOct
        invoke SetDlgItemText,hWin,IDB_MODE_HEX,ADDR szBtnModeHex
        invoke SetDlgItemText,hWin,IDB_MODE_DEC,ADDR szBtnModeDec

        ; NUEVOS: Inicializar botones hexadecimales
        invoke SetDlgItemText,hWin,IDB_HEX_A,ADDR szHexA
        invoke SetDlgItemText,hWin,IDB_HEX_B,ADDR szHexB
        invoke SetDlgItemText,hWin,IDB_HEX_C,ADDR szHexC
        invoke SetDlgItemText,hWin,IDB_HEX_D,ADDR szHexD
        invoke SetDlgItemText,hWin,IDB_HEX_E,ADDR szHexE
        invoke SetDlgItemText,hWin,IDB_HEX_F,ADDR szHexF

    .elseif uMsg == WM_COMMAND
        mov eax,wParam
        mov edx,eax
        shr edx,16
        and eax,0FFFFh
        
        .if edx == EN_CHANGE
            .if eax == IDC_INPUT
                invoke GetDlgItemText,hWin,IDC_INPUT,ADDR szInputBuffer,MAXSiZE
                invoke lstrlen,ADDR szInputBuffer
                mov dInputLength,eax
                invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szModified
                
                ; Si el usuario está escribiendo, ya no está mostrando resultado
                mov result_displayed, 0
                
                invoke clean_buffers
            .endif
        .endif
        
        ; MODIFIED: Usar nueva función para equals
        .if wParam == IDB_CALCULATE || wParam == IDB_EQUALS
            invoke handle_equals, hWin
            
        .elseif wParam == IDB_CLEAR
            invoke clear_all, hWin
            invoke init_calculator_memory  ; NUEVO: Reiniciar memoria
            
        .elseif wParam == IDB_QUIT
            invoke EndDialog,hWin,0
            
        ; Botones numericos - comportamiento normal
        .elseif wParam == IDB_NUM_0
            invoke append_to_input, hWin, ADDR szBtn0
        .elseif wParam == IDB_NUM_1
            invoke append_to_input, hWin, ADDR szBtn1
        .elseif wParam == IDB_NUM_2
            invoke append_to_input, hWin, ADDR szBtn2
        .elseif wParam == IDB_NUM_3
            invoke append_to_input, hWin, ADDR szBtn3
        .elseif wParam == IDB_NUM_4
            invoke append_to_input, hWin, ADDR szBtn4
        .elseif wParam == IDB_NUM_5
            invoke append_to_input, hWin, ADDR szBtn5
        .elseif wParam == IDB_NUM_6
            invoke append_to_input, hWin, ADDR szBtn6
        .elseif wParam == IDB_NUM_7
            invoke append_to_input, hWin, ADDR szBtn7
        .elseif wParam == IDB_NUM_8
            invoke append_to_input, hWin, ADDR szBtn8
        .elseif wParam == IDB_NUM_9
            invoke append_to_input, hWin, ADDR szBtn9
            
        ; MODIFIED: Operadores usan nueva función con memoria
        .elseif wParam == IDB_ADD
            invoke handle_operator_with_memory, hWin, ADDR szBtnAdd
        .elseif wParam == IDB_SUB
            invoke handle_operator_with_memory, hWin, ADDR szBtnSub
        .elseif wParam == IDB_MUL
            invoke handle_operator_with_memory, hWin, ADDR szBtnMul
        .elseif wParam == IDB_DIV
            invoke handle_operator_with_memory, hWin, ADDR szBtnDiv
            
        ; Funciones cientificas - comportamiento normal por ahora
        .elseif wParam == IDB_SIN
            invoke append_to_input, hWin, ADDR szSinFunc
        .elseif wParam == IDB_COS
            invoke append_to_input, hWin, ADDR szCosFunc
        .elseif wParam == IDB_TAN
            invoke append_to_input, hWin, ADDR szTanFunc
        .elseif wParam == IDB_LOG
            invoke append_to_input, hWin, ADDR szLogFunc
        .elseif wParam == IDB_LN
            invoke append_to_input, hWin, ADDR szLnFunc
        .elseif wParam == IDB_SQRT
            invoke append_to_input, hWin, ADDR szSqrtFunc
        

        ; NUEVOS: Manejar paréntesis y decimal
        .elseif wParam == IDB_LPAREN
            invoke append_to_input, hWin, ADDR szBtnLParen
        .elseif wParam == IDB_RPAREN
            invoke append_to_input, hWin, ADDR szBtnRParen
        .elseif wParam == IDB_DECIMAL
            invoke append_to_input, hWin, ADDR szBtnDecimal

        ; NUEVOS: Conversiones de base
        .elseif wParam == IDB_TO_BIN
            invoke convert_current_to_base, hWin, BASE_BINARY
        .elseif wParam == IDB_TO_OCT
            invoke convert_current_to_base, hWin, BASE_OCTAL
        .elseif wParam == IDB_TO_HEX
            invoke convert_current_to_base, hWin, BASE_HEXADECIMAL
        .elseif wParam == IDB_TO_BCD
            invoke convert_current_to_bcd, hWin
        .elseif wParam == IDB_TO_DEC
            invoke convert_current_to_base, hWin, BASE_DECIMAL

        ; NUEVOS: Modos de entrada
        .elseif wParam == IDB_MODE_BIN
            invoke set_input_mode, MODE_BINARY
        .elseif wParam == IDB_MODE_OCT
            invoke set_input_mode, MODE_OCTAL
        .elseif wParam == IDB_MODE_HEX
            invoke set_input_mode, MODE_HEXADECIMAL
        .elseif wParam == IDB_MODE_DEC
            invoke set_input_mode, MODE_DECIMAL

        ; NUEVOS: Dígitos hexadecimales
        .elseif wParam == IDB_HEX_A
            invoke validate_and_append, hWin, ADDR szHexA
        .elseif wParam == IDB_HEX_B
            invoke validate_and_append, hWin, ADDR szHexB
        .elseif wParam == IDB_HEX_C
            invoke validate_and_append, hWin, ADDR szHexC
        .elseif wParam == IDB_HEX_D
            invoke validate_and_append, hWin, ADDR szHexD
        .elseif wParam == IDB_HEX_E
            invoke validate_and_append, hWin, ADDR szHexE
        .elseif wParam == IDB_HEX_F
            invoke validate_and_append, hWin, ADDR szHexF
        .endif
    .elseif	uMsg == WM_CLOSE
        invoke EndDialog,hWin,0
    .endif
    
    xor eax,eax
    ret
DlgProc	endp

; ===============================================
; FUNCIONES AUXILIARES MODIFICADAS
; ===============================================

calculate_expression proc hWin:DWORD
    invoke GetDlgItemText,hWin,IDC_INPUT,ADDR szInputBuffer,MAXSiZE
    
    invoke EvaluateExpression,ADDR szInputBuffer
    
    .if eax == 1
        invoke format_result, ADDR szDisplayBuffer, 6
        invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szDisplayBuffer
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szCompleted
    .else
        invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szErrorSyntax
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szErrorSyntax
    .endif
    
    ret
calculate_expression endp

append_to_input proc hWin:DWORD, lpszText:DWORD
    LOCAL szTemp[512]:BYTE
    
    ; Si estamos mostrando un resultado y se presiona un número,
    ; empezar nueva expresión
    .if result_displayed == 1
        mov esi, lpszText
        mov al, [esi]
        .if al >= '0' && al <= '9'
            invoke SetDlgItemText,hWin,IDC_INPUT,lpszText
            mov result_displayed, 0
            mov calculator_state, CALC_STATE_NEW
            ret
        .endif
    .endif
    
    invoke GetDlgItemText,hWin,IDC_INPUT,ADDR szTemp,MAXSiZE
    invoke lstrcat,ADDR szTemp,lpszText
    invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szTemp
    
    ret
append_to_input endp

clear_all proc hWin:DWORD
    invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szEmpty
    invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szZero
    invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szStatusText
    invoke clean_buffers
    ret
clear_all endp

clean_buffers proc
    invoke RtlZeroMemory,ADDR szInputBuffer,SIZEOF szInputBuffer
    invoke RtlZeroMemory,ADDR szDisplayBuffer,SIZEOF szDisplayBuffer
    invoke RtlZeroMemory,ADDR szResultBuffer,SIZEOF szResultBuffer
    invoke RtlZeroMemory,ADDR dInputLength,SIZEOF dInputLength
    ret
clean_buffers endp

; ===============================================
; FUNCIONES DE CONVERSIÓN DE BASES NUMÉRICAS
; ===============================================

; Establecer modo de entrada
set_input_mode PROC mode:DWORD
    mov eax, mode
    mov input_mode, eax
    ret
set_input_mode ENDP

; Validar entrada para la base actual
validate_input_for_base PROC hWin:DWORD, lpszChar:DWORD
    mov eax, input_mode
    .if eax == MODE_BINARY
        ; Solo permitir 0 y 1
        mov esi, lpszChar
        mov al, [esi]
        .if al == '0' || al == '1'
            mov eax, 1  ; Válido
        .else
            mov eax, 0  ; Inválido
        .endif
    .elseif eax == MODE_OCTAL
        ; Solo permitir 0-7
        mov esi, lpszChar
        mov al, [esi]
        .if al >= '0' && al <= '7'
            mov eax, 1  ; Válido
        .else
            mov eax, 0  ; Inválido
        .endif
    .elseif eax == MODE_HEXADECIMAL
        ; Permitir 0-9, A-F
        mov esi, lpszChar
        mov al, [esi]
        .if (al >= '0' && al <= '9') || (al >= 'A' && al <= 'F') || (al >= 'a' && al <= 'f')
            mov eax, 1  ; Válido
        .else
            mov eax, 0  ; Inválido
        .endif
    .else
        ; Modo decimal - permitir 0-9 y punto decimal
        mov eax, 1  ; Siempre válido para decimal
    .endif
    ret
validate_input_for_base ENDP

; Validar y agregar carácter
validate_and_append PROC hWin:DWORD, lpszChar:DWORD
    invoke validate_input_for_base, hWin, lpszChar
    .if eax == 1
        invoke append_to_input, hWin, lpszChar
    .endif
    ret
validate_and_append ENDP

; Convertir número actual a la base especificada
convert_current_to_base PROC hWin:DWORD, target_base:DWORD
    LOCAL szBuffer[64]:BYTE
    LOCAL szInput[256]:BYTE
    LOCAL decimal_value:DWORD
    
    ; Obtener el número actual del campo de entrada
    lea eax, szInput
    invoke GetDlgItemText, hWin, IDC_INPUT, eax, 256
    
    ; Convertir a decimal primero (dependiendo del modo actual)
    mov eax, input_mode
    .if eax == MODE_BINARY
        lea eax, szInput
        invoke binary_to_decimal, eax
    .elseif eax == MODE_OCTAL
        lea eax, szInput
        invoke octal_to_decimal, eax
    .elseif eax == MODE_HEXADECIMAL
        lea eax, szInput
        invoke hex_to_decimal, eax
    .else
        ; Ya está en decimal - usar función simple de conversión
        push esi
        push edi
        lea esi, szInput
        mov eax, 0
        
        simple_atoi_loop:
            mov bl, [esi]
            .if bl == 0
                jmp simple_atoi_done
            .endif
            .if bl >= '0' && bl <= '9'
                sub bl, '0'
                imul eax, 10
                add eax, ebx
            .endif
            inc esi
            jmp simple_atoi_loop
        
        simple_atoi_done:
        pop edi
        pop esi
    .endif
    mov decimal_value, eax
    
    ; Convertir a la base objetivo
    mov eax, target_base
    .if eax == BASE_BINARY
        lea eax, szBuffer
        invoke decimal_to_binary, decimal_value, eax
    .elseif eax == BASE_OCTAL
        lea eax, szBuffer
        invoke decimal_to_octal, decimal_value, eax
    .elseif eax == BASE_HEXADECIMAL
        lea eax, szBuffer
        invoke decimal_to_hex, decimal_value, eax
    .else
        ; Base decimal - usar conversión simple
        push ebx
        push ecx
        push edx
        
        mov eax, decimal_value
        lea edi, szBuffer
        mov ecx, 0  ; contador de dígitos
        
        ; Caso especial para cero
        .if eax == 0
            mov BYTE PTR [edi], '0'
            mov BYTE PTR [edi+1], 0
            jmp done_decimal
        .endif
        
        ; Convertir a decimal
        decimal_loop:
            .if eax == 0
                jmp reverse_decimal
            .endif
            
            mov edx, 0
            mov ebx, 10
            div ebx  ; eax = eax/10, edx = resto
            
            add dl, '0'  ; convertir a ASCII
            push edx     ; guardar dígito
            inc ecx      ; incrementar contador
            jmp decimal_loop
        
        reverse_decimal:
            ; Escribir dígitos en orden correcto
            mov ebx, 0
            reverse_decimal_loop:
                .if ecx == 0
                    jmp done_decimal
                .endif
                pop edx
                mov [edi+ebx], dl
                inc ebx
                dec ecx
                jmp reverse_decimal_loop
        
        done_decimal:
            mov BYTE PTR [edi+ebx], 0  ; null terminator
            
        pop edx
        pop ecx
        pop ebx
    .endif
    
    ; Mostrar resultado
    lea eax, szBuffer
    invoke SetDlgItemText, hWin, IDC_DISPLAY, eax
    ret
convert_current_to_base ENDP

; Convertir a BCD (implementación básica)
convert_current_to_bcd PROC hWin:DWORD
    LOCAL szBuffer[64]:BYTE
    LOCAL szInput[256]:BYTE
    
    ; Obtener número y convertir a BCD (simplificado)
    lea eax, szInput
    invoke GetDlgItemText, hWin, IDC_INPUT, eax, 256
    lea eax, szBuffer
    lea edx, szInput
    invoke lstrcpy, eax, edx  ; Por ahora, copia simple
    lea eax, szBuffer
    invoke lstrcat, eax, ADDR szBcdSuffix
    lea eax, szBuffer
    invoke SetDlgItemText, hWin, IDC_DISPLAY, eax
    ret
convert_current_to_bcd ENDP

; Funciones de conversión básicas (implementaciones simplificadas por ahora)
decimal_to_binary PROC value:DWORD, buffer:DWORD
    ; Implementación básica - convertir decimal a binario
    push ebx
    push ecx
    push edx
    
    mov eax, value
    mov edi, buffer
    mov ecx, 0  ; contador de dígitos
    
    ; Caso especial para cero
    .if eax == 0
        mov BYTE PTR [edi], '0'
        mov BYTE PTR [edi+1], 0
        jmp done_binary
    .endif
    
    ; Convertir a binario
    binary_loop:
        .if eax == 0
            jmp reverse_binary
        .endif
        
        mov edx, 0
        mov ebx, 2
        div ebx  ; eax = eax/2, edx = resto
        
        add dl, '0'  ; convertir a ASCII
        push edx     ; guardar dígito
        inc ecx      ; incrementar contador
        jmp binary_loop
    
    reverse_binary:
        ; Escribir dígitos en orden correcto
        mov ebx, 0
        reverse_loop:
            .if ecx == 0
                jmp done_binary
            .endif
            pop edx
            mov [edi+ebx], dl
            inc ebx
            dec ecx
            jmp reverse_loop
    
    done_binary:
        mov BYTE PTR [edi+ebx], 0  ; null terminator
        
    pop edx
    pop ecx
    pop ebx
    ret
decimal_to_binary ENDP

decimal_to_octal PROC value:DWORD, buffer:DWORD
    ; Convertir a octal usando conversión manual
    push ebx
    push ecx
    push edx
    
    mov eax, value
    mov edi, buffer
    mov ecx, 0  ; contador de dígitos
    
    ; Caso especial para cero
    .if eax == 0
        mov BYTE PTR [edi], '0'
        mov BYTE PTR [edi+1], 0
        jmp done_octal
    .endif
    
    ; Convertir a octal
    octal_loop:
        .if eax == 0
            jmp reverse_octal
        .endif
        
        mov edx, 0
        mov ebx, 8
        div ebx  ; eax = eax/8, edx = resto
        
        add dl, '0'  ; convertir a ASCII
        push edx     ; guardar dígito
        inc ecx      ; incrementar contador
        jmp octal_loop
    
    reverse_octal:
        ; Escribir dígitos en orden correcto
        mov ebx, 0
        reverse_octal_loop:
            .if ecx == 0
                jmp done_octal
            .endif
            pop edx
            mov [edi+ebx], dl
            inc ebx
            dec ecx
            jmp reverse_octal_loop
    
    done_octal:
        mov BYTE PTR [edi+ebx], 0  ; null terminator
        
    pop edx
    pop ecx
    pop ebx
    ret
decimal_to_octal ENDP

decimal_to_hex PROC value:DWORD, buffer:DWORD
    ; Convertir a hexadecimal usando conversión manual
    push ebx
    push ecx
    push edx
    
    mov eax, value
    mov edi, buffer
    mov ecx, 0  ; contador de dígitos
    
    ; Caso especial para cero
    .if eax == 0
        mov BYTE PTR [edi], '0'
        mov BYTE PTR [edi+1], 0
        jmp done_hex
    .endif
    
    ; Convertir a hexadecimal
    hex_loop:
        .if eax == 0
            jmp reverse_hex
        .endif
        
        mov edx, 0
        mov ebx, 16
        div ebx  ; eax = eax/16, edx = resto
        
        .if edx < 10
            add dl, '0'  ; 0-9
        .else
            add dl, 'A' - 10  ; A-F
        .endif
        
        push edx     ; guardar dígito
        inc ecx      ; incrementar contador
        jmp hex_loop
    
    reverse_hex:
        ; Escribir dígitos en orden correcto
        mov ebx, 0
        reverse_hex_loop:
            .if ecx == 0
                jmp done_hex
            .endif
            pop edx
            mov [edi+ebx], dl
            inc ebx
            dec ecx
            jmp reverse_hex_loop
    
    done_hex:
        mov BYTE PTR [edi+ebx], 0  ; null terminator
        
    pop edx
    pop ecx
    pop ebx
    ret
decimal_to_hex ENDP

decimal_to_bcd PROC value:DWORD, buffer:DWORD
    ; Implementación básica BCD - igual que decimal por ahora
    push ebx
    push ecx
    push edx
    
    mov eax, value
    mov edi, buffer
    mov ecx, 0  ; contador de dígitos
    
    ; Caso especial para cero
    .if eax == 0
        mov BYTE PTR [edi], '0'
        mov BYTE PTR [edi+1], 0
        jmp done_bcd
    .endif
    
    ; Convertir a BCD (simplificado como decimal)
    bcd_loop:
        .if eax == 0
            jmp reverse_bcd
        .endif
        
        mov edx, 0
        mov ebx, 10
        div ebx  ; eax = eax/10, edx = resto
        
        add dl, '0'  ; convertir a ASCII
        push edx     ; guardar dígito
        inc ecx      ; incrementar contador
        jmp bcd_loop
    
    reverse_bcd:
        ; Escribir dígitos en orden correcto
        mov ebx, 0
        reverse_bcd_loop:
            .if ecx == 0
                jmp done_bcd
            .endif
            pop edx
            mov [edi+ebx], dl
            inc ebx
            dec ecx
            jmp reverse_bcd_loop
    
    done_bcd:
        mov BYTE PTR [edi+ebx], 0  ; null terminator
        
    pop edx
    pop ecx
    pop ebx
    ret
decimal_to_bcd ENDP

; Funciones de conversión desde otras bases
binary_to_decimal PROC binary_str:DWORD
    ; Convertir binario a decimal
    mov esi, binary_str
    mov eax, 0  ; resultado
    mov ebx, 1  ; potencia de 2
    
    ; Ir al final de la cadena
    invoke lstrlen, esi
    add esi, eax
    dec esi  ; último carácter
    
    binary_to_dec_loop:
        mov cl, [esi]
        .if cl == 0
            jmp binary_done
        .endif
        .if cl == '1'
            add eax, ebx
        .endif
        shl ebx, 1  ; multiplicar por 2
        dec esi
        cmp esi, binary_str
        jae binary_to_dec_loop
    
    binary_done:
    ret
binary_to_decimal ENDP

octal_to_decimal PROC octal_str:DWORD
    ; Usar función de conversión manual
    mov esi, octal_str
    mov eax, 0  ; resultado
    mov ebx, 1  ; potencia de 8
    
    ; Ir al final de la cadena
    invoke lstrlen, esi
    add esi, eax
    dec esi  ; último carácter
    
    octal_to_dec_loop:
        mov cl, [esi]
        .if cl == 0
            jmp octal_done
        .endif
        .if cl >= '0' && cl <= '7'
            sub cl, '0'
            push eax
            mov eax, 0
            mov al, cl
            mul ebx  ; multiplicar dígito por potencia
            pop edx  ; recuperar resultado anterior
            add eax, edx  ; sumar al resultado
            push eax
            mov eax, ebx
            mov edx, 8
            mul edx  ; multiplicar potencia por 8
            mov ebx, eax
            pop eax
        .endif
        dec esi
        cmp esi, octal_str
        jae octal_to_dec_loop
    
    octal_done:
    ret
octal_to_decimal ENDP

hex_to_decimal PROC hex_str:DWORD
    ; Convertir hexadecimal a decimal
    mov esi, hex_str
    mov eax, 0
    
    hex_to_dec_loop:
        mov cl, [esi]
        .if cl == 0
            jmp hex_done
        .endif
        
        shl eax, 4  ; multiplicar por 16
        
        .if cl >= '0' && cl <= '9'
            sub cl, '0'
            add eax, ecx
        .elseif cl >= 'A' && cl <= 'F'
            sub cl, 'A'
            add cl, 10
            add eax, ecx
        .elseif cl >= 'a' && cl <= 'f'
            sub cl, 'a'
            add cl, 10
            add eax, ecx
        .endif
        
        inc esi
        jmp hex_to_dec_loop
    
    hex_done:
    ret
hex_to_decimal ENDP

bcd_to_decimal PROC bcd_str:DWORD
    ; Conversión BCD simplificada - usar función simple
    push esi
    push edi
    mov esi, bcd_str
    mov eax, 0
    
    simple_bcd_to_dec_loop:
        mov bl, [esi]
        .if bl == 0
            jmp simple_bcd_to_dec_done
        .endif
        .if bl >= '0' && bl <= '9'
            sub bl, '0'
            imul eax, 10
            add eax, ebx
        .endif
        inc esi
        jmp simple_bcd_to_dec_loop
    
    simple_bcd_to_dec_done:
    pop edi
    pop esi
    ret
bcd_to_decimal ENDP

end start