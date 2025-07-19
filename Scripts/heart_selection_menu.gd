extends Control

@onready var background: TextureRect = $Background
@onready var texture_button: TextureButton = $TextureButton

@onready var arrow_button_left: TextureButton = $Arrow_button_left
@onready var arrow_button_right: TextureButton = $Arrow_button_right

@onready var i = 1



#TeleportPositions
@onready var teleport_position_left: Node2D = $TeleportPositions/Teleport_position_left
@onready var teleport_position_right: Node2D = $TeleportPositions/Teleport_position_right
@onready var teleport_position_middle: Node2D = $TeleportPositions/Teleport_position_middle
@onready var teleport_position_outside_left: Node2D = $TeleportPositions/Teleport_position_outside_left
@onready var teleport_position_outside_right: Node2D = $TeleportPositions/Teleport_position_outside_right

#Hearts
@export var amount_of_hearts = 3
@onready var prosthetic_heart: TextureRect = $Hearts/Prosthetic_Heart
@onready var normal_heart: TextureRect = $Hearts/Normal_Heart
@onready var lobotomy_heart: TextureRect = $Hearts/Lobotomy_Heart


#Positions:
var pos_prosthetic_heart = 0
var pos_normal_heart = 0
var pos_lobotomy_heart = 0



func _ready():
	arrow_button_left.connect("pressed", arrow_button_pressed_left)
	arrow_button_right.connect("pressed", arrow_button_pressed_right)


@export var hearts = {
	"prosthetic_heart":
		{
		"Description": 
			{
			"something" = "Prosthetic funny",
			},
		},
	"normal_heart": 
		{
		"Description":
			{
			"something" = "Normal funny",
			},
		},
	"lobotomy_heart":
		{
		"Description":
			{
			"something" = "Lobotomy funny",
			},
		},
}

func _process(delta: float):
	for n in $Hearts.get_children():
		if n.name != Heart_keys[i]:
			n.position = n.position + Vector2(distance, 0)
		elif n.name == Heart_keys[(i - move_direction)]:
			n.position = n.positon.lerp(n.position, Vector2(distance + n.position.x, 100 + n.position.y), 0.01)
		else:
			n.position = n.position.lerp(n.position, Vector2(distance + n.position.x, -100 + n.position.y), 0.01)






func arrow_button_pressed_left():
	var move_direction = 1.0
	var Heart_keys = hearts.keys()
	if move_direction == 1.0:
		var distance = 371.0
		if i - move_direction != -1:
			for n in $Hearts.get_children():
				if n.name != Heart_keys[i]:
					n.position = n.position + Vector2(distance, 0)
				elif n.name == Heart_keys[(i - move_direction)]:
					n.position = n.positon.lerp(n.position, Vector2(distance + n.position.x, 100 + n.position.y), 0.01)
				else:
					n.position = n.position.lerp(n.position, Vector2(distance + n.position.x, -100 + n.position.y), 0.01)
			i -= move_direction




func arrow_button_pressed_right():
	var Heart_keys = hearts.keys()
	var move_direction = -1.0
	var distance = -371.0
	if i - move_direction > amount_of_hearts:
		for n in $Hearts.get_children():
			if n.name != Heart_keys[i]:
				n.position = n.position + Vector2(distance, 0)
			elif n.name == Heart_keys[i - move_direction]:
				n.position = n.position.lerp(n.position, Vector2(distance + n.position.x, 100 + n.position.y), 0.01)
			else:
				n.position = n.position.lerp(n.position, Vector2(distance + n.position.x, -100 + n.position.y), 0.01)
		i -= move_direction
