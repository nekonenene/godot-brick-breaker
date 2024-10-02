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
			GameManager.to_title_scene()

func _on_ball_block_hit() -> void:
	$PaddleHitSE.play()

func _on_ball_paddle_hit() -> void:
	$BlockHitSE.play()

func _on_ball_wall_hit() -> void:
	#$WallHitSE.play()
	pass
