# Costealo - Frontend Web Application

## 📋 Descripción
Aplicación web moderna para gestión inteligente de costos. Permite crear bases de datos de precios, calcular costos de producción con planillas interactivas, y gestionar suscripciones.

**Backend API:** `https://app-251126163117.azurewebsites.net`

## 🎨 Diseño
- **Verde Costealo**: `#4CAF50` (principal), `#81C784` (suave), `#C8E6C9` (pastel), `#2E7D32` (oscuro)
- **Rosa Costealo**: `#F7A8B8` (principal), `#FBD0D9` (suave), `#FFE6EC` (pastel), `#E0647B` (profundo)
- **Lila Costealo**: `#A78BFA` (principal), `#DAD0FF` (pastel), `#EDE9FE` (lavanda)

## 🚀 Tech Stack
**Vanilla Web** - HTML, CSS, JavaScript (sin frameworks)
- ✅ No requiere instalación de Node.js
- ✅ Solo un navegador (Chrome)
- ✅ Fácil colaboración en equipo

## 📦 Estructura del Proyecto
```
porsiaca/
├── index.html              # Landing page
├── css/
│   ├── variables.css       # Design tokens (colores, espaciado)
│   ├── styles.css          # Estilos globales
│   └── components.css      # Componentes reutilizables
├── js/
│   ├── api.js              # API client y servicios
│   ├── config.js           # Configuración
│   ├── router.js           # Utilidades de navegación
│   └── utils.js            # Funciones auxiliares
└── pages/
    ├── auth/               # Login, registro
    ├── dashboard/          # Página principal
    ├── databases/          # Gestión de bases de datos
    ├── workbooks/          # Calculadora de planillas
    └── profile/            # Perfil de usuario
```

## 🔧 Cómo Usar

### Desarrollo Local
1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repo>
   cd porsiaca
   ```

2. **Abrir en el navegador**
   - Simplemente abre `index.html` en Chrome
   - O usa Live Server en VS Code para auto-reload

3. **Trabajar en tu rama**
   ```bash
   git checkout -b tu-nombre
   # Hacer cambios
   git add .
   git commit -m "feat: descripción"
   git push origin tu-nombre
   ```

### Sincronizar con Main
```bash
git checkout main
git pull origin main
git checkout tu-rama
git merge main
```

## 🌿 Ramas
- `main` - Código estable y sincronizado
- `mariana` - Desarrollo actual
- Cada miembro crea su rama con su nombre

## 📚 Guía Rápida de Componentes

### Botones
```html
<button class="btn btn-primary">Botón Verde</button>
<button class="btn btn-secondary">Botón Rosa</button>
<button class="btn btn-ghost">Botón Outline</button>
```

### Inputs
```html
<div class="form-group">
  <label class="form-label">Nombre</label>
  <input type="text" class="form-input" placeholder="Ingresa tu nombre">
</div>
```

### Cards
```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Título</h3>
  </div>
  <div class="card-body">
    Contenido de la card
  </div>
</div>
```

## 🔌 Uso del API

```javascript
// Login
const token = await AuthService.login('email@example.com', 'password');

// Obtener bases de datos
const databases = await DatabaseService.getAll();

// Crear workbook
const workbook = await WorkbookService.create({
  name: 'Mi Planilla',
  productionUnits: 50,
  profitMarginPercentage: 0.25
});
```

## ✅ Checklist para Nuevas Páginas
1. Crear HTML en `/pages/<categoria>/`
2. Agregar estilos en CSS existente o crear nuevo
3. Usar componentes de `components.css`
4. Conectar con API usando `api.js`
5. Probar en Chrome localmente
6. Commit y push a tu rama

## 🤝 Colaboración
- Usa nombres descriptivos en commits: `feat:`, `fix:`, `style:`, `docs:`
- Revisa código antes de hacer merge a `main`
- Mantén consistencia con los colores y componentes del diseño

## 📝 Notas Importantes
- **Sin foto de perfil** en la app
- **Sin selector de moneda** (backend maneja)
- **BOB text field** en workbooks y databases
- **Unidad doble dropdown** solo en databases
- **Planilla units**: Cantidad de raciones + unidades SI (g, ml, m, °C)
- **Precio ↔ Margen**: Interdependientes (editar uno actualiza el otro)

