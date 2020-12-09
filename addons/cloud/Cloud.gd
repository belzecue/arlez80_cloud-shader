tool
extends MeshInstance

class_name CloudDome

#
# ドームの動的移動 + 動的生成雲の設定 by きのもと 結衣 @arlez80
#

export(Color) var cloud_color:Color = Color(1.0,1.0,1.0,1.0)
export(Color) var shade_color:Color = Color(0.568627, 0.698039, 0.878431, 1.0)
export(int, 1, 64) var draw_count:int = 6 setget _set_draw_count
export(float) var cloud_seed:float = -10000.0 setget _set_cloud_seed
export(Vector2) var cloud_speed:Vector2 = Vector2( 2.0, 0.0 ) setget _set_cloud_speed
export(Vector2) var cloud_transform_speed:Vector2 = Vector2( 0.0, 0.00001 ) setget cloud_transform_speed
export(float) var cloud_thickness:float = 156.0 setget _set_cloud_thickness
export(float) var cloud_altitude:float = 2000.0 setget _set_cloud_altitude

export(float) var cloud_min_level_low:float = 0.48 setget _set_cloud_min_level_low
export(float) var cloud_min_level_high:float = 0.6 setget _set_cloud_min_level_high
export(float) var cloud_max_level_low:float = 12.0 setget _set_cloud_max_level_low
export(float) var cloud_max_level_high:float = 6.0 setget _set_cloud_max_level_high

func _ready( ):
	self._regen_mesh( )

func _set_draw_count( _draw_count:int ) -> int:
	draw_count = _draw_count
	self._regen_mesh( )
	return draw_count

func _set_cloud_seed( _cloud_seed:float ) -> float:
	cloud_seed = _cloud_seed
	self._regen_mesh( )
	return cloud_seed

func _set_cloud_speed( _cloud_speed:Vector2 ) -> Vector2:
	cloud_speed = _cloud_speed
	self._regen_mesh( )
	return cloud_speed

func cloud_transform_speed( _cloud_transform_speed:Vector2 ) -> Vector2:
	cloud_transform_speed = _cloud_transform_speed
	self._regen_mesh( )
	return cloud_transform_speed

func _set_cloud_thickness( _cloud_thickness:float ) -> float:
	cloud_thickness = _cloud_thickness
	self._regen_mesh( )
	return cloud_thickness

func _set_cloud_altitude( _cloud_altitude:float ) -> float:
	cloud_altitude = _cloud_altitude
	self._regen_mesh( )
	return cloud_altitude

func _set_cloud_min_level_low( _cloud_min_level_low:float ) -> float:
	cloud_min_level_low = _cloud_min_level_low
	self._regen_mesh( )
	return cloud_min_level_low

func _set_cloud_min_level_high( _cloud_min_level_high:float ) -> float:
	cloud_min_level_high = _cloud_min_level_high
	self._regen_mesh( )
	return cloud_min_level_high

func _set_cloud_max_level_low( _cloud_max_level_low:float ) -> float:
	cloud_max_level_low = _cloud_max_level_low
	self._regen_mesh( )
	return cloud_max_level_low

func _set_cloud_max_level_high( _cloud_max_level_high:float ) -> float:
	cloud_max_level_high = _cloud_max_level_high
	self._regen_mesh( )
	return cloud_max_level_high

func _regen_mesh( ):
	self.mesh = preload( "CageMesh.tres" )

	var cloud_shader:ShaderMaterial = preload( "CloudMat.tres" )
	var currently_shader:ShaderMaterial = null

	# 雲の上から下に作っていく
	for i in range( self.draw_count ):
		var t:float = float(i) / ( self.draw_count - 1 )
		var s:float = 1.0 - t
		var color_t:float = t * t
		var color_s:float = 1.0 - color_t
		var sin_t:float = 1.0 - sin( s * 0.8 * PI )

		var cs:ShaderMaterial = cloud_shader.duplicate( )
		cs.set_shader_param( "seed", self.cloud_seed )
		cs.set_shader_param( "color", self.cloud_color * color_s + self.shade_color * color_t )
		cs.set_shader_param( "speed", self.cloud_speed )
		cs.set_shader_param( "transform_speed", self.cloud_transform_speed )
		cs.set_shader_param( "min_level", lerp( self.cloud_min_level_low, self.cloud_min_level_high, sin_t ) )
		cs.set_shader_param( "max_level", lerp( self.cloud_max_level_low, self.cloud_max_level_high, sin_t ) )
		cs.set_shader_param( "altitude", self.cloud_altitude + lerp( self.cloud_thickness, 0.0, t ) )
		cs.set_shader_param( "detail_noise", ( self.draw_count * 3 / 4 ) < i )
		cs.render_priority = Material.RENDER_PRIORITY_MIN + i

		if currently_shader == null:
			self.material_override = cs
		else:
			currently_shader.next_pass = cs
		currently_shader = cs

func _process( delta:float ):
	self._move_to_camera( )

func _physics_process( delta:float ):
	self._move_to_camera( )

func _move_to_camera( ):
	var camera:Camera = self.get_viewport( ).get_camera( )
	if camera == null:
		return

	var middle:float = ( camera.far + camera.near ) / 2.0
	var middle_size:Vector3 = Vector3.ONE * middle

	self.transform.origin = camera.global_transform.origin
	self.transform.basis.x = Vector3( middle, 0.0, 0.0 )
	self.transform.basis.y = Vector3( 0.0, middle, 0.0 )
	self.transform.basis.z = Vector3( 0.0, 0.0, middle )
