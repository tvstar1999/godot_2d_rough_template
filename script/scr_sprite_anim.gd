extends Sprite

#external anim arg
export var run = false
export var limit = 2
export var frames_H = 3
export var frames_V = 1
export var anim_type = "ping"

export var repeat = 0

#internal anim arg
var phase = 0
var count = 0
var inc = 0

var flip = false

var rec_tex

var exit = false

var force_frame = 0
var reset = true

#anim end signal
signal stopped
var anim_stop = false

#move command
var move_comm = false
var t = 0.0

var move_arg_x = 0
var move_arg_y = 0
var move_arg_time = 0
var move_isplayer = false


func _physics_process(delta):
	if move_comm:
		t += delta * float(move_arg_time)
		
		if move_isplayer:
			if is_equal_approx(sceneload.get_player("").position.x, float(move_arg_x)) and is_equal_approx(sceneload.get_player("").position.y, float(move_arg_y)):
	#			print("movement has ended")
				move_comm = false
			else:
#				print("position x: " + String(sceneload.get_player("").position.x) + " y: " + String(sceneload.get_player("").position.y))
				sceneload.get_player("").position = sceneload.get_player("").position.linear_interpolate(Vector2(int(move_arg_x), int(move_arg_y)), t)
		else:
			if is_equal_approx(self.position.x, float(move_arg_x)) and is_equal_approx(self.position.y, float(move_arg_y)):
	#			print("movement has ended")
				move_comm = false
			else:
#				print("position x: " + String(self.position.x) + " y: " + String(self.position.y))
				self.position = self.position.linear_interpolate(Vector2(int(move_arg_x), int(move_arg_y)), t)
	else:
		t = 0.0


func _ready():
	rec_tex = self.texture


func _process(_delta):
	if run:
		anim()
	
	if exit:
		anim_type = "none"
		exit = false


func anim():
	anim_stop = false
	var stop_call = false
	
	if reset:
		self.texture = load("res://image/empty.png")
		
		self.hframes = frames_H
		self.vframes = frames_V
		
		self.texture = rec_tex
	
	else:
		self.hframes = frames_H
		self.vframes = frames_V
		
		self.frame = force_frame
		
		self.texture = rec_tex
		
		reset = true
	
	if self.hframes != 0:
		while true:
			yield(get_tree().create_timer(.01), "timeout")
			
			if self.hframes != 0:
				break
	
	if exit:
		run = false
		reset = true
		
		anim_stop = true
		emit_signal("stopped")
	
	if inc > limit:
		match anim_type:
			"none":
				inc = 0
				phase = 0
				
				stop_call = true
		
			"stop":
				self.frame = 0
				
				self.hframes = 1
				self.vframes = 1
				
				inc = 0
				phase = 0
				
				stop_call = true
		
			"onefr":
				if phase < self.hframes - 1:
					phase += 1
				else:
					self.frame = frame
					inc = 0
					
					stop_call = true
		
			"one":
				if phase < self.hframes - 1:
					phase += 1
				else:
					self.frame = 0
					inc = 0
					
					stop_call = true
		
			"rep":
				if count < repeat + 1:
					if phase < self.hframes - 1:
						phase += 1
					else:
						self.frame = 0
						phase = 0
						count += 1
				else:
					self.frame = 0
					inc = 0
					
					stop_call = true
		
			"strt":
				if phase < self.hframes - 1:
					phase += 1
				else:
					phase = 0
		
			"ping":
				match phase:
					0:
						phase = 1
						flip = false
					1:
						if flip:
							phase = 0
						else:
							phase = 2
					2:
						phase = 1
						flip = true
		
		if stop_call:
			run = false
			reset = true
			
			phase = 0
			count = 0
			inc = 0
			
			anim_stop = true
			emit_signal("stopped")
		else:
			self.frame = phase
			inc = 0
	else:
		inc += .1

