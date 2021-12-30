// `include "mux/mux.v"
module IF #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH = 32
) (
    input clk,
    input rst,
    input PCSrc,

    input hz_PCWrite,

    input [WORD_BITWIDTH-1:0] branch_pc,
    output reg [WORD_BITWIDTH-1:0] pc
);
  reg [WORD_BITWIDTH-1:0] next_pc;

  always @(*) begin//Should include imm?
    next_pc = (hz_PCWrite ? pc : ((PCSrc) ? (branch_pc) : (pc + 4)));
  end
  always @(posedge clk or posedge rst) begin
    if (rst) pc <= 32'hFFFFFFFC;
    else pc <= next_pc;
  end
endmodule
