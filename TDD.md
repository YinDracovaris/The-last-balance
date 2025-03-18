Technical Design Document (TDD) 

1. Introducción 
Título: The Last Balance 
Versión del Documento: 1.0 
Desarrollado por: Vergara Calvario César Julian 
Contacto: cvergara1@ucol.mx 
Fecha de Publicación: 17/03/2025 

Resumen: 
Este documento técnico define los aspectos clave para la implementación del videojuego 
The Last Balance, un RPG táctico por turnos. Se detallan las decisiones técnicas, la 
estructura del juego, las herramientas utilizadas y los requerimientos para su desarrollo y 
ejecución. 

Lista de Características obtenidas del GDD 

Las principales características técnicas del juego, basadas en el GDD, son: 
• Combate por turnos en un mapa de casillas con posicionamiento estratégico. 
• Sistema de progresión basado en niveles y desbloqueo de habilidades. 
• Narrativa interactiva con múltiples finales basados en las decisiones del jugador. 
• Exploración de territorios con santuarios clave que deben ser liberados. 
• Inspiración visual en la antigua China, con pixel art retro y elementos de fantasía. 

Elección de Game Engine 
El motor de desarrollo elegido para The Last Balance es Godot Engine. La elección se basa 
en los siguientes criterios: 

• Optimizado para juegos 2D: Cuenta con un sistema de tilemaps y nodos ideales 
para un juego táctico por turnos. 
• Lenguaje accesible (GDScript): Similar a Python, facilita la programación de 
mecánicas y IA. 
• Sistema de escenas modular: Permite organizar niveles y transiciones de manera 
eficiente. 
• Licencia libre: No requiere pago de regalías, lo que lo hace ideal para el proyecto. 
• Herramientas de interfaz integradas: Facilita la creación de HUD y menús de 
usuario.

Planeación (Diagrama de Gantt)
El desarrollo del juego se divide en las siguientes fases:

Planificación y base del proyecto – Del 27 de marzo al 5 de abril.
Implementación de mecánicas base – Del 5 al 19 de abril.
Contenido y optimización – Del 19 de abril al 3 de mayo.
Pruebas – Del 3 al 8 de mayo.
Lanzamiento – 11 de mayo.

Diagrama de módulos principales del juego

Juego
Atributos:
Estado_Juego: Enum
Nivel_Actual: list
Métodos:
Iniciar_Partida()
Finalizar_Partida()
Cambiar_Estado(Nuevo_Estado)

UIManager
Atributos:
HUD_Combate: Elementos gráficos
HUD_Dialogos: Elementos gráficos
Métodos:
Actualizar_HUD()
Mostrar_Mensaje(Texto)

Combate
Atributos:
Turno_Actual: int
Unidades_Aliadas: Array de Personaje
Unidades_Enemigas: Array de Personaje
Mapa_Batalla: Matriz de celdas
Métodos:
Iniciar_Combate()
Ejecutar_Accion(Accion)
Enemigos (hereda de Personaje)
Atributos:
Patron_IA: String
Métodos:
Tomar_Decision()

Personaje
Atributos:
Nombre: String
Vida: int
Ataque: int
Defensa: int
Magia: int
Velocidad: int
Posicion: Vector2
Métodos:
Moverse(Direccion: Vector2)
Atacar(Objetivo: Personaje)
Recibir_Dano(Cantidad: int)

Habilidades
Atributos:
Nombre: String
Tipo: String
Costo: int
Métodos:
Ejecutar(Usuario: Personaje, Objetivo: Personaje)
Dialogos
Atributos:
Conversacion_Actual: String
Opciones_Disponibles: Array de Strings
Métodos:
Mostrar_Dialogo(Dialogo)
Seleccionar_Opcion(Opcion)

Herramientas de Arte 
Las herramientas utilizadas para la creación de sprites y arte del juego son: 
• Aseprite: Para la creación y edición de sprites en pixel art. 
• Photoshop/GIMP: Para ilustraciones y efectos visuales. 
• Tiled Map Editor: Para la construcción de mapas de casillas y escenarios. 

Objetos 3D, Terreno y Escenas 
No se utilizarán modelos 3D, ya que el juego está diseñado en 2D. 
Los escenarios estarán basados en tilemaps en Godot, permitiendo un diseño modular y 
optimizado. 

Detección de Colisiones, Físicas e Interacciones 
• CollisionShape2D y CollisionPolygon2D: Para definir áreas de colisión en 
personajes y objetos. 
• Área2D: Para detectar interacciones sin física, como diálogos y activación de 
eventos. 
• StaticBody2D y RigidBody2D: Para definir colisiones estáticas y físicas en 
elementos clave del escenario. 
Lógica de Juego e Inteligencia Artificial 
• Sistema de turnos: El jugador y la computadora tomaran turnos para mover y 
atacar con sus personajes. 
• IA de enemigos: Basada en estados y reglas condicionales (movimiento o ataque). 
• Gestión de datos: JSON para almacenar información de personajes, habilidades y 
eventos. 

Networking 
El juego se encuentra orientado a un solo jugador, por lo que no se aplicaría networking. 

Audio y Efectos Visuales 
• Sonidos y música: Se utilizarán archivos OGG para música y efectos de sonido. 
• Banda sonora: Inspirada en música tradicional china. 
• Efectos visuales: Uso de shaders en Godot para ataques, auras y efectos 
especiales en combate. 

Plataforma y Requerimientos de Software 
• Plataforma objetivo: PC (Windows). 
• Requerimientos mínimos: 
o Sistema Operativo: Windows 10 o superior 
o Procesador: Intel i3 o equivalente 
o Memoria RAM: 4GB 
o Gráficos: Integrados o dedicados con soporte OpenGL 3.0+ 
o Almacenamiento: 2GB libres
