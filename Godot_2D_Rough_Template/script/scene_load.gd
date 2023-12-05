extends Node

var player_ref
var dialogue_ref

var currentnode
var scene_to_preload = preload("res://scene/Node2D.tscn")


func move_node(target:Node, child: Node, indx:int):
	target.move_child(child, indx)


func reparent_node(parent: Node, child: Node):
	var old_parent = child.get_parent()
	if old_parent != null:
		old_parent.remove_child(child)
	parent.add_child(child)
	child.set_owner(parent)


func _ready():
	load_scene(scene_to_preload, 0)
	load_player()
	pass


func _process(_delta):
	if (Input.is_action_just_pressed("ui_focus_next")):
		var node_to_add = load("res://node/dialogue.tscn").instance()
		get_tree().root.add_child(node_to_add)
	pass


func add_player():
	var player = load("res://node/player_2D.tscn").instance()
	player.request_ready()
	return player


func load_player():
	if !get_tree().root.has_node("player_2D"):
		player_ref = add_player()
	
	if player_ref != null:
		get_tree().root.get_node("base").call_deferred("add_child", player_ref)


func get_player(target):
	if target != "":
		return player_ref.get_node(String(target))
	else:
		return player_ref


func remove_player():
	if player_ref != null:
		player_ref.movement = false
#		reparent_node(get_tree().root, player_ref)
#		get_tree().root.move_child(player_ref, get_tree().root.get_child_count())
		
		get_tree().root.get_node("base").remove_child(player_ref)
		player_ref = null


func add_dialogue():
	if !get_tree().root.has_node("dialogue"):
		var node_to_add = load("res://node/dialogue.tscn").instance()
		get_tree().root.call_deferred("add_child", node_to_add)
		
		dialogue_ref = node_to_add
		return dialogue_ref


func load_dialogue(target):
	dialogue_ref = add_dialogue()
	var temp_ref = dialogue_ref.get_node("DIALOGUE")
	
	if temp_ref != null:
		if !temp_ref.isrunning:
			if target == "null":
				temp_ref.DLGfile = "res://dialogue/test.txt"
				temp_ref.start_dialogue()
			else:
				temp_ref.DLGfile = "res://dialogue/" + String(target) + ".txt"
				temp_ref.start_dialogue()


func get_dialogue():
	return dialogue_ref.get_node("DIALOGUE")


func remove_dialogue():
	if dialogue_ref != null:
		dialogue_ref.queue_free()
		dialogue_ref = null

func load_scene(target, type):
#	var currentnode =  get_tree().current_scene
	var node_to_add = target.instance()
	
#	if player_ref != null:
#		rootnode.remove_child(player_ref)
#		player_ref = null
		
	if dialogue_ref != null:
		dialogue_ref.queue_free()
		dialogue_ref = null
	
	#print(node_to_add.name)
	if type == 0:
		#free prev, add child, record curr
		
		if currentnode != null:
			currentnode.queue_free()
			currentnode = null
		
		for i in get_tree().root.get_children():
			if node_to_add.name in i.name:
				i.queue_free()
		
		get_tree().root.call_deferred("add_child", node_to_add)
#		get_tree().root.call_deferred("move_child", rootnode, get_tree().root.get_child_count())
		currentnode = node_to_add
		return
	



