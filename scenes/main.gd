extends Node

# ゲームの状態を管理する ENUM
enum GameState {
	WAIT_SHOOTING, # ボールを打ち始めるのを待っている状態
	PLAYING, # ボールが動いている状態
	MISSING_BALL, # ボールを落として、ボールが画面に返ってくるまで
	GAME_CLEAR, # ゲームクリア
}

var game_state: GameState = GameState.WAIT_SHOOTING

# 残りブロック数
var remaining_blocks_count: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remaining_blocks_count = $Level1_Blocks.get_tree().get_nodes_in_group("Blocks").size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("press_esc_key"):
			# タイトルに戻る
			GameManager.to_title_scene()

func _on_ball_block_hit() -> void:
	$BlockHitSE.play()

	remaining_blocks_count -= 1
	if remaining_blocks_count == 0:
		game_state = GameState.GAME_CLEAR
		$Ball.speed = 10
		$MainSyncMusic.is_waiting_end_music = true

func _on_ball_paddle_hit() -> void:
	$PaddleHitSE.play()

func _on_ball_wall_hit() -> void:
	#$WallHitSE.play()
	pass

func _on_ball_edge_hit() -> void:
	game_state = GameState.MISSING_BALL
	$MainSyncMusic.is_waiting_failed_music = true

func _on_main_failed_music_finished() -> void:
	game_state = GameState.WAIT_SHOOTING
	$MainSyncMusic.is_waiting_failed_music = false
	$MainSyncMusic.play()

func _on_main_end_music_finished() -> void:
	GameManager.to_title_scene()
