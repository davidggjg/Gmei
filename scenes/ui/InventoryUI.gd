extends Control
class_name InventoryUI

@onready var title_label: Label = $Panel/VBox/Title
@onready var list: VBoxContainer = $Panel/VBox/ScrollContainer/List
@onready var empty_label: Label = $Panel/VBox/EmptyLabel
@onready var close_button: Button = $Panel/VBox/CloseButton

var player: Player

func _ready() -> void:
	Loc.apply_rtl(self)
	title_label.text = Loc.t("INVENTORY_TITLE")
	empty_label.text = Loc.t("INVENTORY_EMPTY")
	close_button.text = Loc.t("MENU_BACK")
	close_button.pressed.connect(_close)
	visible = false

func bind_player(p: Player) -> void:
	player = p
	player.inventory.inventory_changed.connect(_refresh)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = not visible
		if visible:
			_refresh()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("pause"):
		_close()

func _close() -> void:
	visible = false

func _refresh() -> void:
	for child in list.get_children():
		child.queue_free()
	if player == null:
		return
	var ids := player.inventory.stacks.keys()
	empty_label.visible = ids.is_empty()
	for item_id in ids:
		var item: Item = ItemDB.get_item(item_id)
		if item == null:
			continue
		list.add_child(_build_row(item, player.inventory.stacks[item_id]))

func _build_row(item: Item, count: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(28, 28)
	swatch.color = item.icon_color
	row.add_child(swatch)

	var label := Label.new()
	label.text = "%s x%d" % [Loc.t(item.name_key), count]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	if item.item_type == Item.ItemType.HEALING:
		var use_btn := Button.new()
		use_btn.text = Loc.t("INVENTORY_USE")
		use_btn.pressed.connect(func():
			player.inventory.use_healing_item(item.id, player.health)
		)
		row.add_child(use_btn)
	elif item.item_type == Item.ItemType.WEAPON:
		var equip_btn := Button.new()
		equip_btn.text = Loc.t("INVENTORY_EQUIP")
		equip_btn.disabled = player.inventory.equipped_weapon_id == item.id
		equip_btn.pressed.connect(func():
			player.inventory.equip_weapon(item.id)
			_refresh()
		)
		row.add_child(equip_btn)

	return row
