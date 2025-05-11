extends DefenceTurret

func _process(_delta: float) -> void:
	curr_target = find_closest_global_target("Hostile")
	if is_instance_valid(curr_target):
		barrel.look_at(curr_target.global_position)
		if can_fire:
			shoot()
