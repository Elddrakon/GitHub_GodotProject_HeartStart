extends Node2D

#all the nodes functions

@onready var gun: Node2D = $"."
@onready var pistol: Sprite2D = $Pistol
@onready var bare_hand: Sprite2D = $Bare_Hand
@onready var smg: Sprite2D = $Smg
@onready var shotgun: Sprite2D = $Shotgun
@onready var sniper: Sprite2D = $Sniper

@onready var pistol_fire: AnimatedSprite2D = $Pistol/Pistol_fire

#weapon state
enum Weapon {PISTOL,SMG,SHOTGUN,SNIPER,BARE_HAND}
var weapon_in_hand = Weapon 

#dictionary for the guns and the attributes 

@export var weapons = {
	"pistol": 
		{"damage" = 10,
	 	"ammo" = 8,
	 	"shooting_speed" = 5.0,
	 	"weapon_fire_speed" = 0.5,
	 	"reload_speed" = 1.0},
	"smg": 
		{"damage" = 3,
		 "ammo" = 40,
		 "shooting_speed" = 20.0,
		 "weapon_fire_speed" = 0.125,
		 "reload_speed" = 0.7},
	"shotgun": 
		{"damage" = 30,
		 "ammo" = 5, 
		"shooting_speed" = 2.5,
		 "weapon_fire_speed" = 1.0,
		 "reload_speed" = 2.0},
	"sniper": 
		{"damage" = 50,
		 "ammo" = 3,
		 "shooting_speed" = 1.0,
		 "weapon_fire_speed" = 2.5,
		 "reload_speed" = 3.0},
	"bare_hand":
		{"damage" = 0,
		 "ammo" = 0,
		 "shooting_speed" = 0.0,
		 "weapon_fire_speed" = 0.0,
		 "reload_speed" = 0.0}
}

# 
var animation_timer = 0.0
var is_shooting = false

#key from the dictionary
func get_weapon_key():
	match weapon_in_hand:
		Weapon.PISTOL: return "pistol"
		Weapon.SMG: return "smg"
		Weapon.SHOTGUN: return "shotgun"
		Weapon.SNIPER: return "sniper"
		Weapon.BARE_HAND: return "bare_hand"
		
var key = get_weapon_key()
		
func _ready() -> void:
	for n in gun.get_children():
		gun.remove_child(n)
		
	key = "pistol"
	
func _process(delta: float) -> void:
	match key:
		"pistol":
			if not pistol.get_parent():gun.add_child(pistol)
		
	look_at(get_global_mouse_position())
	if position.x > 0:
		rotation_degrees = clamp(rotation_degrees,-90,90)
		scale.y = 1
	else:
		rotation_degrees = clamp(rotation_degrees,90,270)
		scale.y = -1
	shoot_animation(delta)
		
		
func shoot_animation(delta):
	if Input.is_action_pressed("Shoot") and not is_shooting:
		is_shooting = true
		animation_timer = weapons[key]["weapon_fire_speed"]
		pistol_fire.play("shoot")
	
	if is_shooting:
		animation_timer -= delta
		if animation_timer <= 0:
			is_shooting = false
			pistol_fire.stop()
			pistol_fire.play("Idle")  # Or stop+reset fram
	
