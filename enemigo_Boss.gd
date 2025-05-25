extends CharacterBody2D

@export var vida: int = 500
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("Idle")
	get_parent().get_node("Protagonista").connect("ataque_realizado", Callable(self, "_verificar_ataque"))
	print("Enemigo inicializado en posición:", position)

#func _verificar_ataque(posicion_ataque):
#	print("Revisando ataque en:", posicion_ataque, " | Mi posición:", position)
#	if position == posicion_ataque:
#		print("¡Enemigo ha sido atacado!")
#		recibir_daño(100)

func recibir_daño(cantidad):
	vida -= cantidad
	print("Enemigo recibió daño. Vida restante:", vida)
	if vida > 0:
		sprite.play("Hurt")
		await sprite.animation_finished
		sprite.play("Idle")
	else:
		morir()

func morir():
	print("Enemigo ha muerto. Eliminando...")
	sprite.play("Death")
	await sprite.animation_finished
	queue_free()
