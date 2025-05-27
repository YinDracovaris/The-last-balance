extends CharacterBody2D

@export var grid_size: Vector2 = Vector2(64, 64)  # Tamaño de las casillas
@onready var sprite = $AnimatedSprite2D  # Referencia al sprite
@export var vida: int = 200
@export var vida_maxima: int = 200
@export var nivel: int = 1
@onready var health_bar: ProgressBar = $VidaUI/HealthBar
@onready var vida_numero_label: Label = $VidaUI/VidaNumeroLabel

var objetivo: Vector2  # Posición futura en la cuadrícula
var seleccionado: bool = true  # Está activo desde el inicio
var en_turno: bool = true
var movimientos_max_por_turno: int = 3
var ataque_max_por_turno: int = 1
var movimientos_iniciales_por_turno: int = 3 # Valor base para reiniciar
var ataques_iniciales_por_turno: int = 1
# Control del power-up
var pasos_extra: int = 1  # Multiplicador de movimiento normal (1 casilla)
var turnos_restantes: int = 0  # Turnos con el efecto activo

signal ataque_realizado
signal ataque_realizado2
signal ataque_realizado3
signal turno_del_protagonista_terminado

func _ready():
	objetivo = position.snapped(grid_size)  # Asegurar que empiece en la cuadrícula
	sprite.play("Idle")  # Animación inicial
	# Configurar la barra de vida inicialmente
	print("Vida Máxima Inicial (script): ", vida_maxima)
	print("Vida Actual Inicial (script): ", vida)
	
	if health_bar:
		health_bar.max_value = vida_maxima
		health_bar.value = vida
	else:
		print_rich("[color=red]Error:[/color] No se encontró el nodo HealthBar. Verifica la ruta en @onready.")
		
	if vida_numero_label:
		actualizar_texto_vida()
	else:
		print_rich("[color=red]Error:[/color] No se encontró el nodo VidaNumeroLabel. Verifica la ruta.")
		
	movimientos_max_por_turno = movimientos_iniciales_por_turno
	ataque_max_por_turno = ataques_iniciales_por_turno

func _input(event):
	if not en_turno:
		return

	# Procesar movimiento
	if event is InputEventKey and event.pressed and movimientos_max_por_turno > 0:
		var se_movio = false
		if event.keycode == KEY_W:
			mover(Vector2(0, -1))
			se_movio = true
		elif event.keycode == KEY_S:
			mover(Vector2(0, 1))
			se_movio = true
		elif event.keycode == KEY_A:
			sprite.flip_h = true
			mover(Vector2(-1, 0))
			se_movio = true
		elif event.keycode == KEY_D:
			mover(Vector2(1, 0))
			sprite.flip_h = false
			se_movio = true
		
		if se_movio:
			movimientos_max_por_turno -= 1
			print("Protagonista: Movimientos restantes: ", movimientos_max_por_turno)
			_verificar_fin_de_turno() # <<--- AÑADIR ESTA LLAMADA
			return # Para que una pulsación de tecla no cuente para movimiento Y ataque a la vez

	# Procesar ataque (solo si aún está en turno)
	if en_turno and event is InputEventKey and event.pressed and ataque_max_por_turno > 0:
		var se_ataco = false
		if event.keycode == KEY_F:
			atacar()
			se_ataco = true
		elif event.keycode == KEY_E:
			atacar2()
			se_ataco = true
		elif event.keycode == KEY_Q:
			atacar3()
			se_ataco = true
		
		if se_ataco:
			ataque_max_por_turno -= 1
			print("Protagonista: Ataques restantes: ", ataque_max_por_turno)
			_verificar_fin_de_turno()
			
func _verificar_fin_de_turno():
	# El turno termina si se agotan los movimientos Y los ataques,
	if movimientos_max_por_turno <= 0 and ataque_max_por_turno <= 0:
		if en_turno: # Solo finalizar si realmente estaba en turno
			finalizar_turno()

func finalizar_turno():
	print("Protagonista: Finalizando turno.")
	en_turno = false
	# Aquí podrías añadir lógica adicional, como deshabilitar UI específica del jugador.
	emit_signal("turno_del_protagonista_terminado")
	# Los contadores se resetearán en iniciar_turno()

func iniciar_turno():
	print("Protagonista: Iniciando turno.")
	en_turno = true
	movimientos_max_por_turno = movimientos_iniciales_por_turno
	ataque_max_por_turno = ataques_iniciales_por_turno
	print("Acciones restauradas: Movimientos=", movimientos_max_por_turno, ", Ataques=", ataque_max_por_turno)

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
	await sprite.animation_finished # Espera a que termine la animación
	emit_signal("ataque_realizado")
	print("Señal ataque_realizado emitida.")
	sprite.play("Idle")
	
func atacar2():
	print("Función atacar2() llamada")
	sprite.play("Attack")
	await sprite.animation_finished # Espera a que termine la animación
	emit_signal("ataque_realizado2")
	print("Señal ataque_realizado2 emitida.")
	sprite.play("Idle")
	
func atacar3():
	print("Función atacar3() llamada")
	sprite.play("Attack")
	await sprite.animation_finished # Espera a que termine la animación
	emit_signal("ataque_realizado3")
	print("Señal ataque_realizado3 emitida.")
	sprite.play("Idle")

# Método para recibir el efecto del objeto
func activar_powerup():
	pasos_extra = 2  # Duplicar la distancia de movimiento
	turnos_restantes = 3  # Durará 3 movimientos
	print("¡Power-up activado! Movimientos dobles por 3 turnos.")

func recibir_daño(cantidad: int): # Especifica el tipo de 'cantidad'

	vida -= cantidad
	vida = clampi(vida, 0, vida_maxima) # Asegura que la vida esté entre 0 y vida_maxima

	print("Protagonista ", name, " recibió daño. Vida: ", vida, "/", vida_maxima)
	actualizar_barra_vida()
	actualizar_texto_vida()

	if vida > 0:
		if sprite:
			sprite.play("Hurt")
			await sprite.animation_finished
			if vida > 0 and sprite.animation != "Death": # Evitar interrumpir Death si se llama morir después
				sprite.play("Idle")
	else: # vida <= 0
		morir()

func actualizar_barra_vida() -> void:
	if health_bar:
		health_bar.value = vida
		health_bar.max_value = vida_maxima

func actualizar_texto_vida() -> void:
	if vida_numero_label:
		vida_numero_label.text = "%d/%d" % [vida, vida_maxima]

func morir():
	print("Protagonista ha muerto. Eliminando...")
	sprite.play("Death")
	await sprite.animation_finished
	queue_free()
