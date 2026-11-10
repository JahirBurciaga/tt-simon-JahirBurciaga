## How it works

Simon Says is an electronic memory game: the player has to repeat a growing sequence of colors.
The sequence is shown by lighting up the LEDs, and each color has its own tone.

In each turn the game plays the sequence and then waits for the player to repeat it with the buttons.
If the sequence is correct, a level-up sound plays, a new color is added and the score goes up.
On a mistake, a game over sound plays and the game restarts.

Based on [tt10-simon-game](https://github.com/urish/tt10-simon-game) by Uri Shaked (Apache-2.0).
Tested first on a Basys 3 FPGA as a university project (UACJ, VLSI).

## Clock settings

The `clk_sel` input selects the clock source:
- `0`: external 50 kHz clock on the `clk` input.
- `1`: internal clock from a 13-stage ring oscillator divided by 8192 (~62.5 kHz).
  In this mode the internal clock is also output on `uo_out[7]` for debugging.

## How to test

1. Provide a 50 kHz clock with `clk_sel` = 0.
2. Set `seginv`: high for a common anode display, low for common cathode.
3. Reset the design (pull `rst_n` low, then high).
4. Press any button to start, then repeat the sequence shown by the LEDs.
5. The score is shown on the 2-digit 7-segment display.

## External hardware

- 4 push buttons on `btn1`-`btn4`, each with a 10k pull-down resistor.
- 4 LEDs on `led1`-`led4` with current-limiting resistors (same color order as the buttons).
- Passive buzzer on `speaker` (optional).
- 2-digit 7-segment display: `seg_a`-`seg_g` to the segments, `dig1` to the tens common pin, `dig2` to the ones common pin.
