module sound_gen (
    input wire clk,
    input wire rst,
    input wire [15:0] ticks_per_milli,
    input wire [9:0] freq,
    output reg sound
);
  reg  [15:0] tick_counter;  // reducido de 32 a 16 bits (max ~26k a 50 kHz)
    wire [15:0] freq16 = {6'b0, freq};
  wire [15:0] half_second = (ticks_per_milli * 1000) >> 1;  // 25000 a 50 kHz

  always @(posedge clk) begin
    if (rst) begin
      tick_counter <= 0;
      sound <= 0;
    end else if (freq == 0) begin
      sound <= 0;
    end else begin
      tick_counter <= tick_counter + freq16;
      if (tick_counter >= half_second) begin
        sound <= !sound;
        tick_counter <= tick_counter + freq16 - half_second;
      end
    end
  end

endmodule

