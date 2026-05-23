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
	# 공격 준비중
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

		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
			weapon_angle_offset -= angle_step

		if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
			weapon_angle_offset += angle_step

		weapon_angle_offset = clamp(weapon_angle_offset, angle_min, angle_max)
		weapon_sprite.rotation_degrees = base_rotation + weapon_angle_offset

		if Input.is_action_just_pressed("ui_accept"):
			await execute_player_attack()

		return
# 처음에 한번 실행 함수
func _ready():
	attack_button.focus_mode = Control.FOCUS_NONE
	observe_button.focus_mode = Control.FOCUS_NONE
	item_button.focus_mode = Control.FOCUS_NONE
	end_turn_button.focus_mode = Control.FOCUS_NONE
	run_button.focus_mode = Control.FOCUS_NONE
	attack_guide.z_index = 1
	weapon_sprite.z_index = 2

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

	start_attack_mode()
# 관찰 버튼 클릭 함수
func _on_observe_button_pressed():
	if not is_player_turn:
		return

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

	open_battle_item_list()
# 턴종료 버튼 클릭 함수
func _on_end_turn_button_pressed():
	if not is_player_turn:
		return

	battle_text.text = "턴을 종료했다."

	set_action_buttons_disabled(true)

	await get_tree().create_timer(0.7).timeout

	start_enemy_turn()
# 도망 버튼 클릭 함수
func _on_run_button_pressed():
	if not is_player_turn:
		return

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
# 승리 함수 추가
func win_battle():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = enemy_data.get("name", "적") + "을 쓰러뜨렸다."

	var tween = create_tween()
	tween.tween_property(enemy_sprite, "modulate:a", 0.0, 1.0)

	await tween.finished

	battle_text.text = "전투에서 승리했다."
	enemy_hp_text.visible = false
	
	await get_tree().create_timer(1.0).timeout

	emit_signal("battle_finished", {
		"result": "win",
		"enemy_id": enemy_id,
		"player_hp": player_hp,
		"inventory": inventory
	})
# 대미지 계산 함수 추가
func get_player_attack_damage():
	var weapon_id = "fist"

	if equipped_weapon != null:
		weapon_id = equipped_weapon["id"]

	if not items.has(weapon_id):
		return 1

	var weapon_data = items[weapon_id]

	return weapon_data.get("attack", 1)
# UI 갱신 함수 추가
func update_enemy_hp_ui():
	enemy_hp_text.text = str(int(enemy_hp)) + " / " + str(int(enemy_max_hp))
# 게임 오버 함수
func game_over():
	battle_ended = true
	set_action_buttons_disabled(true)

	battle_text.text = "YOU DIED"

	await get_tree().create_timer(2.0).timeout
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
# 실제 공격 함수
func execute_enemy_attack():
	var damage = current_enemy_pattern.get("damage", 1)

	player_hp -= damage

	if player_hp < 0:
		player_hp = 0

	update_player_hp_ui()

	battle_text.text = str(int(damage)) + " 의 피해를 입었다."

	if player_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		await game_over()
		return

	await get_tree().create_timer(1.0).timeout

	start_player_turn()
# 패턴 선택 함수
func choose_enemy_pattern():
	var patterns = enemy_data.get("patterns", [])

	if patterns.size() == 0:
		return {}

	return patterns.pick_random()
# 이펙트 프레임 생성 함수
func make_effect_frames(base_path, count):
	var frames = []

	for i in range(1, count + 1):
		var number = str(i).pad_zeros(2)
		frames.append(base_path + number + ".png")

	return frames
# 이펙트 재생 함수
func play_effect_frames(effect_node, frame_paths, frame_time = 0.05):
	effect_node.visible = true

	for path in frame_paths:
		effect_node.texture = load(path)
		await get_tree().create_timer(frame_time).timeout

	effect_node.visible = false
	effect_node.texture = null
# 무기 현재 아이디 값 가져오는 함수
func get_current_weapon_id():
	if equipped_weapon != null:
		return equipped_weapon["id"]

	return "fist"
# 무기 현재 데이터 가져오는 함수
func get_current_weapon_data():
	var weapon_id = get_current_weapon_id()

	if not items.has(weapon_id):
		return {}

	return items[weapon_id]
# 무기 현재 탄환 아이디 가져오는 함수
func get_current_attack_projectile_id():
	var weapon_data = get_current_weapon_data()

	return weapon_data.get("attack_projectile", "slash_basic")
# 무기 현재 탄환 데이터 함수
func get_current_projectile_data():
	var projectile_id = get_current_attack_projectile_id()

	if not projectiles.has(projectile_id):
		return {}

	return projectiles[projectile_id]
# 현재 무기 ui에 추가하는 함수
func update_weapon_sprite_texture():
	var weapon_data = get_current_weapon_data()

	if weapon_data.has("image"):
		weapon_sprite.texture = load(weapon_data["image"])
	else:
		weapon_sprite.texture = null
# 무기별 size 적용 함수
func apply_weapon_visual_settings():
	var weapon_data = get_current_weapon_data()

	if weapon_data.has("battle_sprite_size"):
		var size_data = weapon_data["battle_sprite_size"]
		weapon_sprite.size = Vector2(size_data[0], size_data[1])

	weapon_sprite.pivot_offset = weapon_sprite.size / 2
# 무기별 기본 위치값 추가 함수
func update_weapon_base_position():
	var guide_center_global = attack_guide.get_global_rect().get_center()
	var weapon_parent_global_pos = weapon_sprite.get_parent().get_global_rect().position

	weapon_base_position = guide_center_global - weapon_parent_global_pos - weapon_sprite.pivot_offset
	weapon_sprite.position = weapon_base_position
# 공격 모드 시작 함수
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
# 플레이어 공격 실행 함수
func execute_player_attack():
	if not is_attack_mode:
		return

	is_attack_mode = false
	weapon_swing_enabled = false
	weapon_sprite.visible = false
	attack_guide.visible = false

	player_attack_hit = false

	await fire_player_attack_projectile()

	if player_attack_hit:
		var damage = get_player_attack_damage()
		var hitbox_name = last_hitbox_data.get("name", "부위")
		var is_weak = last_hitbox_data.get("weak", false)

		if is_weak:
			damage *= 2

		enemy_hp -= damage

		if enemy_hp < 0:
			enemy_hp = 0

		update_enemy_hp_ui()

		await play_effect_frames(hit_effect, hit_frames, 0.05)

		if is_weak:
			battle_text.text = (
				hitbox_name
				+ " 약점을 공격했다!\n"
				+ str(int(damage))
				+ " 의 피해를 주었다."
			)
		else:
			battle_text.text = (
				hitbox_name
				+ "에 맞았다.\n"
				+ str(int(damage))
				+ " 의 피해를 주었다."
			)
	else:
		battle_text.text = "공격이 빗나갔다."

	await get_tree().create_timer(1.0).timeout

	if enemy_hp <= 0:
		await win_battle()
		return

	start_enemy_turn()
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

		if check_attack_hit():
			player_attack_hit = true
			player_attack_hitbox_debug.visible = false

			var piercing = current_projectile_data.get("piercing", false)

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
func check_attack_hit():
	var attack_rect = get_player_attack_hit_rect()

	if not enemy_data.has("hitboxes"):
		return false

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
			last_hitbox_data = hitbox
			return true

	return false
# 히트 박스 확인용 함수
func update_hitbox_debug():
	for child in hitbox_debug_container.get_children():
		if child == player_attack_hitbox_debug:
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
