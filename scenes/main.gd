extends Node

# ゲームの状態を管理する ENUM
enum GameState {
	WAIT_SHOOTING, # ボールを打ち始めるのを待っている状態
	PLAYING, # ボールが動いている状態
	MISSING_BALL, # ボールを落として、ボールが画面に返ってくるまで
	GAME_CLEAR, # ゲームクリア
}

var game_state: GameState = GameState.WAIT_SHOOTING
var game_tension: int = 1

var initial_blocks_count: int # 最初のブロック数
var remaining_blocks_count: int # 残りブロック数
var paddle_hit_combo: int = 0 # パドルに当たった回数（ボールが落ちるとリセットされる）
var block_hit_combo: int = 0 # ブロックに当たったコンボ数（パドルに当たるか、ボールが落ちるとリセットされる）
var max_block_hit_combo: int = 0 # ブロックに当たった最大コンボ数

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_blocks_count = $Level1_Blocks.get_tree().get_nodes_in_group("Blocks").size()
	remaining_blocks_count = initial_blocks_count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if game_state == GameState.WAIT_SHOOTING:
		$Ball.position.x = $Paddle.position.x

func _input(event: InputEvent) -> void:
	if game_state == GameState.WAIT_SHOOTING:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			shoot_ball()
		elif event is InputEventKey and event.is_action_pressed("press_accept_key"):
			shoot_ball()

	if event is InputEventKey:
		if event.is_action_pressed("press_esc_key"):
			# タイトルに戻る
			GameManager.to_title_scene()

func shoot_ball() -> void:
	if game_state != GameState.WAIT_SHOOTING:
		return
	game_state = GameState.PLAYING
	calculate_tension()

# ゲームの緊張度。音楽とボールの速度に影響する
func calculate_tension() -> void:
	var tension: int = 1
	var remaining_rate: float = float(remaining_blocks_count) / initial_blocks_count

	# 残りブロック数が少ないほど緊張度が上がる
	if remaining_rate <= 0.1:
		tension = 5
	elif remaining_rate <= 0.3:
		tension = 4
	elif remaining_rate <= 0.6:
		tension = 3
	elif remaining_rate <= 0.9:
		tension = 2
	else:
		tension = 1

	# ブロックヒットの最大コンボ数に応じて緊張度を加算。ただし5より大きくはならない
	@warning_ignore("INTEGER_DIVISION")
	tension += max_block_hit_combo / 5
	tension = min(tension, 5)

	# パドルに10回以上当てていると緊張度が上がる
	if paddle_hit_combo >= 10 and tension == 5:
		tension = 7
	elif paddle_hit_combo >= 20:
		tension += 2
	elif paddle_hit_combo >= 10:
		tension += 1

	game_tension = tension
	$MainSyncMusic.set_music_by_level(tension)
	var speedup_base = $Ball.initial_speed / 10
	$Ball.speed = $Ball.initial_speed + tension * (randf_range(speedup_base * 0.8, speedup_base * 1.2)) + 2 * paddle_hit_combo + 10 * max_block_hit_combo

func _on_ball_block_hit() -> void:
	if game_state != GameState.PLAYING:
		return
	$BlockHitSE.play()
	remaining_blocks_count -= 1
	block_hit_combo += 1
	max_block_hit_combo = max(max_block_hit_combo, block_hit_combo)
	calculate_tension()

	if remaining_blocks_count == 0:
		# ゲームクリア時の処理
		game_state = GameState.GAME_CLEAR
		$MainSyncMusic.is_waiting_end_music = true
		var tween = get_tree().create_tween()
		tween.tween_property($Ball, "speed", $Ball.initial_speed, $MainSyncMusic.sec_for_next_bar)
		tween.tween_property($Ball, "speed", 0, $MainSyncMusic.BeatPerSec * 8)

func _on_ball_paddle_hit() -> void:
	if game_state != GameState.PLAYING:
		return
	$PaddleHitSE.play()
	paddle_hit_combo += 1
	block_hit_combo = 0
	calculate_tension()

func _on_ball_wall_hit() -> void:
	#$WallHitSE.play()
	pass

# ボールが落ちたときの処理
func _on_ball_missed() -> void:
	if game_state != GameState.PLAYING:
		return
	game_state = GameState.MISSING_BALL
	$MainSyncMusic.is_waiting_failed_music = true
	paddle_hit_combo = 0
	block_hit_combo = 0
	max_block_hit_combo = 0

func _on_main_failed_music_finished() -> void:
	game_state = GameState.WAIT_SHOOTING
	$MainSyncMusic.is_waiting_failed_music = false
	$MainSyncMusic.init_music_level()
	$MainSyncMusic.play()
	$Paddle.reset_position()
	$Ball.reset_position()

func _on_main_end_music_finished() -> void:
	GameManager.to_title_scene()
