extends CharacterBody3D

@export var speed = 5.0
@export var rotation_speed = 3.0

var gravity = 9.8

# referência ao pivô da câmera
@onready var camera_rig = $CameraRig

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- Rotação da Câmera ---
	# Pega o input das ações "camera_left" e "camera_right"
	var rotation_input = Input.get_axis("camera_left", "camera_right")
	
	# Gira o nó "CameraRig" em torno do eixo Y
	camera_rig.rotate_y(-rotation_input * rotation_speed * delta)


	# --- Movimento Relativo à Câmera ---
	# Pega o input de movimento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Pega a base de transformação (eixos X, Y, Z) do *pivô da câmera*
	var camera_basis = camera_rig.global_transform.basis

	# Calcula a direção do movimento:
	# input_dir.y (W/S) controla o movimento "frente/trás" (basis.z)
	# input_dir.x (A/D) controla o movimento "esquerda/direita" (basis.x)
	var direction = (camera_basis.z * input_dir.y) + (camera_basis.x * input_dir.x)

	direction.y = 0
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 2.0)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 2.0)
	move_and_slide()
