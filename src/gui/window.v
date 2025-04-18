module gui

import gg
import sokol.sapp
import sync

@[heap]
pub struct Window {
mut:
	ui                    &gg.Context       = &gg.Context{}
	state                 voidptr           = unsafe { nil }
	mutex                 &sync.Mutex       = sync.new_mutex()
	layout                Layout            = Layout{}
	renderers             []Renderer        = []
	gen_view              fn (&Window) View = default_view
	id_focus              u32
	focused               bool = true
	mouse_cursor          sapp.MouseCursor
	input_state           map[u32]InputState
	scroll_state_vertical map[u32]f32
	text_widths           map[string]int
	on_event              fn (e &Event, mut w Window) = fn (_ &Event, mut _ Window) {}
}

// Window is the application window. The state parameter is a reference to where
// the application state is stored. `on_init` is where to set the application's
// first view. See `examples/get-started.v` for complete example.
// Example:
// ```v
// import gui
//
// fn main() {
// 	mut window := gui.window(
// 		width:   300
// 		height:  300
// 		on_init: fn (mut w gui.Window) {
// 			w.update_view(main_view)
// 		}
// 	)
// 	window.run()
// }
//
// fn main_view(window &gui.Window) gui.View {
// 	w, h := window.window_size()
// 	return gui.column(
// 		width:   w
// 		height:  h
// 		sizing:  gui.fixed_fixed
// 		h_align: .center
// 		v_align: .middle
// 		content: [gui.text(text: 'Welcome to GUI')]
// 	)
// }
// ```
pub struct WindowCfg {
pub:
	state    voidptr = unsafe { nil }
	title    string  = app_title
	width    int
	height   int
	bg_color Color        = gui_theme.color_background
	on_init  fn (&Window) = fn (mut w Window) {
		w.update_view(default_view)
	}
	on_event fn (e &Event, mut w Window) = fn (_ &Event, mut _ Window) {}
}

// window creates the application window. See WindowCfg on how to configure it
pub fn window(cfg WindowCfg) &Window {
	mut window := &Window{
		state:    cfg.state
		on_event: cfg.on_event
	}
	window.ui = gg.new_context(
		bg_color:     cfg.bg_color.to_gx_color()
		width:        cfg.width
		height:       cfg.height
		window_title: cfg.title
		event_fn:     event_fn
		frame_fn:     frame_fn
		init_fn:      cfg.on_init
		ui_mode:      true // only draw on events
		user_data:    window
	)
	return window
}

// frame_fn is the only place where the window is rendered.
fn frame_fn(mut window Window) {
	window.mutex.lock()
	window.ui.begin()
	renderers_draw(window.renderers, window.ui)
	window.ui.end()
	window.mutex.unlock()
	sapp.set_mouse_cursor(window.mouse_cursor)
}

// background_color returns the window background color
pub fn (window &Window) color_background() Color {
	return from_gx_color(window.ui.config.bg_color)
}

// context gets the windows gg.Context
pub fn (window &Window) context() &gg.Context {
	return window.ui
}

// event_fn is where all user events are handled. Mostly it delegates
// to child views.
fn event_fn(ev &gg.Event, mut w Window) {
	mut e := from_gg_event(ev)
	if !w.focused && e.typ !in [.focused, .mouse_scroll] {
		return
	}
	w.mutex.lock()
	layout := w.layout
	w.mutex.unlock()

	match e.typ {
		.char {
			char_handler(layout, mut e, w)
		}
		.focused {
			w.focused = true
		}
		.unfocused {
			w.focused = false
		}
		.key_down {
			keydown_handler(layout, mut e, mut w)
			m := unsafe { gg.Modifier(e.modifiers) }
			if !e.is_handled && e.key_code == .tab && m == gg.Modifier.shift {
				if shape := layout.previous_focusable(mut w) {
					w.id_focus = shape.id_focus
				}
			} else if !e.is_handled && e.key_code == .tab {
				if shape := layout.next_focusable(mut w) {
					w.id_focus = shape.id_focus
				}
			}
		}
		.mouse_down {
			w.set_mouse_cursor_arrow()
			w.set_id_focus(0)
			mouse_down_handler(layout, mut e, mut w)
		}
		.mouse_move {
			w.set_mouse_cursor_arrow()
			mouse_move_handler(layout, mut e, mut w)
		}
		.mouse_scroll {
			mouse_scroll_handler(layout, mut e, mut w)
		}
		else {
			// dump(e)
		}
	}
	if !e.is_handled {
		w.on_event(e, mut w)
	}
	w.update_window()
}

// default_view creates a simple welcome to gui view. GUI initializes the
// windows view to this view.
fn default_view(window &Window) View {
	w, h := window.window_size()
	return column(
		width:   w
		height:  h
		h_align: .center
		v_align: .middle
		sizing:  fixed_fixed
		content: [
			text(
				text:       'Welcome to GUI'
				text_style: TextStyle{
					...gui_theme.text_style
					size: 25
				}
			),
		]
	)
}

// get_text_width gets the width of the text in logical units
pub fn (mut window Window) get_text_width(text string, text_style TextStyle) int {
	return get_text_width(text, text_style, mut window)
}

// id_focus gets the window's focus id
pub fn (window &Window) id_focus() u32 {
	return window.id_focus
}

// is_focus tests if the given id_focus is equal to the windows's id_focus
pub fn (window &Window) is_focus(id_focus u32) bool {
	return window.id_focus > 0 && window.id_focus == id_focus
}

// pointer_over_app returns true if the mouse pointer is over the app
pub fn (window &Window) pointer_over_app(e &Event) bool {
	if e.mouse_x < 0 || e.mouse_y < 0 {
		return false
	}
	size := window.ui.window_size()
	if e.mouse_x > size.width || e.mouse_y > size.height {
		return false
	}
	return true
}

// resize_to_content is currently not working. Need to implement gg.resize()
pub fn (mut window Window) resize_to_content() {
	window.mutex.lock()
	defer { window.mutex.unlock() }
	window.ui.resize(int(window.layout.shape.width), int(window.layout.shape.height))
}

// run starts the UI and handles events
pub fn (mut window Window) run() {
	window.ui.run()
}

// set_color_background changes the windows background color
pub fn (mut window Window) set_color_background(color Color) {
	window.ui.set_bg_color(color.to_gx_color())
}

// scroll_vertical_by scrolls the given scrollable by delta.
// Use update_window() if not called from event handler
pub fn (mut window Window) scroll_vertical_by(id_scroll u32, delta f32) {
	window.scroll_state_vertical[id_scroll] += delta
}

// scroll_vertical_by scrolls the given scrollable to the offset. offset is negative.
// Use update_window() if not called from event handler
pub fn (mut window Window) scroll_vertical_to(id_scroll u32, offset f32) {
	window.scroll_state_vertical[id_scroll] = offset
}

// set_id_focus sets the window's focus id.
pub fn (mut window Window) set_id_focus(id u32) {
	window.id_focus = id
	window.update_window()
}

// set_mouse_cursor_arrow sets the window's mouse cursor to an arrow
pub fn (mut window Window) set_mouse_cursor_arrow() {
	window.mouse_cursor = .arrow
}

// set_mouse_cursor_ibeam sets the window's mouse cursor to an I-Beam
// typically indicating text handling.
pub fn (mut window Window) set_mouse_cursor_ibeam() {
	window.mouse_cursor = .ibeam
}

// set_mouse_cursor_pointing_hand sets the window's mouse cursor to a pointy finger
pub fn (mut window Window) set_mouse_cursor_pointing_hand() {
	window.mouse_cursor = .pointing_hand
}

// set_theme sets the current theme to the given theme.
// GUI has two builtin themes. theme_dark, theme_light
pub fn (mut window Window) set_theme(theme Theme) {
	gui_theme = theme
	window.set_color_background(theme.color_background)
}

// state returns a reference to user supplied data
pub fn (window &Window) state[T]() &T {
	assert window.state != unsafe { nil }
	return unsafe { &T(window.state) }
}

// update_view sets the Window's view generator. A window can have only one
// view generator. Giving a Window a new view generator replaces the current
// view generator and clears the input states, scroll states and other
// internal management states.
pub fn (mut window Window) update_view(gen_view fn (&Window) View) {
	view := gen_view(window)
	mut layout := generate_layout(view, window)
	layouts := layout_do(mut layout, window)

	mut renderers := []Renderer{}
	for lyo in layouts {
		renderers << render(lyo, window.color_background(), layout.shape.scroll_v, window.ui)
	}
	// Combine the layouts into one layout to rule them all
	// and bind them in the darkness
	layout = Layout{
		children: layouts
	}

	window.mutex.lock()
	defer { window.mutex.unlock() }

	// Clear internal state management buffers.
	// This is the only place these are cleared.
	window.id_focus = 0
	window.input_state.clear()
	window.scroll_state_vertical.clear()
	window.text_widths.clear()
	// Needed to regen views, event callbacks, drawing
	window.gen_view = gen_view
	window.layout = layout
	window.renderers = renderers
}

// update_window generates a new layout from the windows currnet
// view generator. Does not clear the input states. This should
// rarely be needed since events trigger new layouts/rendereres.
pub fn (mut window Window) update_window() {
	window.mutex.lock()
	gen_view := window.gen_view
	window.mutex.unlock()

	view := gen_view(window)
	mut layout := generate_layout(view, window)
	layouts := layout_do(mut layout, window)

	mut renderers := []Renderer{}
	for lyo in layouts {
		renderers << render(lyo, window.color_background(), layout.shape.scroll_v, window.ui)
	}
	// Combine the layouts into one layout to rule them all
	// and bind them in the darkness
	layout = Layout{
		children: layouts
	}

	window.mutex.lock()
	defer { window.mutex.unlock() }

	window.layout = layout
	window.renderers = renderers
}

// window_size gets the size of the window in logical units.
pub fn (window &Window) window_size() (int, int) {
	size := window.ui.window_size()
	return size.width, size.height
}
