extends Node2D

@onready var protagonista = $Protagonista
var enemigos_vivos: Array[CharacterBody2D] = [] 
@onready var items = []  # Agregar más objetos si es necesario
@onready var pause_menu_instance: Control = $PauseMenu
var grid_size = Vector2(64, 64)
# --- VARIABLES DEL GESTOR DE TURNOS ---
enum EstadosTurno { PROTAGONISTA, ENEMIGOS, TRANSICION }
var estado_turno_actual = EstadosTurno.PROTAGONISTA
var indice_enemigo_actual: int = 0

func _ready():
	# Inicializar lista de enemigos vivos
	if $Enemigo1 and $Enemigo1 is CharacterBody2D: # Verifica que el nodo exista y sea del tipo esperado
		enemigos_vivos.append($Enemigo1)
	if $Enemigo2 and $Enemigo2 is CharacterBody2D:
		enemigos_vivos.append($Enemigo2)
	if $Enemigo3 and $Enemigo3 is CharacterBody2D:
		enemigos_vivos.append($Enemigo3)

	# Conexiones del Protagonista
	if protagonista:
		protagonista.connect("ataque_realizado", Callable(self, "_on_Protagonista_ataque_realizado")) # Renombrada para claridad
		protagonista.connect("ataque_realizado2", Callable(self, "_on_Protagonista_ataque_realizado2"))# Renombrada
		protagonista.connect("ataque_realizado3", Callable(self, "_on_Protagonista_ataque_realizado3"))# Renombrada
		protagonista.connect("turno_del_protagonista_terminado", Callable(self, "_on_Protagonista_turno_terminado"))
	else:
		print_rich("[color=red]Error Crítico:[/color] Nodo Protagonista no encontrado.")
		get_tree().quit() # O manejar el error de otra forma

	# Conexiones de los Enemigos
	for enemigo in enemigos_vivos:
		if is_instance_valid(enemigo): # Asegurarse que el enemigo es válido antes de conectar
			enemigo.connect("ataque_enemigo1", Callable(self, "_on_Enemigo_ataque"))
			enemigo.connect("turno_enemigo_terminado", Callable(self, "_on_Enemigo_turno_terminado"))
			# Conectar señal de muerte si los enemigos la tuvieran, para removerlos de 'enemigos_vivos'
			# enemigo.connect("muerto", Callable(self, "_on_Enemigo_muerto").bind(enemigo))


	print("Escena inicializada. Protagonista en:", protagonista.position if protagonista else "N/A")
	
	# Iniciar el primer turno
	_iniciar_turno_protagonista()

func _iniciar_turno_protagonista():
	print_rich("[color=green]-- TURNO DEL PROTAGONISTA --[/color]")
	estado_turno_actual = EstadosTurno.PROTAGONISTA
	if protagonista and is_instance_valid(protagonista):
		protagonista.iniciar_turno()
	else:
		print_rich("[color=red]Error:[/color] Intentando iniciar turno de protagonista inválido.")
		# Aquí podrías manejar una condición de fin de juego si el prota no existe/murió
		# y no se manejó antes.


func _on_Protagonista_turno_terminado():
	print("EscenaPrincipal: Protagonista terminó su turno.")
	# Pasar al turno de los enemigos
	indice_enemigo_actual = 0
	_procesar_siguiente_enemigo()

func _procesar_siguiente_enemigo():
	estado_turno_actual = EstadosTurno.ENEMIGOS
	# Asegurarse que la lista de enemigos_vivos esté actualizada
	enemigos_vivos = enemigos_vivos.filter(func(e): return is_instance_valid(e))


	if indice_enemigo_actual < enemigos_vivos.size():
		var enemigo_actual = enemigos_vivos[indice_enemigo_actual]
		if is_instance_valid(enemigo_actual):
			print_rich("[color=orange]-- TURNO DE: " + (enemigo_actual.name if enemigo_actual.name else "Enemigo " + str(indice_enemigo_actual)) + " --[/color]")
			enemigo_actual.protagonista_ref = protagonista
			enemigo_actual.turno_enemigo = true
			await enemigo_actual.ejecutar_turno_ia() # Esperar a que la IA del enemigo termine
			# La señal 'turno_enemigo_terminado' ahora se conectará para avanzar
		else:
			# Enemigo inválido, intentar el siguiente
			print("EscenaPrincipal: Enemigo en índice", indice_enemigo_actual, "es inválido. Saltando.")
			_on_Enemigo_turno_terminado() # Simula que terminó para pasar al siguiente
	else:
		# Todos los enemigos han jugado, volver al turno del protagonista
		print("EscenaPrincipal: Todos los enemigos han jugado.")
		_iniciar_turno_protagonista()

func _on_Enemigo_turno_terminado():
	print("EscenaPrincipal: Un enemigo terminó su turno.")
	indice_enemigo_actual += 1
	_procesar_siguiente_enemigo() # Procesar el siguiente enemigo o pasar al prota

# Manejador para cuando un enemigo ataca (conectado a la señal 'ataque_enemigo1' del enemigo)
func _on_Enemigo_ataque(atacante_node: Node2D):
	if not is_instance_valid(protagonista) or not is_instance_valid(atacante_node):
		return

	print("EscenaPrincipal: Enemigo", atacante_node.name, "ha atacado.")
	# Verificar si el protagonista está adyacente al enemigo que atacó
	var casillas_adyacentes_al_enemigo: Array[Vector2] = []
	var pos_enemigo_snapped = atacante_node.position.snapped(grid_size)
	casillas_adyacentes_al_enemigo.append(pos_enemigo_snapped + Vector2(grid_size.x, 0))
	casillas_adyacentes_al_enemigo.append(pos_enemigo_snapped + Vector2(-grid_size.x, 0))
	casillas_adyacentes_al_enemigo.append(pos_enemigo_snapped + Vector2(0, grid_size.y))
	casillas_adyacentes_al_enemigo.append(pos_enemigo_snapped + Vector2(0, -grid_size.y))

	if protagonista.position.snapped(grid_size) in casillas_adyacentes_al_enemigo:
		print("EscenaPrincipal: ¡El ataque del enemigo alcanza al protagonista!")
		var dano_enemigo = 60 # Define el daño del enemigo aquí o en el script del enemigo
		protagonista.recibir_daño(dano_enemigo)
	else:
		print("EscenaPrincipal: El ataque del enemigo no alcanzó al protagonista.")

# --- FIN FUNCIONES DEL GESTOR DE TURNOS ---

func _process(delta):
	# Revisar si el protagonista pisa un objeto
	verificar_powerup()	

func _unhandled_input(event):
	# Abrir/cerrar el menú de pausa con la tecla de acción "ui_cancel"
	if event.is_action_pressed("PAUSA"):
		if pause_menu_instance:
			if pause_menu_instance.visible:
				pause_menu_instance._on_ResumeButton_pressed()
			else:
				pause_menu_instance.show_menu() # Llama a la función del menú que pausa y muestra

func _on_Protagonista_ataque_realizado():
	# ... (la lógica que tenías en _verificar_ataque se mantiene) ...
	# Asegúrate de usar 'enemigos_vivos' si es la lista que gestionas
	if not is_instance_valid(protagonista): return
	var pos_protagonista = protagonista.position
	var casillas_adyacentes = [ # Copiado de tu lógica original
		pos_protagonista + Vector2(grid_size.x, 0),
		pos_protagonista + Vector2(-grid_size.x, 0),
		pos_protagonista + Vector2(0, grid_size.y),
		pos_protagonista + Vector2(0, -grid_size.y)
	]
	var enemigos_en_area = []
	for enemigo in enemigos_vivos: # Usar la lista actualizada
		if is_instance_valid(enemigo) and enemigo.position.snapped(grid_size) in casillas_adyacentes:
			enemigos_en_area.append(enemigo)
	
	if enemigos_en_area.is_empty(): return
	var enemigo_objetivo = enemigos_en_area[0]
	for i in range(1, enemigos_en_area.size()):
		if enemigos_en_area[i].vida < enemigo_objetivo.vida:
			enemigo_objetivo = enemigos_en_area[i]
	
	print("Aplicando daño de 50 a:", enemigo_objetivo.name)
	enemigo_objetivo.recibir_daño(50)
	if enemigo_objetivo.vida <= 0:
		print(enemigo_objetivo.name, "ha sido derrotado.")
		enemigos_vivos.erase(enemigo_objetivo) # Quitar de la lista de vivos


func _on_Protagonista_ataque_realizado2():
	# ... (la lógica que tenías en _verificar_ataque se mantiene) ...
	# Asegúrate de usar 'enemigos_vivos' si es la lista que gestionas
	if not is_instance_valid(protagonista): return
	var pos_protagonista = protagonista.position
	var casillas_adyacentes = [ # Copiado de tu lógica original
		pos_protagonista + Vector2(grid_size.x, 0),
		pos_protagonista + Vector2(-grid_size.x, 0),
		pos_protagonista + Vector2(0, grid_size.y),
		pos_protagonista + Vector2(0, -grid_size.y)
	]
	var enemigos_en_area = []
	for enemigo in enemigos_vivos: # Usar la lista actualizada
		if is_instance_valid(enemigo) and enemigo.position.snapped(grid_size) in casillas_adyacentes:
			enemigos_en_area.append(enemigo)
	
	if enemigos_en_area.is_empty(): return
	var enemigo_objetivo = enemigos_en_area[0]
	for i in range(1, enemigos_en_area.size()):
		if enemigos_en_area[i].vida < enemigo_objetivo.vida:
			enemigo_objetivo = enemigos_en_area[i]
	
	print("Aplicando daño de 100 a:", enemigo_objetivo.name)
	enemigo_objetivo.recibir_daño(100)
	if enemigo_objetivo.vida <= 0:
		print(enemigo_objetivo.name, "ha sido derrotado.")
		enemigos_vivos.erase(enemigo_objetivo) # Quitar de la lista de vivos

func _on_Protagonista_ataque_realizado3():
	# ... (la lógica que tenías en _verificar_ataque se mantiene) ...
	# Asegúrate de usar 'enemigos_vivos' si es la lista que gestionas
	if not is_instance_valid(protagonista): return
	var pos_protagonista = protagonista.position
	var casillas_adyacentes = [ # Copiado de tu lógica original
		pos_protagonista + Vector2(grid_size.x, 0),
		pos_protagonista + Vector2(-grid_size.x, 0),
		pos_protagonista + Vector2(0, grid_size.y),
		pos_protagonista + Vector2(0, -grid_size.y)
	]
	var enemigos_en_area = []
	for enemigo in enemigos_vivos: # Usar la lista actualizada
		if is_instance_valid(enemigo) and enemigo.position.snapped(grid_size) in casillas_adyacentes:
			enemigos_en_area.append(enemigo)
	
	if enemigos_en_area.is_empty(): return
	var enemigo_objetivo = enemigos_en_area[0]
	for i in range(1, enemigos_en_area.size()):
		if enemigos_en_area[i].vida < enemigo_objetivo.vida:
			enemigo_objetivo = enemigos_en_area[i]
	
	print("Aplicando daño de 200 a:", enemigo_objetivo.name)
	enemigo_objetivo.recibir_daño(200)
	if enemigo_objetivo.vida <= 0:
		print(enemigo_objetivo.name, "ha sido derrotado.")
		enemigos_vivos.erase(enemigo_objetivo) # Quitar de la lista de vivos

func es_posicion_valida(pos: Vector2) -> bool:
	# Evita que el protagonista se mueva a donde hay enemigos
	if enemigos_vivos.size() > 0:
		for enemigo in enemigos_vivos:
			if enemigo.position == pos:
				print("Posición ocupada por enemigo en:", enemigo.position)
				return false

	# Verifica si hay un objeto en la casilla
	if items.size() > 0:
		for item in items:
			if item.position == pos:
				print("Posición contiene un power-up en:", item.position)
				return true  # Puede moverse y recogerlo

	return true

func _encontrar_enemigo_mas_debil_en_area(pos_centro: Vector2, area_rel: Array[Vector2]) -> CharacterBody2D:
	var casillas_absolutas: Array[Vector2] = []
	return null

func verificar_powerup():
	var items_a_eliminar = []

	# Primero, marcamos los items que serán eliminados
	for item in items:
		if is_instance_valid(item) and is_instance_valid(protagonista) and protagonista.position == item.position:
			print("Protagonista recogió un power-up en:", item.position)
			protagonista.activar_powerup()
			items_a_eliminar.append(item)

	# Luego, eliminamos los items de la lista y de la escena
	for item in items_a_eliminar:
		if is_instance_valid(item):  # Verificar antes de borrar
			items.erase(item)  # Eliminar de la lista
			item.call_deferred("queue_free")  # Posponer la eliminación
