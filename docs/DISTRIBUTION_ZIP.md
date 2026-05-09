# Distribución del ZIP — Kabbo Hotel v0.1.0-demo

Guía para preparar y entregar el build de Windows a testers externos.

---

## Contenido del ZIP

Después de exportar (ver [EXPORT_WINDOWS.md](EXPORT_WINDOWS.md)), la carpeta `build/windows/` contiene:

| Archivo | Descripción |
|---|---|
| `KabboLike.exe` | Ejecutable principal |
| `KabboLike.pck` | Datos del juego (si embed_pck=false) |

> Si `binary_format/embed_pck=true`, el `.pck` queda dentro del `.exe` y no es necesario incluirlo por separado.

---

## Pasos para crear el ZIP

1. Exportar el proyecto: `Project → Export → Windows Desktop → Export Project`
2. Verificar que `build/windows/KabboLike.exe` existe y arranca sin Godot instalado.
3. Comprimir la carpeta `build/windows/` en un ZIP:

```
KabboHotel_v0.1.0-demo_windows.zip
└── KabboLike.exe
└── KabboLike.pck   (si aplica)
```

4. Incluir opcionalmente `docs/TESTER_GUIDE.md` como `README_TESTER.txt` dentro del ZIP.

---

## Checklist antes de distribuir

- [ ] El `.exe` abre sin Godot instalado en una máquina limpia.
- [ ] Inicia en el menú principal (muestra "Kabbo Hotel" + versión).
- [ ] Splash screen aparece brevemente y desaparece.
- [ ] Botón "Acerca de" muestra el panel con créditos y versión correcta.
- [ ] Todos los sistemas del QA_CHECKLIST pasan.
- [ ] El ZIP no contiene rutas absolutas ni archivos del editor.

---

## Datos guardados

Los datos del jugador se guardan en:

```
%APPDATA%\Godot\app_userdata\KabboLike\
```

No se incluyen en el ZIP. Cada tester parte desde cero.
