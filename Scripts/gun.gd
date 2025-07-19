extends Node2D

#all the nodes functions
const bullet = preload("res://Scenes/bullets.tscn")
@onready var gun: StaticBody2D = $"."
@onready var pistol: Sprite2D = $Pistol
@onready var bare_hand: Sprite2D = $Bare_Hand
@onready var smg: Sprite2D = $Smg
@onready var shotgun: Sprite2D = $Shotgun
@onready var sniper: Sprite2D = $Sniper
@onready var pistol_fire: AnimatedSprite2D = $Pistol/Pistol_fire
@onready var smg_fire: AnimatedSprite2D = $Smg/Smg_fire
@onready var shotgun_fire: AnimatedSprite2D = $Shotgun/Shotgun_fire
@onready var sniper_fire: AnimatedSprite2D = $Sniper/Sniper_fire


#weapon state
enum Weapon {PISTOL,SMG,SHOTGUN,SNIPER,BARE_HAND}
var weapon_in_hand : Weapon = Weapon.SMG

var reload_timer := 0.0


#dictionary for the guns and the attributes 

@export var weapons = {
	"pistol": 
		{
	 	"ammo" = 8,
	 	"weapon_fire_speed" = 0.75,
	 	"reload_speed" = 1.0,
		"push" = 2000,
		"knockback_dur" = 0.1},
	"smg": 
		{
		 "ammo" = 40,
		 "weapon_fire_speed" = 0.1,
		 "reload_speed" = 0.7,
		 "push" = 1000,
		"knockback_dur" = 0.1},
	"shotgun": 
		{
		 "ammo" = 5, 
		 "weapon_fire_speed" = 1.5,
		 "reload_speed" = 2.0,
		 "push" = 5000,
		"knockback_dur" = 0.2},
	"sniper": 
		{
		 "ammo" = 3,
		 "weapon_fire_speed" = 2.0,
		 "reload_speed" = 0.2,
		 "push" = 8000,
		"knockback_dur" = 0.2},
	"bare_hand":
		{
		 "ammo" = 0,
		 "weapon_fire_speed" = 0.0,
		 "reload_speed" = 0.0,
		 "push" = 0.0}
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
		

		
func _ready() -> void:
	for n in gun.get_children():
		gun.remove_child(n)
	

	
func _physics_process(delta: float) -> void:

	match get_weapon_key():
		"pistol":
			if not pistol.get_parent():gun.add_child(pistol)
			if not pistol_fire.get_parent():gun.add_child(pistol_fire)
			pistol_fire.play("Idle")
		"smg":
			if not smg.get_parent():gun.add_child(smg)
			if not smg_fire.get_parent():gun.add_child(smg_fire)
			smg_fire.play("Idle")
		"shotgun":
			if not shotgun.get_parent():gun.add_child(shotgun)
			if not shotgun_fire.get_parent():gun.add_child(shotgun_fire)
			shotgun_fire.play("Idle")
		"sniper":
			if not sniper.get_parent():gun.add_child(sniper)
			if not sniper_fire.get_parent():gun.add_child(sniper_fire)
			sniper_fire.play("Idle")
		"bare_hand":
			if not bare_hand.get_parent():gun.add_child(bare_hand)
			
	look_at(get_global_mouse_position())
	if position.x > 0:
		rotation_degrees = clamp(rotation_degrees,-90,90)
		scale.y = 1
	else:
		rotation_degrees = clamp(rotation_degrees,90,270)
		scale.y = -1
	shoot(delta)
	
	
	
func shoot(delta):
	if Input.is_action_pressed("Shoot") and not is_shooting:
		if get_weapon_key() != "bare_hand":
			is_shooting = true
			animation_timer = weapons[get_weapon_key()]["weapon_fire_speed"]
			var bullet_instance = bullet.instantiate()
			
			apply_knockback()
			match get_weapon_key():
				"pistol":
					pistol_fire.play("Shooting")
					bullet_instance.type = Bullet.BulletType.PISTOL
					bullet_instance.global_position = $Pistol/aim.global_position
					bullet_instance.global_rotation  = $Pistol/aim.global_rotation
					get_tree().root.add_child(bullet_instance)	
				"smg":
					smg_fire.play("Shooting")
					bullet_instance.type = Bullet.BulletType.SMG
					bullet_instance.global_position = $Smg/aim.global_position
					bullet_instance.global_rotation  = $Smg/aim.global_rotation
					get_tree().root.add_child(bullet_instance)	
				"shotgun":
					for i in range(3):
						shotgun_fire.play("Shooting")
						var pellet = bullet.instantiate()
						pellet.type = Bullet.BulletType.SHOTGUN
						var spread_angle = deg_to_rad(randf_range(-5, 0))
						@warning_ignore("shadowed_variable_base_class")
						var transform = $Shotgun/aim.global_transform
						transform = transform.rotated(spread_angle)
						pellet.global_transform = transform
						get_tree().current_scene.add_child(pellet)

				"sniper":
					sniper_fire.play("Shooting")
					bullet_instance.type = Bullet.BulletType.SNIPER
					bullet_instance.global_position = $Sniper/aim.global_position
					bullet_instance.global_rotation  = $Sniper/aim.global_rotation
					get_tree().root.add_child(bullet_instance)	
			
		else:
			match get_weapon_key():
				"pistol":
					pistol_fire.play("Idle")
				"smg":
					smg_fire.play("Idle")
				"shotgun":
					shotgun_fire.play("Idle")
				"sniper":
					sniper_fire.play("Idle")

	if is_shooting:
		animation_timer -= delta
		if animation_timer <= 0:
			is_shooting = false
	

func apply_knockback():
	if is_shooting:
		var dir = (global_position - get_global_mouse_position()).normalized()
		var force = weapons[get_weapon_key()]["push"]
		var duration = weapons[get_weapon_key()].get("knockback_dur", 0.2)
		get_parent().apply_knockback(dir, force, duration)
	
	
