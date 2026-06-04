extends Control

# ============================================================
# PauseUIScene
# ------------------------------------------------------------
# 인게임 탐색 화면에서 ESC 입력 시 표시되는 일시정지 UI.
#
# 역할:
# - 게임 일시정지 상태에서 표시
# - 이어하기 버튼으로 일시정지 해제
# - ESC 재입력으로 일시정지 해제
# - 종료 버튼으로 메인 메뉴 이동
# - 설정 버튼은 추후 구현 예정
# ============================================================


# ------------------------------------------------------------
# 시그널
# ------------------------------------------------------------
# main.gd가 이 시그널을 받아 Pause UI를 닫는다.
signal resume_requested

# main.gd가 이 시그널을 받아 메인 메뉴로 이동한다.
signal quit_to_title_requested

# main.gd가 이 시그널을 받아 BGM 볼륨을 적용한다.
signal bgm_volume_changed(value)

# main.gd가 이 시그널을 받아 SFX 볼륨을 적용한다.
signal sfx_volume_changed(value)


# ------------------------------------------------------------
# 폰트 경로
# ------------------------------------------------------------
const TITLE_FONT_PATH = "res://fonts/SB 어그로 L.ttf"
const TEXT_FONT_PATH = "res://fonts/x12y12pxMaruMinyaHangul.ttf"


# ------------------------------------------------------------
# 색상 설정
# ------------------------------------------------------------
const DIM_BACKGROUND_COLOR = Color(0.0, 0.0, 0.0, 0.65)

const TITLE_COLOR = Color("#ffffff")
const TEXT_COLOR = Color("#ffffff")
const DISABLED_TEXT_COLOR = Color(0.45, 0.45, 0.45, 1.0)

const BUTTON_NORMAL_COLOR = Color(0.02, 0.02, 0.02, 0.72)
const BUTTON_HOVER_COLOR = Color(0.18, 0.18, 0.18, 0.82)
const BUTTON_PRESSED_COLOR = Color(0.35, 0.35, 0.35, 0.9)
const BUTTON_BORDER_COLOR = Color(0.75, 0.75, 0.75, 0.45)
const BUTTON_FOCUS_BORDER_COLOR = Color(1.0, 1.0, 1.0, 0.9)


# ------------------------------------------------------------
# UI 노드
# ------------------------------------------------------------
@onready var dim_background = $DimBackground
@onready var center_box = $CenterBox

@onready var title_label = $CenterBox/TitleLabel
@onready var setting_button = $CenterBox/SettingButton
@onready var resume_button = $CenterBox/ResumeButton
@onready var quit_button = $CenterBox/QuitButton

@onready var click_sound = $ClickSound

# 설정 패널
@onready var settings_panel = $SettingsPanel
@onready var settings_box = $SettingsPanel/SettingsBox

@onready var settings_title_label = $SettingsPanel/SettingsBox/SettingsTitleLabel
@onready var bgm_volume_label = $SettingsPanel/SettingsBox/BgmVolumeLabel
@onready var bgm_volume_slider = $SettingsPanel/SettingsBox/BgmVolumeSlider
@onready var sfx_volume_label = $SettingsPanel/SettingsBox/SfxVolumeLabel
@onready var sfx_volume_slider = $SettingsPanel/SettingsBox/SfxVolumeSlider
@onready var settings_reset_button = $SettingsPanel/SettingsBox/SettingsResetButton
@onready var settings_back_button = $SettingsPanel/SettingsBox/SettingsBackButton


# 처음 포커스가 잡힐 때 효과음이 바로 나는 것을 막기 위한 변수
var can_play_focus_sound = false


func _ready():
	# 일시정지 상태에서도 이 UI는 입력을 받아야 한다.
	process_mode = Node.PROCESS_MODE_ALWAYS

	setup_texts()
	apply_ui_style()
	connect_button_signals()

	# 설정 패널 초기화
	setup_settings_panel()

	# Pause UI 클릭 효과음에도 현재 SFX 설정 적용
	register_pause_sfx_base_volumes()
	apply_pause_sfx_volume()

	resume_button.grab_focus()

	await get_tree().process_frame
	can_play_focus_sound = true


# ------------------------------------------------------------
# UI 텍스트 설정
# ------------------------------------------------------------
func setup_texts():
	title_label.text = "일시정지"
	setting_button.text = "설정"
	resume_button.text = "이어하기"
	quit_button.text = "종료"
	
	settings_title_label.text = "설정"
	settings_reset_button.text = "초기화"
	settings_back_button.text = "뒤로"


# ------------------------------------------------------------
# UI 스타일 적용
# ------------------------------------------------------------
func apply_ui_style():
	dim_background.color = DIM_BACKGROUND_COLOR

	var title_font = load_font_or_null(TITLE_FONT_PATH)
	var text_font = load_font_or_null(TEXT_FONT_PATH)

	apply_label_style(title_label, title_font, 44, TITLE_COLOR)

	for button in get_all_buttons():
		apply_button_style(button, text_font)

# ------------------------------------------------------------
# 패널 스타일 적용
# ------------------------------------------------------------
func apply_panel_style(panel):
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.82)
	panel_style.border_color = Color(0.7, 0.7, 0.7, 0.35)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 24
	panel_style.content_margin_right = 24
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24

	panel.add_theme_stylebox_override("panel", panel_style)

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
# 버튼 배열 반환
# ------------------------------------------------------------
func get_all_buttons():
	return [
		setting_button,
		resume_button,
		quit_button,
		settings_reset_button,
		settings_back_button
	]


# ------------------------------------------------------------
# 버튼 시그널 연결
# ------------------------------------------------------------
func connect_button_signals():
	setting_button.pressed.connect(_on_setting_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	settings_back_button.pressed.connect(_on_settings_back_button_pressed)
	settings_reset_button.pressed.connect(_on_settings_reset_button_pressed)

	bgm_volume_slider.value_changed.connect(_on_bgm_volume_slider_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_changed)

	for button in get_all_buttons():
		button.mouse_entered.connect(_on_button_focused_or_hovered.bind(button))
		button.focus_entered.connect(_on_button_focused_or_hovered.bind(button))


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
func _on_setting_button_pressed():
	play_click_sound()
	open_settings_panel()


func _on_resume_button_pressed():
	play_click_sound()
	resume_requested.emit()


func _on_quit_button_pressed():
	play_click_sound()
	quit_to_title_requested.emit()


func _on_settings_back_button_pressed():
	play_click_sound()
	close_settings_panel()

func _on_bgm_volume_slider_changed(value):
	GameSession.set_bgm_volume_percent(value)
	update_bgm_volume_label()

	# main.gd에 BGM 볼륨 변경 요청
	bgm_volume_changed.emit(value)


func _on_sfx_volume_slider_changed(value):
	GameSession.set_sfx_volume_percent(value)
	update_sfx_volume_label()

	# Pause UI 자기 자신의 클릭 효과음에도 즉시 적용
	apply_pause_sfx_volume()

	# main.gd에도 SFX 볼륨 변경 요청
	sfx_volume_changed.emit(value)

# ------------------------------------------------------------
# ESC 입력 처리
# ------------------------------------------------------------
func _unhandled_input(event):
	if event.is_action_pressed("esc") or event.is_action_pressed("ui_cancel"):
		# 설정 패널이 열려 있으면 Pause UI를 닫지 않고 설정 패널만 닫는다.
		if settings_panel.visible:
			play_click_sound()
			close_settings_panel()
			return

		resume_requested.emit()
		
# ------------------------------------------------------------
# 설정 패널 초기화
# ------------------------------------------------------------
func setup_settings_panel():
	settings_panel.visible = false

	bgm_volume_slider.value = GameSession.bgm_volume_percent
	sfx_volume_slider.value = GameSession.sfx_volume_percent

	update_bgm_volume_label()
	update_sfx_volume_label()


# ------------------------------------------------------------
# 설정 패널 열기
# ------------------------------------------------------------
func open_settings_panel():
	center_box.visible = false
	settings_panel.visible = true

	bgm_volume_slider.grab_focus()


# ------------------------------------------------------------
# 설정 패널 닫기
# ------------------------------------------------------------
func close_settings_panel():
	settings_panel.visible = false
	center_box.visible = true

	setting_button.grab_focus()


# ------------------------------------------------------------
# BGM 볼륨 라벨 갱신
# ------------------------------------------------------------
func update_bgm_volume_label():
	bgm_volume_label.text = "BGM 볼륨 : " + str(int(bgm_volume_slider.value)) + "%"


# ------------------------------------------------------------
# SFX 볼륨 라벨 갱신
# ------------------------------------------------------------
func update_sfx_volume_label():
	sfx_volume_label.text = "SFX 볼륨 : " + str(int(sfx_volume_slider.value)) + "%"		

# ------------------------------------------------------------
# Pause UI 효과음 기본 볼륨 저장
# ------------------------------------------------------------
func register_pause_sfx_base_volumes():
	if click_sound == null:
		return

	if not click_sound.has_meta("base_volume_db"):
		click_sound.set_meta("base_volume_db", click_sound.volume_db)


# ------------------------------------------------------------
# Pause UI 효과음 볼륨 적용
# ------------------------------------------------------------
func apply_pause_sfx_volume():
	if click_sound == null:
		return

	var base_volume_db = 0.0

	if click_sound.has_meta("base_volume_db"):
		base_volume_db = float(click_sound.get_meta("base_volume_db"))
	else:
		base_volume_db = click_sound.volume_db
		click_sound.set_meta("base_volume_db", base_volume_db)

	click_sound.volume_db = base_volume_db + GameSession.get_sfx_volume_db()

func _on_settings_reset_button_pressed():
	play_click_sound()

	# GameSession의 오디오 설정을 기본값으로 초기화하고 settings.json에 저장한다.
	GameSession.reset_audio_settings()

	# 슬라이더 값을 초기화된 값으로 갱신한다.
	bgm_volume_slider.value = GameSession.bgm_volume_percent
	sfx_volume_slider.value = GameSession.sfx_volume_percent

	# 라벨 갱신
	update_bgm_volume_label()
	update_sfx_volume_label()

	# Pause UI 자기 자신의 클릭 효과음에도 즉시 반영
	apply_pause_sfx_volume()

	# main.gd에 BGM/SFX 볼륨 변경 요청
	bgm_volume_changed.emit(GameSession.bgm_volume_percent)
	sfx_volume_changed.emit(GameSession.sfx_volume_percent)

	print("Pause UI 설정 초기화 완료")
