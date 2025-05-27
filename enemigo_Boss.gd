extends CharacterBody2D

@export var grid_size: Vector2 = Vector2(64, 64)  # Tamaño de las casillas
@onready var sprite = $AnimatedSprite2D  # Referencia al sprite
@export var vida: int = 500
@export var vida_maxima: int = 500
@onready var health_bar: ProgressBar = $VidaUI/HealthBar
@onready var vida_numero_label: Label = $VidaUI/VidaNumeroLabel

var objetivo: Vector2  # Posición futura en la cuadrícula
var seleccionado: bool = true  # Está activo desde el inicio (esto podría cambiar con un sistema de turnos)

# Control del power-up (para el jugador, asumimos que la IA no lo usa a menos que se especifique)
var pasos_extra: int = 1  # Multiplicador de movimiento normal (1 casilla)
var turnos_restantes: int = 0  # Turnos con el efecto activo

signal ataque_enemigo1(posicion_ataque) # Considera si esta señal necesita pasar quién es el atacante o el objetivo
signal turno_enemigo_terminado
# --- NUEVAS VARIABLES PARA IA Y TURNOS ---
var turno_enemigo: bool = false # Por defecto es falso, el gestor de turnos lo activará
var protagonista_ref: Node2D = null # Referencia al nodo del protagonista, a ser seteada por el gestor de turnos

var movimientos_max_por_turno: int = 3
var ataque_max_por_turno: int = 1 # El enemigo puede hacer 1 ataque
# --- FIN DE NUEVAS VARIABLES ---

func _ready():
	sprite.flip_h = true
	objetivo = position.snapped(grid_size)  # Asegurar que empiece en la cuadrícula
	position = objetivo # Forzar posición inicial a la cuadrícula
	sprite.play("Idle")  # Animación inicial
	
	if health_bar:
		health_bar.max_value = vida_maxima
		health_bar.value = vida
	else:
		print_rich("[color=red]Error:[/color] No se encontró el nodo HealthBar.")
		
	if vida_numero_label:
		actualizar_texto_vida()
	else:
		print_rich("[color=red]Error:[/color] No se encontró el nodo VidaNumeroLabel.")

# --- FUNCIONES AUXILIARES PARA IA ---
func obtener_casillas_adyacentes() -> Array[Vector2]:
	var adyacentes: Array[Vector2] = []
	var pos_actual_snapped = position.snapped(grid_size)
	adyacentes.append(pos_actual_snapped + Vector2(grid_size.x, 0))  # Derecha
	adyacentes.append(pos_actual_snapped + Vector2(-grid_size.x, 0)) # Izquierda
	adyacentes.append(pos_actual_snapped + Vector2(0, grid_size.y))  # Abajo
	adyacentes.append(pos_actual_snapped + Vector2(0, -grid_size.y)) # Arriba
	return adyacentes

func puede_atacar_al_protagonista_adyacente() -> bool:
	if not is_instance_valid(protagonista_ref):
		return false
	var casillas_adyacentes = obtener_casillas_adyacentes()
	return protagonista_ref.position.snapped(grid_size) in casillas_adyacentes

func intentar_mover_ia_un_paso(direccion_normalizada: Vector2) -> bool:
	if direccion_normalizada == Vector2.ZERO:
		return false # No hay dirección a donde moverse

	var proxima_pos_calculada = position.snapped(grid_size) + direccion_normalizada * grid_size

	if get_parent().es_posicion_valida(proxima_pos_calculada):
		print(name + " se mueve hacia: " + str(proxima_pos_calculada))
		objetivo = proxima_pos_calculada # Establece el nuevo 'objetivo' para mover_animacion
		
		if sprite.animation != "Walk": # Evita reiniciar la animación si ya está caminando
			sprite.play("Walk")
		
		# Determinar la orientación del sprite basado en la dirección horizontal
		if direccion_normalizada.x < 0:
			sprite.flip_h = true # Mirando a la izquierda
		elif direccion_normalizada.x > 0:
			sprite.flip_h = false # Mirando a la derecha
		# Si es vertical, mantiene la orientación actual o puedes definir una por defecto

		await mover_animacion() # mover_animacion usa 'self.objetivo' y termina en 'Idle'
		return true
	else:
		print(name + " no puede moverse a: " + str(proxima_pos_calculada) + " (posición no válida por escena principal)")
		return false
# --- FIN FUNCIONES AUXILIARES PARA IA ---

# --- LÓGICA PRINCIPAL DEL TURNO DEL ENEMIGO ---
func ejecutar_turno_ia():
	if not turno_enemigo:
		return

	if not is_instance_valid(protagonista_ref):
		print_rich("[color=yellow]Advertencia (" + name + "):[/color] No hay referencia al protagonista.")
		turno_enemigo = false 
		emit_signal("turno_enemigo_terminado") # <<--- EMITIR SEÑAL INCLUSO SI HAY ERROR
		return

	print_rich("[color=cyan]" + name + " iniciando turno IA.[/color]")
	
	var movimientos_hechos_este_turno: int = 0
	var ataque_hecho_este_turno: bool = false

	for i in range(movimientos_max_por_turno):
		if ataque_hecho_este_turno:
			break

		if puede_atacar_al_protagonista_adyacente():
			print(name + " está adyacente al protagonista. ¡Atacando!")
			await atacar() 
			ataque_hecho_este_turno = true
			break 
		
		if movimientos_hechos_este_turno < movimientos_max_por_turno:
			# ... (lógica de decisión de movimiento se mantiene) ...
			var direccion_hacia_protagonista = (protagonista_ref.position.snapped(grid_size) - position.snapped(grid_size))
			var direccion_paso = Vector2.ZERO

			if abs(direccion_hacia_protagonista.x) > abs(direccion_hacia_protagonista.y):
				direccion_paso.x = sign(direccion_hacia_protagonista.x)
			elif abs(direccion_hacia_protagonista.y) > 0:
				direccion_paso.y = sign(direccion_hacia_protagonista.y)
			else:
				print(name + " no necesita moverse más.")
				break 

			if direccion_paso != Vector2.ZERO:
				if await intentar_mover_ia_un_paso(direccion_paso):
					movimientos_hechos_este_turno += 1
					if puede_atacar_al_protagonista_adyacente():
						print(name + " ahora está adyacente tras moverse. ¡Atacando!")
						await atacar()
						ataque_hecho_este_turno = true
						break 
				else:
					print(name + " bloqueado al intentar moverse en " + str(direccion_paso) + ".")
					break 
			else:
				print(name + " no se calculó dirección de paso.")
				break
		else:
			break 
	
	if not ataque_hecho_este_turno and puede_atacar_al_protagonista_adyacente():
		print(name + " realizando comprobación final de ataque.")
		await atacar()
		# ataque_hecho_este_turno = true # Ya no es necesario reasignar aquí

	print_rich("[color=cyan]" + name + " ha terminado su turno IA. Movimientos: " + str(movimientos_hechos_este_turno) + ", Ataque: " + str(ataque_hecho_este_turno) + "[/color]")
	turno_enemigo = false
	emit_signal("turno_enemigo_terminado")

# La función mover original, usada por el jugador (si este script fuera también para un jugador)
# o por un sistema de power-ups más complejo. La IA usa 'intentar_mover_ia_un_paso'.
func mover(direccion: Vector2):
	var nueva_posicion = objetivo + direccion * grid_size * pasos_extra
	# La IA usa su propia lógica de validación dentro de 'intentar_mover_ia_un_paso'
	# por lo que esta función 'mover' no sería llamada directamente por la IA simple.
	if get_parent().es_posicion_valida(nueva_posicion):
		print("Moviendo a:", nueva_posicion)
		objetivo = nueva_posicion
		sprite.play("Walk")
		mover_animacion() # mover_animacion ya es async
		if turnos_restantes > 0:
			turnos_restantes -= 1
			if turnos_restantes == 0:
				pasos_extra = 1

func mover_animacion(): # Marcada como async explícitamente
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", objetivo, 0.3)
	await tween.finished
	# No te muevas instantáneamente a 'objetivo' aquí si la animación es la fuente de verdad del movimiento.
	# position = objetivo # Esto puede ser redundante si el tween ya lo hace precisamente.
	print("Movimiento ("+ name +") terminado. Posición actual:", position)
	sprite.play("Idle")

func atacar():
	print("Función atacar() llamada por " + name)

	if not is_instance_valid(self):
		print(name + ".atacar(): Error - self (este enemigo) es inválido ANTES de la animación.")
		return # No continuar si el nodo ya es inválido

	if sprite and sprite is AnimatedSprite2D: # Asegúrate que sprite sea del tipo correcto también
		print(name + ".atacar(): Reproduciendo animación 'Attack'. Sprite es: ", sprite.name)
		sprite.play("Attack")
		print(name + ".atacar(): Esperando final de animación 'Attack'...")
		await sprite.animation_finished
		print(name + ".atacar(): Animación 'Attack' TERMINADA.") # <<< ¿LLEGA AQUÍ?
	else:
		print(name + ".atacar(): Sprite no es válido o no es AnimatedSprite2D. Sprite: ", str(sprite))
		# Si no hay animación, ¿qué debería pasar? ¿Aún atacar?
		# Por ahora, si no hay animación, el flujo continuará sin el await.
		# Considera si esto es lo que quieres.

	if not is_instance_valid(self):
		print(name + ".atacar(): Error - self (este enemigo) se volvió inválido DESPUÉS de await animation_finished.")
		return

	print(name + ".atacar(): Verificando condiciones para infligir daño...")
	if is_instance_valid(protagonista_ref) and puede_atacar_al_protagonista_adyacente():
		print(name + ".atacar(): CONDICIÓN VERDADERA - " + name + " inflige daño al protagonista.")
		emit_signal("ataque_enemigo1", self)
	else:
		if not is_instance_valid(protagonista_ref):
			print(name + ".atacar(): CONDICIÓN FALSA - protagonista_ref es inválido.")
		elif not puede_atacar_al_protagonista_adyacente():
			print(name + ".atacar(): CONDICIÓN FALSA - protagonista no está adyacente.")
		else:
			print(name + ".atacar(): CONDICIÓN FALSA - por razón desconocida (ambas subcondiciones parecían verdaderas).")
		print(name + ".atacar(): " + name + " realizó un ataque al aire.")

	if is_instance_valid(self) and sprite and sprite is AnimatedSprite2D: # Chequeo de nuevo antes de play("Idle")
		print(name + ".atacar(): Volviendo a animación 'Idle'.")
		sprite.play("Idle")
	else:
		if not is_instance_valid(self):
			print(name + ".atacar(): No se puede volver a Idle porque self es inválido.")
		else:
			print(name + ".atacar(): No se puede volver a Idle porque sprite no es válido. Sprite: " + str(sprite))

func activar_powerup():
	pasos_extra = 2
	turnos_restantes = 3
	print("¡Power-up activado! Movimientos dobles por 3 turnos.")

func recibir_daño(cantidad: int):
	vida -= cantidad
	vida = clampi(vida, 0, vida_maxima)
	print("Enemigo ", name, " recibió daño. Vida: ", vida, "/", vida_maxima)
	actualizar_barra_vida()
	actualizar_texto_vida()
	if vida > 0:
		if sprite:
			sprite.play("Hurt")
			await sprite.animation_finished
			if vida > 0 and sprite and sprite.animation != "Death" and sprite.animation != "Idle":
				sprite.play("Idle") # Vuelve a Idle si no está ya en Idle o muriendo
	else:
		morir()

func actualizar_barra_vida() -> void:
	if health_bar:
		health_bar.value = vida
		health_bar.max_value = vida_maxima

func actualizar_texto_vida() -> void:
	if vida_numero_label:
		vida_numero_label.text = "%d/%d" % [vida, vida_maxima]

func morir(): # Marcada como async explícitamente
	print("Enemigo " + name + " ha muerto. Eliminando...")
	if sprite:
		sprite.play("Death")
		await sprite.animation_finished
	queue_free()
