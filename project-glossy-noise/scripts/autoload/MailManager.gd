extends Node

## ============================================
## MAIL MANAGER — Управление почтой
## Autoload
## ============================================

var mails: Dictionary = {}       # mail_id -> MailData
var selected_mail: MailData = null

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	_load_mails("res://resources/mails/")
	print("📬 MailManager: загружено писем: ", mails.size())

func _load_mails(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		print("⚠️ MailManager: папка не найдена: ", path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res = load(path + file_name)
			if res and res is MailData:
				mails[res.mail_id] = res
				print("✅ Загружено письмо: ", res.subject)
		file_name = dir.get_next()
	dir.list_dir_end()

# ============================================
# ПОЛУЧЕНИЕ ПИСЕМ
# ============================================

func get_all_mails() -> Array:
	return mails.values()

func select_mail(mail_id: String):
	if mails.has(mail_id):
		selected_mail = mails[mail_id]
		print("📬 Выбрано письмо: ", selected_mail.subject)

# ============================================
# ПРИНЯТИЕ ЗАКАЗА
# ============================================

func accept_order():
	if not selected_mail:
		print("⚠️ Письмо не выбрано!")
		return
	
	# Пасхальные письма (reward = 0, device_id = "") — заказ НЕ дают
	if selected_mail.reward <= 0 or selected_mail.device_id == "":
		print("📬 Пасхальное письмо — заказ не принят.")
		selected_mail = null
		return
	
	# Отправляем данные в GameManager
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.start_new_order({
			"name": selected_mail.device_id,
			"reward": selected_mail.reward
		})
		print("✅ Заказ принят: ", selected_mail.subject)
		selected_mail = null
