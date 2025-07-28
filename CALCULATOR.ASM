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
include		C:\masm32\macros\macros.asm

includelib	C:\masm32\lib\kernel32.lib
includelib	C:\masm32\lib\user32.lib
includelib	C:\masm32\lib\gdi32.lib
includelib	C:\masm32\lib\msvcrt.lib

; Incluir nuestro m�dulo de matem�ticas
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

MAXSiZE         equ 256

; Estados de la calculadora
CALC_STATE_NEW      equ 0   ; Nueva operación
CALC_STATE_RESULT   equ 1   ; Mostrando resultado, esperando operador
CALC_STATE_OPERATOR equ 2   ; Operador ingresado, esperando número
CALC_STATE_ERROR    equ 3   ; Estado de error

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
szAns               db "Ans",0                      ; NUEVO

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

end start