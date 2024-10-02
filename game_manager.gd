extends Control

var title_scene = preload("res://scenes/title.tscn")
var main_scene = preload("res://scenes/main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func to_title_scene():
	get_tree().change_scene_to_packed(title_scene)

func to_main_scene():
	get_tree().change_scene_to_packed(main_scene)
