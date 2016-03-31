
extends PopupPanel


var rareranks = [
	"[*][ ][ ][ ][ ]",
	"[*][*][ ][ ][ ]",
	"[*][*][*][ ][ ]",
	"[*][*][*][*][ ] !",
	"[*][*][*][*][*] !!"
]


func _ready():
	set_process_input(true)


func _input(event):
	if is_visible():
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
			get_tree().set_input_as_handled()


func set_fish(fish):
	get_node("Fish Texture").set_texture(load("res://textures/fish/" + fish.icon + ".png"))
	
	var label = get_node("Fish Label")
	label.add_text("You caught a " + str(fish["name"]) + "!\n")
	
	var length = round(fish["length"] * 100) / 100
	label.add_text("Size: " + str(length) + " cm\n")
	
	var rarity = 4 - round(4 * (fish["weight"] - 10) / 60.0)
	label.add_text("Rarity: " + rareranks[rarity])


func _on_Button_pressed():
	hide()
	get_node("Fish Label").clear()



func _on_Keep_Button_pressed():
	hide()
	get_node("Fish Label").clear()
	get_parent().keep_fish()


func _on_Release_Button_pressed():
	hide()
	get_node("Fish Label").clear()
	get_parent().release_fish()
