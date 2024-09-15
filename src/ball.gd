extends Area2D

var velocity = Vector2.ZERO # （向き情報を含む）速度
var speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_speed()
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta * speed

	# 画面外に出ないように反転させる
	if position.x < 0 and velocity.x < 0 or position.x > get_viewport_rect().size.x and velocity.x > 0:
		velocity.x *= -1
		reset_speed()
	if position.y < 0 and velocity.y < 0 or position.y > get_viewport_rect().size.y and velocity.y > 0:
		velocity.y *= -1
		reset_speed()

func reset_speed() -> void:
	speed = randi_range(400, 800)
