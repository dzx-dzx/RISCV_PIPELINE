// `include "mux/mux.v"
module IF #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH = 32
) (
    input clk,
    input rst,
    input PCSrc,

    input hz_PCWrite,

    input [WORD_BITWIDTH-1:0] imm,
    input [WORD_BITWIDTH-1:0] last_pc,
    output reg [WORD_BITWIDTH-1:0] pc
);
  reg [WORD_BITWIDTH-1:0] next_pc;

  always @(PCSrc or hz_PCWrite) begin//Should include imm?
    next_pc = (hz_PCWrite ? pc : ((PCSrc) ? (last_pc + (imm)) : (last_pc + 4)));
  end
  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 0;
    else pc <= next_pc;
  end
endmodule
