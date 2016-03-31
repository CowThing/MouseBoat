
extends PopupPanel


var fishitem = preload("res://scenes/GUI/fish_item.scn")

var rareranks = [
	"[*][ ][ ][ ][ ]",
	"[*][*][ ][ ][ ]",
	"[*][*][*][ ][ ]",
	"[*][*][*][*][ ]",
	"[*][*][*][*][*]"
]


func _ready():
	set_process_input(true)


func _input(event):
	if is_visible():
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
			get_tree().set_input_as_handled()


func add_fish(fish, id):
	var fi = fishitem.instance()
	get_node("ScrollContainer/VBoxContainer").add_child(fi)
	
	fi.get_node("Fish Texture").set_texture(load("res://textures/fish/" + fish["icon"] + ".png"))
	
	var label = fi.get_node("Fish Label")
	label.add_text("Fish: " + str(fish["name"]) + "\n")
	
	var length = round(fish["length"] * 100) / 100
	label.add_text("Size: " + str(length) + " cm\n")
	
	var rarity = 4 - round(4 * (fish["weight"] - 10) / 60.0)
	label.add_text("Rarity: " + rareranks[rarity])
	
	var button = fi.get_node("Release Button")
	button.connect("pressed", self, "_on_Release_Button_pressed", [id])


func remove_fish(id):
	get_parent().fish_inventory.remove(id)
	refresh()


func clear_fish():
	var fishnodes = get_node("ScrollContainer/VBoxContainer").get_children()
	for i in range(fishnodes.size()):
		fishnodes[i].queue_free()


func refresh():
	clear_fish()
	
	yield(get_tree(), "idle_frame")
	
	var fish = get_parent().fish_inventory
	for i in range(fish.size()):
		add_fish(fish[i], i)


func _on_Close_Button_pressed():
	if get_parent().get_node("Main Menu Camera").is_current():
		get_parent().game_main_menu()
	
	hide()


func _on_Release_Button_pressed(id):
	remove_fish(id)


func _on_Menu_Button_pressed():
	get_parent().game_main_menu()
	hide()
