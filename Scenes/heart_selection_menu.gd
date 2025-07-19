extends Control

@onready var background: TextureRect = $Background
@onready var texture_button: TextureButton = $TextureButton

@onready var arrow_button_left: TextureButton = $Arrow_button_left
@onready var arrow_button_right: TextureButton = $Arrow_button_right

@onready var currentpositioninlist = 1

#TeleportPositions
@onready var teleport_position_left: Node2D = $TeleportPositions/Teleport_position_left
@onready var teleport_position_right: Node2D = $TeleportPositions/Teleport_position_right
@onready var teleport_position_middle: Node2D = $TeleportPositions/Teleport_position_middle
@onready var teleport_position_outside_left: Node2D = $TeleportPositions/Teleport_position_outside_left
@onready var teleport_position_outside_right: Node2D = $TeleportPositions/Teleport_position_outside_right

#Hearts
@onready var prosthetic_heart: TextureRect = $Hearts/Prosthetic_Heart
@onready var normal_heart: TextureRect = $Hearts/Normal_Heart
@onready var lobotomy_heart: TextureRect = $Hearts/Lobotomy_Heart

func _ready():
	arrow_button_left.connect("pressed", arrow_button_pressed(1.0))
	arrow_button_right.connect("pressed", arrow_button_pressed(-1.0))


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

func arrow_button_pressed(move_direction):
	if move_direction == 1.0:
		if i - move_direction != 
	var lefttween = self.create_tween()
