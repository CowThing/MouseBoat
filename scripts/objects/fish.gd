
extends Area

var playerClass = preload("res://scripts/boat.gd")
var bobberClass = preload("res://scripts/objects/bobber.gd")
var fishClass = preload("res://scripts/fish_class.gd")

var rippleeffect = preload("res://scenes/effects/ripple.scn")

const STATE_IDLE = 0
const STATE_ATTRACT = 1
const STATE_CAUGHT = 2
const STATE_FLEE = 3

var current_state

var energy = 100
var struggle = Vector2()

var bobber

#fish differences
var fishtype
var name = "Fish"
var maxenergy = 100
var shadowsize = 1
var reaction = 1
var length = 10


func _ready():
	set_process(true)
	get_node("AnimationPlayer").queue("idle")
	get_node("Leave Timer").set_wait_time(60 + randf() * 30)
	get_node("Leave Timer").start()
	
	fishtype = fishClass.new().random_fish()
	name = fishtype["name"]
	maxenergy = fishtype["energy"]
	reaction = fishtype["reaction"]
	length = max(1, fishtype["length"] - (fishtype["length"] * 0.3) + (randf() * fishtype["length"] * 0.6))
	length = round(length * 100) / 100
	
	shadowsize = Vector3(1,1,1) * fishtype["shadowsize"]
	set_scale(shadowsize)
	energy = maxenergy


func get_bobber():
	if bobber:
		return bobber.get_ref()
	return bobber


func add_energy(val):
	energy = clamp(energy + val, 0, maxenergy)


func caught():
	if current_state != STATE_FLEE:
		get_node("Escape Delay").stop()
		
		current_state = STATE_CAUGHT
		get_node("CenterPivot").set_transform(get_node("CenterPivot/Sprite3D").get_transform())
		get_node("CenterPivot/Sprite3D").set_translation(Vector3())
		get_node("AnimationPlayer").play("caught")
		
		get_node("Struggle Timer").set_wait_time(4)
		get_node("Struggle Timer").start()
		return true
	
	return false


func escape():
	current_state = STATE_FLEE
	if get_bobber():
		get_bobber().remove_fish(self)
	get_node("AnimationPlayer").play("escape")


func ripple_spawn():
	if randi()%3 == 0:
		var ripple = rippleeffect.instance()
		get_parent().add_child(ripple)
		
		var rippletr = ripple.get_global_transform()
		rippletr.origin = get_node("CenterPivot/Sprite3D").get_global_transform().origin
		rippletr.origin.y = 0.1
		rippletr = rippletr.rotated(Vector3(0, 1, 0), randf() * 2 * PI)
		
		ripple.set_transform(rippletr)
		ripple.set_scale(Vector3(1,1,1) * (0.5 + randf()))
		ripple.get_node("Sprite3D").set_frame(randi()%3)
		
		get_node("SFX").play("splashsmall", 1)
		get_node("SFX").voice_set_pitch_scale(1, 0.9 + randf() * 0.2)


func lerp_Vector3(veca, vecb, weight):
	return Vector3(lerp(veca.x, vecb.x, weight), lerp(veca.y, vecb.y, weight), lerp(veca.z, vecb.z, weight))


func _process(delta):
	if bobber:
		if get_bobber() != null:
			if get_bobber().in_water:
				if current_state == STATE_ATTRACT:
					if not get_bobber().is_catching_fish:
						#This is all pretty glitchy
						var fishtr = get_global_transform().affine_inverse() * get_node("CenterPivot/Sprite3D").get_global_transform()
						var target = get_global_transform().affine_inverse() * get_bobber().get_global_transform()
						target.origin.y = 0.1
						
#						var targetangle = Vector2(target.origin.x, target.origin.z)
#						var ang = Vector2(-fishtr.basis.x.x, -fishtr.basis.x.z).angle_to_point(targetangle)
#						if ang > deg2rad(5):
#							fishtr = fishtr.rotated(Vector3(0, 1, 0), ang * delta)
						
						fishtr.origin = lerp_Vector3(fishtr.origin, target.origin, delta * 2)
						get_node("CenterPivot/Sprite3D").set_translation(fishtr.origin)
						
					else:
						escape()
		else:
			if current_state != STATE_FLEE:
				escape()


func _on_Fish_body_enter( body ):
	if body extends bobberClass:
		get_node("Leave Timer").stop()
		
		bobber = weakref(body)
		get_node("Attract Timer").set_wait_time(1 + randf() * 3)
		get_node("Attract Timer").start()
	
	if body extends playerClass:
		escape()


func _on_Attract_Timer_timeout():
	yield(get_tree(), "idle_frame")
	current_state = STATE_ATTRACT
	get_node("AnimationPlayer").stop()
	
	get_node("CenterPivot/Sprite3D").set_rotation(get_node("CenterPivot").get_rotation())
	
	get_node("Bite Timer").set_wait_time(3 + randf() * 4)
	get_node("Bite Timer").start()
	
	get_node("AnimationPlayer").play("swimming")


func _on_Bite_Timer_timeout():
	if not get_bobber():
		escape()
		return
	
	if not get_bobber().get_fish():
		get_bobber().set_fish(self)
		get_bobber().ripple_spawn(true)
		get_node("Escape Delay").set_wait_time(reaction)
		get_node("Escape Delay").start()
	else:
		escape()


func _on_Escape_Delay_timeout():
	escape()


func escape_finish():
	queue_free()


func _on_Leave_Timer_timeout():
	escape()


func _on_Struggle_Timer_timeout():
	if struggle == Vector2():
		struggle = Vector2(1, 0).rotated((randi())%8 * (PI / 4))
		get_node("Struggle Timer").set_wait_time(2 + randf() * 2)
		get_node("Struggle Timer").start()
		get_node("SFX").play("fishstruggle", 0)
	else:
		struggle = Vector2()
		get_node("Struggle Timer").set_wait_time(4 + randf() * 3)
		get_node("Struggle Timer").start()
		get_node("SFX").stop_voice(0)



