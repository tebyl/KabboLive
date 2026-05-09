# Export Windows — KabboLike

## Versión recomendada de Godot

**Godot 4.6** (la misma versión que usa el proyecto).

Descargar en: https://godotengine.org/download/

---

## Abrir el proyecto

1. Abrir Godot 4.6.
2. En el Project Manager: **Import** → seleccionar la carpeta `kabbo-like/` → **Import & Edit**.
3. Esperar que se importe el proyecto.

---

## Instalar Export Templates

Los export templates son necesarios para generar el `.exe`.

1. Dentro del editor: **Editor** → **Manage Export Templates...**
2. En la ventana que abre: **Download and Install** (elegir la versión 4.6).
3. Esperar descarga (~500 MB).

O descargar manualmente desde:
https://godotengine.org/download/
→ Export Templates → versión 4.6

---

## Exportar para Windows

1. En el editor: **Project** → **Export...**
2. En la lista de presets debe aparecer **Windows Desktop**.
   - Si no aparece: **Add Preset** → **Windows Desktop**.
   - Confirmar que la ruta de export sea: `build/windows/KabboLike.exe`
3. Click en **Export Project**.
4. Marcar **Export with Debug** para demo local (más fácil de depurar).
5. Confirmar la ruta de salida: `build/windows/KabboLike.exe`.

### Via CLI (si Godot está en PATH)

```bash
godot --headless --export-debug "Windows Desktop" build/windows/KabboLike.exe
```

---

## Probar fuera del editor

1. Ir a la carpeta `build/windows/`.
2. Ejecutar `KabboLike.exe` directamente (no requiere Godot instalado).
3. Si aparece un error de DLL de DirectX, instalar DirectX redistributable desde Microsoft.

---

## Datos guardados — user://

En Windows, los archivos `user://` se guardan en:

```
%APPDATA%\Godot\app_userdata\KabboLike\
```

Archivos generados durante el juego:

| Archivo | Contenido |
|---|---|
| `rooms_save.json` | Muebles colocados en cada sala |
| `currency_state.json` | Créditos del jugador |
| `shop_state.json` | Items comprados |
| `furniture_stock_state.json` | Unidades en inventario |
| `missions_state.json` | Progreso de misiones |
| `tutorial_state.json` | Estado del tutorial |
| `player_profile.json` | Nombre y color de avatar |
| `settings_state.json` | Preferencias (autosave, misiones) |

---

## Resetear datos locales

**Desde el juego:**
Configuración → Resetear datos locales → Confirmar → cerrar y abrir el juego.

**Manualmente:**
Borrar todos los archivos `.json` en:
```
%APPDATA%\Godot\app_userdata\KabboLike\
```

---

## Notas

- El proyecto usa `Forward Plus` renderer (requiere GPU compatible con D3D12/Vulkan).
- Para máquinas antiguas, cambiar en `project.godot`:
  `config/features=PackedStringArray("4.6", "GL Compatibility")`
  y reexportar.
- Tamaño aproximado del export: ~50-80 MB.
