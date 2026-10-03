extends Node

## ============================================
## RESOURCE MANAGER — Autoload для загрузки всех ресурсов
## ============================================

var devices: Dictionary = {}    # device_id -> DeviceData
var faults: Dictionary = {}     # fault_id -> FaultData
var dialogues: Dictionary = {}  # dialogue_id -> GlitchieDialogue

func _ready():
	_load_all_resources("res://resources/devices/", devices)
	_load_all_resources("res://resources/faults/", faults)
	_load_all_resources("res://resources/dialogues/", dialogues)
	
	print("📦 ResourceManager: загружено девайсов: ", devices.size())
	print("📦 ResourceManager: загружено поломок: ", faults.size())
	print("📦 ResourceManager: загружено диалогов: ", dialogues.size())

# ============================================
# ЗАГРУЗКА
# ============================================

func _load_all_resources(path: String, target: Dictionary):
	var dir = DirAccess.open(path)
	if not dir:
		print("⚠️ ResourceManager: папка не найдена: ", path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path = path + file_name
			var res = load(full_path)
			if res:
				# Определяем ключ по типу ресурса
				var key = ""
				if res is DeviceData:
					key = res.device_id
				elif res is FaultData:
					key = res.fault_id
				elif res is GlitchieDialogue:
					key = res.dialogue_id
				
				if key != "":
					target[key] = res
					print("✅ Загружен: ", key, " (", file_name, ")")
				else:
					print("⚠️ Пустой ID в: ", file_name)
			else:
				print("❌ Не удалось загрузить: ", full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

# ============================================
# ПОЛУЧЕНИЕ РЕСУРСОВ
# ============================================

func get_device(device_id: String) -> DeviceData:
	if devices.has(device_id):
		return devices[device_id]
	print("⚠️ Девайс не найден: ", device_id)
	return null

func get_fault(fault_id: String) -> FaultData:
	if faults.has(fault_id):
		return faults[fault_id]
	print("⚠️ Поломка не найдена: ", fault_id)
	return null

func get_dialogue(dialogue_id: String) -> GlitchieDialogue:
	if dialogues.has(dialogue_id):
		return dialogues[dialogue_id]
	print("⚠️ Диалог не найден: ", dialogue_id)
	return null

# ============================================
# СПИСКИ
# ============================================

func get_all_device_ids() -> Array:
	return devices.keys()

func get_random_device() -> DeviceData:
	if devices.is_empty():
		return null
	var keys = devices.keys()
	return devices[keys[randi() % keys.size()]]
