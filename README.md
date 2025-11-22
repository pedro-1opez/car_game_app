# 🚗 Slider App

## 🎮 Descripción 

Se trata de un juego tipo endless runner donde el jugador controla un coche que debe esquivar obstáculos, recoger combustible y acumular puntos. El juego presenta dos modos de orientación:

- **Modo Vertical**: El coche se mueve horizontalmente entre carriles mientras avanza hacia adelante
- **Modo Horizontal**: El coche se mueve verticalmente entre carriles mientras avanza lateralmente


## 📁 Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── core/                              # ------------------------------------
│   ├── constants/                     # Constantes del juego
│   │   ├── game_constants.dart        # Configuraciones generales
│   │   ├── orientation_config.dart    # Configuración por orientación
│   │   ├── colors.dart                # Paleta de colores
│   │   └── assets.dart                # Rutas de assets
│   ├── models/                        # ------------------------------------
│   │   ├── game_orientation.dart      # Modelo de orientación
│   │   ├── car.dart                   # Modelo del coche
│   │   ├── obstacle.dart              # Modelo de obstáculos
│   │   ├── power_up.dart              # Modelo de power-ups
│   │   └── game_state.dart            # Estado del juego
│   └── utils/                         # ------------------------------------
│       ├── orientation_helper.dart    # Ayudas para orientación
│       ├── collision_detector.dart    # Detección de colisiones
│       ├── coordinate_converter.dart  # Conversión de coordenadas
│       └── score_calculator.dart      # Cálculo de puntuación
├── features/                          # ------------------------------------
│   ├── game/                          # ------------------------------------
│   │   ├── screens/                   # Pantallas del juego
│   │   ├── widgets/                   # Widgets específicos del juego
│   │   └── controllers/               # Controladores de lógica
│   ├── menu/                          # ------------------------------------
│   │   ├── screens/                   # Pantallas de menú
│   │   └── widgets/                   # Widgets de menú
│   └── profile/                       # ------------------------------------
│       ├── screens/                   # Pantallas de perfil
│       └── widgets/                   # Widgets de perfil
├── services/                          # ------------------------------------
│   ├── supabase_service.dart          # Integración con Supabase
│   ├── game_service.dart              # Lógica de juego
│   ├── audio_service.dart             # Manejo de audio
│   ├── orientation_service.dart       # Servicio de orientación
│   └── preferences_service.dart       # Preferencias locales
└── shared/                            # ------------------------------------
    └── widgets/
        └── draggable_car.dart         # Widget del Proyecto Base -Sustituir-
```

## 🎨 Assets

### Imágenes por Orientación
```
assets/images/
├── cars/                            # Texturas de los autos
│   ├── vertical/                    
│   └── horizontal/                  
├── roads/                           # Texturas de carretera
│   ├── vertical/                    
│   └── horizontal/                  
├── obstacles/                       # Obstáculos del juego
│   ├── vertical/                    
│   └── horizontal/                  
└── ui/                              # Elementos de interfaz
│   ├── vertical/                    
│   └── horizontal/                  
```

### Audio
```
assets/sounds/
├── engine.mp3                       # Sonido del motor
├── pickup.mp3                       # Sonido de recolección
├── crash.mp3                        # Sonido de colisión
└── background_music.mp3             # Música de fondo
```

### Fuentes
```
assets/fonts/
└── game_font.ttf                    # Fuente del juego
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (≥3.9.2)
- Dart SDK
- Cuenta de Supabase (para backend)

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/pedro-1opez/car_game_app.git
cd car_game_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar variables de entorno**
Crear archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=tu_supabase_url
SUPABASE_ANON_KEY=tu_supabase_anon_key
AUTH_EMAIL=tu_email
AUTH_PASSWORD=tu_password
```

4. **Ejecutar la aplicación**
```bash
flutter run
```
