extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var vida: int = 70
@export var vida_maxima: int = 70
@onready var health_bar: ProgressBar = $VidaUI/HealthBar

signal ataque_realizado(posicion_ataque)

func _ready():
	sprite.flip_h = true
	sprite.play("Idle")
	get_parent().get_node("Protagonista").connect("ataque_realizado", Callable(self, "_verificar_ataque"))
	print("Enemigo inicializado en posición:", position)
	print("Vida Máxima Inicial (script): ", vida_maxima)
	print("Vida Actual Inicial (script): ", vida)
	if health_bar:
		health_bar.max_value = vida_maxima
		health_bar.value = vida
	else:
		print_rich("[color=red]Error:[/color] No se encontró el nodo HealthBar. Verifica la ruta en @onready.")

#func _verificar_ataque(posicion_ataque):
#	print("Revisando ataque en:", posicion_ataque, " | Mi posición:", position)
#	if position == posicion_ataque:
#		print("¡Protagonista ha sido atacado!")
#		recibir_daño(100)

func recibir_daño(cantidad: int): # Especifica el tipo de 'cantidad'

	vida -= cantidad
	vida = clampi(vida, 0, vida_maxima) # Asegura que la vida esté entre 0 y vida_maxima

	print("Enemigo ", name, " recibió daño. Vida: ", vida, "/", vida_maxima)
	actualizar_barra_vida()

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

func morir():
	print("Enemigo ha muerto. Eliminando...")
	sprite.play("Death")
	await sprite.animation_finished
	queue_free()
