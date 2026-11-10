/*
 * Simon Says - basado en tt10-simon-game (Uri Shaked, Apache-2.0)
 */

`default_nettype none

module tt_um_jahirburciaga_simon (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs: camino de entrada
    output wire [7:0] uio_out,  // IOs: camino de salida
    output wire [7:0] uio_oe,   // IOs: 1 = salida, 0 = entrada
    input  wire       ena,      // siempre 1 cuando hay energia
    input  wire       clk,      // reloj
    input  wire       rst_n     // reset activo en bajo
);

  // 1) Wires para interconectar
  wire [3:0] led;
  wire [6:0] segments;
  wire [1:0] segment_digits;
  wire       sound;
  wire       clk_sel = ui_in[7];
  wire       clk_ring_osc;
  wire       clk_internal;
  wire       clk_simon        = clk_sel ? clk_internal : clk;
  wire       clk_internal_out = clk_sel ? clk_internal : 1'b0;

  // 2) Asignar TODAS las salidas (lo que no se use, a 0)
  assign uo_out  = {clk_internal_out, segment_digits, sound, led};
  assign uio_out = {1'b0, segments};
  assign uio_oe  = 8'b0111_1111;   // uio[6:0] salidas, uio[7] entrada

  // 3) Instanciar los modulos
  ring_osc #(
      .CHAIN_LENGTH(13),
      .DIVIDER_BITS(13)
  ) ring_osc (
      .clk_out    (clk_ring_osc),
      .clk_out_div(clk_internal)
  );

  simon simon1 (
      .clk            (clk_simon),
      .rst            (!rst_n),               // rst_n es activo en bajo
      .ticks_per_milli(clk_sel ? 16'd62 : 16'd50),
      .btn            (ui_in[3:0]),
      .led            (led),
      .segments       (segments),
      .segment_digits (segment_digits),
      .segments_invert(ui_in[4]),
      .sound          (sound)
  );

  // 4) Entradas sin usar, para evitar warnings
  wire _unused = &{ena, ui_in[6:5], uio_in, clk_ring_osc, 1'b0};

endmodule
