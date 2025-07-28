# Documentación de la Calculadora Científica x86

## Descripción General

Este proyecto implementa una calculadora científica en Assembly x86 con interfaz gráfica Windows. La arquitectura está dividida en dos módulos principales:

- **CALCULATOR.ASM**: Manejo de la interfaz de usuario y lógica de memoria
- **MATHCORE.ASM**: Motor matemático para evaluación de expresiones

## Arquitectura del Sistema

### Módulos y Responsabilidades

```
┌─────────────────┐    include    ┌─────────────────┐
│  CALCULATOR.ASM │ ──────────────→│  MATHCORE.ASM   │
│                 │               │                 │
│ - Interfaz GUI  │               │ - Motor Matemático│
│ - Memoria calc. │               │ - Parser expresiones│
│ - Estados       │               │ - Operaciones    │
│ - Eventos       │               │ - Formateo       │
└─────────────────┘               └─────────────────┘
```

## CALCULATOR.ASM - Módulo Principal

### Variables de Estado

#### Variables de Interfaz

```asm
hInstance           dd ?        ; Handle de la instancia de la aplicación
szInputBuffer       db 265 dup (?)   ; Buffer de entrada del usuario
szDisplayBuffer     db 265 dup (?)   ; Buffer para mostrar resultados
dInputLength        dd ?        ; Longitud de la entrada actual
bHasError           db ?        ; Flag de error general
```

#### Variables de Memoria de Calculadora

```asm
last_result         real8 ?     ; Último resultado calculado
calculator_state    dd ?        ; Estado actual (NEW, RESULT, OPERATOR, ERROR)
has_result          dd ?        ; 1 si hay resultado válido, 0 si no
pending_operator    db ?        ; Operador pendiente de aplicar
result_displayed    dd ?        ; 1 si se muestra resultado, 0 si no
```

### Estados de la Calculadora

| Estado                  | Valor | Descripción                            |
| ----------------------- | ----- | --------------------------------------- |
| `CALC_STATE_NEW`      | 0     | Nueva operación iniciada               |
| `CALC_STATE_RESULT`   | 1     | Mostrando resultado, esperando operador |
| `CALC_STATE_OPERATOR` | 2     | Operador ingresado, esperando número   |
| `CALC_STATE_ERROR`    | 3     | Estado de error                         |

### Funciones Principales

#### `start` - Punto de Entrada

```asm
Propósito: Inicializar la aplicación y crear el diálogo principal
Flujo:
1. GetModuleHandle(NULL) → hInstance
2. init_calculator_memory()
3. DialogBoxParam() → crear ventana principal
4. ExitProcess()
```

#### `DlgProc` - Procedimiento del Diálogo

```asm
Propósito: Manejar todos los mensajes de la ventana
Mensajes manejados:
- WM_INITDIALOG: Inicializar controles
- WM_COMMAND: Procesar clics de botones
- WM_CLOSE: Cerrar aplicación

Botones procesados:
- IDB_NUM_0-9: append_to_input()
- IDB_ADD/SUB/MUL/DIV: handle_operator_with_memory()
- IDB_EQUALS: handle_equals()
- IDB_CLEAR: clear_all() + init_calculator_memory()
- IDB_SIN/COS/TAN/LOG/LN/SQRT: append_to_input()
```

### Funciones de Memoria

#### `init_calculator_memory`

```asm
Propósito: Inicializar variables de memoria
Acciones:
- calculator_state = CALC_STATE_NEW
- has_result = 0
- pending_operator = 0
- result_displayed = 0
- last_result = 0.0
```

#### `store_last_result`

```asm
Parámetros: value:REAL8
Propósito: Guardar resultado y cambiar estado
Acciones:
- last_result = value
- has_result = 1
- calculator_state = CALC_STATE_RESULT
- result_displayed = 1
```

#### `handle_operator_with_memory`

```asm
Parámetros: hWin:DWORD, lpOperator:DWORD
Propósito: Manejar operadores considerando memoria
Lógica:
IF result_displayed == 1 THEN
    format_result() → temp_str
    SetDlgItemText(INPUT, temp_str)
    append_to_input(operator)
    calculator_state = CALC_STATE_OPERATOR
    result_displayed = 0
ELSE
    append_to_input(operator)
ENDIF
```

#### `handle_equals`

```asm
Parámetros: hWin:DWORD
Propósito: Evaluar expresión y guardar resultado
Flujo:
1. calculate_expression() → evalúa usando MATHCORE
2. IF error_flag == 0 THEN store_last_result()
```

### Funciones Auxiliares

#### `calculate_expression`

```asm
Propósito: Interfaz entre GUI y motor matemático
Flujo:
1. GetDlgItemText() → szInputBuffer
2. EvaluateExpression() → llama a MATHCORE
3. IF éxito THEN format_result() + mostrar
4. ELSE mostrar error
```

#### `append_to_input`

```asm
Propósito: Agregar texto al campo de entrada
Lógica especial:
IF result_displayed == 1 AND input es número THEN
    Nueva expresión (reemplazar)
ELSE
    Concatenar al input actual
ENDIF
```

## MATHCORE.ASM - Motor Matemático

### Variables del Motor

#### Variables de Cálculo

```asm
calc_buffer     db 64 dup(?)    ; Buffer temporal
result_value    real8 ?         ; Resultado de operación
operand1        real8 ?         ; Primer operando
operand2        real8 ?         ; Segundo operando
current_op      db ?            ; Operador actual
error_flag      db ?            ; Flag de error matemático
```

#### Variables de Pila de Expresiones

```asm
expr_stack      real8 32 dup(?) ; Pila para expresiones complejas
stack_ptr       dd ?            ; Puntero de pila
```

#### Constantes de Formato

```asm
fmt_str         db "%.6f",0     ; Formato sprintf
ten_const       real8 10.0      ; Constante 10.0
zero_string     db "0", 0       ; String para cero
```

### Funciones del Motor

#### `EvaluateExpression` - Función Principal

```asm
Parámetros: lpExpression:DWORD
Retorna: EAX = 1 (éxito), 0 (error)
Propósito: Evaluar expresión matemática
Flujo:
1. parse_and_calculate() → procesar expresión
2. IF error_flag == 0 THEN return 1 ELSE return 0
Resultado guardado en: result_value
```

#### `parse_and_calculate` - Parser Simple

```asm
Propósito: Parser básico para expresiones tipo "num1 op num2"
Algoritmo:
1. Extraer primer número → num1_str
2. Extraer operador → operator
3. Extraer segundo número → num2_str
4. local_string_to_double() para ambos números
5. Llamar operación correspondiente
6. Resultado en result_value
```

### Operaciones Matemáticas

#### Operaciones Básicas

```asm
math_add():      operand1 + operand2 → result_value
math_subtract(): operand1 - operand2 → result_value
math_multiply(): operand1 * operand2 → result_value
math_divide():   operand1 / operand2 → result_value (con verificación de cero)
```

#### `math_divide` - División con Verificación

```asm
Algoritmo especial:
1. fld operand2
2. ftst → verificar si es cero
3. IF cero THEN error_flag = 1
4. ELSE operand1 / operand2 → result_value
```

### Funciones de Conversión

#### `local_string_to_double`

```asm
Parámetros: EAX = puntero a string
Retorna: Número en pila FPU
Propósito: Convertir string a número flotante
Maneja: signo, parte entera, parte decimal
```

#### `format_result`

```asm
Parámetros: lpBuffer:DWORD, precision:DWORD
Propósito: Formatear result_value a string
Casos especiales:
- Valores cero → zero_string
- Otros valores → crt_sprintf con fmt_str
```

## Flujo de Interacción Entre Módulos

### Secuencia de Cálculo Normal

```
1. Usuario presiona botón número
   ├─ DlgProc() recibe WM_COMMAND
   ├─ append_to_input() modifica IDC_INPUT
   └─ GUI actualizada

2. Usuario presiona operador (+, -, *, /)
   ├─ DlgProc() → handle_operator_with_memory()
   ├─ IF result_displayed THEN usar último resultado
   └─ Agregar operador al input

3. Usuario presiona segundo número
   ├─ append_to_input() continúa expresión
   └─ Input = "num1 op num2"

4. Usuario presiona EQUALS
   ├─ handle_equals()
   ├─ calculate_expression()
   ├─ EvaluateExpression() en MATHCORE
   ├─ parse_and_calculate() → extrae números y operador
   ├─ math_add/subtract/multiply/divide()
   ├─ format_result() → string formateado
   ├─ store_last_result() → guardar en memoria
   └─ Mostrar resultado en IDC_DISPLAY
```

### Secuencia de Cálculo Continuo

```
1. Resultado anterior en memoria (result_displayed = 1)
2. Usuario presiona operador
   ├─ handle_operator_with_memory()
   ├─ format_result() → convierte last_result a string
   ├─ SetDlgItemText(INPUT, resultado + operador)
   └─ result_displayed = 0

3. Usuario ingresa nuevo número y presiona EQUALS
   ├─ Expresión = "resultado_anterior op nuevo_numero"
   ├─ MATHCORE evalúa la expresión completa
   └─ Nuevo resultado guardado para próximo cálculo
```

## Variables Compartidas

### CALCULATOR.ASM → MATHCORE.ASM

- `result_value`: Resultado de operaciones matemáticas
- `error_flag`: Estado de error del motor matemático

### Funciones Expuestas por MATHCORE

- `EvaluateExpression()`: Evaluación principal
- `format_result()`: Formateo de resultados

Controles de la Interfaz

| Control ID              | Tipo   | Propósito                     |
| ----------------------- | ------ | ------------------------------ |
| `IDC_INPUT`           | Edit   | Campo de entrada de expresión |
| `IDC_DISPLAY`         | Static | Mostrar resultado              |
| `IDC_STATUS`          | Static | Barra de estado                |
| `IDB_NUM_0-9`         | Button | Botones numéricos             |
| `IDB_ADD/SUB/MUL/DIV` | Button | Operadores básicos            |
| `IDB_EQUALS`          | Button | Calcular resultado             |
| `IDB_CLEAR`           | Button | Limpiar todo                   |
| `IDB_SIN/COS/TAN`     | Button | Funciones trigonométricas     |
| `IDB_LOG/LN/SQRT`     | Button | Funciones logarítmicas        |

## Manejo de Errores

### Tipos de Error

1. **Error de sintaxis**: Parser no puede interpretar expresión
2. **División por cero**: Detectada en `math_divide()`
3. **Error de conversión**: String no válido en `local_string_to_double()`

### Propagación de Errores

```
MATHCORE error_flag = 1
    ↓
calculate_expression() detecta error
    ↓
Mostrar szErrorSyntax en IDC_DISPLAY
    ↓
Estado de calculadora no cambia
```

## Limitaciones Actuales

1. **Parser simple**: Solo maneja expresiones "num1 op num2"
2. **Sin precedencia**: No evalúa operaciones complejas como "2+3*4"
3. **Funciones científicas**: Solo agregan texto, no están implementadas
4. **Sin paréntesis**: No maneja agrupación de operaciones

## Extensiones Futuras

1. **Parser avanzado**: Implementar precedencia de operadores
2. **Pila de evaluación**: Para expresiones complejas
3. **Funciones científicas**: Implementar sin(), cos(), log(), etc.
4. **Historial**: Mantener lista de operaciones realizadas
5. **Memoria extendida**: Variables M+, M-, MC, MR

## Compilación y Dependencias

### Archivos Requeridos

- `CALCULATOR.ASM`: Módulo principal
- `MATHCORE.ASM`: Motor matemático
- `CALCULATOR.RC`: Recursos de la interfaz
- `build.bat`: Script de compilación

### Librerías Utilizadas

- `kernel32.lib`: Funciones básicas de Windows
- `user32.lib`: Interfaz de usuario
- `gdi32.lib`: Gráficos
- `msvcrt.lib`: Funciones C runtime (sprintf)

### Herramientas

- MASM32: Ensamblador Microsoft
- RC.EXE: Compilador de recursos
- LINK.EXE: Enlazador
