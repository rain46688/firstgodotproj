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
const BATTLE_ITEM_VISIBLE_COUNT = 4

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
# parry_input_buffer_time
# parry_height

# 상수 변수 모음

# 프레임 마다 실행 함수
func _process(delta):
		# 개발자 모드
	if Input.is_action_just_pressed("debug_toggle"):
		debug_mode = !debug_mode
		update_hitbox_debug()
	# 관찰중
	if is_observing:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
			move_observe_target(-1)

		if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
			move_observe_target(1)

		if Input.is_action_just_pressed("ui_accept"):
			is_observing = false
			observe_targets.clear()
			start_enemy_turn()

		return			
	# 아이템 선택중
	if is_item_selecting:
		if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("battle_item_down"):
			move_battle_item_selection(1)

		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("battle_item_up"):
			move_battle_item_selection(-1)

		if Input.is_action_just_pressed("ui_accept"):
			use_selected_battle_item()

		if Input.is_action_just_pressed("esc"):
			is_item_selecting = false
			battle_text.text = "행동을 선택하세요."
			set_action_buttons_disabled(false)

		return
	# 적 공격 대기중
	if waiting_enemy_attack:
		if Input.is_action_just_pressed("ui_accept"):
			waiting_enemy_attack = false
			await execute_enemy_attack()
		return
	# 방어 모드
	if is_defense_mode:
		update_defense_weapon_movement(delta)
		check_defense_side_warp_input()
		
		# 패링 판정 처리 부분 1
		if Input.is_action_just_pressed("ui_accept"):
			parry_input_buffer_time = 0.035

		if parry_input_buffer_time > 0:
			parry_input_buffer_time -= delta	
	# 공격 모드
	if is_attack_mode:
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
		return
	# 플레이어 행동 버튼 키보드 조작
	if is_player_turn and not battle_ended:
		update_action_button_keyboard_input()
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
# 전투 화면 설정 함수
func setup_battle(data):
	battle_ended = false
	is_player_turn = false
	is_attack_mode = false
	is_defense_mode = false
	is_observing = false
	is_item_selecting = false
	waiting_enemy_attack = false

	enemy_id = data.get("enemy_id", "")
	enemy_data = data.get("enemy_data", {})
	enemy_max_hp = enemy_data.get("max_hp", 10)
	enemy_hp = enemy_max_hp
	player_hp = data.get("player_hp", 100)
	player_max_hp = data.get("player_max_hp", 100)
	items = data.get("items", {})
	equipped_weapon = data.get("equipped_weapon", null)
	inventory = data.get("inventory", [])
	projectiles = data.get("projectiles", {})
	enemies = data.get("enemies", {})
	# 메인에서 넘겨받은 플래그
	flags = data.get("flags", {})
	encounter_first_turn = data.get("first_turn", "")
	
	# 상태이상 초기화
	player_status_effects.clear()
	
	update_weapon_sprite_texture()
	weapon_sprite.visible = false
	
	# 플레이어 및 적 hp ui
	update_player_hp_ui()
	update_enemy_hp_ui()
	
	enemy_sprite.modulate.a = 1.0

	if enemy_data.has("image"):
		enemy_sprite.texture = load(enemy_data["image"])
		apply_enemy_visual_settings()
		setup_enemy_parts()
		
	if enemy_data.has("battle_background"):
		enemy_background.texture = load(enemy_data["battle_background"])
		enemy_background.visible = true

		var bg_alpha = enemy_data.get("battle_background_alpha", 0.3)
		enemy_background.modulate = Color(1, 1, 1, bg_alpha)
	else:
		enemy_background.visible = false
		
	# 플레이어 초상화 
	player_portrait_paths = data.get("player_portraits", {})

	if data.has("player_portrait"):
		player_portrait_paths["normal"] = data["player_portrait"]

	update_player_portrait_by_status()
		
	# 히트 박스 확인용
	update_hitbox_debug()

	is_player_turn = false
	set_action_buttons_disabled(true)
	
	await update_battle_bgm()
	play_enemy_encounter_sound()

	battle_text.text = enemy_data.get(
		"encounter_text",
		enemy_data.get("name", "무언가") + "가 나타났다..."
	) + "\n\n[Space]"

	await wait_for_accept_input()
	
	# 첫 턴 결정
	if encounter_first_turn == "enemy":
		start_enemy_turn()
	else:
		start_player_turn()

# === 버튼 클릭 함수 모음 ===
# 공격 버튼 클릭 함수
func _on_attack_button_pressed():
	if not is_player_turn:
		return
	
	play_click_sound()
	start_attack_mode()
# 관찰 버튼 클릭 함수
func _on_observe_button_pressed():
	if not is_player_turn:
		return

	play_click_sound()
	set_action_buttons_disabled(true)

	is_observing = true
	observe_targets = make_observe_targets()
	observe_index = 0

	if observe_targets.size() == 0:
		battle_text.text = "관찰할 수 있는 대상이 없다.\n\n[Space]"
		return

	show_current_observe_target()
# 아이템 버튼 클릭 함수
func _on_item_button_pressed():
	if not is_player_turn:
		return

	play_click_sound()
	open_battle_item_list()
# 턴종료 버튼 클릭 함수
func _on_end_turn_button_pressed():
	if not is_player_turn:
		return

	play_click_sound()
	battle_text.text = "턴을 종료했다."

	set_action_buttons_disabled(true)

	await get_tree().create_timer(0.7).timeout

	start_enemy_turn()
# 도망 버튼 클릭 함수
func _on_run_button_pressed():
	if not is_player_turn:
		return

	play_click_sound()
	set_action_buttons_disabled(true)

	if enemy_data.get("can_escape", true):
		battle_text.text = "도망쳤다."

		await get_tree().create_timer(1.0).timeout

		emit_signal("battle_finished", {
			"result": "escaped",
			"player_hp": player_hp,
			"inventory": inventory
		})
	else:
		battle_text.text = "도망칠 수 없다..."

		await get_tree().create_timer(1.0).timeout

		start_enemy_turn()

# === 기타 함수 모음 ===
# 플레이어 턴 시작 함수
func start_player_turn():
	print("start_player_turn")

	is_player_turn = true
	action_button_index = 0
	is_attack_mode = false
	
	weapon_swing_enabled = false
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
	attack_guide.visible = false
	battle_text.text = get_player_turn_start_text()

	set_action_buttons_disabled(false)
# 적 턴 시작 함수
func start_enemy_turn():
	print("start_enemy_turn")
	is_player_turn = false
	
	weapon_swing_enabled = false
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
	attack_guide.visible = false
	waiting_enemy_attack = true

	set_action_buttons_disabled(true)
	current_enemy_pattern = choose_enemy_pattern()

	var warning_text = current_enemy_pattern.get(
		"warning_text",
		enemy_data.get("name", "적") + "이(가) 공격하려고 한다..."
	)

	battle_text.text = warning_text + "\n\n[Space]"
# 버튼 활성/비활성 함수
func set_action_buttons_disabled(disabled):
	attack_button.disabled = disabled
	observe_button.disabled = disabled
	item_button.disabled = disabled
	end_turn_button.disabled = disabled
	run_button.disabled = disabled
	update_action_button_focus()
# 승리 함수 추가
func win_battle():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = enemy_data.get("name", "적") + "을 쓰러뜨렸다."

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
	
	battle_text.text = "전투에서 승리했다.\n\n[Space]"
	await wait_for_accept_input()

	if reward_messages.size() > 0:
		await show_battle_result_messages(reward_messages)

	# 전투 종료 후 메인에 전달할 변수들
	emit_signal("battle_finished", {
		"result": "win",
		"enemy_id": enemy_id,
		"player_hp": player_hp,
		"inventory": inventory,
		"rewards": rewards,
		"reward_flags": reward_flags
	})
# 게임 오버 함수
func game_over():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = "YOU DIED"

	await get_tree().create_timer(2.0).timeout
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
# 관찰 하는 현재 대상 표시 함수
func show_current_observe_target():
	if observe_targets.size() == 0:
		return

	var target = observe_targets[observe_index]
	var target_type = target.get("target_type", "body")
	var target_id = target.get("id", "")
	var target_name = target.get("name", "대상")

	var text = ""

	if target_type == "part":
		var part = enemy_parts.get(target_id, {})

		text += "[ " + target_name + " ]\n"
		text += part.get("observe_text", "특별한 점은 보이지 않는다.") + "\n"

		var weakness_text = part.get("weakness_text", "")
		if weakness_text != "":
			text += weakness_text + "\n"

		var hp = enemy_part_hp.get(target_id, 0)
		var max_hp = part.get("max_hp", hp)
		text += "\n남은 체력 : " + str(int(hp)) + " / " + str(int(max_hp))

	else:
		text += "[ " + target_name + " ]\n"
		text += enemy_data.get("observe_text", "특별한 점은 보이지 않는다.") + "\n"

		var weakness_text = enemy_data.get("weakness_text", "")
		if weakness_text != "":
			text += weakness_text + "\n"

		text += "\n남은 체력 : " + str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))

	if observe_targets.size() > 1:
		text += "\n\n[A/D] 관찰 대상 변경"

	text += "\n[Space] 관찰을 끝낸다."

	battle_text.text = text
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
# 아이템 목록 열기 함수
func open_battle_item_list():
	battle_consumables.clear()
	item_index = 0
	battle_item_scroll_start = 0

	for inventory_item in inventory:
		var item_id = inventory_item["id"]

		if not items.has(item_id):
			continue

		var item_data = items[item_id]

		if item_data.get("type", "") == "consumable":
			battle_consumables.append(inventory_item)

	if battle_consumables.size() == 0:
		set_action_buttons_disabled(true)
		battle_text.text = "사용할 수 있는 아이템이 없다."

		await get_tree().create_timer(1.0).timeout

		set_action_buttons_disabled(false)
		battle_text.text = get_player_turn_start_text()
		return

	set_action_buttons_disabled(true)
	is_item_selecting = true
	update_battle_item_list()
# 아이템 목록 표시 함수
func update_battle_item_list():
	update_battle_item_scroll()

	var text = "사용할 아이템을 선택하세요.\n\n"

	var start_index = battle_item_scroll_start
	var end_index = min(
		battle_consumables.size(),
		battle_item_scroll_start + BATTLE_ITEM_VISIBLE_COUNT
	)

	if start_index > 0:
		text += "  ↑\n"

	for i in range(start_index, end_index):
		var inventory_item = battle_consumables[i]
		var item_id = inventory_item.get("id", "")

		if not items.has(item_id):
			continue

		var item_name = items[item_id].get("name", item_id)
		var count_text = ""

		if inventory_item.has("count"):
			count_text = " x" + str(int(inventory_item["count"]))

		if i == item_index:
			text += "▶ " + item_name + count_text + "\n"
		else:
			text += "  " + item_name + count_text + "\n"

	if end_index < battle_consumables.size():
		text += "  ↓\n"

	text += "\n[↑↓/WS] 선택 / [Space] 사용 / [ESC] 취소"
	battle_text.text = text
# 아이템 사용 함수
func use_selected_battle_item():
	if battle_consumables.size() == 0:
		return

	var inventory_item = battle_consumables[item_index]
	var item_id = inventory_item["id"]

	if not items.has(item_id):
		return

	var item_data = items[item_id]
	
	if item_data.has("heal"):
		player_hp += item_data["heal"]

		if player_hp > player_max_hp:
			player_hp = player_max_hp
			
	if item_data.has("clear_status_effects"):
		clear_selected_player_status_effects(item_data.get("clear_status_effects", []))

	healing_sound.play()
	update_player_hp_ui()

	if inventory_item.has("count"):
		inventory_item["count"] -= 1

		if inventory_item["count"] <= 0:
			inventory.erase(inventory_item)
	else:
		inventory.erase(inventory_item)

	is_item_selecting = false

	battle_text.text = items[item_id].get("name", item_id) + " 을 사용했다."

	await get_tree().create_timer(1.0).timeout

	start_enemy_turn()
# 전투 드랍 아이템 계산 함수
func calculate_enemy_drops():
	var rewards = []
	var drops = enemy_data.get("drops", [])

	for drop in drops:
		var item_id = drop.get("item", "")

		if item_id == "":
			continue

		if not items.has(item_id):
			push_error("드랍 아이템 데이터가 없음: " + item_id)
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
# 인벤토리에 아이템 추가 함수
func add_item_to_inventory(item_id, count = 1):
	if not items.has(item_id):
		return

	var item_data = items[item_id]
	var stackable = item_data.get("stackable", false)
	var max_stack = int(item_data.get("max_stack", 1))
	var remaining = count

	if stackable:
		for inventory_item in inventory:
			if inventory_item.get("id", "") == item_id:
				var current_count = int(inventory_item.get("count", 1))
				var add_count = min(remaining, max_stack - current_count)

				if add_count > 0:
					inventory_item["count"] = current_count + add_count
					remaining -= add_count

				if remaining <= 0:
					return

	while remaining > 0:
		if stackable:
			var add_count = min(remaining, max_stack)
			inventory.append({
				"id": item_id,
				"count": add_count
			})
			remaining -= add_count
		else:
			inventory.append({
				"id": item_id
			})
			remaining -= 1
# 전투 보상 결과 메시지 생성 함수
func make_reward_messages(rewards):
	var messages = []

	for reward in rewards:
		var item_id = reward.get("item", "")
		var count = int(reward.get("count", 1))

		if not items.has(item_id):
			continue

		var item_name = items[item_id].get("name", item_id)
		messages.append(item_name + " " + str(count) + "개를 획득하였습니다.")

	return messages
# 전투 결과 메시지 순차 표시 함수
func show_battle_result_messages(messages):
	for message in messages:
		if result_sound != null:
			result_sound.play()

		battle_text.text = message + "\n\n[Space]"
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

# === 음원 함수 모음 ===
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

# === 디버그 함수 모음 ===
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

	if not enemy_data.has("hitboxes"):
		update_debug_hp_labels()
		return

	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var base_width = float(base_size[0])
	var base_height = float(base_size[1])

	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / base_width
	var scale_y = enemy_rect.size.y / base_height

	for hitbox in enemy_data["hitboxes"]:
		var rect_data = hitbox["rect"]

		var box = ColorRect.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.color = Color(1, 1, 1, 0.12)

		if hitbox.get("weak", false):
			box.color = Color(1, 0, 0, 0.18)

		box.position = Vector2(
			enemy_rect.position.x + rect_data[0] * scale_x,
			enemy_rect.position.y + rect_data[1] * scale_y
		)

		box.size = Vector2(
			rect_data[2] * scale_x,
			rect_data[3] * scale_y
		)

		hitbox_debug_container.add_child(box)
		
	update_part_hitbox_debug(base_size, enemy_rect)
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
func update_part_hitbox_debug(base_size, enemy_rect):
	var base_width = float(base_size[0])
	var base_height = float(base_size[1])

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

		var box = ColorRect.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.color = Color(0.2, 0.7, 1, 0.18)

		box.position = Vector2(
			enemy_rect.position.x + rect_data[0] * scale_x,
			enemy_rect.position.y + rect_data[1] * scale_y
		)

		box.size = Vector2(
			rect_data[2] * scale_x,
			rect_data[3] * scale_y
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
	if not enemy_parts.has(part_id):
		return

	var part = enemy_parts[part_id]
	var hitbox = part.get("hitbox", {})

	if hitbox.is_empty():
		return

	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / float(base_size[0])
	var scale_y = enemy_rect.size.y / float(base_size[1])

	var rect_data = hitbox.get("rect", [0, 0, 100, 100])
	var debug_global = hitbox_debug_container.get_global_rect().position

	var label = Label.new()
	label.text = part.get("name", part_id) + "\nHP " + str(int(enemy_part_hp.get(part_id, 0))) + " / " + str(int(part.get("max_hp", 0)))
	label.z_index = 1000
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.6, 0.85, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 5)

	label.position = Vector2(
		enemy_rect.position.x + (rect_data[0] + rect_data[2] / 2.0) * scale_x - 100,
		enemy_rect.position.y + (rect_data[1] + rect_data[3]) * scale_y + 10
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

# === 적 관련 함수 모음 ===
# 적 HP ui 갱신 함수
func update_enemy_hp_ui():
	update_debug_hp_labels()
# 적 공격 함수
func execute_enemy_attack():
	battle_text.text = ""

	await fire_enemy_projectiles()

	if player_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		await game_over()
		return

	await get_tree().create_timer(0.5).timeout
	start_player_turn()
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
# 적의 탄막 발사 함수
func fire_enemy_projectile(projectile_info):
	projectile_info = get_adjusted_projectile_info(projectile_info)
	var projectile_id = projectile_info.get("projectile", "slash_basic")

	if not projectiles.has(projectile_id):
		push_error("적 투사체 데이터가 없음: " + projectile_id)
		return

	var projectile_data = projectiles[projectile_id]
	var danger_type = projectile_info.get("danger_type", "normal")

	var projectile_size = projectile_data.get("size", [200, 200])
	var projectile_speed = projectile_data.get("speed", 1200)
	var projectile_life_time = projectile_data.get("life_time", 0.9)
	var projectile_frame_time = projectile_data.get("frame_time", 0.04)
	var projectile_frame_count = projectile_data.get("frame_count", 9)
	var projectile_frames_path = projectile_data.get("frames_path", "res://imgs/effects/slash/slash_")

	var projectile_frames = make_effect_frames(projectile_frames_path, projectile_frame_count)

	var projectile = TextureRect.new()
	projectile.z_index = 0
	projectile.size = Vector2(projectile_size[0], projectile_size[1])
	projectile.pivot_offset = projectile.size / 2
	projectile.ignore_texture_size = true
	projectile.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	projectile.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var start_pos = projectile_info.get("start", [900, 120])
	projectile.position = Vector2(start_pos[0], start_pos[1])
	projectile.rotation_degrees = projectile_info.get("rotation", 180)
	
	if danger_type == "parry_only":
		projectile.modulate = Color(1, 0.15, 0.15, 1)
	else:
		projectile.modulate = Color(1, 1, 1, 1)

	enemy_projectile_container.add_child(projectile)
	
	var sound_id = projectile_data.get("sound", "")
	play_projectile_sound(sound_id)

	var direction = Vector2.DOWN
	var elapsed_time = 0.0
	var frame_index = 0
	var hit_player = false
	var blocked = false
	var projectile_parried = false

	while elapsed_time < projectile_life_time:
		projectile.texture = load(projectile_frames[frame_index])
		projectile.position += direction * projectile_speed * projectile_frame_time
		
		update_defense_hitbox_debug(projectile, projectile_data)
		
		if parry_input_buffer_time > 0 and check_parry_hit(projectile, projectile_data):
			projectile_parried = true
			parry_count += 1
			projectile.visible = false
			parry_sound.play()
			spawn_parry_effect(get_parry_effect_position_for_projectile(projectile, projectile_data))
			break
		
		if danger_type != "parry_only" and check_defense_hit(projectile, projectile_data):
			blocked = true
			block_sound.play()
			break
			
		# 바닥 도달 판정도 탄막 hitbox 기준
		var projectile_hit_rect = get_projectile_hit_rect(projectile, projectile_data)
		var damage_line_y = defense_area_rect.position.y + defense_area_rect.size.y - 20

		if projectile_hit_rect.position.y + projectile_hit_rect.size.y >= damage_line_y:
			hit_player = true
			break

		await get_tree().create_timer(projectile_frame_time).timeout

		elapsed_time += projectile_frame_time
		frame_index += 1

		if frame_index >= projectile_frames.size():
			frame_index = 0

	remove_enemy_projectile_debug_box(projectile)
	projectile.queue_free()

	if projectile_parried:
		pass
	elif blocked:
		pass
	elif hit_player:
		apply_projectile_hit_to_player(projectile_info, projectile_data, danger_type)
	else:
		apply_projectile_hit_to_player(projectile_info, projectile_data, danger_type)
# 적의 탄막 패턴 발사 함수
func fire_enemy_projectiles():
	var projectile_list = current_enemy_pattern.get("projectiles", [])
	var fire_mode = current_enemy_pattern.get("fire_mode", "sequential")

	parry_count = 0
	enemy_turn_total_damage = 0
	enemy_turn_applied_status_effects.clear()

	if projectile_list.size() == 0:
		await get_tree().create_timer(0.7).timeout
		return

	start_defense_mode()
	await get_tree().create_timer(0.5).timeout

	if fire_mode == "parallel":
		await fire_enemy_projectiles_parallel(projectile_list)
	else:
		for projectile_info in projectile_list:
			var delay = projectile_info.get("delay", 0.0)

			if delay > 0:
				await get_tree().create_timer(delay).timeout

			await fire_enemy_projectile(projectile_info)

	end_defense_mode()
	
	await show_enemy_turn_player_damage_result()

	defense_weapon_hitbox_debug.visible = false
	enemy_projectile_hitbox_debug.visible = false
	parry_hitbox_debug.visible = false
	clear_enemy_projectile_debug_boxes()

	if parry_count > 0:
		var counter_damage = 0

		for i in range(parry_count):
			counter_damage += get_parry_counter_damage_once()

		apply_parry_counter_damage(counter_damage)

		await get_tree().create_timer(1.0).timeout

		if enemy_hp <= 0:
			await win_battle()
			return
# 적의 패턴에 동시 탄막 추가 함수
func fire_enemy_projectiles_parallel(projectile_list):
	for projectile_info in projectile_list:
		fire_enemy_projectile_parallel_task(projectile_info)

	var max_wait_time = 0.0

	for projectile_info in projectile_list:
		var delay = projectile_info.get("delay", 0.0)
		var projectile_id = projectile_info.get("projectile", "slash_basic")

		if not projectiles.has(projectile_id):
			continue

		var projectile_data = projectiles[projectile_id]
		var life_time = projectile_data.get("life_time", 0.9)

		max_wait_time = max(max_wait_time, delay + life_time + 0.2)

	await get_tree().create_timer(max_wait_time).timeout
# 적 동시 탄막 추가 함수
func fire_enemy_projectile_parallel_task(projectile_info):
	var delay = projectile_info.get("delay", 0.0)

	if delay > 0:
		await get_tree().create_timer(delay).timeout

	await fire_enemy_projectile(projectile_info)
# 적 패턴 선택 함수
func choose_enemy_pattern():
	var candidates = []

	add_pattern_candidates(candidates, enemy_data.get("patterns", []), "body", "")

	for part_id in enemy_parts.keys():
		if destroyed_parts.has(part_id):
			continue

		var part = enemy_parts[part_id]
		add_pattern_candidates(candidates, part.get("patterns", []), "part", part_id)

	if candidates.size() == 0:
		return {}

	return pick_weighted_pattern(candidates)
# 적 패턴 리스트 취합 함수
func add_pattern_candidates(candidates, patterns, owner_type, owner_id):
	for pattern in patterns:
		if int(pattern.get("weight", 100)) <= 0:
			continue

		var copied_pattern = pattern.duplicate(true)
		copied_pattern["owner_type"] = owner_type
		copied_pattern["owner_id"] = owner_id
		candidates.append(copied_pattern)
# 적 패턴 가중치 기반 랜덤 선택 함수
func pick_weighted_pattern(patterns):
	var total_weight = 0

	for pattern in patterns:
		total_weight += int(pattern.get("weight", 100))

	if total_weight <= 0:
		return patterns.pick_random()

	var roll = randi_range(1, total_weight)
	var current = 0

	for pattern in patterns:
		current += int(pattern.get("weight", 100))

		if roll <= current:
			return pattern

	return patterns[0]
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
	if not enemy_data.has("hitboxes"):
		return

	var hitboxes = enemy_data["hitboxes"]

	if hitboxes.size() == 0:
		return

	var top_hitbox = hitboxes[0]

	for hitbox in hitboxes:
		if hitbox["rect"][1] < top_hitbox["rect"][1]:
			top_hitbox = hitbox

	last_hitbox_data = top_hitbox
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
	for hitbox in enemy_data.get("hitboxes", []):
		if hitbox.get("id", "") == hitbox_id:
			var copied_hitbox = hitbox.duplicate(true)
			copied_hitbox["target_type"] = "body"
			return copied_hitbox

	var hitboxes = enemy_data.get("hitboxes", [])

	if hitboxes.size() > 0:
		var copied_hitbox = hitboxes[0].duplicate(true)
		copied_hitbox["target_type"] = "body"
		return copied_hitbox

	return {}
# 적 파츠 히트박스 찾는 함수
func get_part_hitbox_by_id(part_id):
	if not enemy_parts.has(part_id):
		return {}

	var part = enemy_parts[part_id]

	if not part.has("hitbox"):
		return {}

	var copied_hitbox = part["hitbox"].duplicate(true)
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
# 적 파츠 생성 함수
func setup_enemy_parts():
	clear_enemy_parts()

	enemy_parts.clear()
	enemy_part_hp.clear()
	destroyed_parts.clear()
	enemy_part_base_positions.clear()

	var parts = enemy_data.get("parts", [])

	for part in parts:
		var part_id = part.get("id", "")

		if part_id == "":
			continue

		enemy_parts[part_id] = part
		enemy_part_hp[part_id] = part.get("max_hp", 1)

		var part_sprite = TextureRect.new()
		part_sprite.name = "EnemyPart_" + part_id
		part_sprite.texture = load(part.get("image", ""))
		part_sprite.modulate.a = 1.0
		
		part_sprite.ignore_texture_size = true
		part_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		part_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var base_size = enemy_data.get("hitbox_base_size", [enemy_sprite.size.x, enemy_sprite.size.y])
		var base_width = float(base_size[0])
		var base_height = float(base_size[1])

		var scale_x = enemy_sprite.size.x / base_width
		var scale_y = enemy_sprite.size.y / base_height

		if part.has("size"):
			var size_data = part["size"]
			part_sprite.size = Vector2(
				size_data[0] * scale_x,
				size_data[1] * scale_y
			)
		else:
			part_sprite.size = enemy_sprite.size

		var pos = part.get("position", [0, 0])
		part_sprite.position = enemy_sprite.position + Vector2(
			pos[0] * scale_x,
			pos[1] * scale_y
		)
		
		enemy_part_base_positions[part_id] = part_sprite.position

		part_sprite.z_index = part.get("z_index", 20)

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

	var text = ""

	if is_critical:
		text += "치명타!\n"

	text += hitbox_name + "에 맞았다.\n"
	text += str(int(damage)) + " 의 피해를 주었다."
	
	print(part_id, " HP: ", enemy_part_hp[part_id])

	if enemy_part_hp[part_id] <= 0:
		destroy_enemy_part(part_id)
	else:
		battle_text.text = text
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

	var part = enemy_parts.get(part_id, {})
	var destroy_text = part.get("destroy_text", "부위가 파괴되었다.")

	battle_text.text = destroy_text

	update_hitbox_debug()
	update_debug_hp_labels()
# 적 페이즈 전환 함수
func change_enemy_phase():
	var next_enemy_id = enemy_data.get("next_phase_enemy_id", "")

	if next_enemy_id == "":
		await win_battle()
		return

	if not enemies.has(next_enemy_id):
		push_error("다음 페이즈 적 데이터가 없음: " + next_enemy_id)
		await win_battle()
		return

	set_action_buttons_disabled(true)

	# 1. 페이즈1 쪽 전환 텍스트 표시
	battle_text.text = enemy_data.get(
		"phase_transition_text",
		"어둠속에서 무언가가 다시 나타나기 시작한다..."
	) + "\n\n[Space]"

	await wait_for_accept_input()

	# 2. 암전
	await fade_to_black(2)

	# 3. 페이즈1 파츠 제거
	clear_enemy_parts()

	# 4. 페이즈2 적 데이터로 교체
	enemy_id = next_enemy_id
	enemy_data = enemies[next_enemy_id]
	enemy_max_hp = enemy_data.get("max_hp", 10)
	enemy_hp = enemy_max_hp

	# 5. 페이즈2 BGM 갱신
	await update_battle_bgm()

	# 6. 페이즈2 이미지/파츠/히트박스 갱신
	enemy_sprite.modulate.a = 1.0
	enemy_sprite.texture = load(enemy_data["image"])

	apply_enemy_visual_settings()
	setup_enemy_parts()
	update_enemy_hp_ui()
	update_hitbox_debug()

	# 7. 밝아짐
	await fade_from_black(0.6)

	# 8. 페이즈2 등장 효과음
	play_enemy_encounter_sound()

	# 9. 페이즈2 encounter_text 표시 후 Space 대기
	battle_text.text = enemy_data.get(
		"encounter_text",
		enemy_data.get("name", "무언가") + "가 나타났다..."
	) + "\n\n[Space]"

	await wait_for_accept_input()

	# 10. Space를 누른 뒤에야 페이즈2 확정 패턴 경고문 표시
	await start_enemy_turn_with_forced_pattern()
# 적 페이즈 전환 확정 패턴 사용 함수
func start_enemy_turn_with_forced_pattern():
	var pattern_id = enemy_data.get("phase_start_pattern_id", "")

	if pattern_id == "":
		start_enemy_turn()
		return

	var pattern = get_enemy_pattern_by_id(pattern_id)

	if pattern.is_empty():
		start_enemy_turn()
		return

	is_player_turn = false
	waiting_enemy_attack = true
	set_action_buttons_disabled(true)

	current_enemy_pattern = pattern
	current_enemy_pattern["owner_type"] = "body"
	current_enemy_pattern["owner_id"] = ""

	var warning_text = current_enemy_pattern.get(
		"warning_text",
		enemy_data.get("name", "적") + "이(가) 공격하려고 한다..."
	)

	battle_text.text = warning_text + "\n\n[Space]"
# 적 페이즈 전환 확정 패턴 탐색 함수
func get_enemy_pattern_by_id(pattern_id):
	for pattern in enemy_data.get("patterns", []):
		if pattern.get("id", "") == pattern_id:
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

# === 플레이어 관련 함수 모음 ===
# 플레이어 현재 체력 갱신 함수
func update_player_hp_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
# 플레이어 무기 데미지 계산 함수 추가
func get_player_attack_damage():
	var weapon_data = get_current_weapon_data()

	var min_damage = weapon_data.get("attack_min", weapon_data.get("attack", 1))
	var max_damage = weapon_data.get("attack_max", weapon_data.get("attack", 1))

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

	battle_text.text = "패링 반격!\n" + str(int(counter_damage)) + " 의 피해를 주었다."
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

	var part = enemy_parts.get(part_id, {})
	var part_name = part.get("name", "부위")

	battle_text.text = "패링 반격!\n" + part_name + "에 " + str(int(counter_damage)) + " 의 피해를 주었다."

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
# 플레이어 무기 현재 아이디 값 가져오는 함수
func get_current_weapon_id():
	if equipped_weapon != null:
		return equipped_weapon["id"]

	return "fist"
# 플레이어 무기 현재 데이터 가져오는 함수
func get_current_weapon_data():
	var weapon_id = get_current_weapon_id()

	if not items.has(weapon_id):
		return {}

	return items[weapon_id]
# 플레이어 무기 현재 탄환 아이디 가져오는 함수
func get_current_attack_projectile_id():
	var weapon_data = get_current_weapon_data()

	return weapon_data.get("attack_projectile", "slash_basic")
# 플레이어 무기 현재 탄환 데이터 함수
func get_current_projectile_data():
	var projectile_id = get_current_attack_projectile_id()

	if not projectiles.has(projectile_id):
		return {}

	return projectiles[projectile_id]
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
# 플레이어 공격 모드 시작 함수
func start_attack_mode():
	set_action_buttons_disabled(true)

	is_attack_mode = true
	weapon_swing_enabled = true
	weapon_move_time = 0.0

	update_weapon_sprite_texture()
	apply_weapon_visual_settings()
	update_weapon_base_position()
	
	var weapon_data = get_current_weapon_data()
	weapon_angle_offset = 0.0
	weapon_sprite.rotation_degrees = weapon_data.get("attack_base_rotation", 0)

	weapon_sprite.position = weapon_base_position
	weapon_sprite.visible = true
	attack_guide.visible = true

	battle_text.text = ""
# 플레이어 방어 모드 시작 함수
func start_defense_mode():
	var weapon_data = get_current_weapon_data()

	update_weapon_sprite_texture()
	apply_weapon_visual_settings()

	weapon_sprite.rotation_degrees = weapon_data.get("defense_base_rotation", 0)

	weapon_sprite.visible = true

	# 무기 표시/크기/회전 설정 끝난 뒤에 호출
	move_defense_weapon_to_area_center()

	is_defense_mode = true
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
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
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

	var text = ""

	if is_critical:
		text += "치명타!\n"

	if is_weak:
		text += hitbox_name + " 약점을 공격했다!\n"
	else:
		text += hitbox_name + "에 맞았다.\n"

	text += str(int(damage)) + " 의 피해를 주었다."

	battle_text.text = text
# 플레이어 공격 실행 함수
func execute_player_attack():
	if not is_attack_mode:
		return

	is_attack_mode = false
	weapon_swing_enabled = false
	weapon_sprite.visible = false
	attack_guide.visible = false

	player_attack_hit = false
	attack_hit_results.clear()
	pierced_hitbox_ids.clear()

	await fire_player_attack_projectile()

	if not player_attack_hit:
		battle_text.text = "공격이 빗나갔다."

	await get_tree().create_timer(1.0).timeout

	if enemy_hp <= 0:
		if enemy_data.has("next_phase_enemy_id"):
			await change_enemy_phase()
		else:
			await win_battle()
		return

	start_enemy_turn()
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
# 플레이어 공격 투사체 발사 함수
func fire_player_attack_projectile():
	current_projectile_data = get_current_projectile_data()

	if current_projectile_data.is_empty():
		push_error("투사체 데이터가 없음: " + get_current_attack_projectile_id())
		return

	active_attack_projectile = slash_effect
	active_attack_direction = Vector2.UP.rotated(deg_to_rad(weapon_angle_offset))

	var projectile_size = current_projectile_data.get("size", [200, 200])
	var projectile_speed = current_projectile_data.get("speed", 1200)
	var projectile_life_time = current_projectile_data.get("life_time", 0.9)
	var projectile_frame_time = current_projectile_data.get("frame_time", 0.04)
	var projectile_frame_count = current_projectile_data.get("frame_count", 9)
	var projectile_frames_path = current_projectile_data.get("frames_path", "res://imgs/effects/slash/slash_")

	var projectile_frames = make_effect_frames(projectile_frames_path, projectile_frame_count)

	slash_effect.size = Vector2(projectile_size[0], projectile_size[1])
	slash_effect.pivot_offset = slash_effect.size / 2
	slash_effect.position = weapon_sprite.position
	slash_effect.rotation_degrees = weapon_angle_offset
	slash_effect.visible = true
	
	var sound_id = current_projectile_data.get("sound", "")
	play_projectile_sound(sound_id)

	var elapsed_time = 0.0
	var frame_index = 0

	while elapsed_time < projectile_life_time:
		var frame_path = projectile_frames[frame_index]
		slash_effect.texture = load(frame_path)

		slash_effect.position += active_attack_direction * projectile_speed * projectile_frame_time

		if debug_mode:
			var attack_rect = get_player_attack_hit_rect()
			player_attack_hitbox_debug.visible = true
			player_attack_hitbox_debug.position = attack_rect.position
			player_attack_hitbox_debug.size = attack_rect.size

		var weapon_data = get_current_weapon_data()
		var piercing = weapon_data.get("piercing", false)

		var collided_hitboxes = get_attack_collided_hitboxes()

		if collided_hitboxes.size() > 0:
			player_attack_hit = true
			player_attack_hitbox_debug.visible = false

			for hitbox in collided_hitboxes:
				var hitbox_id = hitbox.get("id", "")

				if piercing:
					if pierced_hitbox_ids.has(hitbox_id):
						continue
					# 관통
					pierced_hitbox_ids.append(hitbox_id)
					apply_player_attack_hit(hitbox)
				else:
					# 비관통
					apply_player_attack_hit(hitbox)
					break

			if not piercing:
				break

		await get_tree().create_timer(projectile_frame_time).timeout

		elapsed_time += projectile_frame_time
		frame_index += 1

		if frame_index >= projectile_frames.size():
			frame_index = 0

	slash_effect.visible = false
	slash_effect.texture = null
	player_attack_hitbox_debug.visible = false
	active_attack_projectile = null
	current_projectile_data = {}
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

	if not enemy_data.has("hitboxes"):
		return results

	var base_size = enemy_data.get("hitbox_base_size", [667, 1000])
	var base_width = float(base_size[0])
	var base_height = float(base_size[1])

	var enemy_rect = enemy_sprite.get_global_rect()

	var scale_x = enemy_rect.size.x / base_width
	var scale_y = enemy_rect.size.y / base_height

	for hitbox in enemy_data["hitboxes"]:
		var rect_data = hitbox["rect"]

		var hitbox_rect = Rect2(
			enemy_rect.position.x + rect_data[0] * scale_x,
			enemy_rect.position.y + rect_data[1] * scale_y,
			rect_data[2] * scale_x,
			rect_data[3] * scale_y
		)

		if attack_rect.intersects(hitbox_rect):
			var copied_hitbox = hitbox.duplicate(true)
			copied_hitbox["target_type"] = "body"
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
# 플레이어 전투 메뉴 조작 포커스 함수
func update_action_button_focus():
	if action_buttons.size() == 0:
		return

	for i in range(action_buttons.size()):
		var button = action_buttons[i]
		var base_text = action_button_base_texts[i]

		if not button.disabled and i == action_button_index and is_player_turn:
			button.text = "▶ " + base_text
		else:
			button.text = "  " + base_text
# 플레이어 전투 메뉴 조작 함수
func move_action_button_focus(direction):
	if action_buttons.size() == 0:
		return

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
# 플레이어 전투 메뉴 키보드 입력 함수
func update_action_button_keyboard_input():
	if action_buttons.size() == 0:
		return

	if Input.is_action_just_pressed("move_back"):
		move_action_button_focus(1)

	if Input.is_action_just_pressed("move_forward"):
		move_action_button_focus(-1)

	if Input.is_action_just_pressed("ui_accept"):
		var selected_button = action_buttons[action_button_index]

		if selected_button.disabled:
			return

		selected_button.emit_signal("pressed")
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
# 적 턴 플레이어 피해 결과 표시 함수
func show_enemy_turn_player_damage_result():
	if enemy_turn_total_damage <= 0 and enemy_turn_applied_status_effects.size() == 0:
		return

	var lines = []

	if enemy_turn_total_damage > 0:
		lines.append(str(int(enemy_turn_total_damage)) + " 의 피해를 입었다.")

	if enemy_turn_applied_status_effects.size() > 0:
		lines.append(get_status_applied_text(enemy_turn_applied_status_effects))

	battle_text.text = "\n".join(lines)

	await get_tree().create_timer(1.0).timeout
# 플레이어 탄막 피격 처리 함수
func apply_projectile_hit_to_player(projectile_info, projectile_data, danger_type):
	var damage = projectile_info.get("damage", current_enemy_pattern.get("damage", 1))
	damage = get_player_received_damage(damage)

	player_hp -= damage

	if player_hp < 0:
		player_hp = 0

	enemy_turn_total_damage += damage

	play_player_hit_flash()

	var status_effects = get_projectile_status_effects(projectile_info, projectile_data)
	var added_effects = apply_player_status_effects(status_effects)
	add_enemy_turn_status_effects(added_effects)

	if danger_type == "parry_only":
		hit_red_sound.play()
	else:
		hit_normal_sound.play()

	update_player_hp_ui()
# 플레이어 받는 데미지 계산 함수
func get_player_received_damage(base_damage):
	var damage = float(base_damage)

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

	battle_text.text = get_player_turn_start_text()
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
	var text = get_player_status_description_text()

	if text == "":
		text = "정상 상태 : \n\n안정적인 상태이다."

	status_popup_text.text = text
	status_popup_panel.visible = true
# 플레이어 상태이상 설명 텍스트 함수
func get_player_status_description_text():
	var lines = []

	if has_player_status_effect("fear"):
		lines.append("공포 상태 : \n\n공격 무기의\n스윙 스피드가 50% 빨라진다.")

	if has_player_status_effect("lethargy"):
		lines.append("무기력 상태 : \n\n방어 무기의\n이동속도가 30% 느려진다.")

	if has_player_status_effect("despair"):
		lines.append("절망 상태 : \n\n받는 데미지가\n50% 증가한다.")

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
