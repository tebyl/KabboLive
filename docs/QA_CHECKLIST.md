# QA Checklist — Kabbo Hotel (MVP 31)

## Archivos de datos de usuario (`user://`)

| Archivo | Contenido |
|---|---|
| `rooms_save.json` | Muebles de cada sala |
| `currency_state.json` | Créditos del jugador |
| `shop_state.json` | Items comprados en tienda |
| `furniture_stock_state.json` | Unidades en inventario (items de tienda) |
| `missions_state.json` | Progreso de misiones |
| `tutorial_state.json` | Si el tutorial fue completado |
| `player_profile.json` | Nombre y color del avatar |
| `settings_state.json` | Preferencias (autosave, misiones) |

**Cómo resetear datos locales:**
- Desde el juego: Configuración → Resetear datos locales → Confirmar → reiniciar Godot.
- Manualmente: borrar los archivos listados en `%APPDATA%/Godot/app_userdata/<proyecto>/`.

---

## Controles principales

| Tecla | Acción |
|---|---|
| Click izquierdo | Mover avatar (exploración) / Colocar mueble o seleccionar (decoración) |
| 1 / 2 / 3 | Seleccionar Silla / Mesa / Sofá (solo decoración) |
| Tab | Cambiar entre exploración y decoración |
| M | Mover mueble seleccionado (decoración) |
| R | Rotar mueble seleccionado (decoración) |
| Delete | Eliminar mueble seleccionado (decoración) |
| Enter | Abrir/enviar chat |
| Escape | Cancelar submodo → Cerrar panel prioritario → Abrir/cerrar menú pausa |
| S | Guardar manualmente |
| L | Cargar desde disco |
| B | Abrir/cerrar tienda |
| H | Abrir tutorial |
| O | Abrir configuración |
| F1 / F2 / F3 | Cambiar a Lobby / Sala pequeña / Sala grande |
| WASD / Flechas | Mover cámara |
| Rueda ratón | Zoom |

---

## Checklist de sistemas

### 1. Arranque
- [ ] Abre en menú principal
- [ ] NPC no activo antes de entrar al Lobby
- [ ] No hay catálogo/inspector/previews visibles en menú
- [ ] Sin warnings ni parse errors en consola

### 2. Menú principal
- [ ] "Entrar al hotel" → selector de salas
- [ ] "Perfil" → panel de perfil
- [ ] "Configuración" → panel de configuración con valores actuales

### 3. Selector de salas
- [ ] Lobby, Sala pequeña, Sala grande funcionan
- [ ] Volver al menú principal desde selector
- [ ] Entrar a sala → modo exploración por defecto

### 4. Modo exploración
- [ ] Click en tile libre mueve avatar
- [ ] 1/2/3/M/R/Delete no activan decoración
- [ ] Enter abre chat
- [ ] B abre tienda
- [ ] H abre tutorial
- [ ] Escape abre menú pausa (si no hay panel abierto)

### 5. Modo decoración (Tab para activar)
- [ ] Catálogo aparece
- [ ] 1/2/3 seleccionan mueble
- [ ] Preview verde/roja aparece al mover mouse
- [ ] Click válido coloca mueble
- [ ] Click inválido muestra toast de error
- [ ] Click en mueble abre inspector
- [ ] Alfombra + silla superpuestas → abre selector de objetos
- [ ] M / R / Delete funcionan desde inspector y teclado
- [ ] Tab vuelve a exploración, catálogo se oculta

### 6. Prioridad de Escape
- [ ] Chat activo → Escape cancela chat (no abre pausa)
- [ ] Configuración abierta → Escape cierra config
- [ ] Tienda abierta → Escape cierra tienda
- [ ] Tutorial abierto → Escape no hace nada fuera del tutorial
- [ ] Selector superpuestos → Escape lo cierra
- [ ] Modo mover/colocar activo → Escape cancela submodo
- [ ] Menú pausa abierto → Escape lo cierra
- [ ] Ningún panel → Escape abre menú pausa

### 7. Menú pausa
- [ ] Continuar → cierra pausa, vuelve al modo anterior
- [ ] Guardar ahora → guarda y muestra toast "Partida guardada"
- [ ] Configuración → cierra pausa, abre config con valores reales
- [ ] Volver a salas → guarda si hay dirty, va a selector
- [ ] Salir al menú principal → muestra confirmación
  - [ ] Cancelar → vuelve al menú pausa
  - [ ] Salir → guarda, va al menú principal, NPC desaparece

### 8. Configuración
- [ ] Autosave ON/OFF persiste
- [ ] Intervalo 30/60/120s persiste
- [ ] Mostrar/ocultar misiones funciona (no borra progreso)
- [ ] Reiniciar tutorial → tutorial aparece al abrir sala
- [ ] Resetear datos → confirmación → borra archivos
- [ ] Configuración bloquea gameplay; al cerrar, input vuelve normal

### 9. Tutorial
- [ ] Aparece solo la primera vez
- [ ] Se puede abrir con H / botón Ayuda
- [ ] Siguiente / Anterior / Omitir / Finalizar funcionan
- [ ] Bloquea gameplay mientras está abierto

### 10. Misiones y créditos
- [ ] Misión "primer paso" → se completa una sola vez
- [ ] Misión "colocar mueble" → una sola vez
- [ ] Misión "guardar sala" → una sola vez
- [ ] Créditos se suman correctamente
- [ ] Misiones visibles/ocultas según configuración

### 11. Tienda y stock
- [ ] Comprar descuenta créditos
- [ ] Comprar suma 1 unidad al stock del item
- [ ] Comprar varias veces acumula unidades
- [ ] Stock persiste entre sesiones
- [ ] Catálogo muestra `xN` para items de tienda y `∞` para base
- [ ] Item con stock 0 aparece atenuado y no se puede seleccionar
- [ ] Colocar item limitado consume 1 unidad
- [ ] Eliminar item limitado devuelve 1 unidad
- [ ] Mover/rotar NO cambia stock
- [ ] Sin créditos → toast "Créditos insuficientes"

### 12. Catálogo
- [ ] Pestañas de categoría funcionan
- [ ] Items base siempre visibles (∞)
- [ ] Items de tienda muestran stock actual
- [ ] Resaltado se limpia al cancelar o salir de decoración

### 13. Inspector de muebles
- [ ] Nombre, posición, tamaño, capa correctos
- [ ] Bloquea paso: Sí/No correcto
- [ ] Botones Mover / Rotar / Eliminar / Cerrar funcionan
- [ ] Se oculta al cambiar sala, cargar, abrir pausa/config/tutorial

### 14. Selector de objetos superpuestos
- [ ] Alfombra + mueble encima → selector aparece
- [ ] Seleccionar objeto → abre inspector correcto
- [ ] Escape / Cerrar → cierra selector
- [ ] Cambiar sala / cargar → cierra selector automáticamente

### 15. Previews
- [ ] Preview verde = posición válida, roja = inválida
- [ ] Se ocultan al abrir chat, tienda, config, pausa, tutorial
- [ ] No quedan nodos fantasma al cambiar sala

### 16. Capas y pathfinding
- [ ] Alfombra no bloquea movimiento
- [ ] Silla/mesa/sofá/planta bloquean
- [ ] Silla sobre alfombra: permitido
- [ ] Alfombra sobre alfombra: impedido
- [ ] Avatar camina sobre alfombra
- [ ] NPC no pisa muebles bloqueantes

### 17. NPC (Bot Guía)
- [ ] Solo visible en Lobby
- [ ] Desaparece al cambiar sala
- [ ] Bloquea su celda al estar activo
- [ ] Responde "hola", "ayuda", "salas"
- [ ] Burbuja sigue su posición

### 18. Chat
- [ ] Enter abre input
- [ ] Enter envía mensaje
- [ ] Escape cancela sin enviar
- [ ] Mensaje vacío no se envía
- [ ] Chat activo bloquea cámara y edición

### 19. Perfil
- [ ] Cambiar nombre → persiste
- [ ] Cambiar color → avatar actualiza
- [ ] Chat usa nombre del perfil

### 20. Guardado manual (S) y carga (L)
- [ ] S guarda y limpia dirty / timer autosave
- [ ] L carga correctamente y no dispara autosave
- [ ] Cambiar sala guarda silenciosamente si hay cambios
- [ ] Volver a salas guarda si hay cambios

### 21. Cámara
- [ ] WASD / flechas mueven cámara en sala
- [ ] Zoom con rueda funciona
- [ ] Cámara no se mueve con menú pausa / config / tutorial abiertos
- [ ] Centrar al cambiar sala

### 22. Compatibilidad con archivos viejos / corruptos
- [ ] Sin `rooms_save.json` → sala carga con muebles por defecto
- [ ] Sin `furniture_stock_state.json` → stock vacío, sin crash
- [ ] `settings_state.json` corrupto → usa defaults
- [ ] `player_profile.json` corrupto → usa nombre/color por defecto

---

## QA Pre-Steam / Identidad (MVP 33)

### 23. Splash screen
- [ ] Aparece al arrancar el juego (~1s) con "Kabbo Hotel" + "Cargando demo local..."
- [ ] Desaparece automáticamente y muestra el menú principal
- [ ] No bloquea entrada después de desaparecer

### 24. Menú principal — identidad
- [ ] Título "Kabbo Hotel" visible en fuente grande
- [ ] Versión "v0.1.0-demo" visible debajo del título en color secundario
- [ ] Botón "Acerca de" presente

### 25. Panel "Acerca de"
- [ ] Se abre desde el botón "Acerca de" en menú principal
- [ ] Muestra título, versión, descripción, estado y créditos
- [ ] Botón "Cerrar" cierra el panel
- [ ] Escape cierra el panel (sin abrir menú pausa)
- [ ] El panel bloquea clicks al fondo mientras está abierto
- [ ] Cambiar a sala oculta el panel correctamente

### 26. Lobby decorado — primera entrada (MVP 35)
- [ ] Al abrir el juego sin guardado previo, el Lobby tiene muebles precolocados:
  - [ ] Alfombras en zona central (6 tiles)
  - [ ] Sofá, dos sillas y una mesa en zona de descanso
  - [ ] Plantas decorativas en laterales
- [ ] El NPC Bot Guía aparece en el Lobby (no bloqueado por ningún mueble)
- [ ] Al entrar al Lobby por primera vez, el NPC muestra burbuja de bienvenida tras ~1s
- [ ] Mensaje exacto: "¡Bienvenido a Kabbo Hotel! Usa Tab para decorar o haz click para caminar."
- [ ] El mensaje aparece también en el historial de chat
- [ ] El avatar del jugador puede caminar por el Lobby (pathfinding correcto)
- [ ] Las alfombras NO bloquean el paso del avatar ni del NPC
- [ ] Los muebles (sofá, sillas, mesa, plantas) SÍ bloquean el paso

### 27. Persistencia y primera sesión vs sesión con guardado (MVP 35)
- [ ] Al guardar (S) y reiniciar el juego → los muebles del usuario se restauran automáticamente
- [ ] Al reiniciar sin guardar → el Lobby vuelve al layout inicial decorado
- [ ] Si existe `rooms_save.json`, NO aparece el mensaje de bienvenida del NPC
- [ ] Si NO existe `rooms_save.json`, SÍ aparece el mensaje de bienvenida del NPC
- [ ] El stock del inventario NO se consume por los muebles iniciales del Lobby
- [ ] Guardar (S) después de la primera entrada guarda el estado actual correctamente
- [ ] Eliminar muebles del layout inicial y guardar → no vuelven al reiniciar

### 28. UI demo compacta — modo exploración (MVP 36)
- [ ] Al entrar a sala, barra inferior muestra solo: sala · créditos · Decorar · Tienda(oculta) · ? · Menú
- [ ] Hint inferior dice: "Click para caminar · Enter chat · Tab decorar · Esc menú"
- [ ] Botón Tienda NO visible en exploración
- [ ] Panel de misiones muestra solo el primer objetivo pendiente (no lista completa)
- [ ] Si todas las misiones están completas, muestra "✓ Misiones iniciales completas"
- [ ] El panel de misiones no tiene título "Misiones" redundante
- [ ] No hay lista larga de atajos en pantalla

### 29. UI demo compacta — modo decoración (MVP 36)
- [ ] Al activar decoración (Tab o botón), botón Tienda aparece
- [ ] Hint inferior dice: "Catálogo activo · Click colocar/seleccionar · Tab explorar · Esc cancelar"
- [ ] Al seleccionar un mueble del catálogo, hint cambia a: "Colocando: verde = válido · rojo = inválido · Esc cancelar"
- [ ] Al activar modo mover (M o botón inspector), hint cambia a: "Moviendo mueble: elige destino · Esc cancelar"
- [ ] Al cancelar con Esc, hint vuelve al de decoración
- [ ] Al volver a exploración, botón Tienda se oculta y hint vuelve al de exploración

### 30. UI demo compacta — chat y flujo general (MVP 36)
- [ ] Al abrir chat (Enter), hint cambia a: "Chat: escribe y presiona Enter · Esc cancelar"
- [ ] Al cerrar chat (Esc o enviar), hint vuelve al modo actual
- [ ] Botón "?" abre tutorial igual que tecla H
- [ ] Botón "Menú" abre menú de pausa igual que Esc
- [ ] Config accesible desde Menú → Configuracion (no hay botón Config permanente)
- [ ] Barra inferior es de una sola fila (no dos filas de texto)
- [ ] Toasts siguen apareciendo correctamente
- [ ] Tab, S, L, F1/F2/F3, B, H, O siguen funcionando aunque no estén visibles en pantalla

---

## QA Build Windows

Checklist para validar el `.exe` exportado (`build/windows/KabboLike.exe`):

- [ ] El `.exe` abre sin Godot instalado
- [ ] Inicia en el menú principal (no en sala interactiva)
- [ ] No hay errores críticos ni ventanas de error al arrancar
- [ ] Entrar al Lobby funciona correctamente
- [ ] Movimiento del avatar funciona
- [ ] Modo decoración funciona (catálogo visible, preview, colocación)
- [ ] Catálogo muestra items con stock correcto
- [ ] Tienda abre, permite comprar, descuenta créditos
- [ ] Chat abre con Enter, envía mensaje, bot responde en Lobby
- [ ] Guardar (S) funciona y muestra toast
- [ ] Cargar (L) restaura el estado guardado
- [ ] Cerrar el `.exe` y volver a abrirlo mantiene los datos guardados
- [ ] Reset de datos (desde Configuración) funciona y pide confirmación
- [ ] El juego no depende de archivos fuera de la carpeta del export
- [ ] No usa rutas absolutas del editor (sin crasheo por rutas `res://` externas)
- [ ] Menú pausa abre con Escape y todas sus opciones funcionan
- [ ] Configuración abre con valores actuales (no vacíos/default)
