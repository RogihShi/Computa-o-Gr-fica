extends Node2D

# --- 1. Variáveis ---
var triangulo_verts = PackedVector2Array()
var hexagono_verts = PackedVector2Array()
var estrela_verts = PackedVector2Array()

# Variáveis de cor para o clique do mouse 
var cor_contorno = Color.GOLD
var cores_interpoladas = PackedColorArray()

# --- Texturas para o tile ---
var textura_listras : Texture2D = load("res://listras.jpg")
var textura_pontos : Texture2D = load("res://pontos.png")
var textura_tile : Texture2D = null  # vai ser alternada dinamicamente

var tiles_x := 4.0
var tiles_y := 4.0

func _ready():
	_setup_vertices()
	_gerar_cores_aleatorias()
	textura_tile = textura_listras  # começa com a textura de listras

# Função para criar os vértices dos polígonos 
func _setup_vertices():
	# Triângulo (centro em 0,0)
	triangulo_verts = PackedVector2Array([
		Vector2(0, -50), Vector2(-50, 50), Vector2(50, 50)
	])
	
	# Hexágono (centro em 0,0)
	hexagono_verts.resize(6)
	var hex_raio = 50.0
	for i in range(6):
		# 2 * PI é um círculo, / 6 dá os 6 pontos do hexágono
		var angulo = (2.0 * PI * i / 6.0)
		hexagono_verts[i] = Vector2(cos(angulo) * hex_raio, sin(angulo) * hex_raio)

	# Estrela de 5 pontas (centro em 0,0)
	estrela_verts.resize(10)
	var estrela_raio_ext = 50.0 # Raio das pontas externas
	var estrela_raio_int = 20.0 # Raio das pontas internas
	for i in range(10):
		# Alterna entre raio externo e interno
		var raio = estrela_raio_ext if i % 2 == 0 else estrela_raio_int
		# 2 * PI / 10 dá os 10 pontos. - (PI / 2.0) ajusta para apontar p/ cima
		var angulo = (2.0 * PI * i / 10.0) - (PI / 2.0) 
		estrela_verts[i] = Vector2(cos(angulo) * raio, sin(angulo) * raio)

# Função para gerar cores aleatórias
func _gerar_cores_aleatorias():
	cor_contorno = Color(randf(), randf(), randf())
	
	# Limpa o array e adiciona 10 novas cores
	# (usamos 10 pois é o máximo de vértices que temos, na estrela)
	cores_interpoladas.clear()
	for i in range(10):
		cores_interpoladas.append(Color(randf(), randf(), randf()))


# --- 3. Desenho (o "coração" do script) ---
# Esta função é chamada pelo Godot sempre que a tela precisa ser redesenhada
func _draw():
	# Define posições base para organizar as 3 formas na tela
	var pos_tri = Vector2(150, 150)
	var pos_hex = Vector2(150, 350)
	var pos_estrela = Vector2(150, 550)
	
	# Distância horizontal entre os 3 modos de desenho
	var offset_desenho = Vector2(400, 0)
	
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color.GAINSBORO, true)
	# --- Triângulo ---
	# 1. Contorno [cite: 204]
	desenhar_contorno(triangulo_verts, pos_tri)
	# 2. Interpolação [cite: 205]
	desenhar_interpolado(triangulo_verts, pos_tri + offset_desenho, 3)
	# 3. Textura 
	desenhar_tileado(triangulo_verts, pos_tri + offset_desenho * 2)

	# --- Hexágono ---
	# 1. Contorno [cite: 204]
	desenhar_contorno(hexagono_verts, pos_hex)
	# 2. Interpolação [cite: 205]
	desenhar_interpolado(hexagono_verts, pos_hex + offset_desenho, 6)
	# 3. Textura 
	desenhar_tileado(hexagono_verts, pos_hex + offset_desenho * 2)
	
	# --- Estrela ---
	# 1. Contorno [cite: 204]
	desenhar_contorno(estrela_verts, pos_estrela)
	# 2. Interpolação [cite: 205]
	desenhar_interpolado(estrela_verts, pos_estrela + offset_desenho, 10)
	# 3. Textura 
	desenhar_tileado(estrela_verts, pos_estrela + offset_desenho * 2)


# --- 4. Funções Auxiliares de Desenho ---

# Aplica uma posição de offset a um array de vértices
func _transformar_verts(verts: PackedVector2Array, pos: Vector2) -> PackedVector2Array:
	var transformados = PackedVector2Array()
	for v in verts:
		transformados.append(v + pos) # Simplesmente soma a posição
	return transformados

# Desenha o contorno de um polígono [cite: 204]
func desenhar_contorno(verts: PackedVector2Array, pos: Vector2):
	var verts_fechados = verts.duplicate()
	verts_fechados.append(verts[0]) # Adiciona o primeiro ponto no final para fechar
	
	var verts_transformados = _transformar_verts(verts_fechados, pos)
	
	# draw_polyline é o método para desenhar contornos [cite: 85]
	draw_polyline(verts_transformados, cor_contorno, 2.0)

# Desenha um polígono com cores interpoladas [cite: 205]
func desenhar_interpolado(verts: PackedVector2Array, pos: Vector2, num_cores: int):
	# Pega só o número de cores que precisamos para esta forma
	var cores_para_forma = cores_interpoladas.slice(0, num_cores)
	var verts_transformados = _transformar_verts(verts, pos)
	
	# draw_polygon é o método para interpolação [cite: 85]
	draw_polygon(verts_transformados, cores_para_forma)

# Desenha um polígono com textura tileada 
func desenhar_tileado(verts: PackedVector2Array, pos: Vector2):
	var verts_transformados = _transformar_verts(verts, pos)
	
	# Precisamos calcular os UVs (coordenadas da textura)
	# Vamos mapear os vértices para um "tile" de 4x4
	var uvs = PackedVector2Array()
	
	# Calcula os limites (bounding box) da forma para mapear os UVs
	var bounds = Rect2(verts[0], Vector2.ZERO)
	for v in verts:
		bounds = bounds.expand(v)
	
	for v in verts:
		var uv = (v - bounds.position) / bounds.size # Mapeia de 0.0 a 1.0
		uvs.append(Vector2(uv.x * tiles_x, uv.y * tiles_y))
		
	# Usamos draw_polygon novamente, mas passando os UVs e a textura
	draw_polygon(verts_transformados, PackedColorArray([Color.WHITE]), uvs, textura_tile)


# --- 5. Interação ---
# Detecta inputs do usuário 
func _input(event):
	# Verifica se foi um clique do botão esquerdo do mouse [cite: 92]
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_gerar_cores_aleatorias() # Gera novas cores
		queue_redraw() # Força o Godot a chamar _draw() novamente
		
		# Alterna as texturas
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_1:
				textura_tile = textura_listras
				queue_redraw()
			KEY_2:
				textura_tile = textura_pontos
				queue_redraw()

			# Aumenta/diminui tiles pra testar
			KEY_UP:
				tiles_y += 1.0
				queue_redraw()
			KEY_DOWN:
				tiles_y = max(1.0, tiles_y - 1.0)
				queue_redraw()
			KEY_RIGHT:
				tiles_x += 1.0
				queue_redraw()
			KEY_LEFT:
				tiles_x = max(1.0, tiles_x - 1.0)
				queue_redraw()
