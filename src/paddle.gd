extends CharacterBody2D

var initial_position: Vector2
var dragging: bool
var target_x: float = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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

func _physics_process(_delta: float) -> void:
	if target_x != -1 and position.x != target_x:
		var diff = target_x - position.x
		#print("diff: ", diff)
		if abs(diff) > 1:
			var speed = 6
			var distance = log(abs(diff)) * speed
			if distance > abs(diff):
				distance = abs(diff)
			move_and_collide(Vector2(distance * (diff / abs(diff)), 0))
