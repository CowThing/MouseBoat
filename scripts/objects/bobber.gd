
extends RigidBody

var rippleeffect = preload("res://scenes/effects/ripple.scn")
var splasheffect = preload("res://scenes/effects/splash.scn")

var player
var fish

var in_water = false
var is_catching_fish = false

var anim = ""


func _ready():
	set_process(true)


func set_hook():
	if get_fish():
		if get_fish().caught():
			is_catching_fish = true
			player.set_state(player.STATE_CATCHING)
			return
	
	player.set_state(player.STATE_MOVE)


func set_fish(obj):
	if obj != null:
		fish = weakref(obj)
	else:
		fish = obj


func remove_fish(obj):
	if fish:
		if fish == obj:
			fish = null


func get_fish():
	if fish:
		return fish.get_ref()
	return fish


func ripple_spawn(splash=false, spawn=false):
	if randi()%4 < 3 or spawn:
		var ripple = rippleeffect.instance()
		get_parent().add_child(ripple)
		
		var rippletr = ripple.get_global_transform()
		rippletr.origin = get_global_transform().origin
		rippletr.origin.y = 0.1
		rippletr = rippletr.rotated(Vector3(0, 1, 0), randf() * 2 * PI)
		
		ripple.set_transform(rippletr)
		ripple.set_scale(Vector3(1,1,1) * (0.5 + randf()))
		ripple.get_node("Sprite3D").set_frame(randi()%3)
		
		if is_catching_fish and randi()%4 == 0:
			get_node("SFX").play("splashbig")
		else:
			get_node("SFX").play("splashsmall")
		get_node("SFX").voice_set_pitch_scale(0, 0.9 + randf() * 0.2)
	
	if splash:
		var si = splasheffect.instance()
		get_parent().add_child(si)
		
		si.set_translation(get_global_transform().origin + Vector3(0, 1, 0))
		
		get_node("SFX").play("splashbig")


func _integrate_forces(state):
	set_rotation(Vector3())
	if not in_water:
		var collisions = get_colliding_bodies()
		if collisions.size() > 0:
			for i in range(collisions.size()):
				var cb = collisions[i]
				if cb.is_in_group("WaterLevel"):
					set_sleeping(true)
					in_water = true
					
					var pos = get_translation()
					pos.y = 0
					set_translation(pos)
					
					get_node("AnimationPlayer").play("bobbing")
					
					ripple_spawn(false, true)


func _process(delta):
	if player:
		if player.current_state == player.STATE_CATCHING:
			if anim != "catching":
				get_node("AnimationPlayer").play("catching")
			anim = "catching"
		
		elif player.current_state == player.STATE_MOVE or player.current_state == player.STATE_NONE:
			queue_free()


