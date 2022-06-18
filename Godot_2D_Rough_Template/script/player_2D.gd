extends KinematicBody2D

onready var rootnode = get_tree().root.get_node("base")

var velocity = Vector2(0,0)
export var speed = 200
export var drag_speed = 50

var drag_enabled = false
var movement = true

func _process(delta):
	self.position.x = clamp(position.x, 0, 640)
	self.position.y = clamp(position.y, 0, 480)
	
	if movement:
		if velocity != Vector2.ZERO:
			self.get_node("animation").play("walk")
		else:
			self.get_node("animation").play("RESET")
		
		if drag_enabled:
			var new_position = get_global_mouse_position()
			velocity = new_position - position;
			if velocity.length() > (drag_speed * delta):
				velocity = drag_speed * delta * velocity.normalized()
		else:
			moveinput()
	
		var _moveres = self.move_and_slide(velocity*speed)
	else:
		self.get_node("animation").play("RESET")
	


func moveinput():
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1
	elif Input.is_action_pressed("ui_down"):
		velocity.y = 1
	else:
		velocity.y = 0
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 1
	else:
		velocity.x = 0
	


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if !event.pressed:
			drag_enabled = false
		else:
			drag_enabled = true
	

