extends Node2D

func spawn_pindao_texiao(effect_pos):
	var pindao_scene = load("res://scenes/pindao.tscn")
	var pindao_node = pindao_scene. instantiate()
	pindao_node.position = effect_pos
	add_child(pindao_node)

func spawn_zhanhou_texiao(boss_pos):
	var zhanhou_scene = load("res://scenes/zhanhouspawner.tscn")
	var zhanhou_node = zhanhou_scene. instantiate()
	zhanhou_node.position = boss_pos
	add_child(zhanhou_node)

func spawn_hit_particle(boss_pos):
	var particle = load("res://scenes/hit_particles.tscn")
	var particle_node = particle. instantiate()
	particle_node.position = boss_pos
	add_child(particle_node)
