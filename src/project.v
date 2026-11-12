/*
 * Simon Says - basado en tt10-simon-game (Uri Shaked, Apache-2.0)
 * Version reducida para 1 tile: sin oscilador de anillo interno,
 * siempre usa el reloj externo de 50 kHz.
 */

`default_nettype none

module tt_um_jahirburciaga_simon (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs: camino de entrada
    output wire [7:0] uio_out,  // IOs: camino de salida
    output wire [7:0] uio_oe,   // IOs: 1 = salida, 0 = entrada
    input  wire       ena,      // siempre 1 cuando hay energia
    input  wire       clk,      // reloj (50 kHz)
    input  wire       rst_n     // reset activo en bajo
);

  // 1) Wires para interconectar
  wire [3:0] led;
  wire [6:0] segments;
  wire [1:0] segment_digits;
  wire       sound;

  // 2) Asignar TODAS las salidas (lo que no se use, a 0)
  assign uo_out  = {1'b0, segment_digits, sound, led};
  assign uio_out = {1'b0, segments};
  assign uio_oe  = 8'b0111_1111;   // uio[6:0] salidas, uio[7] entrada

  // 3) Instanciar el juego
  simon simon1 (
      .clk            (clk),
      .rst            (!rst_n),               // rst_n es activo en bajo
      .ticks_per_milli(16'd50),               // 50 kHz -> 50 ciclos por ms
      .btn            (ui_in[3:0]),
      .led            (led),
      .segments       (segments),
      .segment_digits (segment_digits),
      .segments_invert(ui_in[4]),
      .sound          (sound)
  );

  // 4) Entradas sin usar, para evitar warnings
  wire _unused = &{ena, ui_in[7:5], uio_in, 1'b0};

endmodule
