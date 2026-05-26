extends Control

# 시그널 모음
signal battle_finished(result_data)

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
@onready var enemy_hp_text = $EnemyHpText
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
@onready var click_sound = $ClickSound
@onready var healing_sound = $HealingSound

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
var weapon_angle_speed = 120.0
var attack_projectile_speed = 1200.0
var active_attack_projectile = null
var active_attack_direction = Vector2.ZERO
var player_attack_hit = false
var last_hitbox_data = {}
var debug_mode = true
var projectiles = {}
var current_projectile_data = {}
var is_defense_mode = false
var defense_area_rect = Rect2(350, 700, 1220, 360)
var parry_success = false
var parry_input_buffer_time = 0.0
var parry_count = 0
# 전투 난이도 조절 기능
var battle_difficulty = "normal"
var action_buttons = []
var action_button_base_texts = []
var action_button_index = 0
var attack_hit_results = []
var pierced_hitbox_ids = []

# 상수 변수 모음

# 프레임 마다 실행 함수
func _process(delta):
		# 개발자 모드
	if Input.is_action_just_pressed("debug_toggle"):
		debug_mode = !debug_mode
		hitbox_debug_container.visible = debug_mode
	# 관찰중
	if is_observing:
		if Input.is_action_just_pressed("ui_accept"):
			is_observing = false
			start_enemy_turn()	
		return			
	# 아이템 선택중
	if is_item_selecting:
		if Input.is_action_just_pressed("ui_down"):
			item_index += 1
			if item_index >= battle_consumables.size():
				item_index = 0
			update_battle_item_list()
		if Input.is_action_just_pressed("ui_up"):
			item_index -= 1
			if item_index < 0:
				item_index = battle_consumables.size() - 1
			update_battle_item_list()
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

		if Input.is_action_just_pressed("ui_accept"):
			parry_input_buffer_time = 0.03

		if parry_input_buffer_time > 0:
			parry_input_buffer_time -= delta	
	# 공격 모드
	if is_attack_mode:
		var weapon_data = get_current_weapon_data()

		if weapon_swing_enabled:
			weapon_move_time += delta

			var swing_speed = weapon_data.get("attack_swing_speed", 3.0)
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
	
	# 각 이미지들 z 값 설정
	attack_guide.z_index = 1
	weapon_sprite.z_index = 10
	parry_effect.z_index = 20
	# 디버그 모드시 보이는 박스들이 가장 높음
	hitbox_debug_container.z_index = 999

	# 무기 별로 기본 위치 포지션을 잡아줌
	weapon_sprite.pivot_offset = weapon_sprite.size / 2
	update_weapon_base_position()
	
	attack_button.pressed.connect(_on_attack_button_pressed)
	observe_button.pressed.connect(_on_observe_button_pressed)
	item_button.pressed.connect(_on_item_button_pressed)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	
	slash_frames = make_effect_frames("res://imgs/effects/slash/slash_", 9)
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
	
	update_weapon_sprite_texture()
	weapon_sprite.visible = false

	update_player_hp_ui()
	update_enemy_hp_ui()

	if enemy_data.has("image"):
		enemy_sprite.texture = load(enemy_data["image"])
		
	if data.has("player_portrait"):
		player_portrait.texture = load(data["player_portrait"])
		
	# 히트 박스 확인용
	update_hitbox_debug()

	is_player_turn = false
	set_action_buttons_disabled(true)
	
	if not battle_bgm.playing:
		battle_bgm.play()

	battle_text.text = enemy_data.get("name", "무언가") + "가 나타났다..."

	await get_tree().create_timer(1.0).timeout
	start_player_turn()
# 플레이어 현재 체력 갱신 함수
func update_player_hp_ui():
	player_hp_text.text = str(int(player_hp)) + " / " + str(int(player_max_hp))
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

	var observe_text = enemy_data.get(
		"observe_text",
		"특별한 점은 보이지 않는다."
	)

	var weakness_text = enemy_data.get(
		"weakness_text",
		""
	)

	var hp_text = "\n남은 체력 : " + str(int(enemy_hp)) + "/" + str(int(enemy_max_hp))

	battle_text.text = (
		observe_text
		+ "\n"
		+ weakness_text
		+ hp_text
		+ "\n\n[Space] 관찰을 끝낸다."
	)
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
	battle_text.text = "행동을 선택하세요."

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

	await tween.finished
	
	battle_bgm.stop()

	battle_text.text = "전투에서 승리했다."
	enemy_hp_text.visible = false
	
	await get_tree().create_timer(1.0).timeout

	emit_signal("battle_finished", {
		"result": "win",
		"enemy_id": enemy_id,
		"player_hp": player_hp,
		"inventory": inventory
	})
# 게임 오버 함수
func game_over():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = "YOU DIED"

	await get_tree().create_timer(2.0).timeout
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
# 플레이어 HP ui 갱신 함수 추가
func update_enemy_hp_ui():
	enemy_hp_text.text = str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))
# 아이템 목록 열기 함수
func open_battle_item_list():
	battle_consumables.clear()
	item_index = 0

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
		battle_text.text = "행동을 선택하세요."
		return

	set_action_buttons_disabled(true)
	is_item_selecting = true
	update_battle_item_list()
# 아이템 목록 표시 함수
func update_battle_item_list():
	var text = "사용할 아이템을 선택하세요.\n\n"

	for i in battle_consumables.size():
		var inventory_item = battle_consumables[i]
		var item_id = inventory_item["id"]
		var item_name = items[item_id].get("name", item_id)
		var count_text = ""

		if inventory_item.has("count"):
			count_text = " x" + str(int(inventory_item["count"]))

		if i == item_index:
			text += "▶ " + item_name + count_text + "\n"
		else:
			text += "  " + item_name + count_text + "\n"

	text += "\n[Space] 사용 / [ESC] 취소"
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
	parry_success = false

	while elapsed_time < projectile_life_time:
		projectile.texture = load(projectile_frames[frame_index])
		projectile.position += direction * projectile_speed * projectile_frame_time
		
		if parry_input_buffer_time > 0 and check_parry_hit(projectile, projectile_data):
			parry_success = true
			parry_count += 1
			parry_input_buffer_time = 0.0
			projectile.visible = false
			parry_sound.play()
			parry_effect.position = get_parry_effect_position()
			await play_effect_frames(parry_effect, parry_frames, 0.04)
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

	projectile.queue_free()

	defense_weapon_hitbox_debug.visible = false
	enemy_projectile_hitbox_debug.visible = false
	parry_hitbox_debug.visible = false

	if parry_success:
		pass
	elif blocked:
		pass
	elif hit_player:
		var damage = projectile_info.get("damage", current_enemy_pattern.get("damage", 1))
		player_hp -= damage

		if player_hp < 0:
			player_hp = 0
			
		if danger_type == "parry_only":
			hit_red_sound.play()
		else:
			hit_normal_sound.play()

		update_player_hp_ui()
		battle_text.text = str(int(damage)) + " 의 피해를 입었다."
	else:
		var damage = projectile_info.get("damage", current_enemy_pattern.get("damage", 1))
		player_hp -= damage

		if player_hp < 0:
			player_hp = 0

		update_player_hp_ui()
		battle_text.text = str(int(damage)) + " 의 피해를 입었다."
# 적의 탄막 패턴 발사 함수
func fire_enemy_projectiles():
	var projectile_list = current_enemy_pattern.get("projectiles", [])
	var fire_mode = current_enemy_pattern.get("fire_mode", "sequential")

	parry_count = 0

	start_defense_mode()
	await get_tree().create_timer(0.5).timeout

	if projectile_list.size() == 0:
		await fire_enemy_projectile(current_enemy_pattern)
	else:
		if fire_mode == "parallel":
			await fire_enemy_projectiles_parallel(projectile_list)
		else:
			for projectile_info in projectile_list:
				var delay = projectile_info.get("delay", 0.0)

				if delay > 0:
					await get_tree().create_timer(delay).timeout

				await fire_enemy_projectile(projectile_info)

	end_defense_mode()

	defense_weapon_hitbox_debug.visible = false
	enemy_projectile_hitbox_debug.visible = false
	parry_hitbox_debug.visible = false

	if parry_count > 0:
		var counter_damage = 0

		for i in range(parry_count):
			counter_damage += get_parry_counter_damage_once()

		enemy_hp -= counter_damage

		if enemy_hp < 0:
			enemy_hp = 0

		update_enemy_hp_ui()

		set_top_hitbox_as_last_hitbox()
		
		hit_red_sound.play()

		hit_effect.position = get_last_hitbox_center_position()
		show_damage_popup(counter_damage, true)

		await play_enemy_hit_shake()
		await play_effect_frames(hit_effect, hit_frames, 0.05)

		battle_text.text = "패링 반격!\n" + str(int(counter_damage)) + " 의 피해를 주었다."

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
# 동시 탄막 추가 함수
func fire_enemy_projectile_parallel_task(projectile_info):
	var delay = projectile_info.get("delay", 0.0)

	if delay > 0:
		await get_tree().create_timer(delay).timeout

	await fire_enemy_projectile(projectile_info)
# 적 패턴 랜덤 선택 함수
func choose_enemy_pattern():
	var patterns = enemy_data.get("patterns", [])

	if patterns.size() == 0:
		return {}

	return patterns.pick_random()
# 적 피격시 흔들림 함수
func play_enemy_hit_shake():
	var original_position = enemy_sprite.position

	var tween = create_tween()
	tween.tween_property(enemy_sprite, "position", original_position + Vector2(18, 0), 0.04)
	tween.tween_property(enemy_sprite, "position", original_position + Vector2(-18, 0), 0.04)
	tween.tween_property(enemy_sprite, "position", original_position + Vector2(10, 0), 0.04)
	tween.tween_property(enemy_sprite, "position", original_position, 0.04)

	await tween.finished
# 적 피격시 데미지 팝업 함수 
func show_damage_popup(damage, is_weak):
	var label = Label.new()
	var font = load("res://fonts/x12y12pxMaruMinyaHangul.ttf")
	label.add_theme_font_override("font", font)
	if is_weak:
		label.text = "WEAK!\n" + str(int(damage))
	else:
		label.text = str(int(damage))
	label.z_index = 100
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
# 모든 이펙트 프레임 생성 함수
func make_effect_frames(base_path, count):
	var frames = []

	for i in range(1, count + 1):
		var number = str(i).pad_zeros(2)
		frames.append(base_path + number + ".png")

	return frames
# 디버그 히트 박스 확인용 함수
func update_hitbox_debug():
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

	if not enemy_data.has("hitboxes"):
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
# 디버그 박스 갱신 함수 추가
func update_defense_hitbox_debug(projectile, projectile_data):
	if not debug_mode:
		defense_weapon_hitbox_debug.visible = false
		enemy_projectile_hitbox_debug.visible = false
		parry_hitbox_debug.visible = false
		return

	var weapon_rect = get_weapon_defense_hit_rect()
	var projectile_rect = get_projectile_hit_rect(projectile, projectile_data)
	var debug_container_global = hitbox_debug_container.get_global_rect().position
	var parry_rect = get_parry_hit_rect()

	defense_weapon_hitbox_debug.visible = true
	defense_weapon_hitbox_debug.position = weapon_rect.position - debug_container_global
	defense_weapon_hitbox_debug.size = weapon_rect.size

	enemy_projectile_hitbox_debug.visible = true
	enemy_projectile_hitbox_debug.position = projectile_rect.position - debug_container_global
	enemy_projectile_hitbox_debug.size = projectile_rect.size
	
	parry_hitbox_debug.visible = true
	parry_hitbox_debug.position = parry_rect.position - debug_container_global
	parry_hitbox_debug.size = parry_rect.size
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

	var parry_height = weapon_rect.size.y * parry_window
	if parry_height < 6:
		parry_height = 6

	var center_y = weapon_rect.position.y + weapon_rect.size.y / 2.0

	return Rect2(
		Vector2(weapon_rect.position.x, center_y - parry_height / 2.0),
		Vector2(weapon_rect.size.x, parry_height)
	)
# 플레이어 방어 무기 패링 이펙트 위치 함수
func get_parry_effect_position():
	var weapon_data = get_current_weapon_data()
	var offset_data = weapon_data.get("parry_effect_offset", [
		weapon_sprite.size.x / 2,
		weapon_sprite.size.y / 2
	])

	var offset = Vector2(offset_data[0], offset_data[1])
	var effect_parent_global = parry_effect.get_parent().get_global_rect().position

	var effect_global_position = weapon_sprite.get_global_rect().position + offset

	return effect_global_position - effect_parent_global - parry_effect.size / 2
# 플레이어 방어 무기 탄막 충돌 함수
func check_defense_hit(projectile, projectile_data):
	update_defense_hitbox_debug(projectile, projectile_data)

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
	# 방어 무기 초기 위치 + 될수록 내려감 현재 5
	weapon_sprite.position = Vector2(
		defense_area_rect.position.x + defense_area_rect.size.x / 2 - weapon_sprite.size.x / 2,
		defense_area_rect.position.y + defense_area_rect.size.y - weapon_sprite.size.y + 5
	)

	weapon_sprite.visible = true
	is_defense_mode = true
# 플레이어 방어 모드 종료 함수
func end_defense_mode():
	is_defense_mode = false
	weapon_sprite.visible = false
	weapon_sprite.rotation_degrees = 0
# 플레이어 방어 실행 함수
func update_defense_weapon_movement(delta):
	var weapon_data = get_current_weapon_data()
	var move_speed = weapon_data.get("defense_move_speed", 500)

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

	weapon_sprite.position += move_vector * move_speed * delta

	var min_pos = defense_area_rect.position
	var max_pos = defense_area_rect.position + defense_area_rect.size

	var hitbox_data = weapon_data.get("defense_hitbox", {})
	var offset_data = hitbox_data.get("offset", [0, 0])
	var size_data = hitbox_data.get("size", [weapon_sprite.size.x, weapon_sprite.size.y])

	var hitbox_offset = Vector2(offset_data[0], offset_data[1])
	var hitbox_size = Vector2(size_data[0], size_data[1])

	weapon_sprite.position.x = clamp(
		weapon_sprite.position.x,
		min_pos.x - hitbox_offset.x,
		max_pos.x - hitbox_offset.x - hitbox_size.x
	)

	weapon_sprite.position.y = clamp(
		weapon_sprite.position.y,
		min_pos.y - hitbox_offset.y,
		max_pos.y - hitbox_offset.y - hitbox_size.y
	)
# 플레이어 공격 적용 함수
func apply_player_attack_hit(hitbox):
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

	play_enemy_hit_shake()
	play_effect_frames(hit_effect, hit_frames, 0.05)

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
		await win_battle()
		return

	start_enemy_turn()
# 발사체 사운드 재생 함수
func play_projectile_sound(sound_id):
	if sound_id == "":
		return

	if sound_id == "slash":
		slash_sound.play()
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
			results.append(hitbox)

	return results
# 플레이어 공격 패링 반격 데미지 함수
func get_parry_counter_damage_once():
	var damage = get_player_attack_damage()

	if is_player_attack_critical():
		damage *= get_critical_multiplier()

	# 패링 반격은 100% 약점 처리
	damage *= 2

	return int(damage)
# 플레이어 전투 메뉴 조작 사운드 함수
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

	if Input.is_action_just_pressed("ui_down"):
		move_action_button_focus(1)

	if Input.is_action_just_pressed("ui_up"):
		move_action_button_focus(-1)

	if Input.is_action_just_pressed("ui_accept"):
		var selected_button = action_buttons[action_button_index]

		if selected_button.disabled:
			return

		selected_button.emit_signal("pressed")
