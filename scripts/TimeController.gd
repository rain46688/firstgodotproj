extends Node

var base_time_scale := Engine.time_scale
var base_physics_ticks_per_second := Engine.physics_ticks_per_second
var base_physics_steps_per_frame := Engine.max_physics_steps_per_frame

var time_scale_factor := 1.0


func _ready() -> void:
	set_time_scale_factor(1.0)


# 게임 배속을 지정하는 함수
func set_time_scale_factor(factor: float) -> void:
	time_scale_factor = maxf(factor, 0.001)
	update_time_scale()


# 게임 배속을 정상 속도로 되돌리는 함수
func reset_time_scale() -> void:
	set_time_scale_factor(1.0)


# 게임 배속 조절하기 위한 디버그용 입력
func _unhandled_key_input(_event: InputEvent) -> void:
	# 배포 빌드에서는 디버그용 배속 키 비활성화
	if not OS.is_debug_build():
		return

	if Input.is_key_pressed(KEY_I):
		set_time_scale_factor(0.0625)

	if Input.is_key_pressed(KEY_O):
		reset_time_scale()

	if Input.is_key_pressed(KEY_P):
		set_time_scale_factor(8.0)


func update_time_scale() -> void:
	Engine.time_scale = base_time_scale * time_scale_factor

	Engine.physics_ticks_per_second = maxi(
		1,
		int(base_physics_ticks_per_second * time_scale_factor)
	)

	Engine.max_physics_steps_per_frame = maxi(
		base_physics_steps_per_frame,
		int(base_physics_steps_per_frame * time_scale_factor)
	)
