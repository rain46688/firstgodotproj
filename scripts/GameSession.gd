extends Node

# 시작 모드
const START_MODE_NEW = "new"
const START_MODE_LOAD = "load"

# 난이도 ID
const DIFFICULTY_NORMAL = "normal"
const DIFFICULTY_HARD = "hard"
const DIFFICULTY_NIGHTMARE = "nightmare"
const DIFFICULTY_HARDCORE = "hardcore"

# 현재 게임 시작 정보
var start_mode = START_MODE_NEW
var difficulty = DIFFICULTY_NORMAL
var save_slot_index = 1

# ------------------------------------------------------------
# 오디오 설정
# ------------------------------------------------------------
# 0 ~ 100 기준
var bgm_volume_percent = 100
var sfx_volume_percent = 100

# ------------------------------------------------------------
# 설정 저장 경로
# ------------------------------------------------------------
const SETTINGS_SAVE_PATH = "user://settings.json"

# GameSession이 AutoLoad로 시작될 때 설정값을 불러온다.
func _ready():
	load_audio_settings()

# 새 게임 시작 정보 설정
func setup_new_game(selected_difficulty):
	start_mode = START_MODE_NEW
	difficulty = selected_difficulty
	save_slot_index = 1

	print("새 게임 설정")
	print("난이도: " + str(difficulty))

# 이어하기 시작 정보 설정
func setup_load_game(slot_index = 1):
	start_mode = START_MODE_LOAD
	save_slot_index = slot_index

	print("이어하기 설정")
	print("세이브 슬롯: " + str(save_slot_index))

# 하드코어 모드 여부
func is_hardcore_mode():
	return difficulty == DIFFICULTY_HARDCORE

# 현재 세이브 파일 경로
func get_save_path(slot_index = save_slot_index):
	return "user://save_slot_" + str(slot_index) + ".json"

# 현재 슬롯에 세이브 파일이 있는지 확인
func has_save_file(slot_index = save_slot_index):
	return FileAccess.file_exists(get_save_path(slot_index))

# 현재 세이브 파일 이름 반환
func get_save_file_name(slot_index = save_slot_index):
	return "save_slot_" + str(slot_index) + ".json"

# 현재 슬롯의 세이브 파일 삭제
func delete_save_file(slot_index = save_slot_index):
	var file_name = get_save_file_name(slot_index)
	var path = "user://" + file_name

	if not FileAccess.file_exists(path):
		print("삭제할 세이브 파일 없음: " + path)
		return true

	var dir = DirAccess.open("user://")

	if dir == null:
		push_error("user:// 경로 열기 실패")
		return false

	var error = dir.remove(file_name)

	if error != OK:
		push_error("세이브 파일 삭제 실패: " + path + " / error: " + str(error))
		return false

	print("세이브 파일 삭제 완료: " + path)
	return true

# 난이도 이름 반환
func get_difficulty_name():
	if difficulty == DIFFICULTY_NORMAL:
		return "일반"
	elif difficulty == DIFFICULTY_HARD:
		return "어려움"
	elif difficulty == DIFFICULTY_NIGHTMARE:
		return "악몽"
	elif difficulty == DIFFICULTY_HARDCORE:
		return "하드코어"

	return "알 수 없음"

# 난이도별 적 체력 배율
func get_enemy_hp_multiplier():
	if difficulty == DIFFICULTY_HARD:
		return 1.5
	elif difficulty == DIFFICULTY_NIGHTMARE:
		return 2.0
	elif difficulty == DIFFICULTY_HARDCORE:
		return 2.0

	return 1.0

# 난이도별 빨간 탄막 강제 여부
func should_force_red_projectiles():
	return difficulty == DIFFICULTY_NIGHTMARE or difficulty == DIFFICULTY_HARDCORE

# BGM 볼륨 설정
func set_bgm_volume_percent(value):
	bgm_volume_percent = clamp(int(value), 0, 100)
	print("BGM 볼륨 설정: " + str(bgm_volume_percent))

	# 설정값 변경 즉시 저장
	save_audio_settings()

# SFX 볼륨 설정
func set_sfx_volume_percent(value):
	sfx_volume_percent = clamp(int(value), 0, 100)
	print("SFX 볼륨 설정: " + str(sfx_volume_percent))

	# 설정값 변경 즉시 저장
	save_audio_settings()

# 0~100 값을 오디오 배율 0.0~1.0으로 변환
func get_bgm_volume_linear():
	return float(bgm_volume_percent) / 100.0

func get_sfx_volume_linear():
	return float(sfx_volume_percent) / 100.0

# 볼륨 퍼센트를 dB로 변환
func percent_to_db(percent):
	var linear = float(percent) / 100.0

	if linear <= 0.0:
		return -80.0

	return linear_to_db(linear)

func get_bgm_volume_db():
	return percent_to_db(bgm_volume_percent)

func get_sfx_volume_db():
	return percent_to_db(sfx_volume_percent)

# ------------------------------------------------------------
# 오디오 설정 저장/로드
# ------------------------------------------------------------

# 현재 오디오 설정 Dictionary 생성
func get_audio_settings_data():
	return {
		"bgm_volume_percent": bgm_volume_percent,
		"sfx_volume_percent": sfx_volume_percent
	}

# 오디오 설정 저장
func save_audio_settings():
	var settings_data = get_audio_settings_data()
	var json_text = JSON.stringify(settings_data, "\t")

	var file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("설정 파일 저장 실패: " + SETTINGS_SAVE_PATH)
		return false

	file.store_string(json_text)
	file.close()

	print("설정 저장 완료: " + SETTINGS_SAVE_PATH)
	return true

# 오디오 설정 불러오기
func load_audio_settings():
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		print("설정 파일 없음. 기본 설정 사용.")
		return false

	var file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("설정 파일 열기 실패: " + SETTINGS_SAVE_PATH)
		return false

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)

	if error != OK:
		push_error("설정 파일 파싱 실패: " + json.get_error_message())
		return false

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("설정 파일 구조가 Dictionary가 아님")
		return false

	var settings_data = json.data

	bgm_volume_percent = clamp(int(settings_data.get("bgm_volume_percent", 100)), 0, 100)
	sfx_volume_percent = clamp(int(settings_data.get("sfx_volume_percent", 100)), 0, 100)

	print("설정 불러오기 완료")
	print("BGM: " + str(bgm_volume_percent) + "%")
	print("SFX: " + str(sfx_volume_percent) + "%")

	return true

# 오디오 설정 초기화
func reset_audio_settings():
	bgm_volume_percent = 100
	sfx_volume_percent = 100

	save_audio_settings()

	print("오디오 설정 초기화")
