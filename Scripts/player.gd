extends CharacterBody2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Node2D = $Gun
@onready var player: CharacterBody2D = $"."


@export var health := 6
@export var speed = 400.0
@export var invicibilty := false


const dodge_duration := 0.3
var dodge_timer := 0.0
var dodge_direction: Vector2 = Vector2.ZERO

var animation_direction: String = "Idle.F"
enum Direction {RIGHT, LEFT, UP, DOWN, RIGHT_UP, RIGHT_DOWN, LEFT_UP, LEFT_DOWN}
var last_direction : Direction

#movement
func get_input():
	animated_sprite.play(animation_direction)
	var input_direction = Input.get_vector("Left","Right","Up","Down")
	velocity = speed * input_direction
#running animation
	if velocity != Vector2.ZERO:
		var rounded_input = Vector2(
			int(round(input_direction.x)),
			int(round(input_direction.y))
		)
		match rounded_input:
			Vector2.RIGHT:
				animation_direction = "R.Run"
				last_direction = Direction.RIGHT
				gun.position.x = 92
			Vector2.LEFT:
				animation_direction = "L.Run"
				last_direction = Direction.LEFT
				gun.position.x = -92
			Vector2.UP:
				animation_direction = "U.Run"
				last_direction = Direction.UP
			Vector2.DOWN:
				animation_direction = "D.Run"
				last_direction =Direction.DOWN
			Vector2(1,1):
				animation_direction = "RD.Run"
				last_direction = Direction.RIGHT_DOWN
				gun.position.x = 92
			Vector2(1,-1):
				animation_direction = "RU.Run"
				last_direction = Direction.RIGHT_UP
				gun.position.x = 92
			Vector2(-1,1):
				animation_direction = "LD.Run"
				last_direction =Direction.LEFT_DOWN
				gun.position.x = -92
			Vector2(-1,-1):
				animation_direction = "LU.Run"
				last_direction =Direction.LEFT_UP
				gun.position.x = -92
	#Idle
	else:
		match last_direction:
			Direction.RIGHT:
				animation_direction = "Idle.R"
			Direction.LEFT:
				animation_direction = "Idle.L"
			Direction.UP:
				animation_direction = "Idle.B"
			Direction.DOWN:
				animation_direction = "Idle.F"
			Direction.RIGHT_UP:
				animation_direction = "Idle.RU"
			Direction.RIGHT_DOWN:
				animation_direction = "Idle.RD"
			Direction.LEFT_UP:
				animation_direction = "Idle.LU"
			Direction.LEFT_DOWN:
				animation_direction = "Idle.LD"
	
	#when dodge button is pressed
	if Input.is_action_just_pressed("Dodge"):
		if velocity != Vector2.ZERO:
			dodge(input_direction)
		else:
			match last_direction:
				Direction.RIGHT:
					dodge(Vector2.RIGHT)
				Direction.LEFT:
					dodge(Vector2.LEFT)
				Direction.UP:
					dodge(Vector2.UP)
				Direction.DOWN:
					dodge(Vector2.DOWN)
				Direction.RIGHT_UP:
					dodge(Vector2(1,-1))
				Direction.RIGHT_DOWN:
					dodge(Vector2(1,1))
				Direction.LEFT_UP:
					dodge(Vector2(-1,-1))
				Direction.LEFT_DOWN:
					dodge(Vector2(-1,1))
			
#dodge
func dodge(direction): 
	speed = 750.0
	dodge_direction = direction
	dodge_timer = dodge_duration
	invicibilty = true
	player.remove_child(gun)
	
	animated_sprite.speed_scale = 1.0/dodge_duration
	if direction.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	animated_sprite.play("Dodge")

#rules and logic behind the dodge
func dodge_logic(delta: float) -> void: 
	var elapsed_percent = 1.0 - (dodge_timer/dodge_duration)
	var current_speed = lerp(speed, speed * 0.5, elapsed_percent)
	
	velocity = dodge_direction * current_speed
	
	dodge_timer -= delta

	if dodge_timer <= 0:
		speed = 400
		animated_sprite.speed_scale = 1.0
		dodge_direction = Vector2.ZERO
		invicibilty = false
		animated_sprite.flip_h = false
		player.add_child(gun)
		
func _physics_process(delta):
	if dodge_timer > 0.0:
		dodge_logic(delta)
	else:
		get_input()
	move_and_slide()
	
