extends CharacterBody2D

@export var grid_size: Vector2 = Vector2(64, 64)  # Tamaño de las casillas
@onready var sprite = $AnimatedSprite2D  # Referencia al sprite

var objetivo: Vector2  # Posición futura en la cuadrícula
var seleccionado: bool = true  # Está activo desde el inicio

# Control del power-up
var pasos_extra: int = 1  # Multiplicador de movimiento normal (1 casilla)
var turnos_restantes: int = 0  # Turnos con el efecto activo

signal ataque_realizado(posicion_ataque)

func _ready():
	objetivo = position.snapped(grid_size)  # Asegurar que empiece en la cuadrícula
	sprite.play("Idle")  # Animación inicial

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			mover(Vector2(0, -1))
		elif event.keycode == KEY_S:
			mover(Vector2(0, 1))
		elif event.keycode == KEY_A:
			mover(Vector2(-1, 0))
		elif event.keycode == KEY_D:
			mover(Vector2(1, 0))
		elif event.keycode == KEY_F:
			atacar()

func mover(direccion: Vector2):
	var nueva_posicion = objetivo + direccion * grid_size * pasos_extra
	if get_parent().es_posicion_valida(nueva_posicion):
		print("Moviendo a:", nueva_posicion)
		objetivo = nueva_posicion
		sprite.play("Walk")
		mover_animacion()
		# Reducir turnos si el power-up está activo
		if turnos_restantes > 0:
			turnos_restantes -= 1
			print("Turnos restantes con el power-up:", turnos_restantes)
			if turnos_restantes == 0:
				pasos_extra = 1  # Volver a la velocidad normal
				print("Efecto del power-up terminado.")

func mover_animacion():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", objetivo, 0.3)
	await tween.finished
	print("Movimiento terminado. Posición actual:", position)
	sprite.play("Idle")  # Volver a Idle después de moverse

func atacar():
	print("Función atacar() llamada")
	sprite.play("Attack")
	await sprite.animation_finished  # Espera a que termine la animación
	var posicion_ataque = position + Vector2(grid_size.x, 0)
	print("Atacando en posición:", posicion_ataque)
	emit_signal("ataque_realizado", posicion_ataque)

# Método para recibir el efecto del objeto
func activar_powerup():
	pasos_extra = 2  # Duplicar la distancia de movimiento
	turnos_restantes = 3  # Durará 3 movimientos
	print("¡Power-up activado! Movimientos dobles por 3 turnos.")
