extends RigidBody2D
class_name Bullet
@onready var Bullet: Bullet = $"."

# Keep your original enum and dictionary names exactly the same
enum BulletType {PISTOL, SMG, SHOTGUN, SNIPER, ENEMY}
@export var type: BulletType = BulletType.PISTOL

# Keep your original bullets dictionary structure exactly the same
@export var bullets = {
	"pistol": {
		"damage": 10,
		"speed": 4000,
		"texture": preload("res://Assets/Guns/Bullets/Pistol_Bullet.png"),
		"is_player": true
	},
	"smg": {
		"damage": 3,
		"speed": 10000,
		"texture": preload("res://Assets/Guns/Bullets/SMG-Bullet.png"),
		"is_player": true
	},
	"shotgun": {
		"damage": 15,
		"speed": 3500,
		"texture": preload("res://Assets/Guns/Bullets/Shotgun_bullet.png"),
		"is_player": true,
		"scale": 2.0
	},
	"sniper": {
		"damage": 60,
		"speed": 8000,
		"texture": preload("res://Assets/Guns/Bullets/Sniper_bullet.png"),
		"is_player": true
	},
	"enemy": {
		"damage": 2,
		"speed": 3000,
		"texture": preload("res://Assets/Guns/Bullets/Shotgun_bullet.png"),
		"is_player": false,
		"scale": 2.0
	}
}

# Node references remain exactly the same
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Keep your original key property exactly the same
var key: String:
	get:
		match type:
			BulletType.PISTOL: return "pistol"
			BulletType.SMG: return "smg"
			BulletType.SHOTGUN: return "shotgun"
			BulletType.SNIPER: return "sniper"
			BulletType.ENEMY: return "enemy"
			_: return ""

func _ready():
	contact_monitor = true
	
	# First check if we have a valid key
	
	if key.is_empty() or not bullets.has(key):
		push_error("Invalid bullet type or missing bullet data")
		queue_free()
		return
	
	# Get the stats safely
	var stats = bullets.get(key, {})
	if stats.has("scale"):
		sprite.scale = Vector2(stats["scale"], stats["scale"])
	# Configure bullet based on type
	sprite.texture = stats.get("texture", null)
	
	# Set physics properties (unchanged)
	gravity_scale = 0
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	
	# Set collision layers based on bullet owner (unchanged)
	if stats.get("is_player", false):
		collision_layer = 3  # Player bullets
		collision_mask = 2   # Collide with enemies
	else:
		
		collision_layer = 4  # Enemy bullets
		collision_mask = 1   # Collide with player
	
	# Apply initial force (unchanged)
	apply_central_impulse(transform.x * stats.get("speed", 0))
	
	# Set lifetime (unchanged but added one_shot)
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _physics_process(_delta):
	# Rotate bullet to face movement direction (unchanged)
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()

func _on_body_entered(_body):
	# First check if we have valid bullet data
	if key.is_empty() or not bullets.has(key):
		queue_free()
		return
	var damage = bullets[key].get("damage", 0)
	
func bullet_damage():
	return bullets[key]["damage"]
	
