@tool
extends MultiMeshInstance3D

## Keep the populated grass intact so moving a box can restore removed blades.
@export var source_multimesh: MultiMesh
## World-space padding around each box, allowing room for blades and wind.
@export_range(0.0, 2.0, 0.05) var exclusion_margin: float = 0.25
@export_tool_button("Rebuild Grass") var rebuild_button: Callable = rebuild_grass

var _last_layout: Array = []
var _poll_time: float = 0.0


func _ready() -> void:
	if source_multimesh == null:
		source_multimesh = multimesh
	rebuild_grass()
	set_process(Engine.is_editor_hint())


func _process(delta: float) -> void:
	_poll_time += delta
	if _poll_time < 0.2:
		return
	_poll_time = 0.0
	var layout := _get_layout()
	if layout != _last_layout:
		rebuild_grass()


func _get_exclusion_boxes() -> Array[MeshInstance3D]:
	var boxes: Array[MeshInstance3D] = []
	if get_parent() == null:
		return boxes
	for node in get_parent().find_children("*", "MeshInstance3D", true, false):
		if node.mesh is BoxMesh and (
			str(node.name).to_lower().begins_with("exclusionarea")
			or node.is_in_group("grass_exclusion")
		):
			boxes.append(node)
	return boxes


func _get_layout() -> Array:
	var layout: Array = [global_transform, exclusion_margin, source_multimesh]
	if source_multimesh != null:
		layout.append(source_multimesh.instance_count)
	for box in _get_exclusion_boxes():
		layout.append(box.get_instance_id())
		layout.append(box.global_transform)
		layout.append(box.mesh.get_aabb())
	return layout


func rebuild_grass() -> void:
	if not is_inside_tree() or source_multimesh == null:
		return
	if source_multimesh.transform_format != MultiMesh.TRANSFORM_3D:
		push_warning("Grass exclusions require a 3D MultiMesh.")
		return

	var regions: Array = []
	for box in _get_exclusion_boxes():
		if not Engine.is_editor_hint():
			box.hide()
		var box_transform := box.global_transform
		if is_zero_approx(box_transform.basis.determinant()):
			continue
		var bounds := box.mesh.get_aabb()
		var padding := Vector3(
			exclusion_margin / box_transform.basis.x.length(),
			0.0,
			exclusion_margin / box_transform.basis.z.length()
		)
		regions.append({
			"inverse": box_transform.affine_inverse(),
			"minimum": bounds.position - padding,
			"maximum": bounds.end + padding,
		})

	# Configure the buffer layout before allocating instances. Resource.duplicate()
	# can apply MultiMesh properties in the wrong order when custom data is enabled.
	var result := MultiMesh.new()
	result.transform_format = source_multimesh.transform_format
	result.use_colors = source_multimesh.use_colors
	result.use_custom_data = source_multimesh.use_custom_data
	result.mesh = source_multimesh.mesh
	result.custom_aabb = source_multimesh.custom_aabb
	result.instance_count = source_multimesh.instance_count
	var kept := 0
	for index in source_multimesh.instance_count:
		var blade_transform := source_multimesh.get_instance_transform(index)
		var blade_position := global_transform * blade_transform.origin
		if _is_excluded(blade_position, regions):
			continue
		result.set_instance_transform(kept, blade_transform)
		if result.use_colors:
			result.set_instance_color(kept, source_multimesh.get_instance_color(index))
		if result.use_custom_data:
			result.set_instance_custom_data(kept, source_multimesh.get_instance_custom_data(index))
		kept += 1
	# Compaction keeps the visible prefix contiguous without reallocating every frame.
	result.visible_instance_count = kept
	multimesh = result
	_last_layout = _get_layout()


func _is_excluded(blade_position: Vector3, regions: Array) -> bool:
	for region in regions:
		var point: Vector3 = region.inverse * blade_position
		var minimum: Vector3 = region.minimum
		var maximum: Vector3 = region.maximum
		# Use the box's footprint; its height needn't intersect the grass roots.
		if point.x >= minimum.x and point.x <= maximum.x \
			and point.z >= minimum.z and point.z <= maximum.z:
			return true
	return false
