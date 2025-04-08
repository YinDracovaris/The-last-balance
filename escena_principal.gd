extends Node2D

@onready var protagonista = $Protagonista
@onready var enemigos = [$Enemigo1]  # Agregar más enemigos si es necesario
@onready var items = [$Speed_potion]  # Agregar más objetos si es necesario

func _ready():
	protagonista.connect("ataque_realizado", Callable(self, "_verificar_ataque"))
	print("Escena inicializada. Protagonista en:", protagonista.position)

func _process(delta):
	# Revisar si el protagonista pisa un objeto
	verificar_powerup()

func _verificar_ataque(posicion_ataque):
	print("Verificando si hay enemigos en:", posicion_ataque)
	if enemigos.size() > 0:
		for enemigo in enemigos:
			print("Revisando enemigo en:", enemigo.position)
			if enemigo.position == posicion_ataque:
				print("Enemigo alcanzado, aplicando daño.")
				enemigo.recibir_daño(50)

func es_posicion_valida(pos: Vector2) -> bool:
	# Evita que el protagonista se mueva a donde hay enemigos
	if enemigos.size() > 0:
		for enemigo in enemigos:
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
