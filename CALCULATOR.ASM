
.486
.model flat, stdcall
option casemap :none ; case sensitive

; ===============================================
; INCLUDES - Cambiar rutas según tu instalación
; ===============================================
include		C:\MASM32-SDK\include\windows.inc
include		C:\MASM32-SDK\include\kernel32.inc
include		C:\MASM32-SDK\include\user32.inc
include		C:\MASM32-SDK\include\gdi32.inc
include		C:\MASM32-SDK\include\msvcrt.inc
include		C:\MASM32-SDK\macros\macros.asm

includelib	C:\MASM32-SDK\m32lib\kernel32.lib
includelib	C:\MASM32-SDK\m32lib\user32.lib
includelib	C:\MASM32-SDK\m32lib\gdi32.lib
includelib	C:\MASM32-SDK\m32lib\msvcrt.lib

; Incluir nuestro módulo de matemáticas
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

; ===============================================
; CONSTANTES (basadas en base.rc)
; ===============================================
.const
IDC_DISPLAY     equ 1001        ; Pantalla de la calculadora
IDC_INPUT       equ 1002        ; Campo de entrada
IDB_CALCULATE   equ 1003        ; Botón calcular
IDC_GROUPBOX    equ 1004        ; Grupo principal
IDC_STATUS      equ 1005        ; Estado

; Botones numéricos
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

; Operadores
IDB_ADD         equ 1020        ; +
IDB_SUB         equ 1021        ; -
IDB_MUL         equ 1022        ; *
IDB_DIV         equ 1023        ; /
IDB_EQUALS      equ 1024        ; =
IDB_CLEAR       equ 1025        ; C
IDB_QUIT        equ 1026        ; Salir

; Funciones científicas
IDB_SIN         equ 1030
IDB_COS         equ 1031
IDB_TAN         equ 1032
IDB_LOG         equ 1033
IDB_LN          equ 1034
IDB_SQRT        equ 1035

MAXSiZE         equ 256

; ===============================================
; DATOS
; ===============================================
.data
; Datos de la calculadora
szResultBuffer      dd MAXSiZE dup (0)

; Textos de la interfaz
szTitle             db "Calculadora Científica Gráfica",0
szGroupBox          db "CALCULADORA CIENTÍFICA",0
szCalculateBtn      db "CALCULAR",0
szClearBtn          db "LIMPIAR",0
szQuitBtn           db "SALIR",0
szStatusText        db "Listo",0

; Textos de botones numéricos
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

; Funciones científicas
szBtnSin            db "SIN",0
szBtnCos            db "COS",0
szBtnTan            db "TAN",0
szBtnLog            db "LOG",0
szBtnLn             db "LN",0
szBtnSqrt           db "√",0

; Strings para funciones científicas
szSinFunc           db "sin(",0
szCosFunc           db "cos(",0
szTanFunc           db "tan(",0
szLogFunc           db "log(",0
szLnFunc            db "ln(",0
szSqrtFunc          db "sqrt(",0

; Mensajes de error y estado
szErrorTitle        db "Error",0
szErrorDivZero      db "Error: División por cero",0
szErrorSyntax       db "Error: Sintaxis incorrecta",0
szTestExpression    db "2+3*4",0
szModified          db "Expresión modificada",0
szCompleted         db "Cálculo completado",0
szEmpty             db 0
szZero              db "0",0

; ===============================================
; VARIABLES
; ===============================================
.data?
hInstance           dd ?
szInputBuffer       db 265 dup (?)
szDisplayBuffer     db 265 dup (?)
dInputLength        dd ?
dResult             real8 ?
bHasError           db ?

; ===============================================
; CÓDIGO PRINCIPAL
; ===============================================
.code

start:
    invoke GetModuleHandle,NULL
    mov hInstance,eax
    invoke DialogBoxParam,hInstance,101,0,ADDR DlgProc,0
    invoke ExitProcess,eax

; ===============================================
; FUNCIÓN PARA CONVERTIR NÚMERO A STRING
; ===============================================
DoubleToString PROC dblValue:REAL8, lpszBuffer:DWORD, precision:DWORD
    ; Usar sprintf del C runtime
    invoke crt_sprintf, lpszBuffer, ADDR fmt_str, dblValue
    ret
DoubleToString ENDP

; ===============================================
; FUNCIÓN PRINCIPAL DEL DIÁLOGO
; ===============================================
DlgProc proc    hWin    :DWORD,
                uMsg    :DWORD,
                wParam  :DWORD,
                lParam  :DWORD

    .if uMsg == WM_INITDIALOG
        ; Configurar textos de controles
        invoke SetWindowText,hWin,ADDR szTitle
        invoke SetDlgItemText,hWin,IDC_GROUPBOX,ADDR szGroupBox
        invoke SetDlgItemText,hWin,IDB_CALCULATE,ADDR szCalculateBtn
        invoke SetDlgItemText,hWin,IDB_CLEAR,ADDR szClearBtn
        invoke SetDlgItemText,hWin,IDB_QUIT,ADDR szQuitBtn
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szStatusText
        invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szTestExpression
        
        ; Configurar botones numéricos
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
        
        ; Configurar operadores
        invoke SetDlgItemText,hWin,IDB_ADD,ADDR szBtnAdd
        invoke SetDlgItemText,hWin,IDB_SUB,ADDR szBtnSub
        invoke SetDlgItemText,hWin,IDB_MUL,ADDR szBtnMul
        invoke SetDlgItemText,hWin,IDB_DIV,ADDR szBtnDiv
        invoke SetDlgItemText,hWin,IDB_EQUALS,ADDR szBtnEquals
        invoke SetDlgItemText,hWin,IDB_CLEAR,ADDR szBtnClear
        
        ; Configurar funciones científicas
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
                invoke clean_buffers
            .endif
        .endif
        
        ; Manejar clicks de botones
        .if wParam == IDB_CALCULATE 
            invoke calculate_expression, hWin
            
        .elseif wParam == IDB_CLEAR
            invoke clear_all, hWin
            
        .elseif wParam == IDB_QUIT
            invoke EndDialog,hWin,0
            
        ; Botones numéricos
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
            
        ; Operadores
        .elseif wParam == IDB_ADD
            invoke append_to_input, hWin, ADDR szBtnAdd
        .elseif wParam == IDB_SUB
            invoke append_to_input, hWin, ADDR szBtnSub
        .elseif wParam == IDB_MUL
            invoke append_to_input, hWin, ADDR szBtnMul
        .elseif wParam == IDB_DIV
            invoke append_to_input, hWin, ADDR szBtnDiv
        .elseif wParam == IDB_EQUALS
            invoke calculate_expression, hWin
            
        ; Funciones científicas
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
; FUNCIONES AUXILIARES
; ===============================================

calculate_expression proc hWin:DWORD
    ; Obtener expresión de entrada
    invoke GetDlgItemText,hWin,IDC_INPUT,ADDR szInputBuffer,MAXSiZE
    
    ; Calcular usando nuestro motor matemático
    invoke EvaluateExpression,ADDR szInputBuffer
    
    .if eax == 1  ; Éxito
        ; Formatear resultado usando la función de mathcore
        invoke format_result, ADDR szDisplayBuffer, 6
        invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szDisplayBuffer
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szCompleted
    .else
        ; Mostrar error
        invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szErrorSyntax
        invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szErrorSyntax
    .endif
    
    ret
calculate_expression endp

append_to_input proc hWin:DWORD, lpszText:DWORD
    LOCAL szTemp[512]:BYTE
    
    ; Obtener texto actual
    invoke GetDlgItemText,hWin,IDC_INPUT,ADDR szTemp,MAXSiZE
    
    ; Concatenar nuevo texto
    invoke lstrcat,ADDR szTemp,lpszText
    
    ; Establecer texto actualizado
    invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szTemp
    
    ret
append_to_input endp

clear_all proc hWin:DWORD
    ; Limpiar campos
    invoke SetDlgItemText,hWin,IDC_INPUT,ADDR szEmpty
    invoke SetDlgItemText,hWin,IDC_DISPLAY,ADDR szZero
    invoke SetDlgItemText,hWin,IDC_STATUS,ADDR szStatusText
    
    invoke clean_buffers
    ret
clear_all endp

clean_buffers proc
    ; Limpiar buffers
    invoke RtlZeroMemory,ADDR szInputBuffer,SIZEOF szInputBuffer
    invoke RtlZeroMemory,ADDR szDisplayBuffer,SIZEOF szDisplayBuffer
    invoke RtlZeroMemory,ADDR szResultBuffer,SIZEOF szResultBuffer
    invoke RtlZeroMemory,ADDR dInputLength,SIZEOF dInputLength
    ret
clean_buffers endp

end start