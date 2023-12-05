extends KinematicBody2D

onready var rootnode = get_tree().root.get_node("base")

onready var audio_B = rootnode.get_node("AUDIO_B")

onready var anim = self.get_node("ANIM")
onready var cam = self.get_node("CAM")

var velocity = Vector2(0, 0)
var dir = Vector2(0, 0)
var move_dir = Vector2(0, 0)

export var speed = 200
export var drag_speed = 50

export var clamp_x_min = 0
export var clamp_y_min = 0
export var clamp_x_max = 640
export var clamp_y_max = 480

export var def_pos = Vector2(320, 256)

var grid_mov = 8
var grid_target

export var movement = true
export var drag_enabled = false

export var switch = "player"


func _process(delta):
	self.position.x = clamp(position.x, 0, 640)
	self.position.y = clamp(position.y, 0, 480)
	
	if movement:
		#animation
		if velocity != Vector2.ZERO:
			anim.play("walk")
		else:
			anim.play("RESET")
		
		#C key behavior
		if Input.is_action_just_pressed("ui_ok"):
			audio_B.stream = load("res://audio/tone1.wav")
			audio_B.play()
		
		#movement input
		if drag_enabled:
			var new_position = get_global_mouse_position()
			velocity = new_position - position;
			if velocity.length() > (drag_speed * delta):
				velocity = drag_speed * delta * velocity.normalized()
		else:
			moveinput()
	
		var _moveres = self.move_and_slide(velocity*speed)
	else:
		anim.play("RESET")


func moveinput():
	match switch:
		"reset":
			clamp_x_min = 0
			clamp_y_min = 0
			clamp_x_max = 640
			clamp_y_max = 480
			
			cam.clamp_x_min = 0
			cam.clamp_y_min = 0
			cam.clamp_x_max = 640
			cam.clamp_y_max = 480
			
			dir = Vector2.ZERO
			move_dir = Vector2.ZERO
			velocity = Vector2.ZERO
		"player":
			dir = Vector2.ZERO
			
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


func _on_player_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if !event.pressed:
			drag_enabled = false
		else:
			drag_enabled = true

