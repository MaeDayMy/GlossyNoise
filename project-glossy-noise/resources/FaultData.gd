extends Resource
class_name FaultData

## ============================================
## FAULT DATA — Ресурс для описания поломки
## ============================================

@export var fault_id: String = ""              # Уникальный ключ, напр. "dead_battery"
@export var fault_name: String = ""            # Название для UI
@export var required_tool: String = ""         # Какой инструмент нужен ("screwdriver", "soldering_iron")
@export var repair_steps: Array[String] = []   # Шаги ремонта: ["open_cover", "replace_battery"]
@export var penalty_for_ignore: int = 0        # Штраф (стресс), если проигнорировать
@export var stress_on_error: int = 5           # Стресс при ошибке в ремонте
