extends Control

func _ready():
	hide()
	# Conectamos las señales de los botones a las funciones de este script
	$VBoxContainer/BotonReanudar.pressed.connect(_on_ResumeButton_pressed)
	# Asegúrate que la ruta a QuitButton sea correcta si cambiaste la estructura
	$VBoxContainer/BotonMenuPrincipal.pressed.connect(_on_QuitButton_pressed)
	# Si tienes un botón de opciones, conéctalo también:
	$VBoxContainer/BotonOpciones.pressed.connect(_on_OptionsButton_pressed)

func _input(event):
	# Permite cerrar el menú de pausa también con la tecla Escape (o la acción de pausa)
	if event.is_action_pressed("PAUSA") and visible: # "ui_cancel" es comúnmente Escape
		_on_ResumeButton_pressed()

func _on_ResumeButton_pressed():
	get_tree().paused = false # Reanuda el juego
	hide() # Esconde el menú

func _on_QuitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menu_Principal.tscn")

func _on_OptionsButton_pressed():
	# Pendiente
	print("Botón de Opciones presionado")

func show_menu():
	show()
	get_tree().paused = true # Pausa el juego
