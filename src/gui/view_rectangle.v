module gui

pub struct RectangleCfg {
pub:
	id       string
	x        f32
	y        f32
	width    f32
	height   f32
	color    Color = gui_theme.rectangle_style.color
	fill     bool  = gui_theme.rectangle_style.fill
	radius   f32   = gui_theme.rectangle_style.radius
	sizing   Sizing
	disabled bool
}

// rectangle draws a rectangle (shocking!). Rectangles can be filled, outlined,
// colored and have radius corners.
pub fn rectangle(cfg RectangleCfg) Container {
	// Technically, rectangle is a container but it has no children, axis or
	// padding and as such, behaves as a plain rectangle.
	container_cfg := ContainerCfg{
		id:         cfg.id
		x:          cfg.x
		y:          cfg.y
		width:      cfg.width
		height:     cfg.height
		min_width:  cfg.width
		min_height: cfg.height
		color:      cfg.color
		fill:       cfg.fill
		padding:    padding_none
		radius:     cfg.radius
		sizing:     cfg.sizing
		disabled:   cfg.disabled
		spacing:    0
	}
	return container(container_cfg)
}
