extends Button

func _on_pressed():
	# Troca para a cena do jogo (verifique se o caminho é esse mesmo)
	get_tree().change_scene_to_file("res://scenes/CG_Ex01.tscn")
