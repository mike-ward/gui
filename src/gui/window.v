module gui

import gg
import gx
import sync

@[heap]
pub struct Window {
mut:
	layout    ShapeTree    = empty_shape_tree
	mutex     &sync.Mutex  = unsafe { nil }
	ui        &gg.Context  = unsafe { nil }
	on_resize fn (&Window) = unsafe { nil }
}

pub struct WindowCfg {
pub:
	title     string
	width     int
	height    int
	bg_color  gx.Color
	on_init   fn (&Window) = unsafe { nil }
	on_resize fn (&Window) = unsafe { nil }
}

pub fn window(cfg WindowCfg) &Window {
	mut window := &Window{
		mutex:     sync.new_mutex()
		on_resize: cfg.on_resize
	}
	window.ui = gg.new_context(
		ui_mode:      true // only draw on events
		bg_color:     cfg.bg_color
		width:        cfg.width
		height:       cfg.height
		window_title: cfg.title
		init_fn:      cfg.on_init
		resized_fn:   resized
		frame_fn:     frame
		user_data:    window
	)
	return window
}

fn frame(mut window Window) {
	window.mutex.lock()
	window.ui.begin()
	window.draw_shapes(window.layout)
	window.ui.end()
	window.mutex.unlock()
}

fn resized(e &gg.Event, mut w Window) {
	if w.on_resize != unsafe { nil } {
		w.on_resize(w)
	}
}

fn (mut window Window) draw_shapes(shapes ShapeTree) {
	shapes.shape.draw(window.ui)
	for child in shapes.children {
		window.draw_shapes(child)
	}
}

pub fn (mut window Window) update_view(view UI_Tree) {
	mut shapes := generate_shapes(view)
	do_layout(mut shapes)

	window.mutex.lock()
	window.layout = shapes
	window.mutex.unlock()
}

pub fn (window &Window) window_size() (int, int) {
	size := window.ui.window_size()
	return size.width, size.height
}

pub fn (mut window Window) run() {
	window.ui.run()
}
