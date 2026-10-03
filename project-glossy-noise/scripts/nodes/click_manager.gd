extends Camera3D

## ============================================
## CLICK MANAGER — Обработка кликов через RayCast
## Вешается на Camera3D в сцене workbench_v2
## ============================================

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Проверяем, открыта ли ОС
		var root_scene = get_tree().current_scene
		var os_panel = null
		if root_scene:
			os_panel = root_scene.get_node_or_null("OSPanel")
		
		if os_panel and os_panel.visible:
			# ОС открыта — проверяем, не кликнул ли игрок по ПК (чтобы закрыть)
			var space_os = get_world_3d().direct_space_state
			var from_os = project_ray_origin(event.position)
			var to_os = from_os + project_ray_normal(event.position) * 100.0
			var query_os = PhysicsRayQueryParameters3D.create(from_os, to_os)
			query_os.collide_with_areas = true
			query_os.collide_with_bodies = true
			var result_os = space_os.intersect_ray(query_os)
			
			if not result_os.is_empty():
				var target_os = _get_mesh_parent(result_os.collider)
				if target_os and target_os.name == "PCMesh":
					print("🖥️ Закрытие ОС")
					var pc = get_node_or_null("../PC")
					if pc and pc.has_method("open_os"):
						pc.open_os()
					return
			
			# Клик не по ПК — игнорируем
			return
		
		print("🖱️ Клик пойман!")
		
		var space = get_world_3d().direct_space_state
		var from = project_ray_origin(event.position)
		var to = from + project_ray_normal(event.position) * 100.0
		
		# Собираем все объекты под курсором (максимум 5)
		var results = []
		var current_from = from
		var exclude_list = []
		
		for i in range(5):
			var query = PhysicsRayQueryParameters3D.create(current_from, to)
			query.collide_with_areas = true
			query.collide_with_bodies = true
			query.collision_mask = 0xFFFFFFFF
			query.exclude = exclude_list
			
			var r = space.intersect_ray(query)
			if r.is_empty():
				break
			
			results.append(r)
			exclude_list.append(r.collider)
			current_from = r.position + (to - from).normalized() * 0.01
		
		if results.is_empty():
			print("❌ Луч никуда не попал!")
			return
		
		# Получаем Device
		var device = get_node("../Device")
		if not device:
			print("⚠️ Device не найден!")
			return
		
		# ============================================
		# ПРИОРИТЕТ: Винты → Гнездо → Крышка → ПК → Труба
		# ============================================
		
		# 1. ВИНТЫ
		for r in results:
			var target = _get_mesh_parent(r.collider)
			if target:
				for i in range(4):
					if target.name == "Screw" + str(i + 1):
						print("🔩 Винт #", i + 1)
						device.click_screw(i)
						return
		
		# 2. ГНЕЗДО
		for r in results:
			if r.collider.name == "SocketBody":
				print("🔋 Гнездо (по коллайдеру)")
				device.click_socket()
				return
			var target = _get_mesh_parent(r.collider)
			if target and target.name == "BatterySocket":
				print("🔋 Гнездо (по имени меша)")
				device.click_socket()
				return
		
		# 3. КРЫШКА
		for r in results:
			var target = _get_mesh_parent(r.collider)
			if target and target.name == "Cover":
				print("📦 Крышка")
				device.click_cover()
				return
		
		# 4. КОМПЬЮТЕР (CRT-монитор)
		for r in results:
			var target = _get_mesh_parent(r.collider)
			if target and target.name == "PCMesh":
				print("🖥️ Клик по компьютеру")
				var pc = get_node_or_null("../PC")
				if pc and pc.has_method("open_os"):
					pc.open_os()
				return
		
		# 5. ТРУБА
		for r in results:
			var target = _get_mesh_parent(r.collider)
			if target:
				var parent = target.get_parent()
				if parent and parent.name == "PneumoTube":
					print("📤 Труба")
					device.click_tube()
					return
		
		print("🔍 Неопознанный объект")

# ============================================
# ПОИСК MeshInstance3D (учитываем братьев StaticBody3D)
# ============================================

func _get_mesh_parent(node: Node):
	var current_node = node
	while current_node:
		if current_node is MeshInstance3D:
			return current_node
		
		if current_node is StaticBody3D:
			var parent_node = current_node.get_parent()
			if parent_node:
				for sibling in parent_node.get_children():
					if sibling is MeshInstance3D:
						return sibling
		
		current_node = current_node.get_parent()
	return null
