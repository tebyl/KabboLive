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
