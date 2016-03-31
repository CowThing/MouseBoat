
extends CanvasLayer

var anim = ""


func _ready():
	set_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(delta):
	var newanim = "normal"
	
	var mospos = get_tree().get_root().get_mouse_pos()
	get_node("Cursor").set_pos(mospos)
	
	var player = get_node("/root/Main").player
	if player.current_state == player.STATE_CATCHING and Input.is_mouse_button_pressed(BUTTON_LEFT):
		newanim = "reel"
	
	if anim != newanim:
		anim = newanim
		get_node("AnimationPlayer").play(anim)


