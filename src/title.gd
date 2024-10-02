extends Control

var is_started = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("press_accept_key"):
			start_process()

func _on_start_button_pressed() -> void:
	start_process()

func start_process() -> void:
	if is_started:
		return

	print("Start button pressed")
	is_started = true

	$TransitionRect.visible = true
	var transition_sec = 0.4
	var tween = get_tree().create_tween()
	# トランジション用の黒い四角のアルファ値を徐々に上げる
	tween.tween_property($TransitionRect, "color:a", 1, transition_sec)
	# 同時に音楽をフェードアウト
	tween.parallel().tween_property($AudioStreamPlayer, "volume_db", -80, transition_sec)
	await tween.finished

	# トランジションの終わりとともにゲームへ移動
	get_tree().change_scene_to_file("res://main.tscn")
