module main

import gui
import gx

@[heap]
struct AppState {
pub mut:
	name        string
	click_count int
}

fn main() {
	mut window := gui.window(
		title:      'test layout'
		width:      600
		height:     400
		bg_color:   gx.rgb(0x30, 0x30, 0x30)
		state:      &AppState{}
		on_init:    fn (mut w gui.Window) {
			w.set_focus_id(1)
			w.update_view(main_view(w))
		}
		on_resized: fn (mut w gui.Window) {
			w.update_view(main_view(w))
		}
	)
	window.run()
}

fn main_view(w &gui.Window) gui.View {
	width, height := w.window_size()
	mut state := w.get_state[AppState]()

	text_style := gx.TextCfg{
		color: gx.white
	}
	text_style_large := gx.TextCfg{
		...text_style
		size: 20
	}

	return gui.row(
		width:    width
		height:   height
		sizing:   gui.fixed_fixed
		fill:     true
		color:    gx.dark_blue
		children: [
			gui.column(
				padding:  gui.padding_none
				sizing:   gui.fit_flex
				children: [
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.purple
					),
					gui.rectangle(
						width:  75
						height: 50
						sizing: gui.fit_flex
						color:  gui.transparent
					),
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.green
					),
				]
			),
			gui.row(
				id:       'orange'
				color:    gx.orange
				sizing:   gui.flex_flex
				children: [
					gui.column(
						sizing:   gui.flex_flex
						fill:     true
						color:    gx.rgb(0x30, 0x30, 0x30)
						children: [
							gui.rectangle(
								id:     'rect'
								width:  25
								height: 25
								color:  gx.orange
							),
							gui.rectangle(
								width:  25
								height: 25
								color:  gx.orange
							),
							gui.canvas(
								color:    gx.white
								children: [
									gui.text(
										text:  'Hello world!'
										style: text_style_large
									),
								]
							),
							gui.text(
								text:  'This is text'
								style: text_style
							),
							gui.text(
								wrap:  true
								style: text_style
								text:  'Embedded in a column with wrapping'
							),
							gui.button(
								text:       'Button Text ${state.click_count}'
								text_style: text_style
								on_click:   fn (id string, me gui.MouseEvent, mut w gui.Window) {
									mut state := w.get_state[AppState]()
									state.click_count += 1
									w.update_view(main_view(w))
								}
							),
							gui.row(
								padding:  gui.padding_none
								children: [
									gui.text(text: 'Name:', style: text_style),
									gui.input(
										focus_id:        1
										width:           100
										text:            state.name
										text_style:      text_style
										on_text_changed: fn (_ &gui.InputCfg, s string, mut w gui.Window) {
											mut state := w.get_state[AppState]()
											state.name = s
											w.update_view(main_view(w))
										}
									),
								]
							),
							gui.text(text: 'Your name is ${state.name}', style: text_style),
						]
					),
					gui.rectangle(
						id:     'green'
						width:  25
						height: 25
						fill:   true
						sizing: gui.flex_flex
						color:  gx.dark_green
					),
				]
			),
			gui.rectangle(
				width:  75
				height: 50
				fill:   true
				sizing: gui.flex_flex
				color:  gx.red
			),
			gui.column(
				padding:  gui.padding_none
				sizing:   gui.fit_flex
				children: [
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.orange
					),
					gui.rectangle(
						width:  75
						height: 50
						sizing: gui.fit_flex
						color:  gui.transparent
					),
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.yellow
					),
				]
			),
		]
	)
}
