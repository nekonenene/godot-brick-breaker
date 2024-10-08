extends CharacterBody2D

signal wall_hit
signal paddle_hit
signal block_hit
signal missed

var initial_position: Vector2
var initial_speed = 600
var speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position
	reset_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta * speed)

	if collision:
		var collider = collision.get_collider()
		#print("I collided with ", collider.name)

		if collider.name == "Wall":
			# 壁に当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			adjust_velocity()
			wall_hit.emit()
		elif collider.name == "Paddle":
			# パドルに当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			adjust_velocity()
			paddle_hit.emit()
		elif collider.is_in_group("Blocks"):
			# ブロックに当たったら反射
			velocity = velocity.bounce(collision.get_normal())
			adjust_velocity()
			block_hit.emit()
			collider.queue_free()

	# 画面外に出たらミス（画面端より少し上で判定）
	if position.y > get_viewport_rect().size.y - 20:
		missed.emit()
	# # 画面外に出ないように反転させる
	# if position.x < 0 and velocity.x < 0 or position.x > get_viewport_rect().size.x and velocity.x > 0:
	# 	velocity.x *= -1
	# if position.y < 0 and velocity.y < 0 or position.y > get_viewport_rect().size.y and velocity.y > 0:
	# 	velocity.y *= -1

func reset_position() -> void:
	position = initial_position
	speed = 0
	velocity = Vector2(randf_range(-1, 1), randf_range(-1, -0.1)).normalized()
	adjust_velocity()

# 進む角度が真横や真上にならないように調整（ゲームが停滞しないように）
func adjust_velocity() -> void:
	var degree = rad_to_deg(velocity.angle())
	if (-10 < degree && degree <= 0) || (170 < degree && degree <= 180):
		var rotate_degree = randf_range(-10, -5)
		velocity = velocity.rotated(deg_to_rad(rotate_degree))
		print("adusted degree:", rad_to_deg(velocity.angle()))
	elif (-180 <= degree && degree < -170) || (0 <= degree && degree < 10):
		var rotate_degree = randf_range(5, 10)
		velocity = velocity.rotated(deg_to_rad(rotate_degree))
		print("adusted degree:", rad_to_deg(velocity.angle()))
	elif 88 <= abs(degree) && abs(degree) <= 92:
		var rotate_degree = randf_range(-2, 2)
		velocity = velocity.rotated(deg_to_rad(rotate_degree))
		print("adusted degree:", rad_to_deg(velocity.angle()))
