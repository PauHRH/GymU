# GAMEPLAN - GymU

## 1. Objetivo
App profesional de gimnasio en Flutter con backend Node.js y MySQL. Permite a los usuarios:
- Gestionar rutinas y ejercicios personalizados.
- Registrar y visualizar el historial de pesos.
- Ver el progreso en gráficas.
- Cambiar imagen de perfil y tema (claro/oscuro).
- Navegación moderna y visual.

## 2. Estructura del Proyecto

### Frontend (Flutter)
- `lib/main.dart`: Toda la lógica de UI, navegación, conexión con backend, gestión de rutinas, ejercicios, progreso, perfil y ajustes.
- Dependencias: `http`, `fl_chart`, `image_picker`.

### Backend (Node.js)
- `index.js`: Endpoints REST para login, registro, rutinas, ejercicios, historial y gestión de imágenes.
- Dependencias: `express`, `mysql2`, `bcrypt`, `multer`, `cors`.

### Base de Datos (MySQL)
- Tablas:
  - `users` (email, password, name, profile_image)
  - `routines` (id, user_email, name)
  - `routine_exercises` (id, routine_id, name, max_weight)
  - `exercise_history` (id, exercise_id, date, weight)

## 3. Funcionalidades Clave

- **Login/Registro**: Validación, feedback visual, registro seguro (bcrypt).
- **Rutinas**: Crear, listar, gestionar múltiples rutinas y ejercicios.
- **Ejercicios**: Selección visual (grid con imágenes), opción personalizada.
- **Historial y Progreso**: Registro de pesos, gráficas con fl_chart, página de progreso general.
- **Perfil**: Cambiar imagen (image_picker), cambiar tema, ajustes.
- **Backend**: Endpoints RESTful, subida de imágenes, seguridad básica.
- **Frontend**: Navegación inferior, cards limpias, diseño moderno, color rojo principal.

## 4. Buenas Prácticas

- Mantener este gameplan actualizado con cada cambio importante.
- Documentar endpoints y estructura de la base de datos.
- Hacer commits frecuentes y claros.
- No subir archivos sensibles (claves, .env, etc).

## 5. Recuperación Rápida

- Si se pierde el código, reconstruir siguiendo este gameplan.
- Revisar dependencias y estructura de carpetas.
- Consultar este archivo antes de pedir ayuda a una IA o colaborador.
