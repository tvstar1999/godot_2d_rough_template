extends Control

onready var rootnode = get_tree().root.get_node("base")
onready var thisnode = sceneload.currentnode

onready var audio_A = rootnode.get_node("AUDIO_A")
onready var audio_B = rootnode.get_node("AUDIO_B")
onready var audio_C = rootnode.get_node("AUDIO_C")

var inc1 = 0
var inc2 = 0
var lim = .2
var indx = -1
var loadindx = 0
var fileindx = 0

var switch = false

var texinit = false
var fileinit = false

var haltinit = false

var didread = false
var didpush = false

var isrunning = false

var read_tex = []

var tex = []
var spr = []

onready var rect = self.get_node("RECT")

export var DLGfile = "res://dialogue/test.txt"
export var close_time = 5


func erasearr():
	read_tex.clear()
	tex.clear()
	spr.clear()


func loadstr():
	erasearr()
	didread = false
	var file = File.new()
	file.open(DLGfile, File.READ)
	for i in file.get_len():
		read_tex.push_back(file.get_line())
		if file.eof_reached():
			break
	file.close()
	if read_tex.size() != 0:
		didread = true
	return read_tex


func anlzarr():
	didpush = false
	for i in read_tex:
		match i.substr(0,2):
			"TX":
				var push = i.rsplit("_",true, 1)
				var A_indx = Array(push).find("TX")
				push.remove(A_indx)
				#var sep = push[0].rsplit("/",true,1)
				#for v in sep:
				tex.push_back(push[0])
			"SP":
				var push = i.rsplit("_",true, 1)
				var A_indx = Array(push).find("SP")
				push.remove(A_indx)
				#var sep = push[0].rsplit("/",true,1)
				#for v in sep:
				spr.push_back(push[0])
	if tex.size() != 0 and spr.size() != 0:
		didpush = true


func sprlib(S_indx):
	#print("spr indx: "+String(S_indx))
	var face = self.get_node("FACE")
	if spr[S_indx] == "TEST":
		face.set_texture(load("res://icon.png"))
	
	if "FACE" in spr[S_indx]:
		var trim = spr[S_indx].trim_prefix("FACE")
		match trim:
			"NORMAL":
				face.set_texture(load("res://image/face/emote_circle.png"))
			"SAD":
				face.set_texture(load("res://image/face/emote_drop.png"))
			"HAP":
				face.set_texture(load("res://image/face/emote_star.png"))
			"HUH":
				face.set_texture(load("res://image/face/emote_question.png"))


func start_dialogue():
	if !isrunning:
		switch = true
		texinit = true
		fileinit = true


func _process(_delta):
	if Input.is_action_just_pressed("ui_ok"):
		start_dialogue()
	
	if switch:
		taktak()
		isrunning = true


func taktak():
	if texinit:
		loadstr()
		anlzarr()
	
		rect.set_text(String(tex[loadindx]))
		rect.set_visible_characters(0)
		rect.set_visible(true)
	
		texinit = false
	
	if fileinit:
		if loadindx == tex.size():
			haltinit = true
		else:
			sprlib(fileindx)
			fileindx += 1
			rect.set_text(String(tex[loadindx]))
			rect.set_visible_characters(0)
			rect.set_visible(true)
	
		fileinit = false
	
	if inc1 > lim:
		if rect.get_visible_characters() == rect.get_total_character_count():
			if haltinit:
				if inc2 > close_time:
					#free node
					sceneload.player_ref.movement = true
					sceneload.dialogue_ref = null
					self.get_parent().queue_free()
				else:
					inc2 += .2
			
			else:
				if Input.is_action_just_pressed("ui_ok"):
					inc1 = 0
					inc2 = 0
					indx = -1
					loadindx += 1
					
					if didread and didpush:
						fileinit = true
		else:
			if Input.is_action_just_pressed("ui_ok"):
				rect.set_visible_characters(rect.get_total_character_count())
				return
			else:
				inc1 = 0
				indx += 1
				rect.set_visible_characters(indx)
				
				#type sound
				audio_B.stream = load("res://audio/tone1.wav")
				audio_B.play()
	else:
		if Input.is_action_just_pressed("ui_ok"):
			rect.set_visible_characters(rect.get_total_character_count())
			return
		else:
			inc1 += .2

