extends Node3D

## ============================================
## MONEY DISPLAY — Отображение баланса на часах
## Вешается на узел MoneyDisplay в workbench_v2.tscn
## ============================================

@onready var balance_label: Label3D = $BalanceLabel
@onready var clock_mesh: MeshInstance3D = $ClockMesh

var current_balance: int = 0

# ============================================
# ИНИЦИАЛИЗАЦИЯ
# ============================================

func _ready():
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.money_changed.connect(_on_money_changed)
		# Инициализируем текущий баланс
		_on_money_changed(gm.money)
		print("✅ MoneyDisplay подключен к GameManager.money_changed")
	else:
		print("⚠️ GameManager не найден!")

# ============================================
# ОБНОВЛЕНИЕ БАЛАНСА
# ============================================

func _on_money_changed(new_amount: int):
	var difference = new_amount - current_balance
	current_balance = new_amount
	
	# Обновляем текст
	if balance_label:
		balance_label.text = "$" + str(new_amount)
	
	# Если деньги прибавились — анимация
	if difference > 0:
		_animate_gain(difference)
	
	print("💰 Баланс обновлён: $", new_amount, " (", "+" if difference >= 0 else "", difference, ")")

# ============================================
# АНИМАЦИЯ ПРИБАВЛЕНИЯ
# ============================================

func _animate_gain(amount: int):
	if not balance_label:
		return
	
	# Мигаем жёлтым и пульсируем
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Цвет: жёлтый → белый (возврат)
	balance_label.modulate = Color(1, 1, 0)
	tween.tween_property(balance_label, "modulate", Color(1, 0.9, 0.2), 0.6)
	
	# Масштаб: чуть больше → норма
	balance_label.scale = Vector3(1.2, 1.2, 1.2)
	tween.tween_property(balance_label, "scale", Vector3(1, 1, 1), 0.4)
	
	print("✨ Анимация +$", amount, " запущена!")
