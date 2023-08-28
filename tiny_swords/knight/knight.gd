extends CharacterBody2D

const AUDIO_TEMPLATE: PackedScene = preload("res://tiny_swords/management/audio_template.tscn")

@onready var animation: AnimationPlayer =  get_node("Animation")
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimationPlayer")
@onready var sprite: Sprite2D =  get_node("Sprite")
@onready var dust: GPUParticles2D = get_node("Dust")

@onready var attack_area_collision: CollisionShape2D = get_node("attackArea/Collision")

@export var move_speed: float = 256.0
@export var health: int = 10
@export var damage: int = 1

var can_attack: bool = true
var can_die: bool = false

func _ready()-> void:
	if(transition_screen.player_health != 0):
		health = transition_screen.player_health
		return 
	
	transition_screen.player_health = health

func _physics_process(_delta: float) -> void:
	if (
		can_attack == false or 
		can_die
	):
		return
		
	move()
	animate()
	attack_hancler()
	
func move() -> void:
	var direction : Vector2 =  get_direction()
	velocity = direction * move_speed
	move_and_slide()
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
func animate() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
		attack_area_collision.position.x = 60
		
	if velocity.x < 0:
		sprite.flip_h = true
		attack_area_collision.position.x = -60
	
	
	if velocity != Vector2.ZERO:
		dust.emitting = true
		animation.play("run")
		return 
	
	dust.emitting = false
	animation.play("idle")


func attack_hancler() -> void:
	if Input.is_action_just_pressed("attack") and can_attack:
		can_attack = false
		animation.play("attack")

func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate()
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
	

func on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_attack = true
		"death":
			transition_screen.fade_in()
			transition_screen.player_health = 0
			transition_screen.player_score = 0
			

func on_attack_area_body_entered(body):
	body.update_health(damage)
	

func update_health(value: int) -> void:
	health -= value
	transition_screen.player_health = health
	
	get_tree().call_group("level", "update_health", health)
	if (health <= 0):
		can_die = true
		animation.play("death")
		attack_area_collision.set_deferred("disabled", true)
		return
		
	aux_animation_player.play("hit")
