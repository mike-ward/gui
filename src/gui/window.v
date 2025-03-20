module gui

import gg
import gx
import sync

@[heap]
pub struct Window {
mut:
	ui               &gg.Context       = &gg.Context{}
	state            voidptr           = unsafe { nil }
	layout           ShapeTree         = ShapeTree{}
	renderers        []Renderer        = []
	mutex            &sync.Mutex       = sync.new_mutex()
	gen_view         fn (&Window) View = fn (_ &Window) View {
		return canvas(id: 'empty-view')
	}
	focus_id         FocusId
	input_state      map[FocusId]InputState
	update_on_resize bool
	on_resized       fn (&Window) = fn (_ &Window) {}
}

// Window is the application window. The state parameter is a reference to where
// the application state is stored. `on_init` is where to set the application's
// first view.
pub struct WindowCfg {
pub:
	state            voidptr = unsafe { nil }
	title            string
	width            int
	height           int
	bg_color         gx.Color
	update_on_resize bool         = true
	on_init          fn (&Window) = fn (_ &Window) {}
	on_resized       fn (&Window) = fn (_ &Window) {}
}

// window creates the application window. See WindowCfg on how to configure it
pub fn window(cfg WindowCfg) &Window {
	mut window := &Window{
		state:            cfg.state
		update_on_resize: cfg.update_on_resize
		on_resized:       cfg.on_resized
	}
	window.ui = gg.new_context(
		bg_color:     cfg.bg_color
		height:       cfg.height
		init_fn:      cfg.on_init
		ui_mode:      true // only draw on events
		user_data:    window
		width:        cfg.width
		window_title: cfg.title
		char_fn:      char_fn
		click_fn:     click_fn
		frame_fn:     frame_fn
		keydown_fn:   keydown_fn
		resized_fn:   resized_fn
	)
	return window
}

fn frame_fn(mut window Window) {
	window.mutex.lock()
	window.ui.begin()
	for renderer in window.renderers {
		render_draw(renderer, window.ui)
	}
	window.ui.end()
	window.mutex.unlock()
}

fn char_fn(c u32, mut w Window) {
	w.mutex.lock()
	layout := w.layout
	w.mutex.unlock()

	if shape := shape_from_on_char(layout, w.focus_id, 0) {
		if shape.on_char != unsafe { nil } {
			shape.on_char(c, w)
		}
	}
	w.update_window()
}

fn keydown_fn(c gg.KeyCode, m gg.Modifier, mut w Window) {
	w.mutex.lock()
	layout := w.layout
	w.mutex.unlock()

	mut handled := false
	mut shape_uid := u64(0)
	for !handled {
		shape := shape_from_on_key_down(layout, shape_uid) or { break }
		if shape.on_keydown != unsafe { nil } {
			handled = shape.on_keydown(c, m, w)
			shape_uid = shape.uid
		}
	}

	if !handled && c == .tab {
		if shape := shape_next_focusable(layout, mut w) {
			w.focus_id = shape.focus_id
		}
	}
	w.update_window()
}

// clicked delegates to the first Shape that has a click handler within its
// rectanguler area. The search for the Shape is in reverse order.
fn click_fn(x f32, y f32, button gg.MouseButton, mut w Window) {
	w.mutex.lock()
	layout := w.layout
	w.mutex.unlock()

	w.set_focus_id(0)
	if shape := shape_from_on_click(layout, x, y, 0) {
		if shape.on_click != unsafe { nil } {
			if shape.focus_id > 0 {
				w.set_focus_id(shape.focus_id)
			}
			me := MouseEvent{
				mouse_x:      x
				mouse_y:      y
				mouse_button: button
			}
			shape.on_click(shape.id, me, w)
		}
	}
	w.update_window()
}

fn resized_fn(e &gg.Event, mut w Window) {
	w.on_resized(w)
	if w.update_on_resize {
		w.update_window()
	}
}

// focus_id gets the window's focus id
pub fn (window &Window) focus_id() int {
	return window.focus_id
}

// get_state returns a reference to user supplied data
pub fn (window &Window) state[T]() &T {
	assert window.state != unsafe { nil }
	return unsafe { &T(window.state) }
}

// run starts the UI and handles events
pub fn (mut window Window) run() {
	window.ui.run()
}

// set_focus_id sets the window's focus id.
pub fn (mut window Window) set_focus_id(id FocusId) {
	window.focus_id = id
	window.update_window()
}

// update_view sets the Window's view. A window can have only one view. Giving a
// Window a new view replaces the current view. Clears the input states.
pub fn (mut window Window) update_view(gen_view fn (&Window) View) {
	view := gen_view(window)
	mut shapes := generate_shapes(view, window)
	layout_do(mut shapes, window)
	renderers := render(shapes, window.ui)

	window.mutex.lock()
	defer { window.mutex.unlock() }

	window.focus_id = 0
	window.input_state.clear()
	window.gen_view = gen_view
	window.layout = shapes
	window.renderers = renderers
}

// update_window generates a new layout from the windows view. Does not clear
// the input states
pub fn (mut window Window) update_window() {
	window.mutex.lock()
	defer { window.mutex.unlock() }

	view := window.gen_view(window)
	mut shapes := generate_shapes(view, window)
	layout_do(mut shapes, window)
	renderers := render(shapes, window.ui)

	window.layout = shapes
	window.renderers = renderers
}

// window_size gets the size of the window in logical units.
pub fn (window &Window) window_size() (int, int) {
	size := window.ui.window_size()
	return size.width, size.height
}
