extends CharacterBody2D

signal wall_hit
signal paddle_hit
signal block_hit

var speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_speed()
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta * speed)

	if collision:
		var collider = collision.get_collider()
		print("I collided with ", collider.name)

		if collider.name == "Wall":
			# 壁に当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			reset_speed()
			wall_hit.emit()
		elif collider.name == "Paddle":
			# パドルに当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			reset_speed()
			paddle_hit.emit()
		elif collider.is_in_group("Blocks"):
			# ブロックに当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			reset_speed()
			block_hit.emit()
			collider.queue_free()

	# 画面外に出ないように反転させる
	if position.x < 0 and velocity.x < 0 or position.x > get_viewport_rect().size.x and velocity.x > 0:
		velocity.x *= -1
		reset_speed()
	if position.y < 0 and velocity.y < 0 or position.y > get_viewport_rect().size.y and velocity.y > 0:
		velocity.y *= -1
		reset_speed()

func reset_speed() -> void:
	speed = randi_range(400, 800)
