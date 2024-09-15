extends CharacterBody2D

var initial_position: Vector2
var dragging: bool
var move_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var collided = move_and_slide()
	if collided:
		print("Wow, collided with ", get_last_slide_collision().get_collider().name)

		# if move_tween.is_running():
		# 	move_tween.stop()
	#pass

func _input(event):
	# 0.1 秒かけて、入力された X 座標に移動する
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("mouse pressed at ", event.position)
			dragging = true
			move(event.position.x)
		else:
			print("mouse released at ", event.position)
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		print("mouse dragged to ", event.position)
		move(event.position.x)

# 入力された X 座標に移動する
func move(x: float) -> void:
	var sec = 0.2

	move_tween = get_tree().create_tween()
	move_tween.tween_property(self, "position", Vector2(x, initial_position.y), sec)
