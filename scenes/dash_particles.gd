extends GPUParticles2D


func _process(delta: float) -> void:
    process_material.scale_min = self.scale.x / 2
    process_material.scale_min = self.scale.y / 2