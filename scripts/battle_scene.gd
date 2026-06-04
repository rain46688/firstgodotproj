extends Control

# 시그널 모음
signal battle_finished(result_data)

# 추후 용동가 애매하거나 사용하지 않는 변수 정리 필요

# onready 변수 모음
@onready var enemy_sprite = $EnemySprite
@onready var weapon_sprite = $WeaponSprite
@onready var battle_text = $CenterPanel/BattleText
@onready var player_hp_text = $LeftPanel/PlayerHpText
@onready var attack_button = $RightPanel/AttackButton
@onready var observe_button = $RightPanel/ObserveButton
@onready var item_button = $RightPanel/ItemButton
@onready var end_turn_button = $RightPanel/EndTurnButton
@onready var run_button = $RightPanel/RunButton
@onready var player_portrait = $LeftPanel/PlayerPortrait
@onready var slash_effect = $EffectContainer/SlashEffect
@onready var hit_effect = $EffectContainer/HitEffect
@onready var parry_effect = $EffectContainer/ParryEffect
@onready var attack_guide = $CenterPanel/AttackGuide
@onready var hitbox_debug_container = $HitboxDebugContainer
@onready var player_attack_hitbox_debug = $HitboxDebugContainer/PlayerAttackHitboxDebug
@onready var enemy_projectile_container = $EnemyProjectileContainer
@onready var defense_weapon_hitbox_debug = $HitboxDebugContainer/DefenseWeaponHitboxDebug
@onready var enemy_projectile_hitbox_debug = $HitboxDebugContainer/EnemyProjectileHitboxDebug
@onready var parry_hitbox_debug = $HitboxDebugContainer/ParryHitboxDebug
@onready var battle_bgm = $BattleBgm
@onready var parry_sound = $ParrySound
@onready var block_sound = $BlockSound
@onready var hit_normal_sound = $HitNormalSound
@onready var hit_red_sound = $HitRedSound
@onready var slash_sound = $SlashSound
@onready var impact_sound = $ImpactSound
@onready var shot_sound = $ShotSound
@onready var click_sound = $ClickSound
@onready var healing_sound = $HealingSound
@onready var fade_rect = $FadeRect
@onready var enemy_background = $EnemyBackground
@onready var effect_container = $EffectContainer
@onready var background = $Background
@onready var black_background = $BlackBackground
@onready var enemy_encounter_sound = $EnemyEncounterSound
@onready var status_popup_panel = $StatusPopupPanel
@onready var status_popup_text = $StatusPopupPanel/StatusPopupText
@onready var result_sound = $ResultSound
@onready var player_hit_flash = $LeftPanel/PlayerHitFlash
@onready var status_effect_flash = $LeftPanel/StatusEffectFlash
@onready var status_effect_sound = $StatusEffectSound
@onready var center_panel = $CenterPanel
@onready var ui_warp_sound = $UiWarpSound

# 일반 변수 모음
var player_hp = 0
var player_max_hp = 0
var enemy_id = ""
var enemy_data = {}
var is_player_turn = true
var battle_ended = false
var enemy_hp = 0
var enemy_max_hp = 0
var items = {}
var equipped_weapon = null
var is_observing = false
var inventory = []
var is_item_selecting = false
var battle_consumables = []
var item_index = 0
var waiting_enemy_attack = false
var current_enemy_pattern = {}
var slash_frames = []
var parry_frames = []
var hit_frames = []
var weapon_base_position = Vector2.ZERO
var weapon_move_time = 0.0
var weapon_swing_enabled = false
var is_attack_mode = false
var weapon_angle_offset = 0.0
var active_attack_projectile = null
var active_attack_direction = Vector2.ZERO
var player_attack_hit = false
var last_hitbox_data = {}
var projectiles = {}
var current_projectile_data = {}
var is_defense_mode = false
var defense_area_rect = Rect2(350, 700, 1220, 360)
var parry_input_buffer_time = 0.0
var parry_count = 0
var action_buttons = []
var action_button_base_texts = []
var action_button_index = 0
var pierced_hitbox_ids = []
var enemy_parts = {}
var enemy_part_sprites = {}
var enemy_part_hp = {}
var enemy_hp_label = null
var enemy_hp_label_position = Vector2(722, 607)
var enemy_hp_label_size = Vector2(520, 80)
var destroyed_parts = []
var enemy_visual_base_position = Vector2.ZERO
var enemy_part_base_positions = {}
var enemy_shake_tween = null
var enemies = {}
var forced_enemy_pattern = {}
var default_battle_bgm_stream = null
var observe_targets = []
var observe_index = 0
var debug_hp_labels = []
var default_battle_bgm_volume_db = 0.0
var bgm_volume_tween = null
var battle_bgm_should_loop = true
var default_enemy_encounter_stream = null
var default_enemy_encounter_volume_db = 0.0
var player_status_effects = {}
var player_portrait_paths = {}
var battle_result_messages = []
var battle_result_index = 0
var player_hit_flash_tween = null
var status_effect_flash_tween = null
var battle_item_scroll_start = 0
var player_effective_stats = {}
const BATTLE_ITEM_VISIBLE_COUNT = 4

# 게임오버 중복 실행 방지 변수
var game_over_started = false

# 입력 비동기 처리 중복 방지 변수
var is_processing_battle_input = false

# 디버그 모드
var debug_mode = false

# 적 탄막별 디버그 박스 목록
var enemy_projectile_debug_boxes = {}

# 적 턴 플레이어 피해 결과 누적 변수
var enemy_turn_total_damage = 0
var enemy_turn_applied_status_effects = []

# 방어 모드 좌우 워프 관련 변수
var last_left_press_time = -999.0
var last_right_press_time = -999.0
var side_warp_double_tap_time = 0.25
var side_warp_margin = 8.0
# false로 할시 양쪽 무기 워프 차단됨
var side_warp_enabled = true
# 추후 확장 양쪽 골라서 무기 워프 차단
# var side_warp_left_blocked = false
# var side_warp_right_blocked = false

# 첫 턴 결정 변수
var encounter_first_turn = ""

# 메인에서 넘겨받은 플래그
var flags = {}

# 기존 적 포지션 저장 변수
var enemy_sprite_default_size = Vector2.ZERO
var enemy_sprite_default_position = Vector2.ZERO

# 전투 난이도 조절 기능 변수
# easy, normal, hard, nightmare
var battle_difficulty = "normal"

# 리펙토링시 삭제 예정 변수
var weapon_angle_speed = 120.0 
var attack_projectile_speed = 1200.0
var attack_hit_results = []

# 패링 판정 처리 부분
# parry_input_buffer_time 0.035
# parry_height 6

# 상수 변수 모음
# 현재 없음

# ============================================================
# 게임 시작 관련 함수 모음
# ============================================================

# 디버그 토글 입력 처리 함수
func update_debug_toggle_input():
	if Input.is_action_just_pressed("debug_toggle"):
		debug_mode = !debug_mode
		update_hitbox_debug()
# 방어 모드 입력 처리 함수
func update_defense_mode_input(delta):
	update_defense_weapon_movement(delta)
	check_defense_side_warp_input()
	
	# 패링 판정 처리 부분 1
	if Input.is_action_just_pressed("ui_accept"):
		parry_input_buffer_time = 0.035

	if parry_input_buffer_time > 0:
		parry_input_buffer_time -= delta
# 공격 모드 입력 처리 함수
func update_attack_mode_input(delta):
	var weapon_data = get_current_weapon_data()

	if weapon_swing_enabled:
		weapon_move_time += delta

		var swing_speed = get_attack_swing_speed_with_status(weapon_data)
		var move_range = weapon_data.get("attack_move_range", 460)

		var offset_x = sin(weapon_move_time * swing_speed) * move_range
		weapon_sprite.position = weapon_base_position + Vector2(offset_x, 0)

	var angle_min = weapon_data.get("attack_angle_min", -45)
	var angle_max = weapon_data.get("attack_angle_max", 45)
	var base_rotation = weapon_data.get("attack_base_rotation", 0)

	var angle_step = weapon_data.get("weapon_angle_step", 5)
	var old_angle = weapon_angle_offset

	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		weapon_angle_offset -= angle_step

	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		weapon_angle_offset += angle_step
		
	weapon_angle_offset = clamp(
		weapon_angle_offset,
		weapon_data.get("attack_angle_min", -45),
		weapon_data.get("attack_angle_max", 45)
	)
	
	if weapon_angle_offset != old_angle:
		play_click_sound()

	weapon_angle_offset = clamp(weapon_angle_offset, angle_min, angle_max)
	weapon_sprite.rotation_degrees = base_rotation + weapon_angle_offset

	if Input.is_action_just_pressed("ui_accept"):
		await execute_player_attack()
# 전투 입력 비동기 처리 시작 가능 여부 확인 함수
func can_start_battle_input_process():
	if is_processing_battle_input:
		return false

	return true
# 전투 입력 비동기 처리 잠금 함수
func lock_battle_input_process():
	is_processing_battle_input = true
# 전투 입력 비동기 처리 잠금 해제 함수
func unlock_battle_input_process():
	is_processing_battle_input = false
	update_action_button_focus()
# 우선 처리 입력 모드 갱신 함수
func update_priority_battle_input(delta):
	if is_observing:
		update_observe_mode_input()
		return true

	if is_item_selecting:
		update_battle_item_select_input()
		return true

	if waiting_enemy_attack:
		await update_enemy_attack_wait_input()
		return true

	if is_defense_mode:
		update_defense_mode_input(delta)
		return true

	if is_attack_mode:
		await update_attack_mode_input(delta)
		return true

	return false
# 일반 플레이어 턴 입력 처리 함수
func update_normal_player_turn_input():
	if can_player_choose_action():
		update_action_button_keyboard_input()
# 프레임 마다 실행 함수
func _process(delta):
	update_debug_toggle_input()

	var priority_input_handled = await update_priority_battle_input(delta)

	if priority_input_handled:
		return

	update_normal_player_turn_input()
# 처음에 한번 실행 함수
func _ready():
	attack_button.focus_mode = Control.FOCUS_NONE
	observe_button.focus_mode = Control.FOCUS_NONE
	item_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.focus_mode = Control.FOCUS_NONE
	run_button.focus_mode = Control.FOCUS_NONE
	enemy_sprite_default_size = enemy_sprite.size
	enemy_sprite_default_position = enemy_sprite.position
	
	# bgm
	default_battle_bgm_stream = battle_bgm.stream
	default_battle_bgm_volume_db = battle_bgm.volume_db

	default_enemy_encounter_stream = enemy_encounter_sound.stream
	default_enemy_encounter_volume_db = enemy_encounter_sound.volume_db
	player_portrait.gui_input.connect(_on_player_portrait_gui_input)
	
	# visible 처리
	status_popup_panel.visible = false
	enemy_projectile_hitbox_debug.visible = false

	if not battle_bgm.finished.is_connected(_on_battle_bgm_finished):
		battle_bgm.finished.connect(_on_battle_bgm_finished)
		
	# 화면 레이어 z_index 정리
	background.z_index = 2
	black_background.z_index = 0
	enemy_background.z_index = 1
	
	$LeftPanel.z_index = 2
	$CenterPanel.z_index = 2
	$RightPanel.z_index = 2

	enemy_sprite.z_index = 10
	# 파츠는 20
	
	# 중앙 공격 가이드보다 무기가 위에 보이도록 분리
	attack_guide.z_index = 25
	weapon_sprite.z_index = 35
	weapon_sprite.z_as_relative = false

	enemy_projectile_container.z_index = 40
	effect_container.z_index = 50

	slash_effect.z_index = 40
	hit_effect.z_index = 50
	parry_effect.z_index = 50
	
	player_hit_flash.color = Color(1, 0, 0, 0)
	player_hit_flash.visible = true
	player_hit_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_hit_flash.z_index = 100
	
	status_effect_flash.color = Color(0, 0, 0, 0)
	status_effect_flash.visible = true
	status_effect_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_effect_flash.z_index = 101

	hitbox_debug_container.z_index = 900
	hitbox_debug_container.z_index = 999
	fade_rect.z_index = 4096
	
	hitbox_debug_container.visible = debug_mode
	player_attack_hitbox_debug.visible = false
	defense_weapon_hitbox_debug.visible = false
	enemy_projectile_hitbox_debug.visible = false
	parry_hitbox_debug.visible = false
	
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.visible = true

	# 무기 별로 기본 위치 포지션을 잡아줌
	weapon_sprite.pivot_offset = weapon_sprite.size / 2
	update_weapon_base_position()
	ensure_battle_item_input_actions()
	
	attack_button.pressed.connect(_on_attack_button_pressed)
	observe_button.pressed.connect(_on_observe_button_pressed)
	item_button.pressed.connect(_on_item_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	
	parry_frames = make_effect_frames("res://imgs/effects/parry/parry_", 9)
	hit_frames = make_effect_frames("res://imgs/effects/hit/hit_", 5)
	
	action_buttons = [
		attack_button,
		observe_button,
		item_button,
		end_turn_button,
		run_button
	]

	action_button_base_texts = [
		attack_button.text,
		observe_button.text,
		item_button.text,
		end_turn_button.text,
		run_button.text
	]

	update_action_button_focus()
# 전투 시작 시 상태 변수 초기화 함수
func reset_battle_runtime_state():
	battle_ended = false
	is_player_turn = false
	is_attack_mode = false
	is_defense_mode = false
	is_observing = false
	is_item_selecting = false
	waiting_enemy_attack = false
	is_processing_battle_input = false
	game_over_started = false
# 전투 시작 시 플레이어 UI 초기화 함수
func setup_battle_player_ui():
	player_status_effects.clear()

	update_weapon_sprite_texture()
	weapon_sprite.visible = false

	update_player_hp_ui()
	update_player_portrait_by_status()
# 이미지 경로 기준으로 Texture 리소스 가져오기 함수
func load_texture_by_path(texture_path, error_context = ""):
	if texture_path == "":
		return null

	if not ResourceLoader.exists(texture_path):
		push_error("이미지 리소스가 없음: " + str(texture_path) + " / " + str(error_context))
		return null

	var texture = load(texture_path)

	if texture == null:
		push_error("이미지 로드 실패: " + str(texture_path) + " / " + str(error_context))
		return null

	return texture
# 현재 적 이미지 경로 가져오기 함수
func get_current_enemy_image_path():
	if enemy_data.is_empty():
		return ""

	return str(enemy_data.get("image", ""))
# 현재 적 전투 배경 경로 가져오기 함수
func get_current_enemy_battle_background_path():
	if enemy_data.is_empty():
		return ""

	return str(enemy_data.get("battle_background", ""))
# 현재 적 전투 배경 투명도 가져오기 함수
func get_current_enemy_battle_background_alpha():
	if enemy_data.is_empty():
		return 0.3

	return float(enemy_data.get("battle_background_alpha", 0.3))
# 전투 시작 시 적 이미지/파츠 초기화 함수
func setup_battle_enemy_visual():
	enemy_sprite.modulate.a = 1.0

	var enemy_image_path = get_current_enemy_image_path()

	if enemy_image_path == "":
		enemy_sprite.texture = null
		push_error("적 이미지 경로가 비어있음: " + str(enemy_id))
		return

	var enemy_texture = load_texture_by_path(
		enemy_image_path,
		"enemy image / " + str(enemy_id)
	)

	if enemy_texture == null:
		enemy_sprite.texture = null
		return

	enemy_sprite.texture = enemy_texture
	apply_enemy_visual_settings()
	setup_enemy_parts()
# 전투 시작 시 적 배경 초기화 함수
func setup_battle_enemy_background():
	var background_path = get_current_enemy_battle_background_path()

	if background_path == "":
		enemy_background.texture = null
		enemy_background.visible = false
		return

	var background_texture = load_texture_by_path(
		background_path,
		"battle background / " + str(enemy_id)
	)

	if background_texture == null:
		enemy_background.texture = null
		enemy_background.visible = false
		return

	enemy_background.texture = background_texture
	enemy_background.visible = true

	var bg_alpha = get_current_enemy_battle_background_alpha()
	enemy_background.modulate = Color(1, 1, 1, bg_alpha)
# 전투 시작 시 적 UI와 디버그 표시 초기화 함수
func setup_battle_enemy_ui():
	update_enemy_hp_ui()
	update_hitbox_debug()
# 현재 적 이름 가져오기 함수
func get_current_enemy_name():
	if enemy_data.is_empty():
		return "무언가"

	return str(enemy_data.get("name", "무언가"))
# 현재 적 조우 텍스트 가져오기 함수
func get_current_enemy_encounter_text():
	if enemy_data.is_empty():
		return "무언가가 나타났다..."

	return str(enemy_data.get(
		"encounter_text",
		get_current_enemy_name() + "가 나타났다..."
	))
# 전투 시작 조우 텍스트 표시 함수
func show_battle_encounter_text():
	await show_current_enemy_encounter_text()
# 전투 시작 BGM / 조우 사운드 / 조우 텍스트 실행 함수
func play_battle_start_presentation():
	await update_battle_bgm()
	play_enemy_encounter_sound()

	await show_battle_encounter_text()
# 전투 첫 턴 시작 함수
func start_initial_battle_turn():
	if encounter_first_turn == "enemy":
		start_enemy_turn()
	else:
		start_player_turn()
# 전투 화면 설정 함수
func setup_battle(data):
	if not is_valid_battle_setup_data(data):
		push_error("전투 시작 데이터가 올바르지 않음")
		return
		
	# 전투 시작 시 상태 변수 초기화 함수
	reset_battle_runtime_state()

	# 전투에서 참조할 전체 데이터
	items = get_setup_dictionary(data, "items")
	projectiles = get_setup_dictionary(data, "projectiles")
	enemies = get_setup_dictionary(data, "enemies")

	# 현재 전투 적 데이터
	enemy_id = get_setup_string(data, "enemy_id", "")
	enemy_data = get_setup_enemy_data(data)

	if enemy_id == "":
		push_error("전투 enemy_id가 비어있음")
		return

	if enemy_data.is_empty():
		push_error("전투 enemy_data가 비어있음: " + str(enemy_id))
		return

	enemy_max_hp = int(enemy_data.get("max_hp", 10))
	enemy_hp = enemy_max_hp

	# 성물/주물 적용 능력치
	player_effective_stats = get_setup_dictionary(data, "player_effective_stats")

	# 플레이어 체력
	player_hp = get_setup_int(data, "player_hp", 100)
	player_max_hp = int(player_effective_stats.get(
		"max_hp",
		get_setup_int(data, "player_max_hp", 100)
	))

	if player_max_hp < 1:
		player_max_hp = 1

	if player_hp < 1:
		player_hp = 1

	if player_hp > player_max_hp:
		player_hp = player_max_hp

	# 인벤토리는 main.gd와 연결되어야 하므로 duplicate하지 않음
	inventory = get_setup_array(data, "inventory")
	equipped_weapon = get_setup_equipped_weapon(data)

	# 메인에서 넘겨받은 플래그
	flags = get_setup_dictionary(data, "flags")
	encounter_first_turn = get_setup_string(data, "first_turn", "")

	# 플레이어 초상화
	player_portrait_paths = get_setup_dictionary(data, "player_portraits")

	if data.has("player_portrait"):
		player_portrait_paths["normal"] = data["player_portrait"]

	# 플레이어 전투 초기 UI
	setup_battle_player_ui()
	
	# 적 이미지 초기화
	setup_battle_enemy_visual()
		
	# 전투 시작 시 적 배경 초기화
	setup_battle_enemy_background()
		
	# 적 UI/디버그 초기화
	setup_battle_enemy_ui()

	is_player_turn = false
	set_action_buttons_disabled(true)

	await play_battle_start_presentation()

	# 첫 턴 결정
	start_initial_battle_turn()

# ============================================================
# 헬퍼 함수 함수 모음
# ============================================================

# 전투 시작 데이터가 Dictionary인지 확인하는 함수
func is_valid_battle_setup_data(data):
	if data == null:
		return false

	if typeof(data) != TYPE_DICTIONARY:
		return false

	return true
# 전투 시작 데이터에서 Dictionary 값 가져오기 함수
func get_setup_dictionary(data, key):
	if not is_valid_battle_setup_data(data):
		return {}

	var value = data.get(key, {})

	if typeof(value) != TYPE_DICTIONARY:
		return {}

	return value
# 전투 시작 데이터에서 Array 값 가져오기 함수
func get_setup_array(data, key):
	if not is_valid_battle_setup_data(data):
		return []

	var value = data.get(key, [])

	if typeof(value) != TYPE_ARRAY:
		return []

	return value
# 전투 시작 데이터에서 String 값 가져오기 함수
func get_setup_string(data, key, default_value = ""):
	if not is_valid_battle_setup_data(data):
		return default_value

	return str(data.get(key, default_value))
# 전투 시작 데이터에서 int 값 가져오기 함수
func get_setup_int(data, key, default_value = 0):
	if not is_valid_battle_setup_data(data):
		return default_value

	return int(data.get(key, default_value))
# 전투 시작 데이터에서 장착 무기 데이터 가져오기 함수
func get_setup_equipped_weapon(data):
	if not is_valid_battle_setup_data(data):
		return null

	var value = data.get("equipped_weapon", null)

	if value == null:
		return null

	if typeof(value) == TYPE_DICTIONARY:
		return value

	if typeof(value) == TYPE_STRING:
		return value

	return null
# 전투 시작 데이터에서 적 데이터 가져오기 함수
func get_setup_enemy_data(data):
	if not is_valid_battle_setup_data(data):
		return {}

	var setup_enemy_data = data.get("enemy_data", {})

	if typeof(setup_enemy_data) == TYPE_DICTIONARY and not setup_enemy_data.is_empty():
		return setup_enemy_data

	var setup_enemy_id = get_setup_string(data, "enemy_id", "")

	if setup_enemy_id == "":
		return {}

	return get_enemy_data_by_id(setup_enemy_id, true)
# enemy_id 기준으로 전투 씬의 적 데이터 가져오기 함수
func get_enemy_data_by_id(target_enemy_id, show_error = false):
	if target_enemy_id == "":
		if show_error:
			push_error("적 ID가 비어있음")
		return {}

	if not enemies.has(target_enemy_id):
		if show_error:
			push_error("적 데이터가 없음: " + str(target_enemy_id))
		return {}

	var target_enemy_data = enemies[target_enemy_id]

	if typeof(target_enemy_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("적 데이터가 Dictionary가 아님: " + str(target_enemy_id))
		return {}

	return target_enemy_data
# enemy_id 기준으로 적 이름 가져오기 함수
func get_enemy_name_by_id(target_enemy_id):
	var target_enemy_data = get_enemy_data_by_id(target_enemy_id, false)

	if target_enemy_data.is_empty():
		return str(target_enemy_id)

	return str(target_enemy_data.get("name", target_enemy_id))
# 현재 적 데이터에서 다음 페이즈 enemy_id 가져오기 함수
func get_next_phase_enemy_id():
	if enemy_data.is_empty():
		return ""

	# 현재 enemies.json에서 쓰는 기본 키
	if enemy_data.has("next_phase_enemy_id"):
		return str(enemy_data.get("next_phase_enemy_id", ""))

	# 혹시 과거 리팩토링 중 next_phase로 작성된 데이터가 있을 경우 대비
	if enemy_data.has("next_phase"):
		return str(enemy_data.get("next_phase", ""))

	return ""
# projectile_id 기준으로 투사체 데이터 가져오기 함수
func get_projectile_data_by_id(projectile_id, show_error = false):
	if projectile_id == "":
		if show_error:
			push_error("투사체 ID가 비어있음")
		return {}

	if not projectiles.has(projectile_id):
		if show_error:
			push_error("투사체 데이터가 없음: " + str(projectile_id))
		return {}

	var projectile_data = projectiles[projectile_id]

	if typeof(projectile_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("투사체 데이터가 Dictionary가 아님: " + str(projectile_id))
		return {}

	return projectile_data
# projectile_info에서 투사체 ID 가져오기 함수
func get_projectile_id_from_info(projectile_info):
	if projectile_info == null:
		return "slash_basic"

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return "slash_basic"

	return str(projectile_info.get("projectile", "slash_basic"))
# projectile_id 기준으로 투사체 지속 시간 가져오기 함수
func get_projectile_life_time_by_id(projectile_id):
	var projectile_data = get_projectile_data_by_id(projectile_id, false)

	if projectile_data.is_empty():
		return 0.9

	return float(projectile_data.get("life_time", 0.9))
# item_id 기준으로 전투 씬의 아이템 데이터 가져오기 함수
func get_item_data_by_id(item_id, show_error = false):
	if item_id == "":
		if show_error:
			push_error("아이템 ID가 비어있음")
		return {}

	if not items.has(item_id):
		if show_error:
			push_error("아이템 데이터가 없음: " + str(item_id))
		return {}

	var item_data = items[item_id]

	if typeof(item_data) != TYPE_DICTIONARY:
		if show_error:
			push_error("아이템 데이터가 Dictionary가 아님: " + str(item_id))
		return {}

	return item_data
# item_id 기준으로 전투 씬의 아이템 이름 가져오기 함수
func get_item_name_by_id(item_id):
	var item_data = get_item_data_by_id(item_id, false)

	if item_data.is_empty():
		return str(item_id)

	return str(item_data.get("name", item_id))

# ============================================================
# 버튼 클릭 함수 모음
# ============================================================

# 공격 버튼 클릭 함수
func _on_attack_button_pressed():
	if not can_player_choose_action():
		return
	
	play_click_sound()
	start_attack_mode()
# 관찰 버튼 클릭 함수
func _on_observe_button_pressed():
	if not can_player_choose_action():
		return

	play_click_sound()
	start_observe_mode()
# 아이템 버튼 클릭 함수
func _on_item_button_pressed():
	if not can_player_choose_action():
		return

	play_click_sound()
	open_battle_item_list()
# 턴종료 버튼 클릭 함수
func _on_end_turn_button_pressed():
	if not can_player_choose_action():
		return

	play_click_sound()
	hide_player_action_menu()

	await show_battle_text_for_seconds("턴을 종료했다.", 0.7)

	start_enemy_turn()
# 도망 버튼 클릭 함수
func _on_run_button_pressed():
	if not can_player_choose_action():
		return

	play_click_sound()
	hide_player_action_menu()

	if enemy_data.get("can_escape", true):
		# 사운드 추가 및 적 이미지 안보이게 수정
		if result_sound != null:
			result_sound.play()
		enemy_sprite.visible = false

		await show_battle_text_for_seconds("당신은 도망쳤다.", 1.0)

		finish_battle(make_battle_escape_result())
	else:
		# 사운드 추가
		if result_sound != null:
			result_sound.play()
		await show_battle_text_for_seconds("당신은 도망칠 수 없다...", 1.0)

		start_enemy_turn()

# ============================================================
# 기타 함수 모음
# ============================================================

# 플레이어 턴 시작 텍스트 표시 함수
func show_player_turn_start_text():
	set_battle_text(get_player_turn_start_text())
# 플레이어 행동 메뉴 표시 함수
func show_player_action_menu():
	show_player_turn_start_text()
	set_action_buttons_disabled(false)
	update_action_button_focus()
# 플레이어 행동 메뉴 숨김 함수
func hide_player_action_menu():
	set_action_buttons_disabled(true)
	update_action_button_focus()
# 전투 무기 액션 표시 초기화 함수
func reset_weapon_action_visual():
	weapon_swing_enabled = false
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
	attack_guide.visible = false
# 플레이어 액션 모드 초기화 함수
func reset_player_action_modes():
	is_attack_mode = false
	is_defense_mode = false
	is_observing = false
	is_item_selecting = false
# 플레이어 턴 상태 준비 함수
func prepare_player_turn_state():
	is_player_turn = true
	waiting_enemy_attack = false
	action_button_index = 0

	reset_player_action_modes()
	reset_weapon_action_visual()
# 적 공격 대기 시작 함수
func start_enemy_attack_wait():
	waiting_enemy_attack = true
# 적 공격 대기 종료 함수
func end_enemy_attack_wait():
	waiting_enemy_attack = false
# 적 공격 대기 후 공격 실행 함수
func confirm_enemy_attack_wait():
	if not can_start_battle_input_process():
		return

	lock_battle_input_process()

	end_enemy_attack_wait()
	await execute_enemy_attack()

	unlock_battle_input_process()
# 적 공격 대기 입력 처리 함수
func update_enemy_attack_wait_input():
	if Input.is_action_just_pressed("ui_accept"):
		await confirm_enemy_attack_wait()
# 적 턴 상태 준비 함수
func prepare_enemy_turn_state():
	is_player_turn = false

	reset_player_action_modes()
	reset_weapon_action_visual()
	start_enemy_attack_wait()
# 플레이어 턴 시작 함수
func start_player_turn():
	print("start_player_turn")

	prepare_player_turn_state()

	set_action_buttons_disabled(true)

	var can_continue = await apply_player_turn_start_relic_effects()

	if not can_continue:
		return

	show_player_action_menu()
# 적 턴 시작 함수
func start_enemy_turn():
	print("start_enemy_turn")
	
	prepare_enemy_turn_state()

	set_action_buttons_disabled(true)
	apply_normal_enemy_turn_pattern()
# 버튼 활성/비활성 함수
func set_action_buttons_disabled(disabled):
	attack_button.disabled = disabled
	observe_button.disabled = disabled
	item_button.disabled = disabled
	end_turn_button.disabled = disabled
	run_button.disabled = disabled
	update_action_button_focus()
# 전투 종료 기본 결과 데이터 생성 함수
func make_battle_finish_result(result_type):
	return {
		"result": result_type,
		"enemy_id": enemy_id,
		"player_hp": player_hp,
		"inventory": inventory
	}
# 전투 승리 결과 데이터 생성 함수
func make_battle_win_result(rewards, reward_flags):
	var result_data = make_battle_finish_result("win")

	result_data["rewards"] = rewards
	result_data["reward_flags"] = reward_flags

	return result_data
# 전투 도주 결과 데이터 생성 함수
func make_battle_escape_result():
	return make_battle_finish_result("escaped")
# 전투 종료 신호 전달 함수
func finish_battle(result_data):
	emit_signal("battle_finished", result_data)
# 적 처치 텍스트 생성 함수
func make_enemy_defeated_text():
	return enemy_data.get("name", "적") + "을 쓰러뜨렸다."
# 전투 승리 텍스트 표시 함수
func show_battle_win_text():
	# 전투 종료시 정상 상태로 돌아옴.
	player_portrait.texture = load(player_portrait_paths["normal"])
	set_battle_text_with_accept("전투에서 승리했다.")
	await wait_for_accept_input()
# 승리 함수 추가
func win_battle():
	battle_ended = true
	set_action_buttons_disabled(true)

	set_battle_text(make_enemy_defeated_text())

	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 1.0)

	for part_id in enemy_part_sprites.keys():
		var part_sprite = enemy_part_sprites[part_id]

		if part_sprite != null and is_instance_valid(part_sprite):
			tween.parallel().tween_property(part_sprite, "modulate:a", 0.0, 1.0)

	await tween.finished
	
	clear_enemy_parts()
	
	# 적 드랍
	var rewards = calculate_enemy_drops()
	var reward_flags = calculate_enemy_defeat_flags()
	var reward_messages = make_reward_messages(rewards)
	
	await stop_battle_bgm(true, 0.8)
	
	# 사운드 추가
	if result_sound != null:
		result_sound.play()

	await show_battle_win_text()

	if reward_messages.size() > 0:
		await show_battle_result_messages(reward_messages)

	# 전투 종료 후 메인에 전달할 변수들
	finish_battle(
		make_battle_win_result(
			rewards,
			reward_flags
		)
	)
# 게임오버 텍스트 생성 함수
func make_game_over_text():
	return "YOU DIED"
# 게임오버 텍스트 표시 함수
func show_game_over_text():
	await show_battle_text_for_seconds(make_game_over_text(), 2.0)
# 게임오버 상태 준비 함수
func prepare_game_over_state():
	battle_ended = true
	is_player_turn = false
	waiting_enemy_attack = false

	reset_player_action_modes()
	reset_weapon_action_visual()
	set_action_buttons_disabled(true)
# 게임오버 시작 가능 여부 확인 함수
func can_start_game_over_flow():
	if game_over_started:
		return false

	if battle_ended:
		return false

	if player_hp > 0:
		return false

	return true
# 게임오버 플로우 시작 함수
func start_game_over_flow(delay = 0.0):
	if not can_start_game_over_flow():
		return

	game_over_started = true
	prepare_game_over_state()

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

	await game_over()
# 게임 오버 함수
func game_over():
	game_over_started = true
	prepare_game_over_state()

	await show_game_over_text()
# 전투 텍스트 표시 함수
func set_battle_text(text):
	# 여긴 set_battle_text() 함수로 처리하면 안됌 그러면 무하루프에 빠질수가있음!
	battle_text.text = str(text)
# 전투 텍스트 비우기 함수
func clear_battle_text():
	set_battle_text("")
# Space 입력 안내가 붙은 전투 텍스트 표시 함수
func set_battle_text_with_accept(text):
	set_battle_text(str(text) + "\n\n[Space]")
# 일정 시간 동안 전투 텍스트 표시 함수
func show_battle_text_for_seconds(text, seconds = 1.0):
	set_battle_text(text)

	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
# Space 입력 대기 함수
func wait_for_accept_input():
	while true:
		await get_tree().process_frame

		if Input.is_action_just_pressed("ui_accept"):
			break
# 모든 이펙트 프레임 생성 함수
func make_effect_frames(base_path, count):
	var frames = []

	for i in range(1, count + 1):
		var number = str(i).pad_zeros(2)
		frames.append(base_path + number + ".png")

	return frames
# 관찰 모드 시작 함수
func start_observe_mode():
	hide_player_action_menu()

	is_observing = true
	observe_targets = make_observe_targets()
	observe_index = 0

	if observe_targets.size() == 0:
		set_battle_text_with_accept("관찰할 수 있는 대상이 없다.")
		return

	show_current_observe_target()
# 관찰 모드 종료 함수
func end_observe_mode():
	is_observing = false
	observe_targets.clear()
	observe_index = 0
# 관찰 모드 입력 처리 함수
func update_observe_mode_input():
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		move_observe_target(-1)

	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		move_observe_target(1)

	if Input.is_action_just_pressed("ui_accept"):
		end_observe_mode()
		start_enemy_turn()
# 관찰 대상 리스트 생성 함수
func make_observe_targets():
	var targets = []

	targets.append({
		"target_type": "body",
		"id": "body",
		"name": enemy_data.get("name", "적")
	})

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		var part = enemy_parts[part_id]

		targets.append({
			"target_type": "part",
			"id": part_id,
			"name": part.get("name", part_id)
		})

	return targets
# 관찰 대상 이동 함수
func move_observe_target(direction):
	if observe_targets.size() == 0:
		return

	observe_index += direction

	if observe_index < 0:
		observe_index = observe_targets.size() - 1

	if observe_index >= observe_targets.size():
		observe_index = 0

	play_click_sound()
	show_current_observe_target()
# 관찰 대상 타입 가져오기 함수
func get_observe_target_type(target):
	if target == null:
		return "body"

	if typeof(target) != TYPE_DICTIONARY:
		return "body"

	return str(target.get("target_type", "body"))
# 관찰 대상 ID 가져오기 함수
func get_observe_target_id(target):
	if target == null:
		return ""

	if typeof(target) != TYPE_DICTIONARY:
		return ""

	return str(target.get("id", ""))
# 관찰 대상 이름 가져오기 함수
func get_observe_target_name(target):
	if target == null:
		return "대상"

	if typeof(target) != TYPE_DICTIONARY:
		return "대상"

	return str(target.get("name", "대상"))
# 적 본체 관찰 텍스트 생성 함수
func make_body_observe_text(target_name):
	var text = ""

	text += "[ " + str(target_name) + " ]\n"
	text += str(enemy_data.get("observe_text", "특별한 점은 보이지 않는다.")) + "\n"

	var weakness_text = str(enemy_data.get("weakness_text", ""))

	if weakness_text != "":
		text += weakness_text + "\n"

	text += "\n남은 체력 : " + str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))

	return text	
# 적 파츠 관찰 텍스트 생성 함수
func make_part_observe_text(target_id, target_name):
	var part = get_enemy_part_data_by_id(target_id)

	if part.is_empty():
		return "[ " + str(target_name) + " ]\n확인할 수 없는 부위이다."

	var text = ""

	text += "[ " + str(target_name) + " ]\n"
	text += str(part.get("observe_text", "특별한 점은 보이지 않는다.")) + "\n"

	var weakness_text = str(part.get("weakness_text", ""))

	if weakness_text != "":
		text += weakness_text + "\n"

	var hp = int(enemy_part_hp.get(target_id, 0))
	var max_hp = get_enemy_part_max_hp_from_data(part)

	text += "\n남은 체력 : " + str(hp) + " / " + str(max_hp)

	return text	
# 관찰 조작 안내 텍스트 생성 함수
func make_observe_control_text():
	var text = ""

	if observe_targets.size() > 1:
		text += "\n\n[A/D] 관찰 대상 변경"

	text += "\n[Space] 관찰을 끝낸다."

	return text
# 현재 관찰 대상 텍스트 생성 함수
func make_current_observe_target_text():
	if observe_targets.size() == 0:
		return ""

	var target = observe_targets[observe_index]
	var target_type = get_observe_target_type(target)
	var target_id = get_observe_target_id(target)
	var target_name = get_observe_target_name(target)

	var text = ""

	if target_type == "part":
		text = make_part_observe_text(target_id, target_name)
	else:
		text = make_body_observe_text(target_name)

	text += make_observe_control_text()

	return text
# 관찰 하는 현재 대상 표시 함수
func show_current_observe_target():
	var text = make_current_observe_target_text()

	if text == "":
		return

	set_battle_text(text)
# 화면 암전 처리 함수
func fade_to_black(duration = 0.5):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished
# 화면 암전 되돌리기 함수
func fade_from_black(duration = 0.5):
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished
# 전투 아이템 선택 모드 시작 함수
func start_battle_item_select_mode():
	hide_player_action_menu()
	is_item_selecting = true
	update_battle_item_list()
# 전투 아이템 선택 모드 종료 함수
func end_battle_item_select_mode():
	is_item_selecting = false
# 전투 아이템 선택 취소 함수
func cancel_battle_item_select_mode():
	end_battle_item_select_mode()
	show_player_action_menu()
# 아이템 목록 열기 함수
func open_battle_item_list():
	battle_consumables.clear()
	item_index = 0
	battle_item_scroll_start = 0

	for inventory_item in inventory:
		if inventory_item == null:
			continue

		if typeof(inventory_item) != TYPE_DICTIONARY:
			continue

		var item_id = inventory_item.get("id", "")
		var item_data = get_item_data_by_id(item_id)

		if item_data.is_empty():
			continue

		if item_data.get("type", "") == "consumable":
			battle_consumables.append(inventory_item)

	if battle_consumables.size() == 0:
		set_action_buttons_disabled(true)
		if result_sound != null:
			result_sound.play()
			
		await show_battle_text_for_seconds("사용할 수 있는 아이템이 없다.", 1.0)

		show_player_action_menu()
		return

	start_battle_item_select_mode()
# 전투 아이템 목록 전체 텍스트 생성 함수
func make_battle_item_list_text():
	var text = "사용할 아이템을 선택하세요.\n\n"

	var start_index = get_battle_item_visible_start_index()
	var end_index = get_battle_item_visible_end_index()

	if start_index > 0:
		text += "  ↑\n"

	for i in range(start_index, end_index):
		var line_text = make_battle_item_line_text(battle_consumables[i], i)

		if line_text == "":
			continue

		text += line_text

	if end_index < battle_consumables.size():
		text += "  ↓\n"

	text += "\n[↑↓/WS] 선택 / [Space] 사용 / [ESC] 취소"

	return text
# 전투 아이템 목록 표시 시작 인덱스 가져오기 함수
func get_battle_item_visible_start_index():
	return battle_item_scroll_start
# 전투 아이템 목록 표시 끝 인덱스 가져오기 함수
func get_battle_item_visible_end_index():
	return min(
		battle_consumables.size(),
		battle_item_scroll_start + BATTLE_ITEM_VISIBLE_COUNT
	)
# 전투 아이템 목록 한 줄 텍스트 생성 함수
func make_battle_item_line_text(inventory_item, index):
	if inventory_item == null:
		return ""

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return ""

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return ""

	var item_name = get_item_name_by_id(item_id)
	var count_text = make_battle_item_count_text(inventory_item)

	if index == item_index:
		return "▶ " + item_name + count_text + "\n"

	return "  " + item_name + count_text + "\n"
# 전투 아이템 수량 텍스트 생성 함수
func make_battle_item_count_text(inventory_item):
	if inventory_item == null:
		return ""

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return ""

	if inventory_item.has("count"):
		return " x" + str(int(inventory_item["count"]))

	return ""
# 아이템 목록 표시 함수
func update_battle_item_list():
	update_battle_item_scroll()
	set_battle_text(make_battle_item_list_text())
# 전투 아이템 사용 결과 표시 함수
func show_battle_item_used_text(item_id):
	await show_battle_text_for_seconds(
		make_battle_item_used_text(item_id),
		1.0
	)
# 전투 아이템 사용 결과 텍스트 생성 함수
func make_battle_item_used_text(item_id):
	var item_name = get_item_name_by_id(item_id)

	return item_name + " 을 사용했다."
# 아이템 사용 함수
func use_selected_battle_item():
	if battle_consumables.size() == 0:
		return

	if item_index < 0 or item_index >= battle_consumables.size():
		return

	var inventory_item = battle_consumables[item_index]

	if inventory_item == null:
		return

	if typeof(inventory_item) != TYPE_DICTIONARY:
		return

	var item_id = inventory_item.get("id", "")
	var item_data = get_item_data_by_id(item_id)

	if item_data.is_empty():
		return
	
	if item_data.has("heal"):
		player_hp += int(item_data["heal"])

		if player_hp > player_max_hp:
			player_hp = player_max_hp
			
	if item_data.has("clear_status_effects"):
		clear_selected_player_status_effects(item_data.get("clear_status_effects", []))

	if healing_sound != null:
		healing_sound.play()

	update_player_hp_ui()

	if inventory_item.has("count"):
		inventory_item["count"] -= 1

		if inventory_item["count"] <= 0:
			inventory.erase(inventory_item)
	else:
		inventory.erase(inventory_item)

	end_battle_item_select_mode()

	await show_battle_item_used_text(item_id)

	start_enemy_turn()
# 전투 드랍 아이템 계산 함수
func calculate_enemy_drops():
	var rewards = []
	var drops = enemy_data.get("drops", [])

	for drop in drops:
		var item_id = drop.get("item", "")

		if item_id == "":
			continue

		if get_item_data_by_id(item_id, true).is_empty():
			continue
		
		# 한번 획득 가능한 아이템 플래그 검사
		var once_flag = drop.get("once_flag", "")
		if once_flag != "" and flags.has(once_flag) and flags[once_flag] == true:
			continue
		
		var chance = float(drop.get("chance", 100))
		var roll = randf() * 100.0

		if roll > chance:
			continue

		var min_count = int(drop.get("min", 1))
		var max_count = int(drop.get("max", 1))
		var count = randi_range(min_count, max_count)

		if count <= 0:
			continue

		var reward = {
			"item": item_id,
			"count": count
		}
		
		if once_flag != "":
			reward["once_flag"] = once_flag

		rewards.append(reward)

	return rewards
# 전투 보상 결과 메시지 생성 함수
func make_reward_messages(rewards):
	var messages = []

	for reward in rewards:
		if reward == null:
			continue

		if typeof(reward) != TYPE_DICTIONARY:
			continue

		var item_id = reward.get("item", "")
		var count = int(reward.get("count", 1))

		if get_item_data_by_id(item_id).is_empty():
			continue

		var item_name = get_item_name_by_id(item_id)
		messages.append(item_name + " " + str(count) + "개를 획득하였습니다.")

	return messages
# 전투 결과 메시지 순차 표시 함수
func show_battle_result_messages(messages):
	for message in messages:
		if result_sound != null:
			result_sound.play()

		set_battle_text_with_accept(message)
		await wait_for_accept_input()
# 전투 아이템 선택용 키 입력 액션 생성 함수
func ensure_battle_item_input_actions():
	ensure_key_action("battle_item_up", KEY_W)
	ensure_key_action("battle_item_down", KEY_S)
# 키보드 액션이 없으면 코드에서 자동 생성하는 함수
func ensure_key_action(action_name, physical_keycode):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == physical_keycode:
			return

	var key_event = InputEventKey.new()
	key_event.physical_keycode = physical_keycode
	InputMap.action_add_event(action_name, key_event)
# 전투 아이템 선택 모드 입력 처리 함수
func update_battle_item_select_input():
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("battle_item_down"):
		move_battle_item_selection(1)

	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("battle_item_up"):
		move_battle_item_selection(-1)

	if Input.is_action_just_pressed("ui_accept"):
		use_selected_battle_item()

	if Input.is_action_just_pressed("esc"):
		cancel_battle_item_select_mode()
# 전투 아이템 선택 이동 함수
func move_battle_item_selection(direction):
	if battle_consumables.size() == 0:
		return

	item_index += direction

	if item_index >= battle_consumables.size():
		item_index = 0

	if item_index < 0:
		item_index = battle_consumables.size() - 1

	update_battle_item_scroll()
	update_battle_item_list()
	play_click_sound()
# 전투 아이템 목록 스크롤 위치 갱신 함수
func update_battle_item_scroll():
	if item_index < battle_item_scroll_start:
		battle_item_scroll_start = item_index

	if item_index >= battle_item_scroll_start + BATTLE_ITEM_VISIBLE_COUNT:
		battle_item_scroll_start = item_index - BATTLE_ITEM_VISIBLE_COUNT + 1

	if battle_item_scroll_start < 0:
		battle_item_scroll_start = 0

# ============================================================
# 음원 함수 모음
# ============================================================

# 전투 BGM 갱신 함수
func update_battle_bgm():
	var bgm_path = enemy_data.get("battle_bgm", "")
	var next_stream = default_battle_bgm_stream

	if bgm_path != "":
		next_stream = load(bgm_path)

	var bgm_volume = enemy_data.get("battle_bgm_volume_db", default_battle_bgm_volume_db)
	var bgm_loop = enemy_data.get("battle_bgm_loop", true)
	var bgm_fade_in = enemy_data.get("battle_bgm_fade_in", true)
	var bgm_fade_time = enemy_data.get("battle_bgm_fade_time", 1.0)

	await play_battle_bgm(
		next_stream,
		bgm_volume,
		bgm_loop,
		bgm_fade_in,
		bgm_fade_time,
		false
	)
# 오디오 스트림 루프 설정 함수
func set_audio_stream_loop(stream, should_loop):
	if stream == null:
		return

	for property in stream.get_property_list():
		var property_name = property.get("name", "")

		if property_name == "loop":
			stream.set("loop", should_loop)
			return

		if property_name == "loop_mode":
			if should_loop:
				stream.set("loop_mode", AudioStreamWAV.LOOP_FORWARD)
			else:
				stream.set("loop_mode", AudioStreamWAV.LOOP_DISABLED)
			return
# BGM 종료시 루프 보정 함수
func _on_battle_bgm_finished():
	if battle_bgm_should_loop and not battle_ended:
		battle_bgm.play()
# 같은 오디오 스트림인지 확인 함수
func is_same_audio_stream(stream_a, stream_b):
	if stream_a == null or stream_b == null:
		return false

	if stream_a == stream_b:
		return true

	if stream_a.resource_path != "" and stream_b.resource_path != "":
		return stream_a.resource_path == stream_b.resource_path

	return false
# BGM 볼륨 페이드 함수
func fade_bgm_volume(target_volume_db, duration):
	if bgm_volume_tween != null and bgm_volume_tween.is_valid():
		bgm_volume_tween.kill()

	bgm_volume_tween = create_tween()
	bgm_volume_tween.tween_property(battle_bgm, "volume_db", target_volume_db, duration)
# BGM 정지 함수
func stop_battle_bgm(fade_out = true, fade_time = 0.8):
	battle_bgm_should_loop = false

	if bgm_volume_tween != null and bgm_volume_tween.is_valid():
		bgm_volume_tween.kill()

	if fade_out and battle_bgm.playing:
		var tween = create_tween()
		tween.tween_property(battle_bgm, "volume_db", -40.0, fade_time)
		await tween.finished

	battle_bgm.stop()
	battle_bgm.volume_db = default_battle_bgm_volume_db
# BGM 재생 함수
func play_battle_bgm(
	next_stream,
	target_volume_db = null,
	loop = true,
	fade_in = true,
	fade_time = 1.0,
	restart_if_same = false):
	if next_stream == null:
		return

	if target_volume_db == null:
		target_volume_db = default_battle_bgm_volume_db

	set_audio_stream_loop(next_stream, loop)
	battle_bgm_should_loop = loop

	var same_stream = is_same_audio_stream(battle_bgm.stream, next_stream)

	if same_stream and battle_bgm.playing and not restart_if_same:
		fade_bgm_volume(target_volume_db, 0.2)
		return

	if battle_bgm.playing and not same_stream:
		await stop_battle_bgm(true, min(fade_time, 0.5))

	battle_bgm_should_loop = loop
	battle_bgm.stream = next_stream

	if fade_in:
		battle_bgm.volume_db = -40.0
	else:
		battle_bgm.volume_db = target_volume_db

	battle_bgm.play()

	if fade_in:
		fade_bgm_volume(target_volume_db, fade_time)
# 오디오 단발 효과음 재생 함수
func play_one_shot_sound(player, sound_path = "", fallback_stream = null, volume_db = null):
	var next_stream = fallback_stream

	if sound_path != "":
		next_stream = load(sound_path)

	if next_stream == null:
		return

	player.stop()
	player.stream = next_stream

	if volume_db != null:
		player.volume_db = volume_db

	player.play()
# 오디오 적 등장 효과음 재생 함수
func play_enemy_encounter_sound():
	var sound_path = enemy_data.get("encounter_sound", "")
	var volume_db = enemy_data.get("encounter_sound_volume_db", default_enemy_encounter_volume_db)

	play_one_shot_sound(
		enemy_encounter_sound,
		sound_path,
		default_enemy_encounter_stream,
		volume_db
	)
# 같은 효과음이 짧은 시간에 여러 번 나도 서로 끊기지 않게 재생하는 함수
func play_overlap_sound_from_player(source_player):
	if source_player == null:
		return

	if source_player.stream == null:
		return

	var sound = AudioStreamPlayer.new()
	sound.stream = source_player.stream
	sound.volume_db = source_player.volume_db
	sound.pitch_scale = source_player.pitch_scale
	sound.bus = source_player.bus

	add_child(sound)

	sound.finished.connect(Callable(sound, "queue_free"))
	sound.play()

# ============================================================
# 디버그 함수 모음
# ============================================================

# 디버그 히트 박스 확인용 함수
func update_hitbox_debug():
	clear_enemy_projectile_debug_boxes()

	for child in hitbox_debug_container.get_children():
		if child == player_attack_hitbox_debug:
			continue
		if child == defense_weapon_hitbox_debug:
			continue
		if child == enemy_projectile_hitbox_debug:
			continue
		if child == parry_hitbox_debug:
			continue

		child.queue_free()

	if not debug_mode:
		hitbox_debug_container.visible = false
		player_attack_hitbox_debug.visible = false
		defense_weapon_hitbox_debug.visible = false
		enemy_projectile_hitbox_debug.visible = false
		parry_hitbox_debug.visible = false
		update_debug_hp_labels()
		return

	hitbox_debug_container.visible = true

	var body_hitboxes = get_current_enemy_body_hitboxes()
	var enemy_rect = enemy_sprite.get_global_rect()

	for hitbox in body_hitboxes:
		if not is_valid_body_hitbox_data(hitbox):
			continue

		var rect_data = get_hitbox_rect_data(hitbox)

		var box = ColorRect.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.color = Color(1, 1, 1, 0.12)

		if hitbox.get("weak", false):
			box.color = Color(1, 0, 0, 0.18)

		var hitbox_rect = make_scaled_hitbox_rect(enemy_rect, rect_data)
		box.position = hitbox_rect.position
		box.size = hitbox_rect.size

		hitbox_debug_container.add_child(box)
		
	update_part_hitbox_debug(get_enemy_hitbox_base_size(), enemy_rect)
	update_debug_hp_labels()
# 디버그 박스 갱신 함수
func update_defense_hitbox_debug(projectile, projectile_data):
	if not debug_mode:
		defense_weapon_hitbox_debug.visible = false
		enemy_projectile_hitbox_debug.visible = false
		parry_hitbox_debug.visible = false
		clear_enemy_projectile_debug_boxes()
		return

	var weapon_rect = get_weapon_defense_hit_rect()
	var debug_container_global = hitbox_debug_container.get_global_rect().position
	var parry_rect = get_parry_hit_rect()

	defense_weapon_hitbox_debug.visible = true
	defense_weapon_hitbox_debug.position = weapon_rect.position - debug_container_global
	defense_weapon_hitbox_debug.size = weapon_rect.size

	parry_hitbox_debug.visible = true
	parry_hitbox_debug.position = parry_rect.position - debug_container_global
	parry_hitbox_debug.size = parry_rect.size

	# 기존 단일 적 탄막 디버그 노드는 사용하지 않음
	enemy_projectile_hitbox_debug.visible = false

	# 현재 탄막 전용 디버그 박스 갱신
	update_enemy_projectile_debug_box(projectile, projectile_data)
# 디버그 적 파츠 확인 함수
func update_part_hitbox_debug(_base_size, enemy_rect):
	# 변수 scale 경고 떠서 hitbox_scale로 수정
	var hitbox_scale = get_enemy_hitbox_scale()

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		var hitbox = get_enemy_part_hitbox_by_part_id(part_id)

		if hitbox.is_empty():
			continue

		var rect_data = get_hitbox_rect_data(hitbox)

		if rect_data.size() < 4:
			continue

		var box = ColorRect.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.color = Color(0.2, 0.7, 1, 0.18)

		box.position = Vector2(
			enemy_rect.position.x + rect_data[0] * hitbox_scale.x,
			enemy_rect.position.y + rect_data[1] * hitbox_scale.y
		)

		box.size = Vector2(
			rect_data[2] * hitbox_scale.x,
			rect_data[3] * hitbox_scale.y
		)

		hitbox_debug_container.add_child(box)
# 디버그 HP 라벨 제거 함수
func clear_debug_hp_labels():
	for label in debug_hp_labels:
		if label != null and is_instance_valid(label):
			label.queue_free()

	debug_hp_labels.clear()
# 디버그 HP 라벨 갱신 함수
func update_debug_hp_labels():
	clear_debug_hp_labels()

	if not debug_mode:
		return

	create_body_debug_hp_label()

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		create_part_debug_hp_label(part_id)
# 디버그 파츠 HP 라벨 생성 함수
func create_part_debug_hp_label(part_id):
	var part = get_enemy_part_data_by_id(part_id)

	if part.is_empty():
		return

	var hitbox = get_enemy_part_hitbox_from_data(part)

	if hitbox.is_empty():
		return

	var rect_data = get_hitbox_rect_data(hitbox)

	if rect_data.size() < 4:
		return

	var enemy_rect = enemy_sprite.get_global_rect()
	# 변수 scale 경고 떠서 hitbox_scale로 수정
	var hitbox_scale = get_enemy_hitbox_scale()
	var debug_global = hitbox_debug_container.get_global_rect().position

	var part_name = get_enemy_part_name_from_data(part, part_id)
	var current_hp = int(enemy_part_hp.get(part_id, 0))
	var max_hp = get_enemy_part_max_hp_from_data(part)

	var label = Label.new()
	label.text = part_name + "\nHP " + str(current_hp) + " / " + str(max_hp)
	label.z_index = 1000
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.6, 0.85, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 5)

	label.position = Vector2(
		enemy_rect.position.x + (rect_data[0] + rect_data[2] / 2.0) * hitbox_scale.x - 100,
		enemy_rect.position.y + (rect_data[1] + rect_data[3]) * hitbox_scale.y + 10
	) - debug_global

	hitbox_debug_container.add_child(label)
	debug_hp_labels.append(label)
# 디버그 본체 HP 라벨 생성 함수
func create_body_debug_hp_label():
	var label = Label.new()
	label.text = "BODY HP " + str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))
	label.z_index = 1000
	label.size = enemy_hp_label_size
	label.position = enemy_hp_label_position
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 5)

	add_child(label)
	debug_hp_labels.append(label)
# 적 탄막 디버그 박스 가져오기/생성 함수
func get_enemy_projectile_debug_box(projectile):
	if projectile == null:
		return null

	if not is_instance_valid(projectile):
		return null

	var projectile_key = projectile.get_instance_id()

	if enemy_projectile_debug_boxes.has(projectile_key):
		var existing_box = enemy_projectile_debug_boxes[projectile_key]

		if existing_box != null and is_instance_valid(existing_box):
			return existing_box

	var box = ColorRect.new()
	box.name = "EnemyProjectileHitboxDebug_" + str(projectile_key)
	box.color = Color(1, 1, 0, 0.32)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.z_index = 300

	hitbox_debug_container.add_child(box)
	enemy_projectile_debug_boxes[projectile_key] = box

	return box
# 적 탄막 디버그 박스 갱신 함수
func update_enemy_projectile_debug_box(projectile, projectile_data):
	if not debug_mode:
		return

	if projectile == null:
		return

	if not is_instance_valid(projectile):
		return

	var projectile_rect = get_projectile_hit_rect(projectile, projectile_data)
	var debug_container_global = hitbox_debug_container.get_global_rect().position
	var box = get_enemy_projectile_debug_box(projectile)

	if box == null:
		return

	box.visible = true
	box.position = projectile_rect.position - debug_container_global
	box.size = projectile_rect.size
# 특정 적 탄막 디버그 박스 제거 함수
func remove_enemy_projectile_debug_box(projectile):
	if projectile == null:
		return

	var projectile_key = projectile.get_instance_id()

	if not enemy_projectile_debug_boxes.has(projectile_key):
		return

	var box = enemy_projectile_debug_boxes[projectile_key]

	if box != null and is_instance_valid(box):
		box.queue_free()

	enemy_projectile_debug_boxes.erase(projectile_key)
# 모든 적 탄막 디버그 박스 제거 함수
func clear_enemy_projectile_debug_boxes():
	for key in enemy_projectile_debug_boxes.keys():
		var box = enemy_projectile_debug_boxes[key]

		if box != null and is_instance_valid(box):
			box.queue_free()

	enemy_projectile_debug_boxes.clear()

# ============================================================
# 적 관련 함수 모음
# ============================================================

# 적 HP ui 갱신 함수
func update_enemy_hp_ui():
	update_debug_hp_labels()
# 적 공격 실행 시작 준비 함수
func prepare_enemy_attack_execution():
	clear_battle_text()
# 적 공격 후 전투 흐름 중단 여부 확인 함수
func should_stop_after_enemy_attack():
	if game_over_started:
		return true

	if battle_ended:
		return true

	return false
# 적 공격 후 플레이어 사망 처리 함수
func check_player_death_after_enemy_attack():
	if player_hp > 0:
		return false

	await start_game_over_flow()
	return true
# 적 공격 후 플레이어 턴 복귀 대기 함수
func wait_before_returning_to_player_turn():
	await get_tree().create_timer(0.5).timeout
# 적 공격 후 플레이어 턴 복귀 함수
func return_to_player_turn_after_enemy_attack():
	await wait_before_returning_to_player_turn()

	if should_stop_after_enemy_attack():
		return

	start_player_turn()
# 적 공격 함수
func execute_enemy_attack():
	prepare_enemy_attack_execution()

	await fire_enemy_projectiles()

	if should_stop_after_enemy_attack():
		return

	if await check_player_death_after_enemy_attack():
		return

	await return_to_player_turn_after_enemy_attack()
# 적 탄막 난이도 보정 함수
func get_adjusted_projectile_info(projectile_info):
	var adjusted = projectile_info.duplicate(true)
	var danger_type = adjusted.get("danger_type", "normal")
	
	if battle_difficulty == "easy":
		if danger_type == "parry_only":
			adjusted["danger_type"] = "normal"

	elif battle_difficulty == "hard":
		if danger_type == "normal":
			if randf() < 0.35:
				adjusted["danger_type"] = "parry_only"

	elif battle_difficulty == "nightmare":
		adjusted["danger_type"] = "parry_only"

	return adjusted
# 적 탄막 처리 결과 Dictionary 생성 함수
func make_enemy_projectile_result(result_type):
	return {
		"result_type": result_type
	}
# 적 탄막 처리 결과 타입 가져오기 함수
func get_enemy_projectile_result_type(result):
	if result == null:
		return "expired"

	if typeof(result) != TYPE_DICTIONARY:
		return "expired"

	return str(result.get("result_type", "expired"))
# 적 탄막 결과가 플레이어 피해로 이어지는지 확인하는 함수
func should_enemy_projectile_damage_player(result):
	var result_type = get_enemy_projectile_result_type(result)

	if result_type == "parried":
		return false

	if result_type == "blocked":
		return false

	return true
# 적 탄막이 피해 판정선에 도달했는지 확인하는 함수
func has_enemy_projectile_reached_damage_line(projectile, projectile_data):
	var projectile_hit_rect = get_projectile_hit_rect(projectile, projectile_data)
	var damage_line_y = defense_area_rect.position.y + defense_area_rect.size.y - 20

	return projectile_hit_rect.position.y + projectile_hit_rect.size.y >= damage_line_y
# 적 탄막 현재 프레임 적용 함수
func apply_enemy_projectile_frame(projectile, projectile_frames, frame_index, projectile_id):
	var frame_texture = get_enemy_projectile_frame_texture(
		projectile_frames,
		frame_index,
		projectile_id
	)

	if frame_texture != null:
		projectile.texture = frame_texture
# 적 탄막 노드 유효성 확인 함수
func is_valid_enemy_projectile_node(projectile):
	if projectile == null:
		return false

	if not is_instance_valid(projectile):
		return false

	return true
# 적 탄막 이동 루프 중단 여부 확인 함수
func should_stop_enemy_projectile_motion(projectile):
	if should_stop_enemy_projectile_flow():
		return true

	if not is_valid_enemy_projectile_node(projectile):
		return true

	return false
# 적 탄막 1프레임 이동 함수
func move_enemy_projectile_one_frame(projectile, direction, projectile_speed, projectile_frame_time):
	projectile.position += direction * projectile_speed * projectile_frame_time
# 적 탄막 패링 결과 확인 함수
func get_enemy_projectile_parry_result(projectile, projectile_data):
	if parry_input_buffer_time <= 0:
		return {}

	if not check_parry_hit(projectile, projectile_data):
		return {}

	parry_count += 1
	projectile.visible = false

	if parry_sound != null:
		parry_sound.play()

	spawn_parry_effect(
		get_parry_effect_position_for_projectile(projectile, projectile_data)
	)

	return make_enemy_projectile_result("parried")
# 적 탄막 방어 결과 확인 함수
func get_enemy_projectile_block_result(projectile, projectile_data, danger_type):
	if danger_type == "parry_only":
		return {}

	if not check_defense_hit(projectile, projectile_data):
		return {}

	if block_sound != null:
		block_sound.play()

	return make_enemy_projectile_result("blocked")
# 적 탄막 플레이어 피격 결과 확인 함수
func get_enemy_projectile_player_hit_result(projectile, projectile_data):
	if not has_enemy_projectile_reached_damage_line(projectile, projectile_data):
		return {}

	return make_enemy_projectile_result("hit_player")
# 적 탄막 충돌 결과 확인 함수
func get_enemy_projectile_collision_result(projectile, projectile_data, danger_type):
	var parry_result = get_enemy_projectile_parry_result(projectile, projectile_data)

	if not parry_result.is_empty():
		return parry_result

	var block_result = get_enemy_projectile_block_result(
		projectile,
		projectile_data,
		danger_type
	)

	if not block_result.is_empty():
		return block_result

	var hit_result = get_enemy_projectile_player_hit_result(projectile, projectile_data)

	if not hit_result.is_empty():
		return hit_result

	return {}
# 적 탄막 프레임 인덱스 갱신 함수
func get_next_enemy_projectile_frame_index(frame_index, projectile_frames):
	frame_index += 1

	if projectile_frames.size() > 0 and frame_index >= projectile_frames.size():
		frame_index = 0

	return frame_index
# 적 탄막 이동과 충돌 판정 실행 함수
func run_enemy_projectile_motion(
	projectile,
	projectile_data,
	projectile_id,
	danger_type,
	projectile_speed,
	projectile_life_time,
	projectile_frame_time,
	projectile_frames
):
	var direction = Vector2.DOWN
	var elapsed_time = 0.0
	var frame_index = 0

	while elapsed_time < projectile_life_time:
		if should_stop_enemy_projectile_motion(projectile):
			return make_enemy_projectile_result("expired")

		apply_enemy_projectile_frame(
			projectile,
			projectile_frames,
			frame_index,
			projectile_id
		)

		move_enemy_projectile_one_frame(
			projectile,
			direction,
			projectile_speed,
			projectile_frame_time
		)
		
		update_defense_hitbox_debug(projectile, projectile_data)

		var collision_result = get_enemy_projectile_collision_result(
			projectile,
			projectile_data,
			danger_type
		)

		if not collision_result.is_empty():
			return collision_result

		await get_tree().create_timer(projectile_frame_time).timeout

		elapsed_time += projectile_frame_time
		frame_index = get_next_enemy_projectile_frame_index(
			frame_index,
			projectile_frames
		)

	return make_enemy_projectile_result("expired")
# 적 탄막 노드 정리 함수
func clear_enemy_projectile_node(projectile):
	remove_enemy_projectile_debug_box(projectile)

	if projectile != null and is_instance_valid(projectile):
		projectile.queue_free()
# 적 탄막 정보 유효성 확인 함수
func is_valid_enemy_projectile_info(projectile_info):
	if projectile_info == null:
		return false

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return false

	return true
# 적 탄막 정보 안전 보정 함수
func get_safe_adjusted_enemy_projectile_info(projectile_info):
	if not is_valid_enemy_projectile_info(projectile_info):
		return {}

	return get_adjusted_projectile_info(projectile_info)
# 적 탄막 실행 데이터 생성 함수
func make_enemy_projectile_runtime_data(projectile_data):
	return {
		"speed": get_enemy_projectile_speed(projectile_data),
		"life_time": get_enemy_projectile_life_time(projectile_data),
		"frame_time": get_enemy_projectile_frame_time(projectile_data),
		"frames": get_projectile_frames_from_data(projectile_data)
	}
# 적 탄막 노드 전투 화면 추가 함수
func add_enemy_projectile_node(projectile):
	if projectile == null:
		return

	enemy_projectile_container.add_child(projectile)
# 적 탄막 사운드 재생 함수
func play_enemy_projectile_sound(projectile_data):
	if projectile_data == null:
		return

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return

	var sound_id = projectile_data.get("sound", "")
	play_projectile_sound(sound_id)
# 적 탄막 이동 결과 실행 함수
func run_enemy_projectile_and_get_result(
	projectile,
	projectile_data,
	projectile_id,
	danger_type,
	runtime_data
):
	return await run_enemy_projectile_motion(
		projectile,
		projectile_data,
		projectile_id,
		danger_type,
		float(runtime_data.get("speed", 1200.0)),
		float(runtime_data.get("life_time", 0.9)),
		float(runtime_data.get("frame_time", 0.04)),
		runtime_data.get("frames", [])
	)
# 적 탄막 결과 후처리 함수
func apply_enemy_projectile_result_to_player(
	projectile_result,
	projectile_info,
	projectile_data,
	danger_type
):
	if should_enemy_projectile_damage_player(projectile_result):
		apply_projectile_hit_to_player(projectile_info, projectile_data, danger_type)
# 적의 탄막 발사 함수
func fire_enemy_projectile(projectile_info):
	if should_stop_enemy_projectile_flow():
		return

	projectile_info = get_safe_adjusted_enemy_projectile_info(projectile_info)

	if projectile_info.is_empty():
		return

	var projectile_id = get_projectile_id_from_info(projectile_info)
	var projectile_data = get_projectile_data_by_id(projectile_id, true)

	if projectile_data.is_empty():
		return

	var danger_type = get_enemy_projectile_danger_type(projectile_info)
	var runtime_data = make_enemy_projectile_runtime_data(projectile_data)

	var projectile = create_enemy_projectile_node(
		projectile_info,
		projectile_data,
		danger_type
	)

	add_enemy_projectile_node(projectile)
	play_enemy_projectile_sound(projectile_data)

	var projectile_result = await run_enemy_projectile_and_get_result(
		projectile,
		projectile_data,
		projectile_id,
		danger_type,
		runtime_data
	)

	clear_enemy_projectile_node(projectile)

	if should_stop_enemy_projectile_flow():
		return

	apply_enemy_projectile_result_to_player(
		projectile_result,
		projectile_info,
		projectile_data,
		danger_type
	)
# 적 탄막 크기 가져오기 함수
func get_enemy_projectile_size(projectile_data):
	if projectile_data == null:
		return Vector2(200, 200)

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return Vector2(200, 200)

	var size_data = projectile_data.get("size", [200, 200])

	if typeof(size_data) != TYPE_ARRAY:
		return Vector2(200, 200)

	if size_data.size() < 2:
		return Vector2(200, 200)

	return Vector2(size_data[0], size_data[1])
# 적 탄막 속도 가져오기 함수
func get_enemy_projectile_speed(projectile_data):
	if projectile_data == null:
		return 1200.0

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return 1200.0

	return float(projectile_data.get("speed", 1200.0))
# 적 탄막 지속 시간 가져오기 함수p
func get_enemy_projectile_life_time(projectile_data):
	if projectile_data == null:
		return 0.9

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return 0.9

	var life_time = float(projectile_data.get("life_time", 0.9))

	if life_time <= 0.0:
		return 0.9

	return life_time
# 적 탄막 프레임 시간 가져오기 함수
func get_enemy_projectile_frame_time(projectile_data):
	if projectile_data == null:
		return 0.04

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return 0.04

	var frame_time = float(projectile_data.get("frame_time", 0.04))

	if frame_time <= 0.0:
		return 0.04

	return frame_time
# 적 탄막 시작 위치 가져오기 함수
func get_enemy_projectile_start_position(projectile_info):
	if projectile_info == null:
		return Vector2(900, 120)

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return Vector2(900, 120)

	var start_pos = projectile_info.get("start", [900, 120])

	if typeof(start_pos) != TYPE_ARRAY:
		return Vector2(900, 120)

	if start_pos.size() < 2:
		return Vector2(900, 120)

	return Vector2(start_pos[0], start_pos[1])
# 적 탄막 회전값 가져오기 함수
func get_enemy_projectile_rotation(projectile_info):
	if projectile_info == null:
		return 180.0

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return 180.0

	return float(projectile_info.get("rotation", 180.0))
# 적 탄막 위험 타입 가져오기 함수
func get_enemy_projectile_danger_type(projectile_info):
	if projectile_info == null:
		return "normal"

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return "normal"

	var danger_type = str(projectile_info.get("danger_type", "normal"))

	if danger_type == "":
		return "normal"

	return danger_type
# 적 탄막 위험 타입에 따른 색상 적용 함수
func apply_enemy_projectile_danger_visual(projectile, danger_type):
	if projectile == null:
		return

	if danger_type == "parry_only":
		projectile.modulate = Color(1, 0.15, 0.15, 1)
	else:
		projectile.modulate = Color(1, 1, 1, 1)
# 적 탄막 TextureRect 생성 함수
func create_enemy_projectile_node(projectile_info, projectile_data, danger_type):
	var projectile = TextureRect.new()
	var projectile_size = get_enemy_projectile_size(projectile_data)

	projectile.z_index = 0
	projectile.size = projectile_size
	projectile.pivot_offset = projectile.size / 2
	projectile.ignore_texture_size = true
	projectile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	projectile.mouse_filter = Control.MOUSE_FILTER_IGNORE

	projectile.position = get_enemy_projectile_start_position(projectile_info)
	projectile.rotation_degrees = get_enemy_projectile_rotation(projectile_info)

	apply_enemy_projectile_danger_visual(projectile, danger_type)

	return projectile
# 현재 적 패턴 투사체 목록 가져오기 함수
func get_current_enemy_pattern_projectiles():
	if current_enemy_pattern == null:
		return []

	if typeof(current_enemy_pattern) != TYPE_DICTIONARY:
		return []

	var projectile_list = current_enemy_pattern.get("projectiles", [])

	if typeof(projectile_list) != TYPE_ARRAY:
		return []

	return projectile_list
# 현재 적 패턴 발사 방식 가져오기 함수
func get_current_enemy_pattern_fire_mode():
	if current_enemy_pattern == null:
		return "sequential"

	if typeof(current_enemy_pattern) != TYPE_DICTIONARY:
		return "sequential"

	var fire_mode = str(current_enemy_pattern.get("fire_mode", "sequential"))

	if fire_mode == "":
		return "sequential"

	return fire_mode
# 현재 적 패턴 탄막 존재 여부 확인 함수
func has_current_enemy_pattern_projectiles():
	return get_current_enemy_pattern_projectiles().size() > 0
# 적 턴 탄막 결과 누적값 초기화 함수
func reset_enemy_projectile_turn_results():
	parry_count = 0
	enemy_turn_total_damage = 0
	enemy_turn_applied_status_effects.clear()
# 적 탄막 방어 모드 시작 함수
func start_enemy_projectile_defense_phase():
	start_defense_mode()
	await get_tree().create_timer(0.5).timeout
# 적 탄막 방어 모드 종료 함수
func end_enemy_projectile_defense_phase():
	end_defense_mode()
# 적 탄막 방어 디버그 표시 정리 함수
func clear_enemy_projectile_defense_debug():
	defense_weapon_hitbox_debug.visible = false
	enemy_projectile_hitbox_debug.visible = false
	parry_hitbox_debug.visible = false
	clear_enemy_projectile_debug_boxes()
# 적 탄막 흐름 중단 여부 확인 함수
func should_stop_enemy_projectile_flow():
	if battle_ended:
		return true

	if game_over_started:
		return true

	return false
# 적 탄막 발사 딜레이 가져오기 함수
func get_enemy_projectile_delay(projectile_info):
	if projectile_info == null:
		return 0.0

	if typeof(projectile_info) != TYPE_DICTIONARY:
		return 0.0

	var delay = float(projectile_info.get("delay", 0.0))

	if delay < 0.0:
		delay = 0.0

	return delay
# 적 탄막 발사 딜레이 대기 함수
func wait_enemy_projectile_delay(projectile_info):
	var delay = get_enemy_projectile_delay(projectile_info)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
# 적 탄막 sequential 발사 함수
func fire_enemy_projectiles_sequential(projectile_list):
	for projectile_info in projectile_list:
		if should_stop_enemy_projectile_flow():
			return false

		await wait_enemy_projectile_delay(projectile_info)

		if should_stop_enemy_projectile_flow():
			return false

		await fire_enemy_projectile(projectile_info)

		if should_stop_enemy_projectile_flow():
			return false

	return true
# 패링 반격 발생 여부 확인 함수
func has_parry_counter_result():
	return parry_count > 0
# 패링 반격 총 데미지 계산 함수
func calculate_total_parry_counter_damage():
	var counter_damage = 0

	for i in range(parry_count):
		counter_damage += get_parry_counter_damage_once()

	return counter_damage
# 패링 반격 후 적 처치 확인 함수
func check_enemy_defeated_after_parry_counter():
	if enemy_hp <= 0:
		await handle_enemy_defeated()
		return true

	return false
# 적 턴 패링 반격 처리 함수
func process_enemy_turn_parry_counter():
	if not has_parry_counter_result():
		return true

	var counter_damage = calculate_total_parry_counter_damage()

	apply_parry_counter_damage(counter_damage)

	await get_tree().create_timer(1.0).timeout

	if await check_enemy_defeated_after_parry_counter():
		return false

	return true
# 적의 탄막 패턴 발사 함수
func fire_enemy_projectiles():
	var projectile_list = get_current_enemy_pattern_projectiles()
	var fire_mode = get_current_enemy_pattern_fire_mode()

	reset_enemy_projectile_turn_results()

	if not has_current_enemy_pattern_projectiles():
		await get_tree().create_timer(0.7).timeout
		return

	await start_enemy_projectile_defense_phase()

	var projectile_flow_completed = true

	if fire_mode == "parallel":
		await fire_enemy_projectiles_parallel(projectile_list)
		projectile_flow_completed = not should_stop_enemy_projectile_flow()
	else:
		projectile_flow_completed = await fire_enemy_projectiles_sequential(projectile_list)

	if not projectile_flow_completed:
		clear_enemy_projectile_defense_debug()
		return

	end_enemy_projectile_defense_phase()

	await show_enemy_turn_player_damage_result()

	clear_enemy_projectile_defense_debug()

	var can_continue_after_parry_counter = await process_enemy_turn_parry_counter()

	if not can_continue_after_parry_counter:
		return
# 적 병렬 탄막 1개의 예상 종료 시간 가져오기 함수
func get_enemy_parallel_projectile_wait_time(projectile_info):
	var delay = get_enemy_projectile_delay(projectile_info)
	var projectile_id = get_projectile_id_from_info(projectile_info)
	var life_time = get_projectile_life_time_by_id(projectile_id)

	return delay + life_time + 0.2
# 적 병렬 탄막 전체 예상 대기 시간 가져오기 함수
func get_enemy_parallel_projectiles_max_wait_time(projectile_list):
	var max_wait_time = 0.0

	for projectile_info in projectile_list:
		max_wait_time = max(
			max_wait_time,
			get_enemy_parallel_projectile_wait_time(projectile_info)
		)

	return max_wait_time
# 적 병렬 탄막 task 시작 함수
func start_enemy_projectile_parallel_tasks(projectile_list):
	for projectile_info in projectile_list:
		if should_stop_enemy_projectile_flow():
			return

		fire_enemy_projectile_parallel_task(projectile_info)
# 적 병렬 탄막 전체 종료 예상 시간 대기 함수
func wait_enemy_projectiles_parallel(projectile_list):
	var max_wait_time = get_enemy_parallel_projectiles_max_wait_time(projectile_list)

	if max_wait_time <= 0.0:
		return

	await get_tree().create_timer(max_wait_time).timeout
# 적의 패턴에 동시 탄막 추가 함수
func fire_enemy_projectiles_parallel(projectile_list):
	start_enemy_projectile_parallel_tasks(projectile_list)

	if should_stop_enemy_projectile_flow():
		return

	await wait_enemy_projectiles_parallel(projectile_list)
# 적 동시 탄막 추가 함수
func fire_enemy_projectile_parallel_task(projectile_info):
	if should_stop_enemy_projectile_flow():
		return

	await wait_enemy_projectile_delay(projectile_info)

	if should_stop_enemy_projectile_flow():
		return

	await fire_enemy_projectile(projectile_info)
# 현재 적 본체 패턴 목록 가져오기 함수
func get_current_enemy_body_patterns():
	if enemy_data.is_empty():
		return []

	var patterns = enemy_data.get("patterns", [])

	if typeof(patterns) != TYPE_ARRAY:
		return []

	return patterns
# 살아있는 적 파츠 ID 목록 가져오기 함수
func get_active_enemy_part_ids():
	var active_part_ids = []

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		active_part_ids.append(part_id)

	return active_part_ids
# 적 파츠 패턴 목록 가져오기 함수
func get_enemy_part_patterns_by_id(part_id):
	var part = get_enemy_part_data_by_id(part_id)

	if part.is_empty():
		return []

	var patterns = part.get("patterns", [])

	if typeof(patterns) != TYPE_ARRAY:
		return []

	return patterns
# 적 패턴 후보 데이터 생성 함수
func make_enemy_pattern_candidate(pattern, owner_type, owner_id):
	if pattern == null:
		return {}

	if typeof(pattern) != TYPE_DICTIONARY:
		return {}

	if int(pattern.get("weight", 100)) <= 0:
		return {}

	var copied_pattern = pattern.duplicate(true)
	copied_pattern["owner_type"] = owner_type
	copied_pattern["owner_id"] = owner_id

	return copied_pattern
# 적 본체 패턴 후보 추가 함수
func add_body_pattern_candidates(candidates):
	add_pattern_candidates(
		candidates,
		get_current_enemy_body_patterns(),
		"body",
		""
	)
# 적 파츠 패턴 후보 추가 함수
func add_part_pattern_candidates(candidates):
	for part_id in get_active_enemy_part_ids():
		add_pattern_candidates(
			candidates,
			get_enemy_part_patterns_by_id(part_id),
			"part",
			part_id
		)
# 적 전체 패턴 후보 목록 생성 함수
func make_enemy_pattern_candidates():
	var candidates = []

	add_body_pattern_candidates(candidates)
	add_part_pattern_candidates(candidates)

	return candidates
# 적 패턴 선택 함수
func choose_enemy_pattern():
	var candidates = make_enemy_pattern_candidates()

	if candidates.size() == 0:
		return {}

	return pick_weighted_pattern(candidates)
# 적 패턴 리스트 취합 함수
func add_pattern_candidates(candidates, patterns, owner_type, owner_id):
	if typeof(patterns) != TYPE_ARRAY:
		return

	for pattern in patterns:
		var candidate = make_enemy_pattern_candidate(
			pattern,
			owner_type,
			owner_id
		)

		if candidate.is_empty():
			continue

		candidates.append(candidate)
# 적 패턴 가중치 가져오기 함수
func get_enemy_pattern_weight(pattern):
	if pattern == null:
		return 0

	if typeof(pattern) != TYPE_DICTIONARY:
		return 0

	var weight = int(pattern.get("weight", 100))

	if weight < 0:
		weight = 0

	return weight
# 적 패턴 전체 가중치 계산 함수
func get_total_enemy_pattern_weight(patterns):
	var total_weight = 0

	for pattern in patterns:
		total_weight += get_enemy_pattern_weight(pattern)

	return total_weight
# 적 패턴 기본 랜덤 선택 함수
func pick_random_enemy_pattern(patterns):
	if patterns.size() == 0:
		return {}

	return patterns.pick_random()
# 적 패턴 가중치 롤 값 생성 함수
func roll_enemy_pattern_weight(total_weight):
	if total_weight <= 0:
		return 0

	return randi_range(1, total_weight)
# 적 패턴 가중치 롤 결과 선택 함수
func pick_enemy_pattern_by_weight_roll(patterns, roll):
	var current = 0

	for pattern in patterns:
		current += get_enemy_pattern_weight(pattern)

		if roll <= current:
			return pattern

	return {}
# 적 패턴 가중치 기반 랜덤 선택 함수
func pick_weighted_pattern(patterns):
	if patterns.size() == 0:
		return {}

	var total_weight = get_total_enemy_pattern_weight(patterns)

	if total_weight <= 0:
		return pick_random_enemy_pattern(patterns)

	var roll = roll_enemy_pattern_weight(total_weight)
	var selected_pattern = pick_enemy_pattern_by_weight_roll(patterns, roll)

	if selected_pattern.is_empty():
		return patterns[0]

	return selected_pattern
# 적 피격시 흔들림 함수
func play_enemy_hit_shake():
	if enemy_shake_tween != null and enemy_shake_tween.is_valid():
		enemy_shake_tween.kill()

	set_enemy_visual_offset(Vector2.ZERO)

	enemy_shake_tween = create_tween()
	enemy_shake_tween.tween_method(set_enemy_visual_offset, Vector2.ZERO, Vector2(18, 0), 0.04)
	enemy_shake_tween.tween_method(set_enemy_visual_offset, Vector2(18, 0), Vector2(-18, 0), 0.04)
	enemy_shake_tween.tween_method(set_enemy_visual_offset, Vector2(-18, 0), Vector2(10, 0), 0.04)
	enemy_shake_tween.tween_method(set_enemy_visual_offset, Vector2(10, 0), Vector2.ZERO, 0.04)

	await enemy_shake_tween.finished
	set_enemy_visual_offset(Vector2.ZERO)
	update_hitbox_debug()
# 적 본체 및 파츠 위치 동기화 함수
func set_enemy_visual_offset(offset):
	enemy_sprite.position = enemy_visual_base_position + offset

	for part_id in enemy_part_sprites.keys():
		if not enemy_part_base_positions.has(part_id):
			continue

		var part_sprite = enemy_part_sprites[part_id]

		if part_sprite != null and is_instance_valid(part_sprite):
			part_sprite.position = enemy_part_base_positions[part_id] + offset
# 적 피격시 데미지 팝업 함수 
func show_damage_popup(damage, is_weak):
	var label = Label.new()
	var font = load("res://fonts/x12y12pxMaruMinyaHangul.ttf")
	label.add_theme_font_override("font", font)
	if is_weak:
		label.text = "WEAK!\n" + str(int(damage))
	else:
		label.text = str(int(damage))
	label.z_index = 60
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(260, 120)

	# 폰트 크기 키우기
	label.add_theme_font_size_override("font_size", 48)

	if is_weak:
		label.add_theme_color_override("font_color", Color(1, 0.1, 0.1, 1))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 8)
	else:
		label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 8)

	var hit_position = get_last_hitbox_center_position_for_battle_scene()
	label.position = hit_position - Vector2(130, 60)

	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -90), 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)

	await tween.finished
	label.queue_free()
# 적 피격 데미지 팝업 전용 위치 함수
func get_last_hitbox_center_position_for_battle_scene():
	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / float(base_size[0])
	var scale_y = enemy_rect.size.y / float(base_size[1])

	var rect_data = last_hitbox_data.get("rect", [0, 0, 100, 100])

	var center_global = Vector2(
		enemy_rect.position.x + (rect_data[0] + rect_data[2] / 2.0) * scale_x,
		enemy_rect.position.y + (rect_data[1] + rect_data[3] / 2.0) * scale_y
	)

	var battle_scene_global = get_global_rect().position

	return center_global - battle_scene_global
# 적 히트박스 이펙트 위치 조정 함수
func get_last_hitbox_center_position():
	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / float(base_size[0])
	var scale_y = enemy_rect.size.y / float(base_size[1])

	var rect_data = last_hitbox_data.get("rect", [0, 0, 100, 100])

	var center_global = Vector2(
		enemy_rect.position.x + (rect_data[0] + rect_data[2] / 2.0) * scale_x,
		enemy_rect.position.y + (rect_data[1] + rect_data[3] / 2.0) * scale_y
	)

	var effect_parent_global = hit_effect.get_parent().get_global_rect().position

	return center_global - effect_parent_global - hit_effect.size / 2
# 적 패링 반격 데미지 피격 연출 함수
func set_top_hitbox_as_last_hitbox():
	var hitboxes = get_current_enemy_body_hitboxes()

	if hitboxes.size() == 0:
		return

	var top_hitbox = {}

	for hitbox in hitboxes:
		if not is_valid_body_hitbox_data(hitbox):
			continue

		var rect_data = get_hitbox_rect_data(hitbox)

		if top_hitbox.is_empty():
			top_hitbox = hitbox
			continue

		var top_rect_data = get_hitbox_rect_data(top_hitbox)

		if top_rect_data.size() < 4:
			top_hitbox = hitbox
			continue

		if rect_data[1] < top_rect_data[1]:
			top_hitbox = hitbox

	if top_hitbox.is_empty():
		return

	last_hitbox_data = make_body_hitbox_copy(top_hitbox)
# 적 탄막 피격 범위 가져오는 함수
func get_projectile_hit_rect(projectile, projectile_data):
	var hitbox_data = projectile_data.get("hitbox", {})
	var offset_data = hitbox_data.get("offset", [0, 0])
	var size_data = hitbox_data.get("size", [projectile.size.x, projectile.size.y])

	var offset = Vector2(offset_data[0], offset_data[1])
	var hitbox_size = Vector2(size_data[0], size_data[1])

	var rot = int(round(projectile.rotation_degrees)) % 360
	if rot < 0:
		rot += 360

	# 180도 회전 탄막은 이미지 안의 hitbox 위치도 반전
	if rot == 180:
		offset = Vector2(
			projectile.size.x - offset.x - hitbox_size.x,
			projectile.size.y - offset.y - hitbox_size.y
		)

	var parent_global = projectile.get_parent().get_global_rect().position

	return Rect2(
		parent_global + projectile.position + offset,
		hitbox_size
	)
# 적 본체 히트박스 찾는 함수
func get_body_hitbox_by_id(hitbox_id):
	var hitboxes = get_current_enemy_body_hitboxes()

	for hitbox in hitboxes:
		if not is_valid_body_hitbox_data(hitbox):
			continue

		if str(hitbox.get("id", "")) == str(hitbox_id):
			return make_body_hitbox_copy(hitbox)

	for hitbox in hitboxes:
		if is_valid_body_hitbox_data(hitbox):
			return make_body_hitbox_copy(hitbox)

	return {}
# 적 파츠 히트박스 찾는 함수
func get_part_hitbox_by_id(part_id):
	var hitbox = get_enemy_part_hitbox_by_part_id(part_id)

	if hitbox.is_empty():
		return {}

	var copied_hitbox = hitbox.duplicate(true)
	copied_hitbox["target_type"] = "part"
	copied_hitbox["part_id"] = part_id

	return copied_hitbox
# 적 크기 세팅 함수
func apply_enemy_visual_settings():
	enemy_sprite.size = enemy_sprite_default_size
	enemy_sprite.position = enemy_sprite_default_position

	if enemy_data.has("enemy_size"):
		var size_data = enemy_data["enemy_size"]
		enemy_sprite.size = Vector2(size_data[0], size_data[1])

	if enemy_data.has("enemy_position"):
		var pos_data = enemy_data["enemy_position"]
		enemy_sprite.position = Vector2(pos_data[0], pos_data[1])
	
	enemy_visual_base_position = enemy_sprite.position
# 현재 적의 parts 배열 가져오기 함수
func get_current_enemy_parts_data():
	if enemy_data.is_empty():
		return []

	var parts = enemy_data.get("parts", [])

	if typeof(parts) != TYPE_ARRAY:
		return []

	return parts
# 적 파츠 데이터가 유효한지 확인하는 함수
func is_valid_enemy_part_data(part):
	if part == null:
		return false

	if typeof(part) != TYPE_DICTIONARY:
		return false

	if str(part.get("id", "")) == "":
		return false

	return true
# 적 파츠 ID 가져오기 함수
func get_enemy_part_id_from_data(part):
	if not is_valid_enemy_part_data(part):
		return ""

	return str(part.get("id", ""))
# 적 파츠 이름 가져오기 함수
func get_enemy_part_name_from_data(part, fallback_name = "부위"):
	if part == null:
		return fallback_name

	if typeof(part) != TYPE_DICTIONARY:
		return fallback_name

	return str(part.get("name", fallback_name))
# 적 파츠 최대 체력 가져오기 함수
func get_enemy_part_max_hp_from_data(part):
	if part == null:
		return 1

	if typeof(part) != TYPE_DICTIONARY:
		return 1

	var max_hp = int(part.get("max_hp", 1))

	if max_hp < 1:
		max_hp = 1

	return max_hp
# 적 파츠 이미지 경로 가져오기 함수
func get_enemy_part_image_path_from_data(part):
	if part == null:
		return ""

	if typeof(part) != TYPE_DICTIONARY:
		return ""

	return str(part.get("image", ""))
# 적 파츠 위치 데이터 가져오기 함수
func get_enemy_part_position_data(part):
	if part == null:
		return [0, 0]

	if typeof(part) != TYPE_DICTIONARY:
		return [0, 0]

	var position_data = part.get("position", [0, 0])

	if typeof(position_data) != TYPE_ARRAY:
		return [0, 0]

	if position_data.size() < 2:
		return [0, 0]

	return position_data
# 적 파츠 크기 데이터 가져오기 함수
func get_enemy_part_size_data(part):
	if part == null:
		return []

	if typeof(part) != TYPE_DICTIONARY:
		return []

	var size_data = part.get("size", [])

	if typeof(size_data) != TYPE_ARRAY:
		return []

	if size_data.size() < 2:
		return []

	return size_data
# 적 파츠 z_index 가져오기 함수
func get_enemy_part_z_index_from_data(part):
	if part == null:
		return 20

	if typeof(part) != TYPE_DICTIONARY:
		return 20

	return int(part.get("z_index", 20))
# 적 히트박스 기준 크기 가져오기 함수
func get_enemy_hitbox_base_size():
	var base_size = enemy_data.get(
		"hitbox_base_size",
		[enemy_sprite.size.x, enemy_sprite.size.y]
	)

	if typeof(base_size) != TYPE_ARRAY:
		return Vector2(enemy_sprite.size.x, enemy_sprite.size.y)

	if base_size.size() < 2:
		return Vector2(enemy_sprite.size.x, enemy_sprite.size.y)

	var base_width = float(base_size[0])
	var base_height = float(base_size[1])

	if base_width <= 0:
		base_width = enemy_sprite.size.x

	if base_height <= 0:
		base_height = enemy_sprite.size.y

	if base_width <= 0:
		base_width = 1

	if base_height <= 0:
		base_height = 1

	return Vector2(base_width, base_height)
# 현재 적 이미지 크기 대비 히트박스 스케일 가져오기 함수
func get_enemy_hitbox_scale():
	var base_size = get_enemy_hitbox_base_size()

	return Vector2(
		enemy_sprite.size.x / base_size.x,
		enemy_sprite.size.y / base_size.y
	)
# part_id 기준으로 적 파츠 데이터 가져오기 함수
func get_enemy_part_data_by_id(part_id):
	if part_id == "":
		return {}

	if not enemy_parts.has(part_id):
		return {}

	var part = enemy_parts[part_id]

	if typeof(part) != TYPE_DICTIONARY:
		return {}

	return part
# 파츠 데이터에서 hitbox Dictionary 가져오기 함수
func get_enemy_part_hitbox_from_data(part):
	if part == null:
		return {}

	if typeof(part) != TYPE_DICTIONARY:
		return {}

	var hitbox = part.get("hitbox", {})

	if typeof(hitbox) != TYPE_DICTIONARY:
		return {}

	return hitbox
# part_id 기준으로 적 파츠 hitbox Dictionary 가져오기 함수
func get_enemy_part_hitbox_by_part_id(part_id):
	var part = get_enemy_part_data_by_id(part_id)

	if part.is_empty():
		return {}

	return get_enemy_part_hitbox_from_data(part)
# hitbox 데이터에서 rect 배열 가져오기 함수
func get_hitbox_rect_data(hitbox):
	if hitbox == null:
		return []

	if typeof(hitbox) != TYPE_DICTIONARY:
		return []

	var rect_data = hitbox.get("rect", [])

	if typeof(rect_data) != TYPE_ARRAY:
		return []

	if rect_data.size() < 4:
		return []

	return rect_data
# 현재 적 본체 hitboxes 배열 가져오기 함수
func get_current_enemy_body_hitboxes():
	if enemy_data.is_empty():
		return []

	var hitboxes = enemy_data.get("hitboxes", [])

	if typeof(hitboxes) != TYPE_ARRAY:
		return []

	return hitboxes
# 본체 hitbox 데이터가 유효한지 확인하는 함수
func is_valid_body_hitbox_data(hitbox):
	if hitbox == null:
		return false

	if typeof(hitbox) != TYPE_DICTIONARY:
		return false

	var rect_data = get_hitbox_rect_data(hitbox)

	if rect_data.size() < 4:
		return false

	return true
# 본체 hitbox 복사본 생성 함수
func make_body_hitbox_copy(hitbox):
	if not is_valid_body_hitbox_data(hitbox):
		return {}

	var copied_hitbox = hitbox.duplicate(true)
	copied_hitbox["target_type"] = "body"

	return copied_hitbox
# hitbox rect를 실제 전역 Rect2로 변환하는 함수
func make_scaled_hitbox_rect(enemy_rect, rect_data):
	var hitbox_scale = get_enemy_hitbox_scale()

	return Rect2(
		enemy_rect.position.x + rect_data[0] * hitbox_scale.x,
		enemy_rect.position.y + rect_data[1] * hitbox_scale.y,
		rect_data[2] * hitbox_scale.x,
		rect_data[3] * hitbox_scale.y
	)
# 적 파츠 생성 함수
func setup_enemy_parts():
	clear_enemy_parts()

	enemy_parts.clear()
	enemy_part_hp.clear()
	destroyed_parts.clear()
	enemy_part_base_positions.clear()

	var parts = get_current_enemy_parts_data()

	for part in parts:
		if not is_valid_enemy_part_data(part):
			continue

		var part_id = get_enemy_part_id_from_data(part)

		enemy_parts[part_id] = part
		enemy_part_hp[part_id] = get_enemy_part_max_hp_from_data(part)

		var part_image_path = get_enemy_part_image_path_from_data(part)
		var part_texture = load_texture_by_path(
			part_image_path,
			"enemy part image / " + str(enemy_id) + " / " + str(part_id)
		)

		if part_texture == null:
			continue

		var part_sprite = TextureRect.new()
		part_sprite.name = "EnemyPart_" + part_id
		part_sprite.texture = part_texture
		part_sprite.modulate.a = 1.0
		
		part_sprite.ignore_texture_size = true
		part_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		part_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var base_size = enemy_data.get("hitbox_base_size", [enemy_sprite.size.x, enemy_sprite.size.y])
		var base_width = float(base_size[0])
		var base_height = float(base_size[1])

		var scale_x = enemy_sprite.size.x / base_width
		var scale_y = enemy_sprite.size.y / base_height

		var size_data = get_enemy_part_size_data(part)

		if size_data.size() >= 2:
			part_sprite.size = Vector2(
				size_data[0] * scale_x,
				size_data[1] * scale_y
			)
		else:
			part_sprite.size = enemy_sprite.size

		var position_data = get_enemy_part_position_data(part)

		part_sprite.position = enemy_sprite.position + Vector2(
			position_data[0] * scale_x,
			position_data[1] * scale_y
		)
		
		enemy_part_base_positions[part_id] = part_sprite.position
		part_sprite.z_index = get_enemy_part_z_index_from_data(part)

		enemy_sprite.get_parent().add_child(part_sprite)
		enemy_part_sprites[part_id] = part_sprite
# 적 파츠 제거 함수
func clear_enemy_parts():
	for part_id in enemy_part_sprites.keys():
		var sprite = enemy_part_sprites[part_id]

		if sprite != null and is_instance_valid(sprite):
			sprite.queue_free()

	enemy_part_sprites.clear()
# 적 파츠 피격 함수
func apply_player_attack_part_hit(hitbox):
	last_hitbox_data = hitbox

	var part_id = hitbox.get("part_id", "")

	if part_id == "":
		return

	if destroyed_parts.has(part_id):
		return

	var damage = get_player_attack_damage()
	var hitbox_name = hitbox.get("name", "부위")
	var is_weak = hitbox.get("weak", false)
	var is_critical = is_player_attack_critical()

	if is_critical:
		damage *= get_critical_multiplier()

	if is_weak:
		damage *= 2

	damage = int(damage)

	if is_critical or is_weak:
		hit_red_sound.play()
	else:
		hit_normal_sound.play()

	enemy_part_hp[part_id] -= damage
	update_debug_hp_labels()

	if enemy_part_hp[part_id] < 0:
		enemy_part_hp[part_id] = 0

	hit_effect.position = get_last_hitbox_center_position()
	show_damage_popup(damage, is_weak or is_critical)

	start_enemy_hit_feedback()

	var hit_text = make_player_attack_part_hit_text(
		hitbox_name,
		damage,
		is_critical
	)

	print(part_id, " HP: ", enemy_part_hp[part_id])

	if enemy_part_hp[part_id] <= 0:
		destroy_enemy_part(part_id)
	else:
		set_battle_text(hit_text)
# 적 피격 연출 비동기 시작 함수
func start_enemy_hit_feedback():
	var hit_position = get_last_hitbox_center_position()
	spawn_hit_effect(hit_position)
	play_enemy_hit_shake()
# 적 타격 이펙트 노드 생성 함수
func spawn_hit_effect(effect_position):
	var effect = TextureRect.new()
	effect.size = hit_effect.size
	effect.position = effect_position
	effect.z_index = hit_effect.z_index
	effect.ignore_texture_size = true
	effect.stretch_mode = hit_effect.stretch_mode
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.visible = true

	hit_effect.get_parent().add_child(effect)

	play_spawned_hit_effect(effect)
# 적 생성된 타격 이펙트 프레임 재생 함수
func play_spawned_hit_effect(effect):
	for path in hit_frames:
		if effect == null or not is_instance_valid(effect):
			return

		effect.texture = load(path)
		await get_tree().create_timer(0.05).timeout

	if effect != null and is_instance_valid(effect):
		effect.queue_free()
# 적 파츠 파괴 함수
func destroy_enemy_part(part_id):
	if destroyed_parts.has(part_id):
		return

	destroyed_parts.append(part_id)

	if enemy_part_sprites.has(part_id):
		var sprite = enemy_part_sprites[part_id]

		if sprite != null and is_instance_valid(sprite):
			sprite.visible = false

	set_battle_text(get_enemy_part_destroy_text(part_id))
	
	update_hitbox_debug()
	update_debug_hp_labels()
# 적 체력 0 이하 처리 함수
func handle_enemy_defeated():
	var next_enemy_id = get_next_phase_enemy_id()

	if next_enemy_id != "":
		var phase_changed = await change_enemy_phase()

		if phase_changed:
			return

	await win_battle()
# 페이즈 전환 텍스트 생성 함수
func get_phase_transition_text():
	return str(enemy_data.get(
		"phase_transition_text",
		"어둠속에서 무언가가 다시 나타나기 시작한다..."
	))
# 페이즈 전환 텍스트 표시 함수
func show_phase_transition_text():
	set_battle_text_with_accept(get_phase_transition_text())
	await wait_for_accept_input()
# 현재 적 등장 텍스트 표시 함수
func show_current_enemy_encounter_text():
	set_battle_text_with_accept(get_current_enemy_encounter_text())
	await wait_for_accept_input()
# 적 페이즈 전환 함수
func change_enemy_phase():
	var next_enemy_id = get_next_phase_enemy_id()

	if next_enemy_id == "":
		return false

	var next_enemy_data = get_enemy_data_by_id(next_enemy_id, true)

	if next_enemy_data.is_empty():
		return false

	set_action_buttons_disabled(true)

	# 1. 페이즈1 쪽 전환 텍스트 표시
	await show_phase_transition_text()

	# 2. 암전
	await fade_to_black(2)

	# 3. 페이즈1 파츠 제거
	clear_enemy_parts()

	# 4. 페이즈2 적 데이터로 교체
	enemy_id = next_enemy_id
	enemy_data = next_enemy_data
	enemy_max_hp = enemy_data.get("max_hp", 10)
	enemy_hp = enemy_max_hp

	# 5. 페이즈2 BGM 갱신
	await update_battle_bgm()

	# 6. 페이즈2 이미지/파츠/히트박스 갱신
	setup_battle_enemy_visual()
	setup_battle_enemy_background()
	setup_battle_enemy_ui()

	# 7. 밝아짐
	await fade_from_black(0.6)

	# 8. 페이즈2 등장 효과음
	play_enemy_encounter_sound()

	# 9. 페이즈2 encounter_text 표시 후 Space 대기
	await show_current_enemy_encounter_text()

	# 10. Space를 누른 뒤에야 페이즈2 확정 패턴 경고문 표시
	await start_enemy_turn_with_forced_pattern()
	
	return true
# 적 패턴 경고 텍스트 생성 함수
func get_enemy_pattern_warning_text(pattern):
	if pattern == null:
		return get_current_enemy_name() + "이(가) 공격하려고 한다..."

	if typeof(pattern) != TYPE_DICTIONARY:
		return get_current_enemy_name() + "이(가) 공격하려고 한다..."

	return str(pattern.get(
		"warning_text",
		get_current_enemy_name() + "이(가) 공격하려고 한다..."
	))
# 적 패턴 데이터 유효성 확인 함수
func is_valid_enemy_pattern_data(pattern):
	if pattern == null:
		return false

	if typeof(pattern) != TYPE_DICTIONARY:
		return false

	return true
# 현재 적 패턴 초기화 함수
func clear_current_enemy_pattern():
	current_enemy_pattern = {}
# 현재 적 패턴 설정 함수
func set_current_enemy_pattern(pattern):
	if not is_valid_enemy_pattern_data(pattern):
		clear_current_enemy_pattern()
		return

	current_enemy_pattern = pattern.duplicate(true)
# 현재 적 패턴 존재 여부 확인 함수
func has_current_enemy_pattern():
	if current_enemy_pattern == null:
		return false

	if typeof(current_enemy_pattern) != TYPE_DICTIONARY:
		return false

	return not current_enemy_pattern.is_empty()
# 현재 적 패턴 경고 텍스트 표시 함수
func show_current_enemy_pattern_warning_text():
	show_enemy_pattern_warning_text(current_enemy_pattern)
# 일반 적 턴 패턴 적용 함수
func apply_normal_enemy_turn_pattern():
	var pattern = choose_enemy_pattern()

	set_current_enemy_pattern(pattern)
	show_current_enemy_pattern_warning_text()
# 적 패턴 경고 텍스트 표시 함수
func show_enemy_pattern_warning_text(pattern):
	set_battle_text_with_accept(get_enemy_pattern_warning_text(pattern))
# 페이즈 시작 강제 패턴 ID 가져오기 함수
func get_phase_start_pattern_id():
	if enemy_data.is_empty():
		return ""

	return str(enemy_data.get("phase_start_pattern_id", ""))
# 페이즈 시작 강제 패턴 존재 여부 확인 함수
func has_phase_start_pattern():
	return get_phase_start_pattern_id() != ""
# 적 패턴 ID 일치 여부 확인 함수
func is_enemy_pattern_id_match(pattern, pattern_id):
	if pattern == null:
		return false

	if typeof(pattern) != TYPE_DICTIONARY:
		return false

	return str(pattern.get("id", "")) == str(pattern_id)
# 적 페이즈 전환 확정 패턴 사용 함수
func start_enemy_turn_with_forced_pattern():
	if not has_phase_start_pattern():
		start_enemy_turn()
		return

	var pattern = get_phase_start_pattern_data()

	if pattern.is_empty():
		start_enemy_turn()
		return

	prepare_phase_start_forced_enemy_turn()
	apply_phase_start_forced_pattern(pattern)
# 페이즈 시작 강제 패턴 데이터 가져오기 함수
func get_phase_start_pattern_data():
	var pattern_id = get_phase_start_pattern_id()

	if pattern_id == "":
		return {}

	return get_enemy_pattern_by_id(pattern_id)
# 페이즈 시작 강제 패턴 소유자 정보 적용 함수
func apply_phase_start_pattern_owner_data(pattern):
	if pattern.is_empty():
		return {}

	var copied_pattern = pattern.duplicate(true)
	copied_pattern["owner_type"] = "body"
	copied_pattern["owner_id"] = ""

	return copied_pattern
# 페이즈 시작 강제 패턴 적 턴 상태 준비 함수
func prepare_phase_start_forced_enemy_turn():
	is_player_turn = false
	start_enemy_attack_wait()
	set_action_buttons_disabled(true)
# 페이즈 시작 강제 패턴 적용 함수
func apply_phase_start_forced_pattern(pattern):
	var forced_pattern = apply_phase_start_pattern_owner_data(pattern)

	set_current_enemy_pattern(forced_pattern)
	show_current_enemy_pattern_warning_text()
# 적 페이즈 전환 확정 패턴 탐색 함수
func get_enemy_pattern_by_id(pattern_id):
	if pattern_id == "":
		return {}

	for pattern in get_current_enemy_body_patterns():
		if is_enemy_pattern_id_match(pattern, pattern_id):
			return pattern.duplicate(true)

	return {}
# 적 처치 플래그 계산 함수
func calculate_enemy_defeat_flags():
	var result_flags = []

	for flag_id in enemy_data.get("defeat_flags", []):
		if flag_id == "":
			continue

		result_flags.append(flag_id)

	return result_flags

# ============================================================
# 플레이어 관련 함수 모음
# ============================================================

# 플레이어 현재 체력 갱신 함수
func update_player_hp_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
# 플레이어 무기 데미지 계산 함수
func get_player_attack_damage():
	var weapon_data = get_current_weapon_data()

	var min_damage = int(weapon_data.get("attack_min", weapon_data.get("attack", 1)))
	var max_damage = int(weapon_data.get("attack_max", weapon_data.get("attack", min_damage)))

	if min_damage < 1:
		min_damage = 1

	if max_damage < 1:
		max_damage = 1

	if min_damage > max_damage:
		max_damage = min_damage

	return randi_range(min_damage, max_damage)
# 플레이어 공격 치명타 판정 함수
func is_player_attack_critical():
	var weapon_data = get_current_weapon_data()
	var critical_chance = weapon_data.get("critical_chance", 0.0)

	return randf() < critical_chance
# 플레이어 공격 치명타 배율 함수
func get_critical_multiplier():
	var weapon_data = get_current_weapon_data()

	return weapon_data.get("critical_multiplier", 2.0)
# 플레이어 방어 무기 판정 함수
func get_weapon_defense_hit_rect():
	var weapon_rect = weapon_sprite.get_global_rect()
	var weapon_data = get_current_weapon_data()

	var hitbox_data = weapon_data.get("defense_hitbox", {})
	var offset_data = hitbox_data.get("offset", [0, 0])
	var size_data = hitbox_data.get("size", [weapon_sprite.size.x, weapon_sprite.size.y])

	var offset = Vector2(offset_data[0], offset_data[1])
	var hitbox_size = Vector2(size_data[0], size_data[1])

	return Rect2(
		weapon_rect.position + offset,
		hitbox_size
	)
# 플레이어 방어 무기 패링 범위 확인 함수
func get_parry_hit_rect():
	var weapon_rect = get_weapon_defense_hit_rect()
	var weapon_data = get_current_weapon_data()

	var parry_window = weapon_data.get("parry_window", 0.1)

	# 패링 판정 처리 부분 2
	var parry_height = weapon_rect.size.y * parry_window
	if parry_height < 6:
		parry_height = 6

	var center_y = weapon_rect.position.y + weapon_rect.size.y / 2.0

	return Rect2(
		Vector2(weapon_rect.position.x, center_y - parry_height / 2.0),
		Vector2(weapon_rect.size.x, parry_height)
	)
# 플레이어 탄막 위치 기준 패링 이펙트 위치 함수
func get_parry_effect_position_for_projectile(projectile, projectile_data):
	var projectile_rect = get_projectile_hit_rect(projectile, projectile_data)
	var parry_rect = get_parry_hit_rect()

	var overlap_left = max(projectile_rect.position.x, parry_rect.position.x)
	var overlap_right = min(
		projectile_rect.position.x + projectile_rect.size.x,
		parry_rect.position.x + parry_rect.size.x
	)

	var overlap_top = max(projectile_rect.position.y, parry_rect.position.y)
	var overlap_bottom = min(
		projectile_rect.position.y + projectile_rect.size.y,
		parry_rect.position.y + parry_rect.size.y
	)

	var effect_global_position = Vector2(
		(overlap_left + overlap_right) / 2.0,
		(overlap_top + overlap_bottom) / 2.0
	)

	var weapon_data = get_current_weapon_data()
	var extra_offset_data = weapon_data.get("parry_effect_extra_offset", [0, 0])
	var extra_offset = Vector2(extra_offset_data[0], extra_offset_data[1])

	var effect_parent_global = parry_effect.get_parent().get_global_rect().position

	return effect_global_position + extra_offset - effect_parent_global - parry_effect.size / 2
# 플레이어 방어 무기 탄막 충돌 함수
func check_defense_hit(projectile, projectile_data):

	var projectile_rect = get_projectile_hit_rect(projectile, projectile_data)
	var weapon_rect = get_weapon_defense_hit_rect()

	var projectile_bottom = projectile_rect.position.y + projectile_rect.size.y
	var projectile_top = projectile_rect.position.y

	var weapon_block_line_y = weapon_rect.position.y + weapon_rect.size.y

	var projectile_left = projectile_rect.position.x
	var projectile_right = projectile_rect.position.x + projectile_rect.size.x

	var weapon_left = weapon_rect.position.x
	var weapon_right = weapon_rect.position.x + weapon_rect.size.x

	var x_overlaps = projectile_right >= weapon_left and projectile_left <= weapon_right

	var crosses_block_line = (
		projectile_bottom >= weapon_block_line_y
		and projectile_top <= weapon_block_line_y
	)

	return x_overlaps and crosses_block_line
# 플레이어 방어 무기 패링 판정 함수
func check_parry_hit(projectile, projectile_data):
	var projectile_rect = get_projectile_hit_rect(projectile, projectile_data)
	var parry_rect = get_parry_hit_rect()

	return projectile_rect.intersects(parry_rect)
# 플레이어 공격 패링 반격 데미지 함수
func get_parry_counter_damage_once():
	var damage = get_player_attack_damage()

	if is_player_attack_critical():
		damage *= get_critical_multiplier()

	# 패링 반격은 100% 약점 처리
	damage *= 2

	return int(damage)
# 플레이어 패링 반격 적용 함수
func apply_parry_counter_damage(counter_damage):
	var owner_type = current_enemy_pattern.get("owner_type", "body")
	var owner_id = current_enemy_pattern.get("owner_id", "")

	if owner_type == "part" and owner_id != "":
		apply_parry_counter_to_part(owner_id, counter_damage)
	else:
		apply_parry_counter_to_body(counter_damage)
# 플레이어 본체 패링 반격 함수
func apply_parry_counter_to_body(counter_damage):
	enemy_hp -= counter_damage

	if enemy_hp < 0:
		enemy_hp = 0

	update_enemy_hp_ui()

	var counter_hitbox_id = current_enemy_pattern.get("counter_hitbox_id", "head")
	last_hitbox_data = get_body_hitbox_by_id(counter_hitbox_id)

	if last_hitbox_data.is_empty():
		set_top_hitbox_as_last_hitbox()

	hit_red_sound.play()
	show_damage_popup(counter_damage, true)
	start_enemy_hit_feedback()

	set_battle_text(make_parry_counter_body_text(counter_damage))
# 플레이어 파츠 패링 반격 함수
func apply_parry_counter_to_part(part_id, counter_damage):
	if destroyed_parts.has(part_id):
		apply_parry_counter_to_body(counter_damage)
		return

	if not enemy_part_hp.has(part_id):
		apply_parry_counter_to_body(counter_damage)
		return

	enemy_part_hp[part_id] -= counter_damage
	update_debug_hp_labels()

	if enemy_part_hp[part_id] < 0:
		enemy_part_hp[part_id] = 0

	last_hitbox_data = get_part_hitbox_by_id(part_id)

	hit_red_sound.play()
	show_damage_popup(counter_damage, true)
	start_enemy_hit_feedback()

	var part_name = get_enemy_part_name_by_id(part_id)

	set_battle_text(
		make_parry_counter_part_text(
			part_name,
			counter_damage
		)
	)

	if enemy_part_hp[part_id] <= 0:
		destroy_enemy_part(part_id)
# 플레이어 패링 이펙트 노드 생성 함수
func spawn_parry_effect(effect_position):
	var effect = TextureRect.new()
	effect.size = parry_effect.size
	effect.position = effect_position
	effect.z_index = parry_effect.z_index
	effect.ignore_texture_size = true
	effect.stretch_mode = parry_effect.stretch_mode
	effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect.visible = true

	parry_effect.get_parent().add_child(effect)

	play_spawned_parry_effect(effect)
# 생성된 패링 이펙트 프레임 재생 함수
func play_spawned_parry_effect(effect):
	for path in parry_frames:
		if effect == null or not is_instance_valid(effect):
			return

		effect.texture = load(path)
		await get_tree().create_timer(0.04).timeout

	if effect != null and is_instance_valid(effect):
		effect.queue_free()
# 플레이어 이펙트 재생 함수
func play_effect_frames(effect_node, frame_paths, frame_time = 0.05):
	effect_node.visible = true

	for path in frame_paths:
		effect_node.texture = load(path)
		await get_tree().create_timer(frame_time).timeout

	effect_node.visible = false
	effect_node.texture = null
# 플레이어 현재 무기 ID 가져오기 함수
func get_current_weapon_id():
	if equipped_weapon == null:
		return "fist"

	if typeof(equipped_weapon) == TYPE_DICTIONARY:
		var weapon_id = str(equipped_weapon.get("id", "fist"))

		if weapon_id == "":
			return "fist"

		return weapon_id

	if typeof(equipped_weapon) == TYPE_STRING:
		var weapon_id = str(equipped_weapon)

		if weapon_id == "":
			return "fist"

		return weapon_id

	return "fist"
# 플레이어 무기 현재 데이터 가져오는 함수
func get_current_weapon_data():
	var weapon_id = get_current_weapon_id()
	var base_weapon_data = get_item_data_by_id(weapon_id, false)

	if base_weapon_data.is_empty() and weapon_id != "fist":
		base_weapon_data = get_item_data_by_id("fist", false)

	if base_weapon_data.is_empty():
		return {}

	var weapon_data = base_weapon_data.duplicate(true)

	# 원본 items[weapon_id]를 직접 수정하지 않고, 복사본에만 적용 능력치를 덮어씌우는 구조
	if player_effective_stats.size() > 0:
		weapon_data["attack_min"] = int(player_effective_stats.get("attack_min", weapon_data.get("attack_min", weapon_data.get("attack", 1))))
		weapon_data["attack_max"] = int(player_effective_stats.get("attack_max", weapon_data.get("attack_max", weapon_data.get("attack", weapon_data["attack_min"]))))
		weapon_data["critical_chance"] = float(player_effective_stats.get("critical_chance", weapon_data.get("critical_chance", 0.01)))
		weapon_data["critical_multiplier"] = float(player_effective_stats.get("critical_multiplier", weapon_data.get("critical_multiplier", 2.0)))
		weapon_data["parry_window"] = float(player_effective_stats.get("parry_window", weapon_data.get("parry_window", 0.1)))
		weapon_data["attack_swing_speed"] = float(player_effective_stats.get("attack_swing_speed", weapon_data.get("attack_swing_speed", 3.0)))
		weapon_data["defense_move_speed"] = float(player_effective_stats.get("defense_move_speed", weapon_data.get("defense_move_speed", 500.0)))
		# player_effective_stats의 piercing은 main.gd에서 기본 무기 piercing 값을 포함해서 계산되어야 함
		weapon_data["piercing"] = bool(player_effective_stats.get("piercing", weapon_data.get("piercing", false)))

	return weapon_data
# 플레이어 현재 공격 투사체 ID 가져오기 함수
func get_current_attack_projectile_id():
	var weapon_data = get_current_weapon_data()

	if weapon_data.is_empty():
		return "slash_basic"

	var projectile_id = str(weapon_data.get("attack_projectile", "slash_basic"))

	if projectile_id == "":
		return "slash_basic"

	return projectile_id
# 플레이어 무기 현재 탄환 데이터 함수
func get_current_projectile_data():
	var projectile_id = get_current_attack_projectile_id()

	return get_projectile_data_by_id(projectile_id, false)
# 플레이어 무기 현재 ui에 추가하는 함수
func update_weapon_sprite_texture():
	var weapon_data = get_current_weapon_data()

	if weapon_data.has("image"):
		weapon_sprite.texture = load(weapon_data["image"])
	else:
		weapon_sprite.texture = null
# 플레이어 무기별 size 적용 함수
func apply_weapon_visual_settings():
	var weapon_data = get_current_weapon_data()

	if weapon_data.has("battle_sprite_size"):
		var size_data = weapon_data["battle_sprite_size"]
		weapon_sprite.size = Vector2(size_data[0], size_data[1])

	weapon_sprite.pivot_offset = weapon_sprite.size / 2
# 플레이어 무기별 기본 위치값 추가 함수
func update_weapon_base_position():
	var guide_center_global = attack_guide.get_global_rect().get_center()
	var weapon_parent_global_pos = weapon_sprite.get_parent().get_global_rect().position

	weapon_base_position = guide_center_global - weapon_parent_global_pos - weapon_sprite.pivot_offset
	weapon_sprite.position = weapon_base_position
# 공격 모드 상태 준비 함수
func prepare_attack_mode_state():
	is_attack_mode = true
	weapon_swing_enabled = true
	weapon_move_time = 0.0
	weapon_angle_offset = 0.0
# 공격 모드 무기 비주얼 준비 함수
func setup_attack_mode_weapon_visual():
	update_weapon_sprite_texture()
	apply_weapon_visual_settings()
	update_weapon_base_position()

	var weapon_data = get_current_weapon_data()

	weapon_sprite.rotation_degrees = weapon_data.get("attack_base_rotation", 0)
	weapon_sprite.position = weapon_base_position
	weapon_sprite.visible = true
	attack_guide.visible = true
# 공격 모드 UI 시작 처리 함수
func start_attack_mode_ui():
	hide_player_action_menu()
	clear_battle_text()
# 공격 모드 종료 함수
func end_attack_mode():
	is_attack_mode = false
	reset_weapon_action_visual()
# 플레이어 공격 모드 시작 함수
func start_attack_mode():
	start_attack_mode_ui()
	prepare_attack_mode_state()
	setup_attack_mode_weapon_visual()
# 방어 모드 상태 준비 함수
func prepare_defense_mode_state():
	is_defense_mode = true
# 방어 모드 무기 비주얼 준비 함수
func setup_defense_mode_weapon_visual():
	var weapon_data = get_current_weapon_data()

	update_weapon_sprite_texture()
	apply_weapon_visual_settings()

	weapon_sprite.rotation_degrees = weapon_data.get("defense_base_rotation", 0)
	weapon_sprite.visible = true

	# 무기 표시/크기/회전 설정 끝난 뒤에 호출
	move_defense_weapon_to_area_center()
# 방어 모드 무기 비주얼 종료 함수
func clear_defense_mode_weapon_visual():
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
# 플레이어 방어 모드 시작 함수
func start_defense_mode():
	setup_defense_mode_weapon_visual()
	prepare_defense_mode_state()
# 방어 무기 히트박스를 방어 영역 중앙으로 이동시키는 함수
func move_defense_weapon_to_area_center():
	var area = get_defense_area_global_rect()
	var hit_rect = get_weapon_defense_hit_rect()

	var correction = area.get_center() - hit_rect.get_center()
	weapon_sprite.global_position += correction

	clamp_defense_weapon_to_area()
# 플레이어 방어 모드 종료 함수
func end_defense_mode():
	is_defense_mode = false
	clear_defense_mode_weapon_visual()
# 방어 무기 이동 함수
func update_defense_weapon_movement(delta):
	var move_vector = Vector2.ZERO

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
		move_vector.x -= 1

	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"):
		move_vector.x += 1

	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("ui_up"):
		move_vector.y -= 1

	if Input.is_action_pressed("move_back") or Input.is_action_pressed("ui_down"):
		move_vector.y += 1

	if move_vector != Vector2.ZERO:
		move_vector = move_vector.normalized()

	var weapon_data = get_current_weapon_data()
	var move_speed = get_defense_move_speed_with_status(weapon_data)

	weapon_sprite.global_position += move_vector * move_speed * delta

	clamp_defense_weapon_to_area()
# 치명타 접두 텍스트 생성 함수
func make_critical_prefix_text(is_critical):
	if is_critical:
		return "치명타!\n"

	return ""
# 플레이어 본체 공격 결과 텍스트 생성 함수
func make_player_attack_body_hit_text(hitbox_name, damage, is_weak, is_critical):
	var text = make_critical_prefix_text(is_critical)

	if is_weak:
		text += str(hitbox_name) + " 약점을 공격했다!\n"
	else:
		text += str(hitbox_name) + "에 맞았다.\n"

	text += str(int(damage)) + " 의 피해를 주었다."

	return text
# 플레이어 파츠 공격 결과 텍스트 생성 함수
func make_player_attack_part_hit_text(hitbox_name, damage, is_critical):
	var text = make_critical_prefix_text(is_critical)

	text += str(hitbox_name) + "에 맞았다.\n"
	text += str(int(damage)) + " 의 피해를 주었다."

	return text
# 플레이어 공격 빗나감 텍스트 생성 함수
func make_player_attack_miss_text():
	return "공격이 빗나갔다."
# part_id 기준 파츠 이름 가져오기 함수
func get_enemy_part_name_by_id(part_id):
	var part = get_enemy_part_data_by_id(part_id)

	if part.is_empty():
		return "부위"

	return get_enemy_part_name_from_data(part, "부위")
# part_id 기준 파츠 파괴 텍스트 가져오기 함수
func get_enemy_part_destroy_text(part_id):
	var part = get_enemy_part_data_by_id(part_id)

	if part.is_empty():
		return "부위가 파괴되었다."

	return str(part.get("destroy_text", "부위가 파괴되었다."))
# 본체 패링 반격 텍스트 생성 함수
func make_parry_counter_body_text(counter_damage):
	return "패링 반격!\n" + str(int(counter_damage)) + " 의 피해를 주었다."
# 파츠 패링 반격 텍스트 생성 함수
func make_parry_counter_part_text(part_name, counter_damage):
	return "패링 반격!\n" + str(part_name) + "에 " + str(int(counter_damage)) + " 의 피해를 주었다."
# 플레이어 공격 적용 함수
func apply_player_attack_hit(hitbox):
	if hitbox.get("target_type", "body") == "part":
		apply_player_attack_part_hit(hitbox)
		return

	last_hitbox_data = hitbox

	var damage = get_player_attack_damage()
	var hitbox_name = last_hitbox_data.get("name", "부위")
	var is_weak = last_hitbox_data.get("weak", false)
	var is_critical = is_player_attack_critical()

	if is_critical:
		damage *= get_critical_multiplier()

	if is_weak:
		damage *= 2

	damage = int(damage)

	if is_critical or is_weak:
		hit_red_sound.play()
	else:
		hit_normal_sound.play()

	enemy_hp -= damage

	if enemy_hp < 0:
		enemy_hp = 0

	update_enemy_hp_ui()

	hit_effect.position = get_last_hitbox_center_position()
	show_damage_popup(damage, is_weak or is_critical)

	start_enemy_hit_feedback()

	set_battle_text(
		make_player_attack_body_hit_text(
			hitbox_name,
			damage,
			is_weak,
			is_critical
		)
	)
# 플레이어 공격 실행 함수
func execute_player_attack():
	if not is_attack_mode:
		return

	if not can_start_battle_input_process():
		return

	lock_battle_input_process()

	end_attack_mode()

	player_attack_hit = false
	attack_hit_results.clear()
	pierced_hitbox_ids.clear()

	await fire_player_attack_projectile()

	if not player_attack_hit:
		set_battle_text(make_player_attack_miss_text())

	await get_tree().create_timer(1.0).timeout

	if enemy_hp <= 0:
		await handle_enemy_defeated()
		unlock_battle_input_process()
		return

	start_enemy_turn()
	unlock_battle_input_process()
# 발사체 사운드 재생 함수
func play_projectile_sound(sound_id):
	if sound_id == "":
		return

	if sound_id == "slash":
		if slash_sound != null:
			slash_sound.stop()
			slash_sound.play()

	elif sound_id == "impact":
		if impact_sound != null:
			impact_sound.stop()
			impact_sound.play()

	elif sound_id == "shot":
		if shot_sound != null:
			shot_sound.stop()
			shot_sound.play()
# 현재 플레이어 공격 투사체 크기 가져오기 함수
func get_current_attack_projectile_size():
	var projectile_size = current_projectile_data.get("size", [200, 200])

	if typeof(projectile_size) != TYPE_ARRAY:
		return Vector2(200, 200)

	if projectile_size.size() < 2:
		return Vector2(200, 200)

	return Vector2(projectile_size[0], projectile_size[1])
# 현재 플레이어 공격 투사체 속도 가져오기 함수
func get_current_attack_projectile_speed():
	return float(current_projectile_data.get("speed", 1200))
# 현재 플레이어 공격 투사체 지속 시간 가져오기 함수
func get_current_attack_projectile_life_time():
	return float(current_projectile_data.get("life_time", 0.9))
# 현재 플레이어 공격 투사체 프레임 시간 가져오기 함수
func get_current_attack_projectile_frame_time():
	return float(current_projectile_data.get("frame_time", 0.04))
# 투사체 프레임 경로 기본값 보정 함수
func get_safe_projectile_frames_path(frames_path):
	var safe_path = str(frames_path)

	if safe_path == "":
		return "res://imgs/effects/slash/slash_"

	return safe_path
# 투사체 프레임 개수 기본값 보정 함수
func get_safe_projectile_frame_count(frame_count):
	var safe_count = int(frame_count)

	if safe_count < 1:
		return 1

	return safe_count
# 현재 플레이어 공격 투사체 프레임 목록 가져오기 함수
func get_current_attack_projectile_frames():
	var frame_count = get_safe_projectile_frame_count(
		current_projectile_data.get("frame_count", 9)
	)

	var frames_path = get_safe_projectile_frames_path(
		current_projectile_data.get("frames_path", "res://imgs/effects/slash/slash_")
	)

	return make_effect_frames(frames_path, frame_count)
# 프레임 목록에서 안전하게 프레임 경로 가져오기 함수
func get_frame_path_by_index(frame_paths, frame_index):
	if typeof(frame_paths) != TYPE_ARRAY:
		return ""

	if frame_paths.size() == 0:
		return ""

	if frame_index < 0:
		frame_index = 0

	if frame_index >= frame_paths.size():
		frame_index = frame_index % frame_paths.size()

	return str(frame_paths[frame_index])
# 플레이어 공격 투사체 프레임 텍스처 가져오기 함수
func get_player_attack_projectile_frame_texture(frame_paths, frame_index):
	var frame_path = get_frame_path_by_index(frame_paths, frame_index)

	if frame_path == "":
		return null

	return load_texture_by_path(
		frame_path,
		"player attack projectile frame / " + str(get_current_attack_projectile_id())
	)
# 투사체 데이터에서 프레임 개수 가져오기 함수
func get_projectile_frame_count_from_data(projectile_data):
	if projectile_data == null:
		return 9

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return 9

	return get_safe_projectile_frame_count(
		projectile_data.get("frame_count", 9)
	)
# 투사체 데이터에서 프레임 경로 가져오기 함수
func get_projectile_frames_path_from_data(projectile_data):
	if projectile_data == null:
		return "res://imgs/effects/slash/slash_"

	if typeof(projectile_data) != TYPE_DICTIONARY:
		return "res://imgs/effects/slash/slash_"

	return get_safe_projectile_frames_path(
		projectile_data.get("frames_path", "res://imgs/effects/slash/slash_")
	)
# 투사체 데이터에서 프레임 목록 가져오기 함수
func get_projectile_frames_from_data(projectile_data):
	var frame_count = get_projectile_frame_count_from_data(projectile_data)
	var frames_path = get_projectile_frames_path_from_data(projectile_data)

	return make_effect_frames(frames_path, frame_count)
# 적 탄막 프레임 텍스처 가져오기 함수
func get_enemy_projectile_frame_texture(frame_paths, frame_index, projectile_id = ""):
	var frame_path = get_frame_path_by_index(frame_paths, frame_index)

	if frame_path == "":
		return null

	return load_texture_by_path(
		frame_path,
		"enemy projectile frame / " + str(projectile_id)
	)
# 현재 플레이어 공격 투사체 사운드 재생 함수
func play_current_attack_projectile_sound():
	var sound_id = str(current_projectile_data.get("sound", ""))

	play_projectile_sound(sound_id)
# 플레이어 공격 투사체 비주얼 초기화 함수
func setup_player_attack_projectile_visual():
	var projectile_size = get_current_attack_projectile_size()

	slash_effect.size = projectile_size
	slash_effect.pivot_offset = slash_effect.size / 2
	slash_effect.position = weapon_sprite.position
	slash_effect.rotation_degrees = weapon_angle_offset
	slash_effect.visible = true
# 플레이어 공격 투사체 종료 정리 함수
func clear_player_attack_projectile_visual():
	slash_effect.visible = false
	slash_effect.texture = null
	player_attack_hitbox_debug.visible = false
	active_attack_projectile = null
	current_projectile_data = {}
# 플레이어 공격 투사체 발사 함수
func fire_player_attack_projectile():
	current_projectile_data = get_current_projectile_data()

	if current_projectile_data.is_empty():
		push_error("투사체 데이터가 없음: " + get_current_attack_projectile_id())
		return

	active_attack_projectile = slash_effect
	active_attack_direction = Vector2.UP.rotated(deg_to_rad(weapon_angle_offset))

	var projectile_speed = get_current_attack_projectile_speed()
	var projectile_life_time = get_current_attack_projectile_life_time()
	var projectile_frame_time = get_current_attack_projectile_frame_time()
	var projectile_frames = get_current_attack_projectile_frames()

	setup_player_attack_projectile_visual()
	play_current_attack_projectile_sound()

	var elapsed_time = 0.0
	var frame_index = 0

	while elapsed_time < projectile_life_time:
		var frame_texture = get_player_attack_projectile_frame_texture(
			projectile_frames,
			frame_index
		)

		if frame_texture != null:
			slash_effect.texture = frame_texture

		slash_effect.position += active_attack_direction * projectile_speed * projectile_frame_time

		if debug_mode:
			var attack_rect = get_player_attack_hit_rect()
			player_attack_hitbox_debug.visible = true
			player_attack_hitbox_debug.position = attack_rect.position
			player_attack_hitbox_debug.size = attack_rect.size

		var weapon_data = get_current_weapon_data()
		var piercing = bool(weapon_data.get("piercing", false))

		var collided_hitboxes = get_attack_collided_hitboxes()
		var should_stop_projectile = apply_player_attack_to_collided_hitboxes(
			collided_hitboxes,
			piercing
		)

		if should_stop_projectile:
			break

		await get_tree().create_timer(projectile_frame_time).timeout

		elapsed_time += projectile_frame_time
		frame_index += 1

		if projectile_frames.size() > 0 and frame_index >= projectile_frames.size():
			frame_index = 0
			
	clear_player_attack_projectile_visual()
# 플레이어 공격 히트박스 함수 
func get_player_attack_hit_rect():
	var rect = slash_effect.get_global_rect()

	var hitbox_data = current_projectile_data.get("hitbox", {})
	var hitbox_offset = hitbox_data.get("offset", [55, 20])
	var hitbox_size_data = hitbox_data.get("size", [90, 90])

	var hitbox_position = rect.position + Vector2(
		hitbox_offset[0],
		hitbox_offset[1]
	)

	var hitbox_size = Vector2(
		hitbox_size_data[0],
		hitbox_size_data[1]
	)

	return Rect2(hitbox_position, hitbox_size)
# 플레이어 공격에 맞은 히트박스 고유 ID 생성 함수
func get_attack_hitbox_unique_id(hitbox):
	if hitbox == null:
		return ""

	if typeof(hitbox) != TYPE_DICTIONARY:
		return ""

	var target_type = str(hitbox.get("target_type", "body"))
	var hitbox_id = str(hitbox.get("id", ""))

	if target_type == "part":
		var part_id = str(hitbox.get("part_id", ""))

		if part_id != "":
			return "part:" + part_id + ":" + hitbox_id

	return "body:" + hitbox_id
# 관통 공격에서 이미 맞은 히트박스인지 확인하는 함수
func has_pierced_hitbox(hitbox):
	var unique_id = get_attack_hitbox_unique_id(hitbox)

	if unique_id == "":
		return false

	return pierced_hitbox_ids.has(unique_id)
# 관통 공격에서 맞은 히트박스 기록 함수
func mark_pierced_hitbox(hitbox):
	var unique_id = get_attack_hitbox_unique_id(hitbox)

	if unique_id == "":
		return

	pierced_hitbox_ids.append(unique_id)
# 플레이어 공격에 충돌한 히트박스 목록 처리 함수
func apply_player_attack_to_collided_hitboxes(collided_hitboxes, piercing):
	if typeof(collided_hitboxes) != TYPE_ARRAY:
		return false

	if collided_hitboxes.size() == 0:
		return false

	player_attack_hit = true
	player_attack_hitbox_debug.visible = false

	for hitbox in collided_hitboxes:
		if hitbox == null:
			continue

		if typeof(hitbox) != TYPE_DICTIONARY:
			continue

		if piercing:
			if has_pierced_hitbox(hitbox):
				continue

			mark_pierced_hitbox(hitbox)
			apply_player_attack_hit(hitbox)
		else:
			apply_player_attack_hit(hitbox)
			return true

	return not piercing	
# 플레이어 공격 투사체 히트 판정 체크 함수
func get_attack_collided_hitboxes():
	var results = []
	var attack_rect = get_player_attack_hit_rect()

	results.append_array(get_attack_collided_body_hitboxes(attack_rect))
	results.append_array(get_attack_collided_part_hitboxes(attack_rect))

	return results
# 몸체 히트 박스 함수
func get_attack_collided_body_hitboxes(attack_rect):
	var results = []
	var body_hitboxes = get_current_enemy_body_hitboxes()
	var enemy_rect = enemy_sprite.get_global_rect()

	for hitbox in body_hitboxes:
		if not is_valid_body_hitbox_data(hitbox):
			continue

		var rect_data = get_hitbox_rect_data(hitbox)
		var hitbox_rect = make_scaled_hitbox_rect(enemy_rect, rect_data)

		if attack_rect.intersects(hitbox_rect):
			var copied_hitbox = make_body_hitbox_copy(hitbox)
			results.append(copied_hitbox)

	return results
# 파츠 히트 박스 함수
func get_attack_collided_part_hitboxes(attack_rect):
	var results = []

	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var base_width = float(base_size[0])
	var base_height = float(base_size[1])

	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / base_width
	var scale_y = enemy_rect.size.y / base_height

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		var part = enemy_parts[part_id]

		if not part.has("hitbox"):
			continue

		var hitbox = part["hitbox"]
		var rect_data = hitbox["rect"]

		var hitbox_rect = Rect2(
			enemy_rect.position.x + rect_data[0] * scale_x,
			enemy_rect.position.y + rect_data[1] * scale_y,
			rect_data[2] * scale_x,
			rect_data[3] * scale_y
		)

		if attack_rect.intersects(hitbox_rect):
			var copied_hitbox = hitbox.duplicate(true)
			copied_hitbox["target_type"] = "part"
			copied_hitbox["part_id"] = part_id
			results.append(copied_hitbox)

	return results
# 플레이어 전투 뉴뉴 조작 사운드 함수
func play_click_sound():
	if click_sound != null:
		click_sound.play()
# 행동 버튼 인덱스 보정 함수
func clamp_action_button_index():
	if action_buttons.size() == 0:
		action_button_index = 0
		return

	if action_button_index < 0:
		action_button_index = 0

	if action_button_index >= action_buttons.size():
		action_button_index = action_buttons.size() - 1
# 행동 버튼 포커스 표시 가능 여부 확인 함수
func can_show_action_button_focus():
	if battle_ended:
		return false

	if not is_player_alive():
		return false

	if not is_player_turn:
		return false

	if is_priority_battle_mode_active():
		return false

	return true
# 특정 행동 버튼이 현재 포커스 대상인지 확인하는 함수
func is_action_button_focus_target(index):
	if not can_show_action_button_focus():
		return false

	if index != action_button_index:
		return false

	if index < 0 or index >= action_buttons.size():
		return false

	var button = action_buttons[index]

	if button == null:
		return false

	if button.disabled:
		return false

	return true
# 행동 버튼 기본 텍스트 가져오기 함수
func get_action_button_base_text(index):
	if index >= 0 and index < action_button_base_texts.size():
		return action_button_base_texts[index]

	if index >= 0 and index < action_buttons.size():
		var button = action_buttons[index]

		if button != null:
			return button.text.replace("▶ ", "").strip_edges()

	return ""
# 플레이어 전투 메뉴 조작 포커스 함수
func update_action_button_focus():
	if action_buttons.size() == 0:
		return

	clamp_action_button_index()

	for i in range(action_buttons.size()):
		var button = action_buttons[i]

		if button == null:
			continue

		var base_text = get_action_button_base_text(i)

		if is_action_button_focus_target(i):
			button.text = "▶ " + base_text
		else:
			button.text = "  " + base_text
# 플레이어 전투 메뉴 조작 함수
func move_action_button_focus(direction):
	if action_buttons.size() == 0:
		return

	clamp_action_button_index()

	for i in range(action_buttons.size()):
		action_button_index += direction

		if action_button_index < 0:
			action_button_index = action_buttons.size() - 1

		if action_button_index >= action_buttons.size():
			action_button_index = 0

		if not action_buttons[action_button_index].disabled:
			break

	play_click_sound()
	update_action_button_focus()
# 전투 우선 처리 모드 활성 여부 확인 함수
func is_priority_battle_mode_active():
	if is_observing:
		return true

	if is_item_selecting:
		return true

	if waiting_enemy_attack:
		return true

	if is_defense_mode:
		return true

	if is_attack_mode:
		return true

	return false
# 플레이어가 전투에서 살아있는지 확인하는 함수
func is_player_alive():
	return player_hp > 0
# 플레이어 기본 행동 가능 여부 확인 함수
func can_player_choose_action():
	if battle_ended:
		return false

	if not is_player_alive():
		return false

	if not is_player_turn:
		return false

	if is_processing_battle_input:
		return false

	if is_priority_battle_mode_active():
		return false

	return true
# 플레이어 행동 버튼 입력 가능 여부 확인 함수
func can_update_action_button_input():
	if not can_player_choose_action():
		return false

	if action_buttons.size() == 0:
		return false

	return true
# 현재 선택된 행동 버튼 가져오기 함수
func get_selected_action_button():
	if action_buttons.size() == 0:
		return null

	if action_button_index < 0:
		action_button_index = 0

	if action_button_index >= action_buttons.size():
		action_button_index = action_buttons.size() - 1

	return action_buttons[action_button_index]
# 플레이어 행동 버튼 방향 입력 처리 함수
func update_action_button_direction_input():
	if Input.is_action_just_pressed("move_back"):
		move_action_button_focus(1)

	if Input.is_action_just_pressed("move_forward"):
		move_action_button_focus(-1)
# 플레이어 행동 버튼 확정 입력 처리 함수
func update_action_button_confirm_input():
	if not Input.is_action_just_pressed("ui_accept"):
		return

	var selected_button = get_selected_action_button()

	if selected_button == null:
		return

	if selected_button.disabled:
		return

	selected_button.emit_signal("pressed")
# 플레이어 전투 메뉴 키보드 입력 함수
func update_action_button_keyboard_input():
	if not can_update_action_button_input():
		return

	update_action_button_direction_input()
	update_action_button_confirm_input()
# 플레이어 상태이상 부여 함수
func apply_player_status_effects(effect_ids):
	var added_new_status = false
	var added_effects = []

	for effect_id in effect_ids:
		if effect_id == "":
			continue

		if not player_status_effects.has(effect_id):
			added_new_status = true
			added_effects.append(effect_id)

		player_status_effects[effect_id] = true

	if added_new_status:
		play_status_effect_flash()

	update_player_portrait_by_status()
	update_player_action_text_by_status()

	return added_effects
# 탄막 상태이상 목록 가져오기 함수
func get_projectile_status_effects(projectile_info, projectile_data):
	if projectile_info.has("status_effects"):
		return projectile_info.get("status_effects", [])

	if projectile_info.has("status_effect"):
		return [projectile_info.get("status_effect", "")]

	if projectile_data.has("status_effects"):
		return projectile_data.get("status_effects", [])

	if projectile_data.has("status_effect"):
		return [projectile_data.get("status_effect", "")]

	return []
# 적 턴 상태이상 결과 누적 함수
func add_enemy_turn_status_effects(effect_ids):
	for effect_id in effect_ids:
		if effect_id == "":
			continue

		if enemy_turn_applied_status_effects.has(effect_id):
			continue

		enemy_turn_applied_status_effects.append(effect_id)
# 적 턴 플레이어 피해 텍스트 생성 함수
func make_enemy_turn_damage_text():
	if enemy_turn_total_damage <= 0:
		return ""

	return str(int(enemy_turn_total_damage)) + " 의 피해를 입었다."
# 적 턴 상태이상 적용 텍스트 생성 함수
func make_enemy_turn_status_effect_text():
	if enemy_turn_applied_status_effects.size() == 0:
		return ""

	return get_status_applied_text(enemy_turn_applied_status_effects)
# 적 턴 플레이어 피해/상태이상 결과 텍스트 생성 함수
func make_enemy_turn_player_result_text():
	var lines = []

	var damage_text = make_enemy_turn_damage_text()

	if damage_text != "":
		lines.append(damage_text)

	var status_text = make_enemy_turn_status_effect_text()

	if status_text != "":
		lines.append(status_text)

	return "\n".join(lines)
# 적 턴 플레이어 피해 결과 표시 함수
func show_enemy_turn_player_damage_result():
	if game_over_started:
		return

	var result_text = make_enemy_turn_player_result_text()

	if result_text == "":
		return

	await show_battle_text_for_seconds(result_text, 1.0)
# 적 탄막 기본 피해량 가져오기 함수
func get_enemy_projectile_base_damage(projectile_info):
	if projectile_info != null and typeof(projectile_info) == TYPE_DICTIONARY:
		return int(projectile_info.get("damage", current_enemy_pattern.get("damage", 1)))

	return int(current_enemy_pattern.get("damage", 1))
# 플레이어 탄막 피해 적용 함수
func apply_enemy_projectile_damage_to_player(damage):
	var before_hp = player_hp

	player_hp -= damage
	
	# 주물 심장 모형 처리 로직
	if bool(player_effective_stats.get("cannot_die", false)) and before_hp >= 1 and player_hp < 1:
		player_hp = 1

	if player_hp < 0:
		player_hp = 0

	enemy_turn_total_damage += damage

	return before_hp
# 플레이어 탄막 피격 사운드 재생 함수
func play_player_projectile_hit_sound(danger_type):
	if danger_type == "parry_only":
		if hit_red_sound != null:
			hit_red_sound.play()
	else:
		if hit_normal_sound != null:
			hit_normal_sound.play()
# 플레이어 탄막 상태이상 적용 함수
func apply_enemy_projectile_status_effects_to_player(projectile_info, projectile_data):
	var status_effects = get_projectile_status_effects(projectile_info, projectile_data)
	var added_effects = apply_player_status_effects(status_effects)

	add_enemy_turn_status_effects(added_effects)
# 플레이어 탄막 피격 후 사망 처리 함수
func check_player_death_after_projectile_hit():
	if player_hp <= 0:
		start_game_over_flow()
# 플레이어 탄막 피격 처리 함수
func apply_projectile_hit_to_player(projectile_info, projectile_data, danger_type):
	var base_damage = get_enemy_projectile_base_damage(projectile_info)
	var damage = get_player_received_damage(base_damage)

	apply_enemy_projectile_damage_to_player(damage)

	play_player_hit_flash()
	apply_enemy_projectile_status_effects_to_player(projectile_info, projectile_data)
	play_player_projectile_hit_sound(danger_type)

	update_player_hp_ui()
	check_player_death_after_projectile_hit()
# 플레이어 받는 데미지 계산 함수
func get_player_received_damage(base_damage):
	var damage = float(base_damage)
	# 플레이어 받는 피해 증가 및 감소 옵션 적용을 위한 기반
	damage *= float(player_effective_stats.get("damage_taken_multiplier", 1.0))

	if has_player_status_effect("despair"):
		damage *= 1.5

	return int(ceil(damage))
# 플레이어 상태이상 보유 확인 함수
func has_player_status_effect(effect_id):
	return player_status_effects.has(effect_id)
# 플레이어 상태이상 적용 방어 이동속도 함수
func get_defense_move_speed_with_status(weapon_data):
	var move_speed = float(weapon_data.get("defense_move_speed", 500))

	if has_player_status_effect("lethargy"):
		move_speed *= 0.7

	return move_speed
# 플레이어 상태이상 적용 공격 스윙 속도 함수
func get_attack_swing_speed_with_status(weapon_data):
	var swing_speed = float(weapon_data.get("attack_swing_speed", 3.0))

	if has_player_status_effect("fear"):
		swing_speed *= 1.5

	return swing_speed
# 플레이어 상태이상에 따른 초상화 갱신 함수
func update_player_portrait_by_status():
	var portrait_key = "normal"
 
	if has_player_status_effect("despair"):
		portrait_key = "despair"
	elif has_player_status_effect("fear"):
		portrait_key = "fear"
	elif has_player_status_effect("lethargy"):
		portrait_key = "lethargy"

	if player_portrait_paths.has(portrait_key):
		player_portrait.texture = load(player_portrait_paths[portrait_key])
	elif player_portrait_paths.has("normal"):
		player_portrait.texture = load(player_portrait_paths["normal"])
# 플레이어 상태이상 이름 가져오기 함수
func get_status_effect_name(effect_id):
	match effect_id:
		"fear":
			return "공포"
		"lethargy":
			return "무기력"
		"despair":
			return "절망"
		_:
			return effect_id
# 상태이상 적용 텍스트 생성 함수
func get_status_applied_text(effect_ids):
	var lines = []
	var checked_effects = []

	for effect_id in effect_ids:
		if effect_id == "":
			continue

		if checked_effects.has(effect_id):
			continue

		checked_effects.append(effect_id)

		match effect_id:
			"fear":
				lines.append("공포에 질렸다.")
			"lethargy":
				lines.append("무기력에 빠졌다.")
			"despair":
				lines.append("절망에 짓눌렸다.")
			_:
				lines.append(get_status_effect_name(effect_id) + " 상태가 되었다.")

	return "\n".join(lines)
# 플레이어 행동 선택 텍스트 상태이상 반영 함수
func update_player_action_text_by_status():
	if not is_player_turn:
		return

	if is_attack_mode:
		return

	if is_defense_mode:
		return

	if is_observing:
		return

	if is_item_selecting:
		return

	if waiting_enemy_attack:
		return

	show_player_turn_start_text()
# 플레이어 턴 시작 텍스트 함수
func get_player_turn_start_text():
	if has_player_status_effect("despair"):
		return "당신은 절망에 짓눌려 있다."
	if has_player_status_effect("fear"):
		return "당신은 공포에 질려있다."
	if has_player_status_effect("lethargy"):
		return "당신은 무기력에 빠져있다."

	return "행동을 선택하세요."
# 플레이어 상태이상 전체 해제 함수
func clear_player_status_effects():
	player_status_effects.clear()
	update_player_portrait_by_status()
	update_player_action_text_by_status()
	status_popup_panel.visible = false
# 플레이어 상태이상 해제 함수
func clear_selected_player_status_effects(effect_ids):
	# 전체 해제시 json에서 "clear_all_status_effects": true 처리하면됨
	for effect_id in effect_ids:
		if player_status_effects.has(effect_id):
			player_status_effects.erase(effect_id)

	update_player_portrait_by_status()
	update_player_action_text_by_status()

	if player_status_effects.size() == 0:
		status_popup_panel.visible = false
# 플레이어 초상화 입력 함수
func _on_player_portrait_gui_input(event):  
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			show_status_popup()
# 플레이어 상태이상 설명 팝업 표시 함수
func show_status_popup():
	status_popup_text.text = get_player_status_description_text()
	status_popup_panel.visible = true
# 상태 설명 텍스트 생성 함수
func make_normal_status_description_text():
	return "정상 상태 : \n차분한 상태이다."
# 플레이어가 보유한 상태이상 설명 목록 생성 함수
func make_player_status_description_lines():
	var lines = []

	if has_player_status_effect("fear"):
		lines.append(make_status_effect_description_text("fear"))

	if has_player_status_effect("lethargy"):
		lines.append(make_status_effect_description_text("lethargy"))

	if has_player_status_effect("despair"):
		lines.append(make_status_effect_description_text("despair"))

	return lines
# 상태이상 설명 텍스트 생성 함수
func make_status_effect_description_text(effect_id):
	match effect_id:
		"fear":
			return "공포 상태 : \n공격 무기의\n스윙 스피드가 50% 빨라진다.\n"

		"lethargy":
			return "무기력 상태 : \n방어 무기의\n이동속도가 30% 느려진다.\n"

		"despair":
			return "절망 상태 : \n받는 데미지가\n50% 증가한다.\n"

		_:
			return get_status_effect_name(effect_id) + " 상태 : \n알 수 없는 상태이상이다.\n"
# 플레이어 상태이상 설명 텍스트 함수
func get_player_status_description_text():
	var lines = make_player_status_description_lines()

	if lines.size() == 0:
		return make_normal_status_description_text()

	return "\n".join(lines)
# 플레이어 피격시 왼쪽 패널 빨간 플래시 함수
func play_player_hit_flash():
	if player_hit_flash_tween != null and player_hit_flash_tween.is_valid():
		player_hit_flash_tween.kill()

	player_hit_flash.color = Color(1, 0, 0, 0.45)

	player_hit_flash_tween = create_tween()
	player_hit_flash_tween.tween_property(
		player_hit_flash,
		"color:a",
		0.0,
		0.45
	)
# 플레이어 상태이상 발생시 왼쪽 패널 검은 플래시 함수
func play_status_effect_flash():
	if status_effect_flash_tween != null and status_effect_flash_tween.is_valid():
		status_effect_flash_tween.kill()

	status_effect_flash.color = Color(0, 0, 0, 0.6)

	status_effect_flash_tween = create_tween()
	status_effect_flash_tween.tween_property(
		status_effect_flash,
		"color:a",
		0.0,
		0.65
	)

	if status_effect_sound != null:
		status_effect_sound.stop()
		status_effect_sound.play()
# 플레이어 방어 모드 좌우 워프 입력 확인 함수
func check_defense_side_warp_input():
	if not is_defense_mode:
		return

	if not side_warp_enabled:
		return

	if weapon_sprite == null or not weapon_sprite.visible:
		return

	var current_time = Time.get_ticks_msec() / 1000.0

	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		if current_time - last_left_press_time <= side_warp_double_tap_time:
			try_defense_side_warp("left")

		last_left_press_time = current_time

	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		if current_time - last_right_press_time <= side_warp_double_tap_time:
			try_defense_side_warp("right")

		last_right_press_time = current_time
# 플레이어 방어 무기 좌우 워프 함수
func try_defense_side_warp(direction):
	var area = get_defense_area_global_rect()
	var hit_rect = get_weapon_defense_hit_rect()

	var area_left = area.position.x
	var area_right = area.position.x + area.size.x

	var hit_left = hit_rect.position.x
	var hit_right = hit_rect.position.x + hit_rect.size.x

	if direction == "left":
		if hit_left > area_left + side_warp_margin:
			return

		warp_defense_weapon_to_side("right")

	elif direction == "right":
		if hit_right < area_right - side_warp_margin:
			return

		warp_defense_weapon_to_side("left")
# 플레이어 방어 무기를 특정 좌우 끝으로 이동시키는 함수
func warp_defense_weapon_to_side(target_side):
	var area = get_defense_area_global_rect()
	var hit_rect = get_weapon_defense_hit_rect()

	var area_left = area.position.x
	var area_right = area.position.x + area.size.x

	var hit_left = hit_rect.position.x
	var hit_right = hit_rect.position.x + hit_rect.size.x

	var correction = Vector2.ZERO

	if target_side == "right":
		correction.x = area_right - hit_right
	else:
		correction.x = area_left - hit_left

	weapon_sprite.global_position += correction
	clamp_defense_weapon_to_area()

	play_ui_warp_sound()
# 플레이어 UI 워프 효과음 재생 함수
func play_ui_warp_sound():
	if ui_warp_sound != null:
		ui_warp_sound.stop()
		ui_warp_sound.play()
# 플레이어 방어 가능 영역 전역 좌표 반환 함수
func get_defense_area_global_rect():
	var area = center_panel.get_global_rect()

	# 빨간 테두리와 너무 딱 붙는 게 싫으면 약간 안쪽으로 줄임
	var padding = 8.0
	area.position += Vector2(padding, padding)
	area.size -= Vector2(padding * 2.0, padding * 2.0)

	return area
# 플레이어 방어 무기 히트박스를 방어 영역 안에 고정하는 함수
func clamp_defense_weapon_to_area():
	if weapon_sprite == null:
		return

	var area = get_defense_area_global_rect()
	var hit_rect = get_weapon_defense_hit_rect()

	var correction = Vector2.ZERO

	var area_left = area.position.x
	var area_right = area.position.x + area.size.x
	var area_top = area.position.y
	var area_bottom = area.position.y + area.size.y

	var hit_left = hit_rect.position.x
	var hit_right = hit_rect.position.x + hit_rect.size.x
	var hit_top = hit_rect.position.y
	var hit_bottom = hit_rect.position.y + hit_rect.size.y

	if hit_left < area_left:
		correction.x = area_left - hit_left
	elif hit_right > area_right:
		correction.x = area_right - hit_right

	if hit_top < area_top:
		correction.y = area_top - hit_top
	elif hit_bottom > area_bottom:
		correction.y = area_bottom - hit_bottom

	if correction != Vector2.ZERO:
		weapon_sprite.global_position += correction
# 플레이어 현재 체력을 전투 최대 체력 안으로 보정하는 함수
func clamp_battle_player_hp():
	if player_hp > player_max_hp:
		player_hp = player_max_hp

	if player_hp < 0:
		player_hp = 0
# 플레이어 턴 시작 성물/주물 효과 적용 함수
func apply_player_turn_start_relic_effects():
	var player_damage = int(player_effective_stats.get("turn_start_player_damage", 0))
	var player_heal = int(player_effective_stats.get("turn_start_player_heal", 0))
	var enemy_damage = int(player_effective_stats.get("turn_start_enemy_damage", 0))

	var effect_happened = false
	var player_was_damaged = false

	# 1. 먼저 플레이어 피해 효과 적용
	if player_damage > 0:
		var before_hp = player_hp

		player_hp -= player_damage

		if bool(player_effective_stats.get("cannot_die", false)) and before_hp >= 1 and player_hp < 1:
			# cannot_die 여도 연출은 추가하기
			play_player_hit_flash()
			play_overlap_sound_from_player(hit_normal_sound)
			player_hp = 1

		if player_hp < 0:
			player_hp = 0

		if before_hp > player_hp:
			play_player_hit_flash()
			play_overlap_sound_from_player(hit_normal_sound)

			player_was_damaged = true
			effect_happened = true

		update_player_hp_ui()

		if player_hp <= 0:
			prepare_game_over_state()
			await get_tree().create_timer(0.5).timeout
			await game_over()
			return false
		
		if player_was_damaged and enemy_damage > 0:
			await get_tree().create_timer(0.10).timeout

	# 2. 적 본체/파츠 피해 효과 적용
	if enemy_damage > 0:
		var damaged_enemy = false

		if enemy_hp > 0:
			enemy_hp -= enemy_damage

			if enemy_hp < 0:
				enemy_hp = 0

			damaged_enemy = true

		for part_id in enemy_part_hp.keys():
			if destroyed_parts.has(part_id):
				continue

			enemy_part_hp[part_id] -= enemy_damage

			if enemy_part_hp[part_id] < 0:
				enemy_part_hp[part_id] = 0

			damaged_enemy = true

			if enemy_part_hp[part_id] <= 0:
				destroy_enemy_part(part_id)

		if damaged_enemy:
			play_overlap_sound_from_player(hit_normal_sound)

			set_top_hitbox_as_last_hitbox()
			show_damage_popup(enemy_damage, false)
			start_enemy_hit_feedback()

			effect_happened = true

		update_enemy_hp_ui()
		update_debug_hp_labels()

		if enemy_hp <= 0:
			await get_tree().create_timer(0.5).timeout
			await handle_enemy_defeated()
			return false

	# 3. 마지막에 플레이어 회복 효과 적용
	if player_heal > 0:
		var before_heal_hp = player_hp

		player_hp += player_heal

		if player_hp > player_max_hp:
			player_hp = player_max_hp

		if player_hp > before_heal_hp:
			if healing_sound != null:
				healing_sound.play()

			effect_happened = true

		update_player_hp_ui()

	if effect_happened:
		await get_tree().create_timer(0.45).timeout

	return true
