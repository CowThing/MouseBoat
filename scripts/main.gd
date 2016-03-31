
extends Spatial

var fish_scene = preload("res://scenes/objects/fish.scn")

var maxfish = 5
var mindist = 40
var maxdist = 200

var fish_inventory = []
var caught_fish

onready var player = get_node("Objects/Player")


func _ready():
	randomize()
	set_process_input(true)
	
	AudioServer.set_stream_global_volume_scale(0.5)
	load_fish()
	
	get_node("Main Menu").popup()
	get_node("Main Menu Camera").make_current()


func game_start():
	player.set_state(player.STATE_MOVE)
	player.get_node("Camera Pivot/Camera").make_current()


func game_main_menu():
	player.reset_pos()
	player.set_state(player.STATE_NONE)
	
	get_node("Main Menu").popup()
	get_node("Main Menu Camera").make_current()


func save_fish():
	var savegame = File.new()
	savegame.open("user://savegame.save", File.WRITE)
	savegame.store_var(fish_inventory)
	savegame.store_8(get_node("Main Menu/Options/Sound Scroll").get_value())
	savegame.store_8(get_node("Main Menu/Options/Music Scroll").get_value())
	savegame.close()


func load_fish():
	var savegame = File.new()
	if !savegame.file_exists("user://savegame.save"):
		return
	
	savegame.open("user://savegame.save", File.READ)
	
	fish_inventory = savegame.get_var()
	
	var sound = savegame.get_8()
	get_node("Main Menu/Options/Sound Scroll").set_value(sound)
	
	var music = savegame.get_8()
	get_node("Main Menu/Options/Music Scroll").set_value(music)
	
	savegame.close()
	
	if fish_inventory.size() > 0:
		get_node("Fish Inventory").refresh()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_fish()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_node("Fish Inventory").popup()
		get_node("Main Menu").hide()


func _on_Distance_Check_timeout():
	var fish_array = get_tree().get_nodes_in_group("Fish")
	for i in range(fish_array.size()):
		var fish = fish_array[i]
		if (player.get_translation() - fish.get_translation()).length() > maxdist:
			fish.escape()


func _on_Spawn_Fish_Timer_timeout():
	var fish_array = get_tree().get_nodes_in_group("Fish")
	if fish_array.size() < maxfish:
		for i in range(maxfish - fish_array.size()):
			#raycast
			var from = player.get_global_transform().origin
			from.y = 0
			var to = from + Vector3(1 - randf() * 2, 0, 1 - randf() * 2).normalized() * randf() * maxdist
			
			var space_state = get_world().get_direct_space_state()
			var result = space_state.intersect_ray(from, to, [player])
			
			var finalpos = Vector3()
			if not result.empty():
				var norm = result.normal
				norm.y = 0
				norm = norm.normalized()
				
				finalpos = result.position + norm * 8
			else:
				finalpos = to
			
			finalpos.y = 0.1
			
			if (from - finalpos).length() >= mindist:
				var fi = fish_scene.instance()
				get_node("Fish").add_child(fi)
				fi.set_translation(finalpos)


func show_fish(fish):
	caught_fish = fish.fishtype
	caught_fish["length"] = fish.length
	get_node("Fish Popup").set_fish(caught_fish)
	get_node("Fish Popup").popup()


func keep_fish():
	fish_inventory.append(caught_fish)
	get_node("Fish Inventory").add_fish(caught_fish, fish_inventory.size() - 1)
	caught_fish = null


func release_fish():
	caught_fish = null


