# Guía para Testers — KabboLike Demo

Gracias por probar KabboLike. Este documento explica cómo jugar y qué probar.

---

## Controles

| Input | Acción |
|---|---|
| **Click izquierdo** | Caminar (exploración) / Colocar o seleccionar mueble (decoración) |
| **Tab** | Alternar modo exploración ↔ decoración |
| **Enter** | Abrir input de chat / Enviar mensaje |
| **Escape** | Cerrar panel activo → Abrir/cerrar menú pausa |
| **S** | Guardar partida |
| **L** | Cargar última partida guardada |
| **B** | Abrir/cerrar tienda |
| **H** | Abrir tutorial/ayuda |
| **O** | Abrir configuración |
| **1 / 2 / 3** | Seleccionar Silla / Mesa / Sofá (solo en modo decoración) |
| **M** | Mover mueble seleccionado |
| **R** | Rotar mueble seleccionado |
| **Delete** | Eliminar mueble seleccionado |
| **F1** | Ir al Lobby |
| **F2** | Ir a Sala pequeña |
| **F3** | Ir a Sala grande |
| **WASD / Flechas** | Mover cámara |
| **Rueda del ratón** | Zoom |

---

## Flujo básico para probar

### 1. Arranque
- El juego debe abrir en el menú principal.
- Probar los botones: Entrar al hotel, Perfil, Configuración.

### 2. Selector de salas
- Entrar al **Lobby** (hay un NPC Bot Guía).
- Entrar a **Sala pequeña** y **Sala grande**.
- Volver al selector con el botón "Volver a salas" o desde el menú pausa.

### 3. Exploración (modo por defecto)
- Hacer click en tiles libres para caminar.
- Hablar con el NPC: presionar Enter y escribir "hola", "ayuda" o "salas".
- Intentar abrir pausa con Escape.

### 4. Decoración (Tab para activar)
- Activar modo decoración con Tab o el botón "Decorar".
- Seleccionar un mueble del catálogo o con 1/2/3.
- Colocar el mueble haciendo click en un tile válido.
- Seleccionar un mueble ya colocado → abre el inspector.
  - Probar Mover, Rotar, Eliminar desde el inspector o con M/R/Delete.
- Colocar una alfombra y un mueble encima → debe aparecer selector de objetos.

### 5. Tienda
- Abrir tienda con B o el botón "Tienda".
- Comprar un item (necesitas créditos; completa misiones para ganarlos).
- Verificar que el stock aparece en el catálogo (xN) y que se puede colocar.
- Verificar que al eliminar el mueble, la unidad se devuelve al inventario.

### 6. Misiones y créditos
- Al completar acciones (caminar, colocar, guardar) aparecen toasts de misión.
- Los créditos ganados aparecen en la barra inferior.

### 7. Guardar y cargar
- Guardar con S → toast "Sala guardada".
- Salir al menú principal y volver → la sala debe estar igual.
- Cargar con L → restaura la última partida guardada.

### 8. Configuración (O o botón Config)
- Probar autosave ON/OFF.
- Cambiar intervalo de autosave.
- Ocultar misiones.
- Reiniciar tutorial.
- Resetear datos locales (pide confirmación).

### 9. Menú pausa (Escape o botón Menu)
- Continuar: vuelve al juego.
- Guardar ahora: guarda inmediatamente.
- Configuración: abre panel de config.
- Volver a salas: guarda y va al selector.
- Salir al menú principal: pide confirmación.

---

## Cómo reportar un bug

Por favor incluye:

1. **Captura de pantalla o vídeo** del problema.
2. **Pasos para reproducir**:
   - Ejemplo: "1. Abrir Lobby → 2. Activar decoración → 3. Seleccionar Silla → 4. Click en tile (3,3) → crash"
3. **Qué esperabas** que ocurriera.
4. **Qué ocurrió** realmente.
5. **Contexto**:
   - ¿Ocurrió en el editor de Godot o en el `.exe`?
   - ¿Había datos guardados previos?
   - ¿Número de muebles colocados aproximadamente?

---

## Notas conocidas

- Reset de datos requiere cerrar y abrir el juego para que tenga efecto completo.
- El tutorial aparece solo la primera vez; se puede reabrir con H o desde Configuración.
- El Bot Guía solo aparece en el Lobby.
