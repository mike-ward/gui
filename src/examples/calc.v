import gui
import gg
import gx
import math

const bwidth = 30
const bheight = 30
const bpadding = 5
const max_digits = 12

@[heap]
struct App {
mut:
	text       string
	result     f64
	is_float   bool
	new_number bool
	operands   []f64
	operations []string
}

fn main() {
	mut window := gui.window(
		state:    &App{}
		width:    200
		height:   300
		title:    'Calculator'
		on_event: on_event
		on_init:  fn (mut w gui.Window) {
			w.update_view(main_view)
		}
	)
	window.run()
}

fn main_view(mut w gui.Window) gui.View {
	app := w.state[App]()

	row_ops := [
		['C', '%', '^', '÷'],
		['7', '8', '9', '*'],
		['4', '5', '6', '-'],
		['1', '2', '3', '+'],
		['0', '.', '±', '='],
	]

	mut panel := []gui.View{}

	panel << gui.row(
		color:    gx.black
		h_align:  .right
		padding:  gui.pad_4(5)
		sizing:   gui.flex_fit
		children: [
			gui.text(
				text:  app.text
				style: gx.TextCfg{
					size: 20
				}
			),
		]
	)

	for ops in row_ops {
		panel << gui.row(
			spacing:  5
			padding:  gui.padding_none
			children: get_row(ops)
		)
	}

	width, height := w.window_size()
	return gui.row(
		width:    width
		height:   height
		sizing:   gui.fixed_fixed
		h_align:  .center
		v_align:  .middle
		children: [
			gui.column(
				spacing:  5
				color:    gx.rgb(195, 105, 0)
				fill:     true
				padding:  gui.pad_4(10)
				children: panel
			),
		]
	)
}

fn get_row(ops []string) []gui.View {
	mut children := []gui.View{}

	for op in ops {
		children << gui.button(
			text:     op
			width:    bwidth
			height:   bheight
			h_align:  .center
			v_align:  .middle
			sizing:   gui.fixed_fixed
			padding:  gui.padding_none
			on_click: btn_click
		)
	}
	return children
}

fn btn_click(btn &gui.ButtonCfg, e &gg.Event, mut w gui.Window) {
	mut app := w.state[App]()
	app.do_op(btn.text)
}

fn on_event(e &gg.Event, mut w gui.Window) {
	if e.typ == .char {
		c := rune(e.char_code).str().to_upper()
		mut app := w.state[App]()
		app.do_op(c)
	}
}

fn (mut app App) do_op(op string) {
	number := app.text
	if op == 'C' {
		app.result = 0
		app.operands = []
		app.operations = []
		app.new_number = true
		app.is_float = false
		app.update_result()
		return
	}
	if op[0].is_digit() || op == '.' {
		// Can only have one `.` in a number
		if op == '.' && number.contains('.') {
			return
		}
		if app.new_number {
			app.text = op
			app.new_number = false
			app.is_float = false
		} else {
			// Append a new digit
			if app.text.len < max_digits {
				app.text = number + op
			}
		}
		return
	}
	if number.contains('.') {
		app.is_float = true
	}
	if op in ['+', '-', '÷', '*', '±', '='] {
		if !app.new_number {
			app.new_number = true
			app.operands << number.f64()
		}
		app.operations << op
		app.calculate()
	}
	app.update_result()
}

fn (mut app App) update_result() {
	// Format and print the result
	mut text := ''
	if !math.trunc(app.result).eq_epsilon(app.result) {
		text = '${app.result:-9.3f}'
	} else {
		text = int(app.result).str()
	}
	if text.len > max_digits {
		text = text[0..max_digits]
	}
	app.text = text
}

fn pop_f64(a []f64) (f64, []f64) {
	res := a.last()
	return res, a[0..a.len - 1]
}

fn pop_string(a []string) (string, []string) {
	res := a.last()
	return res, a[0..a.len - 1]
}

fn (mut app App) calculate() {
	mut a := f64(0)
	mut b := f64(0)
	mut op := ''
	mut operands := app.operands.clone()
	mut operations := app.operations.clone()
	mut result := if operands.len == 0 { f64(0.0) } else { operands.last() }
	mut i := 0
	for {
		i++
		if operations.len == 0 {
			break
		}
		op, operations = pop_string(operations)
		if op == '=' {
			continue
		}
		if operands.len < 1 {
			operations << op
			break
		}
		b, operands = pop_f64(operands)
		if op == '±' {
			result = -b
			operands << result
			continue
		}
		if operands.len < 1 {
			operations << op
			operands << b
			break
		}
		a, operands = pop_f64(operands)
		match op {
			'+' {
				result = a + b
			}
			'-' {
				result = a - b
			}
			'*' {
				result = a * b
			}
			'÷' {
				if int(b) == 0 {
					eprintln('Division by zero!')
					b = 0.0000000001
				}
				result = a / b
			}
			else {
				operands << a
				operands << b
				result = b
				eprintln('Unknown op: ${op} ')
				break
			}
		}
		operands << result
		// eprintln('i: ${i:4d} | res: ${result} | op: $op | operands: $operands | operations: $operations')
	}
	app.operations = operations
	app.operands = operands
	app.result = result
	// eprintln('----------------------------------------------------')
	// eprintln('Operands: $app.operands  | Operations: $app.operations ')
	// eprintln('-------- result: $result | i: $i -------------------')
}
