# 🧮 Calculadora Científica en Assembly x86

Una calculadora científica avanzada desarrollada en **Assembly x86** (MASM32) con interfaz gráfica de Windows, que incluye funciones matemáticas avanzadas y conversiones entre sistemas numéricos.

![Assembly](https://img.shields.io/badge/Assembly-x86-blue.svg)
![Windows](https://img.shields.io/badge/Platform-Windows-green.svg)
![MASM32](https://img.shields.io/badge/Assembler-MASM32-red.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 📋 Índice

- [Características](#-características)
- [Requerimientos](#-requerimientos)
- [Instalación](#-instalación)
- [Compilación](#-compilación)
- [Uso](#-uso)
- [Funcionalidades](#-funcionalidades)
- [Arquitectura](#-arquitectura)
- [Contribuir](#-contribuir)

## ✨ Características

### 🔢 **Operaciones Básicas**
- Suma, resta, multiplicación y división
- Soporte para números decimales
- Paréntesis para agrupación de operaciones
- Sistema de memoria para operaciones continuas

### 🔬 **Funciones Científicas**
- **Trigonométricas**: `sin()`, `cos()`, `tan()`
- **Logarítmicas**: `log()` (base 10), `ln()` (logaritmo natural)
- **Raíces**: `sqrt()` (raíz cuadrada)
- Precisión de 80 bits usando coprocesador matemático x87

### 🔄 **Conversiones de Sistemas Numéricos**
- **Binario** (base 2): 0, 1
- **Octal** (base 8): 0-7
- **Decimal** (base 10): 0-9
- **Hexadecimal** (base 16): 0-9, A-F
- **BCD** (Binary-Coded Decimal)

### 🖥️ **Interfaz Gráfica**
- Ventana nativa de Windows con API Win32
- Botones organizados intuitivamente
- Campo de entrada y visualización de resultados
- Barra de estado para mensajes informativos

## 🛠️ Requerimientos

### **Sistema Operativo**
- Windows 10/11 (x86/x64)
- Windows 7/8.1 (compatible)

### **Herramientas de Desarrollo** (solo para compilación)
- **MASM32 SDK** - Microsoft Macro Assembler 32-bit
  - Descarga: [masm32.com](http://www.masm32.com/)
  - Instalación recomendada en: `C:\masm32\`

### **Dependencias del Sistema**
- **FPULIB** - Librería de funciones matemáticas
  - Incluida en el proyecto como `mathcore.asm`
- **Librerías Win32**:
  - `kernel32.lib`
  - `user32.lib`
  - `gdi32.lib`
  - `msvcrt.lib`

### **Especificaciones Mínimas**
- **Procesador**: x86 compatible (Intel 486 o superior)
- **Memoria RAM**: 64 MB mínimo
- **Espacio en disco**: 5 MB para archivos fuente

## 📦 Instalación

### **Opción 1: Ejecutable Pre-compilado**
```bash
# Clonar el repositorio
git clone https://github.com/Jos3phil/CalculadoraAssemblerx86.git
cd CalculadoraAssemblerx86/Assembler86Calculator

# Ejecutar directamente
calculator.exe
```

### **Opción 2: Compilar desde Fuente**
```bash
# 1. Instalar MASM32 SDK en C:\masm32\
# 2. Clonar repositorio
git clone https://github.com/Jos3phil/CalculadoraAssemblerx86.git
cd CalculadoraAssemblerx86/Assembler86Calculator

# 3. Compilar proyecto
compile.bat
# o manualmente:
C:\masm32\bin\rc.exe /v CALCULATOR.RC
C:\masm32\bin\ml.exe /c /coff /Cp /nologo CALCULATOR.ASM
C:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /OUT:calculator.exe CALCULATOR.obj CALCULATOR.res
```

## 🔨 Compilación

### **Script Automático**
```bash
# Usar script de compilación incluido
compile.bat
```

### **Compilación Manual**
```bash
# 1. Compilar recursos (.RC → .RES)
C:\masm32\bin\rc.exe /v CALCULATOR.RC

# 2. Ensamblar código (.ASM → .OBJ)
C:\masm32\bin\ml.exe /c /coff /Cp /nologo CALCULATOR.ASM

# 3. Enlazar ejecutable (.OBJ + .RES → .EXE)
C:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /RELEASE ^
    /OUT:calculator.exe CALCULATOR.obj CALCULATOR.res ^
    C:\masm32\lib\kernel32.lib C:\masm32\lib\user32.lib ^
    C:\masm32\lib\gdi32.lib C:\masm32\lib\msvcrt.lib
```

### **Errores Comunes de Compilación**
| Error | Solución |
|-------|----------|
| `A2006: undefined symbol` | Verificar que MASM32 esté instalado en `C:\masm32\` |
| `RC2104: undefined keyword` | Comprobar codificación de archivo `.RC` (ANSI) |
| `LNK2001: unresolved external` | Incluir todas las librerías requeridas |

## 🚀 Uso

### **Interfaz Principal**

```
┌─────────────────────────────────────────────────┐
│          Calculadora Científica                │
├─────────────────────────────────────────────────┤
│ Resultado: [ 0                               ] │
│ Entrada:   [ _                               ] │
├─────────────────────────────────────────────────┤
│ SIN  COS  TAN  LOG  LN  SQRT                   │
├─────────────────────────────────────────────────┤
│  7    8    9    /    CLEAR                     │
│  4    5    6    *                              │
│  1    2    3    -                              │
│  0    (    )    .    +    =                    │
├─────────────────────────────────────────────────┤
│ Conversiones:  Modos:     Hex:                 │
│ →BIN →OCT     BIN OCT    A B C                  │
│ →HEX →BCD     HEX DEC    D E F                  │
│ →DEC                                            │
└─────────────────────────────────────────────────┘
```

### **Ejemplos de Uso**

#### **Operaciones Básicas**
```
Entrada: 2 + 3 * 4
Resultado: 14

Entrada: (5 + 3) * 2
Resultado: 16
```

#### **Funciones Científicas**
```
Entrada: sin(30)
Resultado: 0.5

Entrada: sqrt(16)
Resultado: 4

Entrada: log(100)
Resultado: 2
```

#### **Conversiones de Base**
```
1. Ingresa: 255
2. Presiona: →HEX
3. Resultado: FF

1. Ingresa: 1010
2. Selecciona modo: BIN
3. Presiona: →DEC
4. Resultado: 10
```

### **Flujo de Operaciones Continuas**
```
Paso 1: 10 + 5 = 15
Paso 2: * 2 = 30      (usa resultado anterior)
Paso 3: - 5 = 25      (usa resultado anterior)
```

## 🎯 Funcionalidades

### **Operadores Matemáticos**
| Símbolo | Operación | Ejemplo |
|---------|-----------|---------|
| `+` | Suma | `5 + 3 = 8` |
| `-` | Resta | `10 - 4 = 6` |
| `*` | Multiplicación | `3 * 7 = 21` |
| `/` | División | `15 / 3 = 5` |
| `()` | Paréntesis | `(2 + 3) * 4 = 20` |

### **Funciones Científicas**
| Función | Descripción | Rango/Notas |
|---------|-------------|-------------|
| `sin(x)` | Seno | x en grados |
| `cos(x)` | Coseno | x en grados |
| `tan(x)` | Tangente | x en grados |
| `log(x)` | Logaritmo base 10 | x > 0 |
| `ln(x)` | Logaritmo natural | x > 0 |
| `sqrt(x)` | Raíz cuadrada | x ≥ 0 |

### **Sistemas Numéricos**
| Base | Nombre | Dígitos | Ejemplo |
|------|--------|---------|---------|
| 2 | Binario | 0, 1 | `1010` = 10₁₀ |
| 8 | Octal | 0-7 | `377` = 255₁₀ |
| 10 | Decimal | 0-9 | `255` |
| 16 | Hexadecimal | 0-9, A-F | `FF` = 255₁₀ |

### **Modos de Entrada**
- **DEC**: Modo decimal (predeterminado)
- **BIN**: Solo acepta 0 y 1
- **OCT**: Solo acepta 0-7
- **HEX**: Acepta 0-9 y A-F

## 🏗️ Arquitectura

### **Estructura del Proyecto**
```
Assembler86Calculator/
├── CALCULATOR.ASM      # Módulo principal (UI y lógica)
├── CALCULATOR.RC       # Recursos de interfaz (diálogos)
├── MATHCORE.ASM        # Motor matemático (FPULIB)
├── CONSTANTS.INC       # Constantes globales
├── compile.bat         # Script de compilación
├── calculator.exe      # Ejecutable compilado
└── README.md          # Este archivo
```

### **Módulos Principales**

#### **CALCULATOR.ASM**
- **DlgProc**: Procedimiento principal del diálogo
- **Sistema de memoria**: Operaciones continuas
- **Conversiones de base**: Algoritmos de conversión
- **Validación de entrada**: Por tipo de base numérica

#### **MATHCORE.ASM**
- **EvaluateExpression**: Parser y evaluador de expresiones
- **FPULIB Integration**: Funciones matemáticas avanzadas
- **Manejo de errores**: División por cero, sintaxis

#### **CALCULATOR.RC**
- **Definición de diálogo**: Layout de controles
- **Recursos de cadenas**: Textos de interfaz
- **Estilos y posicionamiento**: Diseño visual

### **Flujo de Datos**
```
[Entrada Usuario] → [Validación] → [Parser] → [FPU/ALU] → [Formato] → [Display]
                                     ↓
[Conversión Base] ← [Algoritmos] ← [Memoria] ← [Resultado]
```

## 📚 Documentación Técnica

### **Variables Globales Principales**
```assembly
szInputBuffer      db 265 dup (?)     ; Buffer de entrada
szDisplayBuffer    db 265 dup (?)     ; Buffer de visualización  
last_result        real8 ?            ; Último resultado (memoria)
calculator_state   dd ?               ; Estado de calculadora
current_base       dd ?               ; Base numérica actual
input_mode         dd ?               ; Modo de entrada activo
```

### **Estados de la Calculadora**
```assembly
CALC_STATE_NEW      equ 0   ; Nueva operación
CALC_STATE_RESULT   equ 1   ; Mostrando resultado
CALC_STATE_OPERATOR equ 2   ; Esperando operando
CALC_STATE_ERROR    equ 3   ; Estado de error
```

### **Precisión Matemática**
- **Enteros**: 32 bits (±2,147,483,647)
- **Punto flotante**: 80 bits IEEE 754 (FPU x87)
- **Precisión decimal**: ~19 dígitos significativos

## 🐛 Solución de Problemas

### **Problemas Comunes**

#### **Error: "No se puede ejecutar"**
```
Causa: Falta MASM32 runtime
Solución: Instalar Visual C++ Redistributable
```

#### **Error: "Sintaxis incorrecta"**
```
Causa: Expresión mal formada
Ejemplos válidos:
  ✓ sin(30)
  ✓ (2+3)*4
  ✗ sin30      (falta paréntesis)
  ✗ 2++3       (operador doble)
```

#### **Error de conversión de base**
```
Causa: Dígito inválido para la base
Solución: Verificar modo activo
  BIN: solo 0,1
  OCT: solo 0-7
  HEX: solo 0-9,A-F
```

### **Logs y Depuración**
- **Barra de estado**: Muestra estado actual
- **Campo de entrada**: Valida entrada en tiempo real
- **Mensajes de error**: En campo de resultado

## 🤝 Contribuir

### **Cómo Contribuir**
1. **Fork** el repositorio
2. **Crear rama** para nueva característica: `git checkout -b feature/nueva-funcion`
3. **Commit** cambios: `git commit -am 'Agregar nueva función'`
4. **Push** a la rama: `git push origin feature/nueva-funcion`  
5. **Pull Request** al repositorio principal

### **Estándares de Código**
- **Comentarios**: En español, descriptivos
- **Convenciones**: CamelCase para funciones, MAYÚSCULAS para constantes
- **Documentación**: Actualizar README para nuevas características

### **Areas de Mejora**
- [ ] Soporte para números complejos
- [ ] Más funciones trigonométricas (sec, csc, cot)
- [ ] Gráficas de funciones
- [ ] Historial de operaciones
- [ ] Temas de interfaz personalizables
- [ ] Soporte para bases numéricas personalizadas

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **Jos3phil** - *Desarrollo principal* - [GitHub](https://github.com/Jos3phil)

## 🙏 Agradecimientos

- **Raymond Filiatreault** - FPULIB (librería de funciones matemáticas)
- **Microsoft** - MASM32 SDK y documentación Win32 API
- **Comunidad Assembly** - Recursos y tutoriales

## 📞 Soporte

¿Tienes preguntas o problemas?

- **Issues**: [GitHub Issues](https://github.com/Jos3phil/CalculadoraAssemblerx86/issues)
- **Documentación**: Ver `informe.md` para análisis técnico detallado
- **Email**: [Contacto del desarrollador]

---

**¡Desarrollado con ❤️ en Assembly x86!**

*"Donde cada bit cuenta y cada instrucción importa"*
