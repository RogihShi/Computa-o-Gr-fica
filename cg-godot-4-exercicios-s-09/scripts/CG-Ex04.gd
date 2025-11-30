extends SpotLight3D

# Função que detecta entrada de dados (teclado/mouse)
func _input(event):
	# Verifica se o evento foi um clique do botão esquerdo do mouse
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Cria uma cor aleatória
		# randf() gera um número entre 0.0 e 1.0 para Vermelho, Verde e Azul
		var nova_cor = Color(randf(), randf(), randf())
		
		# Aplica a cor à luz
		light_color = nova_cor
		print("Cor alterada para: ", nova_cor)
