extends Control


@onready var new_game: Button = $ButtonContainer/NewGame
@onready var quit: Button = $ButtonContainer/Quit
@onready var color_rect: ColorRect = $ColorRect
@onready var button_container: VBoxContainer = $ButtonContainer



@export var load_scene : PackedScene
@export var zoom_in_time : float = 3.0
@export var pause_time : float = 1.5






func _ready():
	var buttton_container_original_position = button_container.position
	
	new_game.connect("pressed", _new_game_button_pressed)
	new_game.connect("mouse_entered", new_game_button_hovered)
	new_game.connect("mouse_exited", new_game_button_not_hovered)
	color_rect.visible = true
	fade_in()


func _new_game_button_pressed():
	print("New_game Button pressed!!!")
	fade_out()
	await fade_out()
	get_tree().change_scene_to_packed(load_scene)


func fade_in():
	var color_tween = self.create_tween()
	color_tween.tween_interval(1.0)
	color_tween.tween_property(color_rect, "color:a", 0.0, 2.0)
	await color_tween.finished
	color_rect.visible = false
func fade_out():
	color_rect.visible = true
	var color_tween2 = self.create_tween()
	color_tween2.tween_interval(1.0)
	color_tween2.tween_property(color_rect, "color:a", 1.0, 2.0)
	await color_tween2.finished





func new_game_button_hovered():
	var new_game_font_size = new_game.get_theme_font_size("font_size")
	new_game_font_size = 1
	print(new_game_font_size)
	print("hovored")

func new_game_button_not_hovered():
	var new_game_font_size = new_game.get_theme_font_size("font_size")
	new_game_font_size = 16.0
	print("not hovored")
