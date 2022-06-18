extends Node

var playerref
var dialogueref

var currentnode

func _ready():
	sceneload.load_scene(preload("res://node/Node2D.tscn"), 0)
	pass


func _process(_delta):
	if (Input.is_action_just_pressed("ui_focus_prev")):
		var node_to_add = load("res://node/dialogue.tscn").instance()
		get_tree().root.add_child(node_to_add)
	pass


func add_player():
	var player = load("res://node/player_2D.tscn").instance()
	player.request_ready()
	get_tree().root.get_node("base").call_deferred("add_child", player)
	return player

func load_scene(target,number):
	#var currentnode =  get_tree().current_scene
	var rootnode = get_tree().root.get_node("base")
	var node_to_add = target.instance()
	var loadplayer = false
	
	if playerref != null:
		rootnode.remove_child(playerref)
		playerref = null
		
	if dialogueref != null:
		dialogueref.queue_free()
		dialogueref = null
		
	if currentnode != null:
		currentnode.queue_free()
		currentnode = null
	
	#print(node_to_add.name)
	for i in get_tree().root.get_children():
		if node_to_add.name in i.name:
			i.queue_free()
	
	match number:
		0:
			get_tree().root.call_deferred("add_child", node_to_add)
			loadplayer = true
		1:
			get_tree().root.add_child(node_to_add)
			loadplayer = false
		2:
			get_tree().root.add_child(node_to_add)
			loadplayer = true
		_:
			print("what do you mean?")
			loadplayer = false
	
	get_tree().root.call_deferred("move_child", rootnode, get_tree().root.get_child_count())
	
	if loadplayer:
		playerref = add_player()
		rootnode.add_child(playerref)
	



