extends Control

func _on_btn_jugar_button_up():
	get_tree().change_scene_to_file("res://Menu_Niveles.tscn")


func _on_btn_configuracion_button_up():
	get_tree().change_scene_to_file("res://Menu_Configuracion.tscn")


func _on_btn_salir_button_up():
	get_tree().quit()
