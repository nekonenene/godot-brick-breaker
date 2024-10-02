extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("press_esc_key"):
			# タイトルに戻る
			get_tree().change_scene_to_file("res://src/title.tscn")
