# 🚀 Inicio Rápido - Calculadora Científica Assembly x86

## ⚡ Ejecución Inmediata

### **Opción 1: Ejecutable Pre-compilado**
```bash
# Simplemente ejecuta:
calculator.exe
```

### **Opción 2: Compilar desde Código**
```bash
# Ejecuta el script de compilación:
compile.bat
```

## 📋 Requerimientos Mínimos

- ✅ **Windows 10/11** (o Windows 7+)
- ✅ **5 MB** de espacio libre
- ✅ **MASM32 SDK** (solo para compilar)

## 🎯 Guía de 5 Minutos

### **1. Operaciones Básicas**
```
Ingresa: 2 + 3 * 4
Presiona: = 
Resultado: 14
```

### **2. Funciones Científicas**  
```
Ingresa: sin(30)
Presiona: =
Resultado: 0.5
```

### **3. Conversiones de Base**
```
Ingresa: 255
Presiona: →HEX
Resultado: FF
```

### **4. Operaciones Continuas**
```
Paso 1: 10 + 5 = 15
Paso 2: * 2 = 30    (usa resultado anterior)
```

## 🛠️ Si Quieres Compilar

### **Instalar MASM32** (una sola vez)
1. Descargar de: http://www.masm32.com/
2. Instalar en: `C:\masm32\`
3. Ejecutar: `compile.bat`

### **Compilación Manual**
```batch
C:\masm32\bin\rc.exe /v CALCULATOR.RC
C:\masm32\bin\ml.exe /c /coff /Cp /nologo CALCULATOR.ASM  
C:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /OUT:calculator.exe CALCULATOR.obj CALCULATOR.res
```

## 🎮 Controles de la Interfaz

| Botón | Función |
|-------|---------|
| **0-9** | Dígitos numéricos |
| **+ - * /** | Operadores básicos |
| **SIN COS TAN** | Funciones trigonométricas |
| **LOG LN SQRT** | Funciones logarítmicas y raíz |
| **( )** | Paréntesis para agrupación |
| **=** | Calcular resultado |
| **C** | Limpiar todo |

| Conversión | Función |
|------------|---------|
| **→BIN** | Convertir a binario |
| **→OCT** | Convertir a octal |
| **→HEX** | Convertir a hexadecimal |
| **→DEC** | Convertir a decimal |

| Modo | Dígitos Permitidos |
|------|-------------------|
| **DEC** | 0-9, . |
| **BIN** | 0, 1 |
| **OCT** | 0-7 |
| **HEX** | 0-9, A-F |

## 🎯 Ejemplos Rápidos

### **Matemáticas Básicas**
- `2 + 3 = 5`
- `10 - 4 = 6`
- `3 * 7 = 21`
- `15 / 3 = 5`
- `(2 + 3) * 4 = 20`

### **Funciones Científicas**
- `sin(30) = 0.5`
- `cos(60) = 0.5`
- `tan(45) = 1`
- `log(100) = 2`
- `ln(2.718) = 1`
- `sqrt(16) = 4`

### **Conversiones**
- `255 →HEX = FF`
- `1010 (BIN) →DEC = 10`
- `377 (OCT) →DEC = 255`
- `FF (HEX) →DEC = 255`

## ❗ Problemas Comunes

### **No se ejecuta calculator.exe**
```
Causa: Falta runtime de Visual C++
Solución: Descargar Visual C++ Redistributable
```

### **Error al compilar**
```
Causa: MASM32 no instalado o ruta incorrecta
Solución: Instalar MASM32 en C:\masm32\
```

### **Sintaxis incorrecta**  
```
✅ Correcto: sin(30), (2+3)*4
❌ Incorrecto: sin30, 2++3
```

## 📞 ¿Necesitas Ayuda?

- 📖 **README completo**: `README.md`
- 🔧 **Informe técnico**: `informe.md`
- 🐛 **Reportar problemas**: GitHub Issues
- 💡 **Sugerencias**: GitHub Discussions

---

**¡Disfruta calculando con Assembly x86! 🧮**
