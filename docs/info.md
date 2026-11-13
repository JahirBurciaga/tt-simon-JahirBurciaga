## How it works

Simon Says is an electronic memory game: the player has to repeat a growing sequence of colors.
Each color is shown by lighting one of the 4 LEDs and playing its own tone.

After reset, the LEDs light up with one LED off spinning around, while the game waits for any button. The time until that first press seeds the random sequence. Then, every round:

1. The game plays the sequence: each color for 300 ms, with 100 ms of silence between colors.
2. The player repeats it with the buttons. Each press lights its LED and plays its tone for 300 ms.
3. If the whole sequence is correct, a short level-up melody plays, the score goes up by one and a new color is added.
4. On a mistake, a game over melody plays, all LEDs blink and the game waits for a button to start again.

The score is shown on a 2-digit, multiplexed 7-segment display (00 to 99).

| Button / LED | Note | Frequency |
|---|---|---|
| 1 | G3 | 196 Hz |
| 2 | C4 | 262 Hz |
| 3 | E4 | 330 Hz |
| 4 | G5 | 784 Hz |

### Internal blocks

- `simon.v`: the game state machine (9 states), a millisecond counter and the sequence length (up to 100 steps).
- `galois_lfsr.v`: a 16-bit LFSR (taps 16, 15, 13, 4). It runs freely until the first button press; its value is captured when the game starts and the sequence is regenerated from it every round, so it does not need to be stored.
- `sound_gen.v`: square wave generator for the requested frequency.
- `score.v`: BCD score counter and digit multiplexing.
- `project.v`: Tiny Tapeout wrapper. It inverts `rst_n` and drives `uio[6:0]` as outputs.

### Changes from the original design

Based on [tt10-simon-game](https://github.com/urish/tt10-simon-game) by Uri Shaked (Apache-2.0).
To fit in a single tile, the internal ring oscillator and the `clk_sel` input were removed (the design always uses the
external 50 kHz clock), the LFSR was reduced from 32 to 16 bits and the internal counters were resized.
Tested first on a Basys 3 FPGA as a university project (UACJ, VLSI).

## How to test

### Simulation

The cocotb testbench is in `test/`. With Icarus Verilog installed:

```sh
pip install -r test/requirements.txt
cd test
make -B
```

`test_simon` checks the reset state, the first LED and the score display. `test_long_game_sequence` plays 5 full rounds
by reading the LEDs and pressing the matching buttons.

### On the chip

1. Set the project clock to 50 kHz.
2. Set `seginv` (`ui[4]`): high for a common anode display, low for common cathode.
3. Reset the design (pull `rst_n` low, then high).
4. Press any button to start, then repeat the sequence shown by the LEDs.
5. The score is shown on the 2-digit 7-segment display.

## External hardware

- 4 push buttons on `btn1`-`btn4`, each with a 10k pull-down resistor.
- 4 LEDs on `led1`-`led4` with current-limiting resistors (same order as the buttons).
- Passive buzzer on `speaker` (optional).
- 2-digit 7-segment display: `seg_a`-`seg_g` to the segments (with resistors), `dig1` to the tens common pin, `dig2` to the ones common pin.
