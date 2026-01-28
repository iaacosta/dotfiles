---
name: pr-builder
description: Skill to know how to build a PR description
---

# PR Builder

## Instructions

Use this guide when drafting PR descriptions so the output matches our house style.

### Template
- Follow the structure:
  1. `### Contexto`
  2. `### Qué se está haciendo` with an `**En resumen**` bullet list
  3. `### Tests más importantes que se agregan o modifican`
  4. `### Checklist de Seguridad Pre-Merge`

### Tone & Content Rules
- Context explains the *motivation* (e.g., “Pitch to make DSR contact info configurable”), not what was implemented.
- Bullets describe features/behaviour (“controllers filtran campos según la config”) rather than implementation details or method names.
- Always highlight new models/objects that were added and note supporting artifacts (serializer/factory/specs).
- Use friendly teammate wording like “agregamos” / “mejoramos”; avoid formal verbs such as “evolucionamos” or “incorpora”.
- Do not reference commit hashes unless specifically requested.
- Don’t include troubleshooting notes (e.g., “no pude correr tests”) inside the PR body.

### Tests Section
- Keep the checkbox format from the template.
- Mark non-applicable items with strike-through (e.g., `~[ ] ...~ No aplica`).

### Security Checklist
- Always include the checklist from the template.
- Check items that apply; strike through non-applicable ones with a short note (“No aplica”).

### Prompt Tip
- When asking the AI for a PR description, say: “Follow the PR template from `dev-scripts/pr_samples.md` using the guidance in `dev-scripts/ai-guides/pr_description_playbook.md`.”

### Output
Write the output to a file named `pr_description.md`, always overwrite as this file is ignored in all projects and will be used by the dev to copy paste

## Examples

### Contexto
Consorcio nos pide algunas configuraciones del DSR

### Qué se esta haciendo

**En resumen**:
- Se agrega la opción de especificar un `origin` para el DSR
- Poder especificar el estado inicial de un DSR
- Poder identificar si Soyio hizo una validación o si fue el comercio (no hay Validation Attempt)

### Tests más importantes que se agregan o modifican

- [x] Agregué tests adicionales para cubrir la nueva funcionalidad desarrollada.

- ~[ ] Agregué un nuevo flujo de UX e incluí los tests e2e correspondientes.~ No aplica

### Checklist de Seguridad Pre-Merge

Antes de solicitar la revisión, por favor, verifica que tu código cumple con los siguientes puntos clave:

- [x] Validación de Entradas: Toda entrada externa o de usuario (parámetros, formularios, APIs) es validada y sanitizada para prevenir ataques (ej. XSS, Inyección SQL).

- ~[ ] Manejo de Datos Personales, Sensibles o Confidenciales: Se evita registrar (loggear) datos personales, contraseñas o secretos. La información se maneja de forma segura y no se expone innecesariamente.~ No aplica

- [x] Errores Seguros: Los mensajes de error son genéricos y no exponen información interna del sistema (como stack traces o rutas de archivos) al usuario final.

- ~[ ] Protección de Endpoints: Toda nueva ruta o endpoint (incluyendo APIs internas) está protegida por defecto y solo concede acceso a los roles que lo requieren, aplicando el principio de mínimo privilegio.~ No aplica

- ~[ ] Gestión de Secretos: No se ha añadido ninguna credencial, clave de API o secreto directamente en el código. Se utiliza el gestor de secretos de la empresa.~ No aplica

- ~[] Nuevas Dependencias: Las dependencias externas añadidas son de fuentes confiables, se encuentran activamente mantenidas y han sido analizadas en busca de vulnerabilidades conocidas.~ No aplica

--------------------------------------------------------

### Contexto
Necesitabamos pasar la escoba con el tema del user reference 

### Qué se esta haciendo

**En resumen**:
- Se corrige un escenario forzado del disclosure donde siempre se considera el user reference como guía
- Se corrige en los consents que se prohiban dos parámetros, Consorcio lo usa y nos bajan a 0.0000001% si le rompemos la integración
- Se corrige que los jobs de crear consents reciban el entity, lo independizo para permitir creación previa en el controlador y aplicarlo a otros casos como el session token
- Hago que los session tokens se puedan obtener via uno u otro (reference / id)
	- SI no existe por user reference, se crea el entity al obtener el session token

### Tests más importantes que se agregan o modifican

- [x] Agregué tests adicionales para cubrir la nueva funcionalidad desarrollada.

- ~[ ] Agregué un nuevo flujo de UX e incluí los tests e2e correspondientes.~ No aplica

### Checklist de Seguridad Pre-Merge

Antes de solicitar la revisión, por favor, verifica que tu código cumple con los siguientes puntos clave:

- ~[ ] Validación de Entradas: Toda entrada externa o de usuario (parámetros, formularios, APIs) es validada y sanitizada para prevenir ataques (ej. XSS, Inyección SQL).~ No aplica

- ~[ ] Manejo de Datos Personales, Sensibles o Confidenciales: Se evita registrar (loggear) datos personales, contraseñas o secretos. La información se maneja de forma segura y no se expone innecesariamente.~ No aplica

- ~[ ] Errores Seguros: Los mensajes de error son genéricos y no exponen información interna del sistema (como stack traces o rutas de archivos) al usuario final.~ No aplica

- [x] Protección de Endpoints: Toda nueva ruta o endpoint (incluyendo APIs internas) está protegida por defecto y solo concede acceso a los roles que lo requieren, aplicando el principio de mínimo privilegio.

- ~[ ] Gestión de Secretos: No se ha añadido ninguna credencial, clave de API o secreto directamente en el código. Se utiliza el gestor de secretos de la empresa.~ No aplica

- ~[ ] Nuevas Dependencias: Las dependencias externas añadidas son de fuentes confiables, se encuentran activamente mantenidas y han sido analizadas en busca de vulnerabilidades conocidas.~ No aplica

---------------------------------------------------------

### Contexto
Estamos modificando el DSR y haciéndolo más configurable para más casos de uso

### Qué se esta haciendo

**En resumen**:
Se agrega el campo de teléfono opcional en la información de contacto


### Tests más importantes que se agregan o modifican

- [x] Agregué tests adicionales para cubrir la nueva funcionalidad desarrollada.

- ~[ ] Agregué un nuevo flujo de UX e incluí los tests e2e correspondientes.~ No aplica

### Checklist de Seguridad Pre-Merge

Antes de solicitar la revisión, por favor, verifica que tu código cumple con los siguientes puntos clave:

- [x] Validación de Entradas: Toda entrada externa o de usuario (parámetros, formularios, APIs) es validada y sanitizada para prevenir ataques (ej. XSS, Inyección SQL). (esto viene por defecto en Rails...)

- [x] Manejo de Datos Personales, Sensibles o Confidenciales: Se evita registrar (loggear) datos personales, contraseñas o secretos. La información se maneja de forma segura y no se expone innecesariamente.

- [x] Errores Seguros: Los mensajes de error son genéricos y no exponen información interna del sistema (como stack traces o rutas de archivos) al usuario final.

- ~[ ] Protección de Endpoints: Toda nueva ruta o endpoint (incluyendo APIs internas) está protegida por defecto y solo concede acceso a los roles que lo requieren, aplicando el principio de mínimo privilegio.~ No aplica

- ~[ ] Gestión de Secretos: No se ha añadido ninguna credencial, clave de API o secreto directamente en el código. Se utiliza el gestor de secretos de la empresa.~ No aplica

- ~[ ] Nuevas Dependencias: Las dependencias externas añadidas son de fuentes confiables, se encuentran activamente mantenidas y han sido analizadas en busca de vulnerabilidades conocidas.~ No aplica

-----------------------------------------------


### Contexto
Estamos haciendo una demo para comercial

### Qué se esta haciendo

**En resumen**:
Se termina el módulo de Seeds, usando los loaders / coordinador creado a nivel de API y job

La idea es, que la API llama a un job que se corre todos los dias en la madrugada igual, y el dashboard llama a esta API

El job solo corre para la empresa demo, independiente de qué empresa corra la seed

### Tests más importantes que se agregan o modifican

- [x] Agregué tests adicionales para cubrir la nueva funcionalidad desarrollada.

- ~[ ] Agregué un nuevo flujo de UX e incluí los tests e2e correspondientes.~ No hay nuevos flujos de front

### Checklist de Seguridad Pre-Merge

Antes de solicitar la revisión, por favor, verifica que tu código cumple con los siguientes puntos clave:

- [x] Validación de Entradas: Toda entrada externa o de usuario (parámetros, formularios, APIs) es validada y sanitizada para prevenir ataques (ej. XSS, Inyección SQL).

- ~[ ] Manejo de Datos Personales, Sensibles o Confidenciales: Se evita registrar (loggear) datos personales, contraseñas o secretos. La información se maneja de forma segura y no se expone innecesariamente.~ No hay datos sensibles involucrados, solo ficticios. El logging se hace exclusivamente en desarrollo

- ~[ ] Errores Seguros: Los mensajes de error son genéricos y no exponen información interna del sistema (como stack traces o rutas de archivos) al usuario final.~ No hay mensajes de error involucrados que no estén ya manejados

- [x] Protección de Endpoints: Toda nueva ruta o endpoint (incluyendo APIs internas) está protegida por defecto y solo concede acceso a los roles que lo requieren, aplicando el principio de mínimo privilegio.

- ~[ ] Gestión de Secretos: No se ha añadido ninguna credencial, clave de API o secreto directamente en el código. Se utiliza el gestor de secretos de la empresa.~ No hay nuevas credenciales

- ~[ ] Nuevas Dependencias: Las dependencias externas añadidas son de fuentes confiables, se encuentran activamente mantenidas y han sido analizadas en busca de vulnerabilidades conocidas.~ No hay nuevas dependencias

-------------------------------------------------------------

### Contexto
Estaba revisando el checkeo con el registro civil y fallaba el front, no mostraba el loading ni el fallo de ser el caso 

### Qué se esta haciendo

**En resumen**:
Pasa que poco despues de hacer esta feature, se cambio un poco las maquinas de estado para funcionar en base a ciertos del requestable y no especificamente del validation attempt, omitiendo un poco el front de un posible segundo check con el registro

Acá lo corrijo. Hay cosas como lo del `document_approved` que no me encantan, pero que corregiré en el pitch de solo validación del numero de documento en el DSR

### Tests más importantes que se agregan o modifican

- [x] Agregué tests adicionales para cubrir la nueva funcionalidad desarrollada.

~- [ ] Agregué un nuevo flujo de UX e incluí los tests e2e correspondientes.~ No agregue porque no hay ninguno, pero me encantaría agregar en el futuro pitch

### Checklist de Seguridad Pre-Merge

Antes de solicitar la revisión, por favor, verifica que tu código cumple con los siguientes puntos clave:

- ~[ ] Validación de Entradas: Toda entrada externa o de usuario (parámetros, formularios, APIs) es validada y sanitizada para prevenir ataques (ej. XSS, Inyección SQL).~ No aplica

- ~[ ] Manejo de Datos Personales, Sensibles o Confidenciales: Se evita registrar (loggear) datos personales, contraseñas o secretos. La información se maneja de forma segura y no se expone innecesariamente.~ No aplica

- ~[ ] Errores Seguros: Los mensajes de error son genéricos y no exponen información interna del sistema (como stack traces o rutas de archivos) al usuario final.~ No aplica

- [x] Protección de Endpoints: Toda nueva ruta o endpoint (incluyendo APIs internas) está protegida por defecto y solo concede acceso a los roles que lo requieren, aplicando el principio de mínimo privilegio.

- [x] Gestión de Secretos: No se ha añadido ninguna credencial, clave de API o secreto directamente en el código. Se utiliza el gestor de secretos de la empresa.

- ~[ ] Nuevas Dependencias: Las dependencias externas añadidas son de fuentes confiables, se encuentran activamente mantenidas y han sido analizadas en busca de vulnerabilidades conocidas.~ No aplica
