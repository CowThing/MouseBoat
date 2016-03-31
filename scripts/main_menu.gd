
extends Popup

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_process_input(true)


func _input(event):
	if is_visible():
		if event.type == InputEvent.MOUSE_BUTTON and event.pressed and event.button_index == BUTTON_LEFT:
			get_tree().set_input_as_handled()


func _on_Start_Button_pressed():
	get_parent().game_start()
	hide()


func _on_Fish_Button_pressed():
	get_parent().get_node("Fish Inventory").popup()
	hide()


func _on_Options_Button_pressed():
	get_node("AnimationPlayer").play("to options")


func _on_How_Button_pressed():
	get_node("AnimationPlayer").play("to how")


func _on_Quit_Button_pressed():
	get_parent().save_fish()
	get_tree().quit()

## OPTIONS ##

func _on_Sound_Scroll_value_changed( value ):
	AudioServer.set_fx_global_volume_scale(value / 10.0)


func _on_Music_Scroll_value_changed( value ):
	AudioServer.set_stream_global_volume_scale(value / 10.0)


func _on_Fullscreen_Button_pressed():
	if OS.is_window_fullscreen():
		OS.set_window_fullscreen(false)
		OS.set_window_size(Vector2(960, 540))
		OS.set_window_position(Vector2())
		get_node("Options/Fullscreen Button").set_text("Fullscreen")
	else:
		OS.set_window_fullscreen(true)
		get_node("Options/Fullscreen Button").set_text("Windowed")


func _on_Options_To_Menu_Button_pressed():
	get_node("AnimationPlayer").play_backwards("to options")

## HOW TO ##

func _on_How_To_Menu_Button_pressed():
	get_node("AnimationPlayer").play_backwards("to how")


