extends Node

## ============================================
## AUDIO MANAGER — Управление звуками и радио
## ============================================

# ------ СИГНАЛЫ ------
signal radio_wave_changed(wave_index: int, wave_name: String)

# ------ НАСТРОЙКИ РАДИО ------
const RADIO_WAVES = {
	0: { "name": "FM 101.5 — Волна Уюта", "path": "res://assets/audio/radio/wave_1.ogg" },
	1: { "name": "FM 88.2 — Странный Шёпот", "path": "res://assets/audio/radio/wave_2.ogg" },
	2: { "name": "AM 720 — Ностальгия", "path": "res://assets/audio/radio/wave_3.ogg" },
	3: { "name": "FM 99.9 — Помехи", "path": "res://assets/audio/radio/wave_4.ogg" },
}

# ------ ПЕРЕМЕННЫЕ ------
var radio_player: AudioStreamPlayer
var radio_is_on: bool = false
var current_wave: int = 0

var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	# Создаём плееры
	radio_player = AudioStreamPlayer.new()
	radio_player.bus = "Master"
	add_child(radio_player)
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)
	
	# Загружаем заглушку (тишину)
	var dummy = AudioStreamWAV.new()
	radio_player.stream = dummy
	
	print("🎵 AudioManager инициализирован")

# ============================================
# ПУБЛИЧНЫЕ МЕТОДЫ (для вызова из GameManager)
# ============================================

func toggle_radio():
	radio_is_on = !radio_is_on
	if radio_is_on:
		radio_player.play()
		print("📻 Радио включено")
	else:
		radio_player.stop()
		print("📻 Радио выключено")

func switch_wave(wave_index: int):
	if wave_index < 0 or wave_index >= RADIO_WAVES.size():
		return
	
	current_wave = wave_index
	var wave_data = RADIO_WAVES[wave_index]
	
	if ResourceLoader.exists(wave_data.path):
		var stream = load(wave_data.path)
		if stream:
			radio_player.stream = stream
			if radio_is_on:
				radio_player.play()
			
			emit_signal("radio_wave_changed", wave_index, wave_data.name)
			print("📻 Смена волны: ", wave_data.name)
	else:
		print("❌ Аудиофайл не найден: ", wave_data.path)

func get_current_wave_name() -> String:
	return RADIO_WAVES[current_wave].name

# ============================================
# ФОНОВЫЕ ЗВУКИ
# ============================================

func play_ambient(stream_path: String, _loop: bool = true):
	if ResourceLoader.exists(stream_path):
		var stream = load(stream_path)
		if stream:
			ambient_player.stream = stream
			ambient_player.playing = true
			print("🔊 Ambient включен: ", stream_path)
	else:
		print("❌ Ambient файл не найден: ", stream_path)

func stop_ambient():
	ambient_player.stop()

# ============================================
# ЗВУКОВЫЕ ЭФФЕКТЫ (SFX)
# ============================================

func play_sfx(stream_path: String, volume_db: float = 0.0):
	if ResourceLoader.exists(stream_path):
		var stream = load(stream_path)
		if stream:
			sfx_player.stream = stream
			sfx_player.volume_db = volume_db
			sfx_player.play()
			print("🔊 SFX воспроизведён: ", stream_path)
	else:
		print("❌ SFX файл не найден: ", stream_path)

func play_sfx_from_stream(stream: AudioStream, volume_db: float = 0.0):
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = volume_db
		sfx_player.play()

# ============================================
# УПРАВЛЕНИЕ ГРОМКОСТЬЮ
# ============================================

func set_radio_volume(db: float):
	radio_player.volume_db = db

func set_ambient_volume(db: float):
	ambient_player.volume_db = db

func set_sfx_volume(db: float):
	sfx_player.volume_db = db
