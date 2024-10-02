extends CharacterBody2D

var initial_position: Vector2
var dragging: bool
var target_x: float = -1 # このX座標に向かって常にパドルは移動する
var distance_by_keyboard: float = 16 # キーボード操作の場合の移動幅

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# target_x と現在の位置が異なる場合に移動（マウスクリックを想定）
	if target_x != -1 and position.x != target_x:
		var diff = target_x - position.x
		#print("diff: ", diff)
		if abs(diff) > 1:
			var speed = 6
			var distance = log(abs(diff)) * speed
			if distance > abs(diff):
				distance = abs(diff)
			move_and_collide(Vector2(distance * (diff / abs(diff)), 0))

	# キーボード入力による移動
	if Input.is_action_pressed("move_right"):
		move_and_collide(Vector2(distance_by_keyboard, 0))
		target_x = position.x
	if Input.is_action_pressed("move_left"):
		move_and_collide(Vector2(-distance_by_keyboard, 0))
		target_x = position.x

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			#print("mouse pressed at ", event.position)
			dragging = true
			target_x = event.position.x
		else:
			#print("mouse released at ", event.position)
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		#print("mouse dragged to ", event.position)
		target_x = event.position.x

func reset_position() -> void:
	position = initial_position
	target_x = -1
