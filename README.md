# Ametrine Launcher 🚀

**Ametrine Launcher** es un fork moderno y optimizado de **Prism Launcher** adaptado específicamente para **iPadOS con procesadores Apple Silicon (M1, M2, M4, etc.)**.

El objetivo principal es permitir la ejecución nativa de Minecraft Java en versiones modernas utilizando **MoltenVK** para la traducción gráfica a **Metal** y resolviendo las limitaciones tradicionales de los mandos físicos mediante un bypass directo en **GLFW (LWJGL)**.

---

## 🛠️ Arquitectura y Componentes

1. **Launcher Core (Prism Launcher)**: Manejo de perfiles, aislamiento de instancias y descarga de modpacks directamente de CurseForge y Modrinth.
2. **Microsoft Authentication**: Adaptación del flujo OAuth extraído de PojavLauncher/Amethyst.
3. **Máquina Virtual Java (JVM)**: OpenJDK 17/21 ARM64 nativo de Adoptium compilado con cabeceras de iPadOS.
4. **Traductor Gráfico MoltenVK**: Translación eficiente en tiempo real de llamadas Vulkan a la API nativa de Apple (Metal).
5. **Bypass de Inputs (GLFW)**: Modificación a bajo nivel de la biblioteca GLFW en C++ para que el framework `GameController` de iPadOS alimente directamente los mods Java como Controlify.

---

## 🖥️ Compilación en la Nube (GitHub Actions)

Dado que este proyecto está diseñado para compilarse en la nube debido a limitaciones de rendimiento locales, el repositorio contiene un workflow automático para **GitHub Actions**.

### Estructura de GitHub Workflows
* **Ubicación**: [`.github/workflows/build-ios.yml`](file:///.github/workflows/build-ios.yml)
* **Runner**: macOS Sonoma (`macos-14`)
* **Herramientas**: Xcode, CMake, Qt 6 para iOS (vía `install-qt-action`), `ldid`, `dpkg`.

Al ejecutarse el workflow, se compilará el launcher y generará un paquete ejecutable `.ipa` firmado mediante `ldid` (pseudo-firmado), listo para su instalación con SideStore o TrollStore.

---

## ⚙️ Configuración y Setup del Repositorio

Si acabas de clonar o iniciar este proyecto de forma local, sigue estos pasos para subirlo a tu cuenta de GitHub y comenzar a compilar:

1. **Crear el repositorio en GitHub**:
   Ingresa a [github.com/new](https://github.com/new) y crea un repositorio llamado `Ametrine-Launcher` (público o privado, no inicialices con README ni .gitignore ya que el repositorio local ya los tiene).

2. **Vincular el repositorio remoto localmente**:
   Abre una terminal en el directorio del proyecto y ejecuta:
   ```bash
   git remote add origin https://github.com/TU_USUARIO/Ametrine-Launcher.git
   git branch -M main
   ```

3. **Subir los cambios**:
   ```bash
   git add .
   git commit -m "Initial commit: Proyecto base y GitHub workflows para iOS"
   git push -u origin main
   ```

4. **Descargar tu IPA**:
   Una vez que subas el código, ve a la pestaña **Actions** en tu repositorio de GitHub, selecciona el workflow **Compile Ametrine Launcher (iOS)** y descarga el archivo `.ipa` compilado como un artefacto.

---

## 📱 Instalación en iPad

### Requisitos previos
- iPad con procesadores M1 o superior.
- **SideStore** (recomendado para usar el Extended RAM Entitlement) o **TrollStore**.
- Herramienta **StikJit** o **StikDebug** activa inalámbricamente en tu red local para habilitar el compilador Just-In-Time (JIT) de Java.

### Entitlements recomendados (SideStore)
El archivo [`Info.plist`](file:///src/Info.plist) ya incluye las llaves para solicitar la RAM extendida:
- `com.apple.developer.kernel.extended-virtual-addressing` (Habilitado)
- `com.apple.developer.increased-memory-limit` (Habilitado)
