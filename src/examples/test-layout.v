module main

import gui
import gg
import gx

@[heap]
struct AppState {
pub mut:
	name        string
	other_input string
	click_count int
}

fn main() {
	mut window := gui.window(
		state:   &AppState{
			name:
				'Lorem Ipsum is simply        dummy text of the printing and typesetting industry. ' +
				"Lorem Ipsum has been       the industry's standard dummy text ever since the 1500s, " +
				'when an unknown printer    took a galley of type and scrambled it to make a type ' +
				'specimen book.'
		}
		title:   'test layout'
		width:   700
		height:  600
		on_init: fn (mut w gui.Window) {
			w.update_view(main_view)
			w.set_id_focus(2)
		}
	)
	window.run()
}

fn main_view(w &gui.Window) gui.View {
	txt_color := if gui.theme().name == 'light' {
		gx.rgb(255, 255, 255)
	} else {
		gui.theme().text_style.text_cfg.color
	}

	text_style := gx.TextCfg{
		...gui.theme().text_style.text_cfg
		color: txt_color
	}
	text_style_blue := gx.TextCfg{
		...text_style
		color: gui.theme().color_link
	}
	text_style_large := gx.TextCfg{
		...text_style
		size: 20
	}

	mut state := w.state[AppState]()
	width, height := w.window_size()

	return gui.row(
		width:   width
		height:  height
		sizing:  gui.fixed_fixed
		color:   gx.dark_blue
		fill:    true
		content: [
			gui.column(
				padding: gui.padding_none
				sizing:  gui.fit_fill
				content: [
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.purple
					),
					gui.rectangle(
						width:  75
						sizing: gui.fit_fill
						color:  gui.color_transparent
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
				id:      'orange'
				text:    ' orange  '
				color:   gx.orange
				sizing:  gui.fill_fill
				content: [
					gui.column(
						sizing:  gui.fill_fill
						fill:    true
						color:   gx.rgb(0x30, 0x30, 0x30)
						content: [
							gui.row(
								color:   gx.white
								content: [
									gui.text(
										text:     'Hello world!'
										text_cfg: text_style_large
										wrap:     true
									),
								]
							),
							gui.text(
								wrap:     true
								text_cfg: text_style
								text:     'Embedded in a column with wrapping'
							),
							gui.button(
								id_focus: 1
								content:  [
									gui.text(text: 'Button Text ${state.click_count}'),
								]
								on_click: fn (_ &gui.ButtonCfg, _ &gg.Event, mut w gui.Window) bool {
									mut state := w.state[AppState]()
									state.click_count += 1
									return true
								}
							),
							gui.row(
								v_align: .middle
								padding: gui.padding_none
								content: [
									gui.text(
										text:     'label'
										text_cfg: text_style
									),
									gui.input(
										id_focus:        2
										width:           100
										sizing:          gui.fixed_fit
										text:            state.other_input
										wrap:            false
										on_text_changed: fn (_ &gui.InputCfg, s string, mut w gui.Window) {
											mut state := w.state[AppState]()
											state.other_input = s
										}
									),
								]
							),
							gui.text(
								text:     'progress bar'
								text_cfg: text_style
							),
							gui.progress_bar(
								percent: 0.35
								sizing:  gui.fill_fit
							),
						]
					),
					gui.rectangle(
						width:  25
						height: 25
						fill:   true
						sizing: gui.fill_fill
						color:  gx.dark_green
					),
				]
			),
			gui.column(
				fill:    true
				sizing:  gui.fill_fill
				color:   gx.rgb(0x30, 0x30, 0x30)
				content: [
					gui.input(
						id_focus:        3
						width:           250
						text:            state.name
						wrap:            true
						sizing:          gui.fixed_fit
						on_text_changed: fn (_ &gui.InputCfg, s string, mut w gui.Window) {
							mut state := w.state[AppState]()
							state.name = s
						}
					),
					gui.column(
						color:   gx.gray
						sizing:  gui.fill_fit
						content: [
							gui.text(
								text:     'keep_spaces = false'
								text_cfg: text_style_blue
							),
							gui.text(
								text:        state.name
								text_cfg:    text_style
								wrap:        true
								keep_spaces: false
							),
						]
					),
					gui.column(
						color:   gx.gray
						sizing:  gui.fill_fit
						content: [
							gui.text(
								text:     'keep_spaces = true'
								text_cfg: text_style_blue
							),
							gui.text(
								text:        state.name
								text_cfg:    text_style
								wrap:        true
								keep_spaces: true
							),
						]
					),
				]
			),
			gui.column(
				padding: gui.padding_none
				sizing:  gui.fit_fill
				content: [
					gui.rectangle(
						width:  75
						height: 50
						fill:   true
						color:  gx.orange
					),
					gui.rectangle(
						width:  75
						sizing: gui.fit_fill
						color:  gui.color_transparent
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
