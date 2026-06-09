extends Node

var base_time_scale := Engine.time_scale
var base_physics_ticks_per_second := Engine.physics_ticks_per_second
var base_physics_steps_per_frame := Engine.max_physics_steps_per_frame

var time_scale_factor := 1.0

func _ready() -> void:
	time_scale_factor = 1.0
	update_time_scale()

# 게임 배속 조절하기 위한 스크립트일 뿐 게임이랑 무관함
func _unhandled_key_input(_event: InputEvent) -> void:
	# I 키: 1/16배속 (0.0625)으로 느려짐
	if Input.is_key_pressed(KEY_I):
		time_scale_factor = 0.0625
		update_time_scale()
		
	# O 키: 정상 속도 (1.0)로 복구
	if Input.is_key_pressed(KEY_O):
		time_scale_factor = 1.0
		update_time_scale()
		
	# P 키: 8배속 (8.0)으로 빨라짐
	if Input.is_key_pressed(KEY_P):
		time_scale_factor = 8.0
		update_time_scale()


func update_time_scale() -> void:
	Engine.time_scale = base_time_scale * time_scale_factor
	Engine.physics_ticks_per_second = maxi(1, int(base_physics_ticks_per_second * time_scale_factor))
	Engine.max_physics_steps_per_frame = maxi(base_physics_steps_per_frame, int(base_physics_steps_per_frame * time_scale_factor))
