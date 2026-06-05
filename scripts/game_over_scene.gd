extends Control

# ============================================================
# GameOverScene
# ------------------------------------------------------------
# 플레이어 사망 시 보여줄 게임오버 화면.
#
# 역할:
# - YOU DIED 표시
# - 이어하기 버튼 처리
# - 하드코어 모드일 경우 이어하기 비활성화
# - 세이브 파일이 없을 경우 이어하기 비활성화
# - 종료 버튼 클릭 시 메인 메뉴로 이동
#
# 현재 단계에서는 battle_scene.gd와 직접 연결하지 않고,
# 씬 단독 실행 테스트만 한다.
# ============================================================

# ------------------------------------------------------------
# 씬 경로
# ------------------------------------------------------------
# 기존 실제 게임 플레이 씬 경로.
# 프로젝트의 main.tscn 위치가 다르면 여기만 수정하면 된다.
const MAIN_SCENE_PATH = "res://scenes/main.tscn"

# 메인 메뉴 씬 경로.
const MAIN_MENU_SCENE_PATH = "res://scenes/main_menu_scene.tscn"

# ------------------------------------------------------------
# 폰트 경로
# ------------------------------------------------------------
const TITLE_FONT_PATH = "res://fonts/SB 어그로 L.ttf"
const TEXT_FONT_PATH = "res://fonts/x12y12pxMaruMinyaHangul.ttf"

# ------------------------------------------------------------
# 색상 설정
# ------------------------------------------------------------
const BACKGROUND_COLOR = Color("#000000")

const TITLE_COLOR = Color(0.9, 0.0, 0.0, 1.0)
const TEXT_COLOR = Color("#ffffff")
const DISABLED_TEXT_COLOR = Color(0.45, 0.45, 0.45, 1.0)

const BUTTON_NORMAL_COLOR = Color(0.02, 0.02, 0.02, 0.65)
const BUTTON_HOVER_COLOR = Color(0.18, 0.18, 0.18, 0.75)
const BUTTON_PRESSED_COLOR = Color(0.35, 0.35, 0.35, 0.85)
const BUTTON_DISABLED_COLOR = Color(0.02, 0.02, 0.02, 0.35)

const BUTTON_BORDER_COLOR = Color(0.75, 0.75, 0.75, 0.45)
const BUTTON_FOCUS_BORDER_COLOR = Color(1.0, 1.0, 1.0, 0.9)

# ------------------------------------------------------------
# UI 노드
# ------------------------------------------------------------
@onready var background = $Background
@onready var center_box = $CenterBox

@onready var title_label = $CenterBox/TitleLabel
@onready var message_label = $CenterBox/MessageLabel

@onready var continue_button = $CenterBox/ContinueButton
@onready var quit_button = $CenterBox/QuitButton

@onready var click_sound = $ClickSound
@onready var game_over_bgm = $GameOverBgm

# 포커스가 처음 잡힐 때 효과음이 바로 재생되는 것을 막기 위한 변수
var can_play_focus_sound = false

func _ready():
	# UI 텍스트 설정
	setup_texts()

	# UI 스타일 적용
	apply_ui_style()

	# 이어하기 버튼 활성/비활성 갱신
	update_continue_button_state()

	# 버튼 시그널 연결
	connect_button_signals()
	
	# 현재 저장된 오디오 설정 적용
	apply_game_over_audio_settings()

	# 게임오버 BGM 재생
	play_game_over_bgm()

	# 키보드 조작을 위해 사용 가능한 버튼에 포커스 부여
	grab_first_available_focus()

	# 첫 프레임 이후부터 포커스 이동 효과음을 허용
	await get_tree().process_frame
	can_play_focus_sound = true

# ------------------------------------------------------------
# UI 텍스트 설정
# ------------------------------------------------------------
func setup_texts():
	title_label.text = "YOU DIED"
	message_label.text = "당신은 쓰러졌다."

	continue_button.text = "이어하기"
	quit_button.text = "종료"

# ------------------------------------------------------------
# UI 스타일 적용
# ------------------------------------------------------------
func apply_ui_style():
	background.color = BACKGROUND_COLOR

	var title_font = load_font_or_null(TITLE_FONT_PATH)
	var text_font = load_font_or_null(TEXT_FONT_PATH)

	apply_label_style(title_label, title_font, 72, TITLE_COLOR)
	apply_label_style(message_label, text_font, 24, TEXT_COLOR)

	for button in get_all_buttons():
		apply_button_style(button, text_font)

# ------------------------------------------------------------
# 폰트 로드
# ------------------------------------------------------------
func load_font_or_null(font_path):
	if ResourceLoader.exists(font_path):
		return load(font_path)

	print("폰트 파일을 찾을 수 없음: " + font_path)
	return null

# ------------------------------------------------------------
# 라벨 스타일 적용
# ------------------------------------------------------------
func apply_label_style(label, font, font_size, font_color):
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_font_size_override("font_size", font_size)

	if font != null:
		label.add_theme_font_override("font", font)

# ------------------------------------------------------------
# 버튼 스타일 적용
# ------------------------------------------------------------
func apply_button_style(button, font):
	button.custom_minimum_size = Vector2(420, 52)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

	button.add_theme_font_size_override("font_size", 24)

	if font != null:
		button.add_theme_font_override("font", font)

	button.add_theme_color_override("font_color", TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", TEXT_COLOR)
	button.add_theme_color_override("font_focus_color", TEXT_COLOR)
	button.add_theme_color_override("font_disabled_color", DISABLED_TEXT_COLOR)

	button.add_theme_stylebox_override("normal", make_button_style(BUTTON_NORMAL_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("hover", make_button_style(BUTTON_HOVER_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("pressed", make_button_style(BUTTON_PRESSED_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("disabled", make_button_style(BUTTON_DISABLED_COLOR, BUTTON_BORDER_COLOR))
	button.add_theme_stylebox_override("focus", make_button_style(Color(0, 0, 0, 0), BUTTON_FOCUS_BORDER_COLOR))

# ------------------------------------------------------------
# 버튼 StyleBox 생성
# ------------------------------------------------------------
func make_button_style(bg_color, border_color):
	var style = StyleBoxFlat.new()

	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)

	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	return style

# ------------------------------------------------------------
# 모든 버튼 반환
# ------------------------------------------------------------
func get_all_buttons():
	return [
		continue_button,
		quit_button
	]

# ------------------------------------------------------------
# 버튼 시그널 연결
# ------------------------------------------------------------
func connect_button_signals():
	continue_button.pressed.connect(_on_continue_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	for button in get_all_buttons():
		button.mouse_entered.connect(_on_button_focused_or_hovered.bind(button))
		button.focus_entered.connect(_on_button_focused_or_hovered.bind(button))

# ------------------------------------------------------------
# 이어하기 버튼 상태 갱신
# ------------------------------------------------------------
func update_continue_button_state():
	var has_save = GameSession.has_save_file(1)
	var is_hardcore = GameSession.is_hardcore_mode()

	# 하드코어 모드이거나 세이브 파일이 없으면 이어하기 비활성화
	continue_button.disabled = is_hardcore or not has_save

	if is_hardcore:
		continue_button.text = "이어하기 - 하드코어 불가"
		message_label.text = "하드코어 모드에서는 죽음이 되돌릴 수 없습니다."
	elif not has_save:
		continue_button.text = "이어하기 - 세이브 없음"
		message_label.text = "불러올 세이브 파일이 없습니다."
	else:
		continue_button.text = "이어하기"
		message_label.text = "최근 저장 지점부터 다시 시작합니다."

# ------------------------------------------------------------
# 첫 포커스 설정
# ------------------------------------------------------------
func grab_first_available_focus():
	if not continue_button.disabled:
		continue_button.grab_focus()
	else:
		quit_button.grab_focus()

# ------------------------------------------------------------
# 게임오버 BGM 재생
# ------------------------------------------------------------
func play_game_over_bgm():
	if game_over_bgm == null:
		return

	if game_over_bgm.stream == null:
		return

	game_over_bgm.play()

# ------------------------------------------------------------
# 버튼 이동/마우스 올림 사운드
# ------------------------------------------------------------
func _on_button_focused_or_hovered(button):
	if not can_play_focus_sound:
		return

	if button.disabled:
		return

	play_click_sound()

# ------------------------------------------------------------
# 클릭 사운드 재생
# ------------------------------------------------------------
func play_click_sound():
	if click_sound == null:
		return

	if click_sound.stream == null:
		return

	click_sound.stop()
	click_sound.play()

# ------------------------------------------------------------
# 버튼 이벤트
# ------------------------------------------------------------
func _on_continue_button_pressed():
	play_click_sound()

	if continue_button.disabled:
		return

	# 이어하기 모드로 설정 후 기존 게임 플레이 씬으로 이동
	GameSession.setup_load_game(1)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_quit_button_pressed():
	play_click_sound()

	# 메인 메뉴로 이동
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

# ------------------------------------------------------------
# 게임오버 화면 오디오 기본 볼륨 저장
# ------------------------------------------------------------
func register_game_over_audio_base_volumes():
	if click_sound != null:
		if not click_sound.has_meta("base_volume_db"):
			click_sound.set_meta("base_volume_db", click_sound.volume_db)

	if game_over_bgm != null:
		if not game_over_bgm.has_meta("base_volume_db"):
			game_over_bgm.set_meta("base_volume_db", game_over_bgm.volume_db)

# ------------------------------------------------------------
# 게임오버 화면 SFX 볼륨 적용
# ------------------------------------------------------------
func apply_game_over_sfx_volume():
	if click_sound == null:
		return

	var base_volume_db = 0.0

	if click_sound.has_meta("base_volume_db"):
		base_volume_db = float(click_sound.get_meta("base_volume_db"))
	else:
		base_volume_db = click_sound.volume_db
		click_sound.set_meta("base_volume_db", base_volume_db)

	click_sound.volume_db = base_volume_db + GameSession.get_sfx_volume_db()

# ------------------------------------------------------------
# 게임오버 화면 BGM 볼륨 적용
# ------------------------------------------------------------
func apply_game_over_bgm_volume():
	if game_over_bgm == null:
		return

	var base_volume_db = 0.0

	if game_over_bgm.has_meta("base_volume_db"):
		base_volume_db = float(game_over_bgm.get_meta("base_volume_db"))
	else:
		base_volume_db = game_over_bgm.volume_db
		game_over_bgm.set_meta("base_volume_db", base_volume_db)

	game_over_bgm.volume_db = base_volume_db + GameSession.get_bgm_volume_db()

# ------------------------------------------------------------
# 게임오버 화면 전체 오디오 설정 적용
# ------------------------------------------------------------
func apply_game_over_audio_settings():
	register_game_over_audio_base_volumes()
	apply_game_over_sfx_volume()
	apply_game_over_bgm_volume()
