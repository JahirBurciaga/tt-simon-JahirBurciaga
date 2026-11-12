/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module galois_lfsr (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire load_enable,
    input wire [15:0] load_value,
    output reg [15:0] lfsr_out
);

  // LFSR de 16 bits (taps 16,15,13,4: periodo maximo 65535)
  wire feedback = lfsr_out[15] ^ lfsr_out[14] ^ lfsr_out[12] ^ lfsr_out[3];

  always @(posedge clk) begin
    if (rst) begin
      lfsr_out <= 16'hFAFA;  // Initialize LFSR to non-zero value
    end else begin
      if (lfsr_out == 16'h0) begin
        lfsr_out <= 16'hFAFA;  // Reload LFSR to non-zero value
      end else if (load_enable) begin
        lfsr_out <= load_value;
      end else if (enable) begin
        lfsr_out <= {lfsr_out[14:0], feedback};  // Shift left and insert feedback bit
      end
    end
  end

endmodule
