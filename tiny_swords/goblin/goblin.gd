extends CharacterBody2D

var player_ref: CharacterBody2D = null

@export var move_speed: float = 192.0

func _physics_process(_delta) -> void:
	if player_ref == null:
		return
	
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	velocity = direction * move_speed
	move_and_slide()

func on_detection_area_body_entered(body):
	player_ref = body


func on_detection_area_body_exited(_body):
	player_ref = null
