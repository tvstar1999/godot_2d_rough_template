extends KinematicBody2D

onready var rootnode = get_tree().root.get_node("base")

onready var audio_A = rootnode.get_node("AUDIO_A")
onready var audio_B = rootnode.get_node("AUDIO_B")
onready var audio_C = rootnode.get_node("AUDIO_C")
onready var audio_D = rootnode.get_node("AUDIO_D")

onready var SPR = get_node("Node2D/SPR")
onready var CS_hit = get_node("CS_HIT")

var velocity = Vector2(0, 0)
var dir = Vector2(0, 0)
var move_dir = Vector2(0, 0)

var speed = 0
export var speed_load = 200
export var speed_read = 250

export var drag_speed = 50

export var clamp_x_min = 0
export var clamp_y_min = 0
export var clamp_x_max = 640
export var clamp_y_max = 480

export var def_pos = Vector2(320, 256)

var grid_mov = 8
var grid_target

export var switch = "player"

export var movement = true
export var drag_enabled = false

export var grid_basis = 16

export var bypass_anim = false
var wait_anim = false

var empty_tex = load("res://image/empty.png")

export var reset_tex:Texture = null
export var walk_tex:Texture = null

var target_ref

var inc = 0

var quit_permit = true


func anim_controller(manual, tex, frame, type, H, V, lim, rep):
	SPR.run = false
	
	SPR.frames_H = H
	SPR.frames_V = V
	
	if manual:
		SPR.frame = frame
	
	SPR.limit = lim
	SPR.repeat = rep
	
	SPR.anim_type = type
	
	SPR.rec_tex = tex
	SPR.run = true


func _process(delta):
	self.position.x = clamp(position.x, clamp_x_min, clamp_x_max)
	self.position.y = clamp(position.y, clamp_y_min, clamp_y_max)
	
	#esc key behavior
	if Input.is_action_pressed("ui_quit") and quit_permit:
		movement = false
		
		sceneload.audio_transit(true, -80, .1, audio_A)
		
		while true:
			yield(get_tree().create_timer(.1), "timeout")
			if sceneload.audio_transit_end:
				break
		
		get_tree().quit()
	
	if movement:
		#shift key behavior
		if Input.is_action_pressed("ui_shift"):
			speed = speed_read
		else:
			speed = speed_load
		
		#C key behavior
		if Input.is_action_just_pressed("ui_ok"):
			if target_ref != null:
				target_ref.free()
#				target_ref.get_child(0).get_child(0).set_deferred("disabled", true)
			
			audio_B.stream = load("res://audio/twotone.wav")
			audio_B.play()
		
		if !bypass_anim:
			#anim behavior
			if velocity != Vector2.ZERO and !wait_anim:
				anim_controller(false, walk_tex, 0, "none", 3, 1, 0, 0)
				
				#scroll X
				if switch == "scroll_X":
					if velocity.y > 0.6:
						anim_controller(true, walk_tex, 1, "none", 3, 1, 0, 0)
					if velocity.y < -0.6:
						anim_controller(true, walk_tex, 2, "none", 3, 1, 0, 0)
				elif switch == "scroll_Y":
					if velocity.x > 0.6:
						anim_controller(true, walk_tex, 1, "none", 3, 1, 0, 0)
					if velocity.x < -0.6:
						anim_controller(true, walk_tex, 2, "none", 3, 1, 0, 0)
				else:
					#player
					anim_controller(false, walk_tex, 0, "ping", 3, 1, 2, 0)
			
			if velocity == Vector2.ZERO and !wait_anim:
				anim_controller(false, reset_tex, 0, "stop", 1, 1, 0, 0)
		
		#movement input
		if drag_enabled:
			var new_position = get_global_mouse_position()
			velocity = (new_position - position);
			
			if velocity.length() > (drag_speed * delta):
#				print(velocity.length())
				
				if velocity.length() < 8:
					velocity = Vector2(0, 0)
				
				velocity = drag_speed * delta * velocity.normalized()
				var _moveres_drag = self.move_and_slide(velocity * speed)
		else:
			moveinput()
		var _moveres = self.move_and_slide(velocity * speed, dir)
		
		if switch == "platform":
			velocity.y += 3 * delta
			
			if Input.is_action_just_pressed("ui_up"):
#				if is_on_floor():
					velocity.y = -2
			
	else:
		if !bypass_anim and !wait_anim:
			anim_controller(true, reset_tex, 0, "none", 1, 1, 0, 0)


func moveinput():
	match switch:
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
		
		"grid":
			dir = Vector2.ZERO
			
			if Input.is_action_just_pressed("ui_up"):
				velocity.y += -grid_basis
			elif Input.is_action_just_pressed("ui_down"):
				velocity.y += grid_basis
			else:
				velocity.y = 0
			if Input.is_action_just_pressed("ui_left"):
				velocity.x += -grid_basis
			elif Input.is_action_just_pressed("ui_right"):
				velocity.x += grid_basis
			else:
				velocity.x = 0
		
		"platform":
			dir = Vector2.UP
			
			if Input.is_action_pressed("ui_left"):
				velocity.x = -1
			elif Input.is_action_pressed("ui_right"):
				velocity.x = 1
			else:
				velocity.x = 0
		
		"scroll_X":
			dir = Vector2.ZERO
			self.velocity.y = clamp(velocity.y, -1, 1)
			
			if Input.is_action_pressed("ui_up"):
				velocity.y -= .2
			elif Input.is_action_pressed("ui_down"):
				velocity.y += .2
			else:
				velocity.y = 0
			if Input.is_action_pressed("ui_left"):
				velocity.x = -1
			elif Input.is_action_pressed("ui_right"):
				velocity.x = 1
			else:
				velocity.x = 0
		
		"scroll_Y":
			dir = Vector2.ZERO
			self.velocity.x = clamp(velocity.x, -1, 1)
			
			if Input.is_action_pressed("ui_up"):
				velocity.y = -1
			elif Input.is_action_pressed("ui_down"):
				velocity.y = 1
			else:
				velocity.y = 0
			if Input.is_action_pressed("ui_left"):
				velocity.x -= .2
			elif Input.is_action_pressed("ui_right"):
				velocity.x += .2
			else:
				velocity.x = 0


func _on_player_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if !event.pressed:
			drag_enabled = false
		else:
			drag_enabled = true
	
	if event is InputEventScreenTouch:
		Input.action_press("ui_ok")
	
	if event is InputEventScreenDrag:
		drag_enabled = !drag_enabled


func _on_anim_stopped():
	wait_anim = false


func _on_player_area_entered(area):
	if area.name == "target":
		target_ref = area.get_parent()


func _on_player_area_exited(_area):
	target_ref = null

