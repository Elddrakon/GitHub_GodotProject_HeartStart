extends Node2D
class_name Enemy

# Node references
@onready var gunhead: CharacterBody2D = $Gunhead
@onready var basic_enemy: CharacterBody2D = $Basic_enemy
@onready var enemy_sprite: AnimatedSprite2D = $Basic_enemy/Enemy_sprite
@onready var enemies: Node2D = $"."
@onready var aim: Area2D = $Gunhead/Head/Aim
@export var DEATH_PARTICALE: PackedScene
@onready var dasher: CharacterBody2D = $Dasher
@onready var dash: Area2D = $Dasher/Dash
@export var Damage_particales : PackedScene
# Arrays for hitboxes and detection areas
@onready var hitboxes := [
	$Basic_enemy/Hitbox,
	$Gunhead/Hitbox,
	$Dasher/Hitbox
]

@onready var detection_areas := [
	$Basic_enemy/Detection_area,
	$Gunhead/Detection_area,
	$Dasher/Detection_area
]

# Preload bullet scene
const BULLET_SCENE = preload("res://Scenes/bullets.tscn")

# Enemy types
enum EnemyType { BASIC, GUN, EXPLODE, DASH, TOXIC }
enum State { IDLE, CHASE }

# Enemy stats
@export var classes = {
	"basic_enemies": {
		"health": 20,
		"speed": 800,
		"attack_power": 1,
		"attack_speed": 0.3,
		"attack_duration": 5.0,
		"hitbox_damage": 1
	},
	"gun_head": {
		"health": 15,
		"speed": 200,
		"attack_power": 2,
		"attack_speed": 4000,
		"attack_duration": 3.0,
		"push": 3000,
		"hitbox_damage": 1
	},
	"biggie_boom": {
		"health": 50,
		"speed": 200,
		"attack_power": 4,
		"attack_speed": 2,
		"attack_duration": 5.0,
		"hitbox_damage": 2
	},
	"dasher": {
		"health": 80,
		"speed": 350,
		"attack_power": 2,
		"attack_speed": 3000,
		"attack_duration": 8.0,
		"hitbox_damage": 2
	},
	"toxic": {
		"health": 30,
		"speed": 300,
		"attack_power": 1,
		"attack_duration": 5.0,
		"hitbox_damage": 1
	}
}

# Enemy state
var type: EnemyType = EnemyType.DASH
var enemy_state: State = State.IDLE
var dead := false
var player_in_area := false
var should_attack := false
var player: Node2D = null
var timer := 0.0
var damage: int = 0
const dash_duration := 1
var dash_timer := 0.0
var chase_cooldown := 0


# Computed properties
var key: String:
	get:
		match type:
			EnemyType.BASIC: return "basic_enemies"
			EnemyType.GUN: return "gun_head"
			EnemyType.EXPLODE: return "biggie_boom"
			EnemyType.DASH: return "dasher"
			EnemyType.TOXIC: return "toxic"
			_: return ""

var detection_area: Area2D:
	get:
		match key:
			"basic_enemies": return detection_areas[0]
			"gun_head": return detection_areas[1]
			"dasher" : return detection_areas[2]
			_: return null

var hitbox: Area2D:
	get:
		match key:
			"basic_enemies": return hitboxes[0]
			"gun_head": return hitboxes[1]
			"dasher" : return hitboxes[2]
			_: return null

func _ready():
	initialize_enemy()

func initialize_enemy():
	should_attack = false
	timer = classes[key]["attack_duration"]
	enemy_state = State.IDLE

	# Clear existing children and add the appropriate one
	for child in enemies.get_children():
		enemies.remove_child(child)
		
	
	match key:
		"basic_enemies":
			if not basic_enemy.get_parent():
				enemies.add_child(basic_enemy)
		"gun_head":
			if not gunhead.get_parent():
				enemies.add_child(gunhead)
				aim.body_entered.connect(on_attack_body_entered)
				aim.body_exited.connect(on_attack_body_exited)
		"dasher":
			if not dasher.get_parent():
				enemies.add_child(dasher)
				dash.body_entered.connect(on_attack_body_entered)
				dash.body_exited.connect(on_attack_body_exited)  
	# Connect signals
	for area in detection_areas:
		area.body_entered.connect(_on_detection_area_body_entered)
		area.body_exited.connect(_on_detection_area_body_exited)

	for h_box in hitboxes:
		h_box.body_entered.connect(_on_hitbox_body_entered)

var health = classes[key]["health"]:
	set(value):
		health = clamp(value, 0, classes[key]["health"])
var speed = classes[key]["speed"]
func update_detection_area():
	if detection_area:
		detection_area.get_node("Range").disabled = dead


func dashing(_delta):
	speed = classes[key]["attack_speed"]
	dash_timer = dash_duration
	chase_cooldown = 1
	dasher.get_node('Dasher_sprite').play("Attack")
	dasher.get_node('Dasher_sprite').speed_scale = 1.0 * dash_timer
	var direction = (player.position - position).normalized()
	position += direction * classes[key]["attack_speed"] * _delta
	

	
func dash_logic(_delta):
	dash_timer -= _delta
	if dash_timer <= 0:
		speed = classes[key]["speed"]
		dasher.get_node('Dasher_sprite').speed_scale = 1.0 
func _physics_process(delta: float) -> void:
	if dead:
		return
	dash_logic(delta)
	timer -= delta
	determine_state()
	handle_state(delta)
	if should_attack:
		attack(delta)

func determine_state():
	if not player_in_area or not player:
		enemy_state = State.IDLE

	match key:
		"basic_enemies", "gun_head", 'dasher':
			enemy_state = State.CHASE if player_in_area else State.IDLE

func handle_state(delta: float):
	match enemy_state:
		State.CHASE:
			chase_player(delta)
		State.IDLE:
			play_idle_animation()

func chase_player(delta: float):
	if chase_cooldown > 0.0:
		chase_cooldown -= delta  # Count down
		return 
	
	var direction = (player.position - position).normalized()
	position += direction * speed * delta

	match key:
		"basic_enemies":
			enemy_sprite.flip_h = player.position.x < position.x
			enemy_sprite.play("Walking")
		"gun_head":
			var head = gunhead.get_node("Head")
			var body = gunhead.get_node("Body")
		

			body.flip_h = player.position.x < position.x
			body.play("Walking")
			head.play("Angry")

			# Head aiming logic
			var direction_head = (player.global_position - head.global_position).normalized()
			head.rotation = direction_head.angle()

			var deg = rad_to_deg(head.rotation)
			head.scale.y = -1 if deg > 90 or deg < -90 else 1
		"dasher":
			dasher.get_node('Dasher_sprite').flip_h = player.position.x < position.x
			dasher.get_node('Dasher_sprite').play("Walking")
			
func play_idle_animation():
	match key:
		"basic_enemies":
			enemy_sprite.play("Idle")
		"gun_head":
			gunhead.get_node("Head").play("Idle")
			gunhead.get_node("Body").play("Idle")
		"dasher":
			dasher.get_node('Dasher_sprite').play("Idle")

func attack(_delta: float):
	if timer > 0 and should_attack:
		should_attack = false
	elif timer <= 0 and should_attack:
		timer = classes[key]["attack_duration"]
		match key:
			"gun_head":
				var head = gunhead.get_node("Head")
				if head.animation != "Shooting":
					head.play("Shooting")

				var bullet_instance = BULLET_SCENE.instantiate()
				bullet_instance.type = Bullet.BulletType.ENEMY
				bullet_instance.global_position = $Gunhead/Head/Marker2D.global_position
				bullet_instance.global_rotation = $Gunhead/Head/Marker2D.global_rotation
				get_parent().add_child(bullet_instance)
				
			"dasher":
				dash_timer = dash_duration
				dashing(_delta)

func take_damage(amount: int):
	health -= amount
	if health <= 0 and not dead:
		pass
		death()

func death():
	if dead:
		return

	dead = true

	# Disconnect signals
	for area in detection_areas:
		if is_instance_valid(area):
			area.body_entered.disconnect(_on_detection_area_body_entered)
			area.body_exited.disconnect(_on_detection_area_body_exited)

	for h_box in hitboxes:
		if is_instance_valid(h_box):
			h_box.body_entered.disconnect(_on_hitbox_body_entered)

	# Spawn death particle
	var particale = DEATH_PARTICALE.instantiate()
	particale.position = global_position
	particale.rotation = global_rotation
	particale.emitting = true
	get_tree().current_scene.add_child(particale)

	# Free children
	for child in get_children():
		if is_instance_valid(child):
			child.queue_free()

	queue_free()

# Signal handlers
func _on_detection_area_body_entered(body: Node2D):
	if body.has_method("character"):
		player_in_area = true
		player = body

func _on_detection_area_body_exited(body: Node2D):
	if body.has_method("character"):
		player_in_area = false

func _on_hitbox_body_entered(body):
	var bullet_type = body.get("key")
	var hit_position = body.global_position  # fallback
	if body.has_method("get_collision_point"):
		hit_position = body.collision_point

	var particale = Damage_particales.instantiate()
	particale.position = hit_position
	particale.emitting = true
	get_tree().current_scene.add_child(particale)
	
	if body.has_method("bullet_damage"):
		if bullet_type != "sniper":
			body.queue_free()
		damage = body.bullet_damage()
		take_damage(damage)

func on_attack_body_entered(body: Node2D):
	if body.has_method("character"):
		should_attack = true
		
func on_attack_body_exited(body: Node2D):
	if body.has_method("character"):
		should_attack = false
