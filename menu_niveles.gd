extends Control


func _on_btn_nivel_11_button_up():
	get_tree().change_scene_to_file("res://escena_principal_campo.tscn")


func _on_btn_nivel_12_button_up():
	get_tree().change_scene_to_file("res://escena_principal_dungeon.tscn")


func _on_btn_nivel_13_button_up():
	get_tree().change_scene_to_file("res://escena_principal_templo.tscn")


func _on_btn_regresar_button_up():
	get_tree().change_scene_to_file("res://Menu_Principal.tscn")
