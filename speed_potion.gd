extends Area2D

@export var item_nombre: String = "Power-Up"

func _ready():
	print(item_nombre, " colocado en ", position)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Protagonista" and body.position == position:  # Ajusta según el nombre real
		print("Protagonista ha recogido el power-up.")
		body.activar_powerup()  # Llama al método en el protagonista
		queue_free()  # Elimina el objeto del mapa
