Aquí tienes el documento de contexto definitivo, unificado y perfectamente estructurado para que se lo pases a cualquier IA (o desarrollador) y entienda el proyecto al 100% desde el primer segundo.

Tiene toda la información técnica, las herramientas que usas, la arquitectura y los enlaces que definimos. Solo cópialo y pégalo.

---

# Documento de Contexto del Proyecto: Prism Launcher para iPadOS (Apple Silicon)

## 1. Visión General del Proyecto

El objetivo es crear un fork moderno de **Prism Launcher** optimizado y adaptado específicamente para **iPadOS con chips de la serie M (M1, M2, M4, etc.)**. El enfoque principal es permitir la ejecución nativa de versiones modernas de **Minecraft Java (Snapshots recientes de 2026 y superiores)** que ya implementan la migración oficial del motor gráfico de **OpenGL a Vulkan**.

A diferencia de launchers antiguos (como PojavLauncher o el fork Amethyst), este proyecto descarta por completo la emulación de OpenGL y el mapeo arcaico de mandos (que traduce joysticks a teclas virtuales), ofreciendo en su lugar un **bypass directo de inputs** para que los mods de interfaz de consola (*Controlify*, *Controllable*) detecten los mandos nativamente.

## 2. Entorno de Ejecución (Target)

El desarrollo y testeo se realiza en un **iPad M1 (8 GB de RAM)** utilizando el siguiente stack de bypass de restricciones de Apple:

* **SideStore + LiveContainer:** Permite la instalación de la app sin las restricciones severas del sandbox tradicional de iOS.
* **Extended RAM Entitlement:** Rompe el límite estándar de 3 GB de RAM de iPadOS, permitiendo asignar entre 4 GB y 5.5 GB de RAM dedicados exclusivamente a la Máquina Virtual de Java (JVM).
* **StikJit / StikDebug:** Habilita de forma inalámbrica la compilación **JIT (Just-In-Time)**, permitiendo que la JVM ejecute el juego a máximo rendimiento (Apple Silicon nativo).

## 3. Arquitectura por Módulos y Repositorios Base

Para acelerar el desarrollo del MVP (Producto Mínimo Viable), el proyecto reutilizará código maduro de la comunidad en lugar de reinventar la rueda:

### A. Core del Launcher y Gestión de Instancias

Se utilizará como base el código de **Prism Launcher**. Manejará la creación de perfiles, el aislamiento de instancias y la descarga directa de modpacks desde Modrinth y CurseForge.

* *Repositorio Base:* [https://github.com/PrismLauncher/PrismLauncher](https://github.com/PrismLauncher/PrismLauncher)

### B. Módulo de Autenticación (Microsoft OAuth)

Para evitar lidiar desde cero con el flujo complejo de tokens de Xbox Live y perfiles de Mojang, se extraerá y adaptará el módulo de inicio de sesión seguro (`MicrosoftAuthenticator` / `AccountManager`) de **PojavLauncher / Amethyst**.

* *Repositorio Base:* [https://github.com/PojavLauncherTeam/PojavLauncher-iOS](https://www.google.com/search?q=https://github.com/PojavLauncherTeam/PojavLauncher-iOS)

### C. Runtime de Java (JVM)

Se descartan las builds de Java modificadas para teléfonos antiguos. Dado que el iPad M comparte arquitectura con las Macs, se utilizará una build limpia de **OpenJDK 17/21 (ARM64)** de **Eclipse Temurin (Adoptium)**, eliminando las dependencias de escritorio de macOS (`AppKit`) y re-enlazándola con el SDK de iPadOS (`Foundation` y `libSystem`).

* *Repositorio Base:* [https://github.com/adoptium/temurin-build](https://github.com/adoptium/temurin-build)
* *Binarios Oficiales:* [https://adoptium.net/](https://adoptium.net/)

### D. Capa Gráfica (Vulkan a Metal)

Aprovechando que el juego moderno corre en Vulkan (o mediante *VulkanMod*), se utilizará **MoltenVK** para traducir en tiempo real las llamadas de Vulkan a la API nativa **Metal** de Apple Silicon, volcando el buffer de imagen sobre un `CAMetalLayer` en iPadOS.

* *Repositorio Base:* [https://github.com/KhronosGroup/MoltenVK](https://github.com/KhronosGroup/MoltenVK)

## 4. El Core de la Innovación: Bypass Nativo de Mandos

Los launchers previos asignan botones táctiles o teclas del teclado a los botones del mando. Este proyecto implementará un **Bypass directo en GLFW (dentro de LWJGL)**:

1. La capa nativa de la app en iPadOS captura los mandos (Xbox, DualSense, etc.) vía el framework **`GameController`** de Apple.
2. Se modifica el código en C++ de GLFW para iOS. En lugar de retornar que no hay gamepads, se llena la estructura interna `GLFWgamepadstate` con los ejes analógicos y estados de los botones del mando físico en tiempo real.
3. La JVM recibe estos datos transparentemente. Para Minecraft y mods como **Controlify**, el iPad es invisible: creen que están corriendo en una PC con un mando de Xbox real conectado por USB, activando nativamente las interfaces de consola, vibración y configuraciones internas.

## 5. Flujo de Datos Unificado

```
[Mando Bluetooth] -> [GameController Framework] -> [Bypass en GLFW (C++)] -> [Mods de Java (Controlify)]
                                                                                     |
[Pantalla iPad]  <- [CAMetalLayer (Metal)]       <- [MoltenVK]             <- [VulkanMod / Juego Base]

```

---

*Instrucciones para la IA: Utiliza este contexto técnico para generar guías de compilación, lógica de código en C++/Objective-C++ para las modificaciones de GLFW, scripts de automatización de argumentos de la JVM (`-XX:CompileCommand`, `-Dapple.awt.UIElement=true`), o diseño de la arquitectura del fork de Prism Launcher.*

---

# Reporte de Estado del Proyecto: Ametrine Launcher (2026)

Este reporte detalla el progreso actual del desarrollo, las configuraciones establecidas, los pendientes prioritarios, y los problemas técnicos a solucionar para la compilación y ejecución de Ametrine Launcher en iPadOS.

## 1. Avances y Tareas Completadas (Cosas Hechas)

*   **Inicialización del Repositorio Local**: Se inicializó el control de versiones con Git estableciendo la rama base `main` en la carpeta raíz `/home/ackb/Pictures/MC`.
*   **Creación de la Configuración del Compilador**: Se desarrolló el archivo [CMakeLists.txt](file:///home/ackb/Pictures/MC/CMakeLists.txt) configurado especialmente para la compilación cruzada hacia iOS, integrando Qt 6 y los frameworks nativos de Apple (`UIKit`, `GameController`, `Metal`).
*   **Workflow de Compilación en la Nube**: Se diseñó el workflow de GitHub Actions [build-ios.yml](file:///home/ackb/Pictures/MC/.github/workflows/build-ios.yml) que automatiza la compilación en runners virtuales de macOS, la instalación del SDK de Qt para iOS, el pseudo-firmado de seguridad y el empaquetado del artefacto ejecutable `.ipa`.
*   **Configuración del Bundle de iOS**: Se implementó el archivo de manifiesto [Info.plist](file:///home/ackb/Pictures/MC/src/Info.plist) que declara el soporte nativo para mandos de videojuegos (`GCSupportedGamepads`) y solicita los privilegios de RAM extendida requeridos para SideStore.
*   **Código de Entrada Inicial y Stubs**:
    *   [main.mm](file:///home/ackb/Pictures/MC/src/main.mm): Punto de entrada nativo Objective-C++ que combina el ciclo de vida de UIKit de iPadOS y la inicialización de la interfaz de usuario en Qt.
    *   [glfw_bypass.cpp](file:///home/ackb/Pictures/MC/src/glfw_bypass.cpp): Estructura del puente C++ para interceptar el framework `GameController` nativo de Apple y mapearlo directamente a `GLFWgamepadstate` de LWJGL.
*   **Archivo de Ignorados de Git**: Se creó el archivo [.gitignore](file:///home/ackb/Pictures/MC/.gitignore) para omitir directorios de compilación temporal y archivos de configuración del IDE.

## 2. Tareas Pendientes (Lo que Falta)

*   **Integración del Core de Prism Launcher**: Agregar el código fuente completo de Prism Launcher al proceso de CMake (o configurarlo como un submódulo Git).
*   **Implementación del Bypass de GLFW**: Escribir la lógica real de consulta en Objective-C++/C++ dentro del loop de GLFW para capturar los ejes y botones analógicos de los mandos físicos y mapearlos sin simulación de teclas de teclado.
*   **Módulo Microsoft OAuth**: Adaptar y traducir la lógica de login de Amethyst/PojavLauncher al entorno C++/Qt de Ametrine Launcher para permitir el inicio de sesión oficial con cuentas de Microsoft.
*   **Enlace de la JVM (Adoptium)**: Crear scripts de empaquetado que incrusten la build de OpenJDK 17/21 para iPadOS dentro de la carpeta Payload del archivo `.ipa`.
*   **Integración de MoltenVK**: Vincular la librería MoltenVK (`libMoltenVK.dylib`) en el archivo `.ipa` para canalizar los comandos Vulkan del juego moderno directamente a Metal en la pantalla del iPad.

## 3. Problemas Técnicas Identificados

1.  **Dependencia del Entorno en la Nube (Rendimiento Local)**: La laptop del desarrollador carece de los recursos para compilar Qt y C++ de forma nativa. Toda la compilación se delega a los macOS runners de GitHub Actions, lo que limita el tiempo de compilación mensual a los minutos gratuitos disponibles en la plataforma.
2.  **Firma y Aprovisionamiento de iOS**: Apple restringe la ejecución de código sin firmar en dispositivos iOS. El uso de `ldid` (pseudo-firmado) nos permite eludir temporalmente esto para instalaciones a través de TrollStore o SideStore, pero se requiere cuidado con los perfiles si se usa AltStore estándar.
3.  **Activación de JIT (Just-In-Time)**: iOS prohíbe la ejecución de JIT en memoria por motivos de seguridad. Para que Java corra a velocidad nativa en Apple Silicon, es necesario activar JIT inalámbricamente con herramientas como SideStore + StikJit/StikDebug. Si JIT no está activo, Minecraft Java correrá extremadamente lento (emulado) o crasheará al iniciar.

## 4. Plan de Pruebas (Test)

*   **Test del Workflow**: Realizar una primera subida al repositorio remoto de GitHub para validar que la descarga de Qt para iOS y la compilación con CMake en el entorno macOS-14 finalicen correctamente sin errores de compilación.
*   **Prueba de Sideload en iPad M1 (8GB)**: Instalar la build `.ipa` resultante en el dispositivo target mediante SideStore y habilitar el "Extended RAM Entitlement" (permitiendo asignar 4-5.5 GB de RAM).
*   **Verificación JIT**: Arrancar la JVM a través de StikJit y confirmar mediante consola que JIT está activo y optimizando el bytecode de Java.
*   **Prueba de Mandos Bluetooth**: Conectar un mando Bluetooth (DualSense o Xbox) al iPad, iniciar una versión moderna de Minecraft con el mod Controlify y verificar si el juego detecta el mando físico sin configurar controles virtuales táctiles.

## 5. Parámetros y Configuraciones Técnicas Recomendadas

Para el correcto funcionamiento de la JVM de Java en iPadOS, se proponen las siguientes flags de ejecución:
*   `-XX:CompileCommand=exclude,org/lwjgl/*`: Evita fallos de optimización JIT causados por la capa GLFW en iOS.
*   `-Dapple.awt.UIElement=true`: Deshabilita los elementos visuales heredados de AWT (macOS Desktop) que provocarían fallos inmediatos al iniciar en iPadOS.
*   `-Xmx4G` o `-Xmx5120M`: Asignación de RAM máxima permitida gracias a las propiedades añadidas en el [Info.plist](file:///home/ackb/Pictures/MC/src/Info.plist).