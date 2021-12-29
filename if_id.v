module IF_ID #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input clk,
    input rst,

    input Flush,
    input hazard,

    input      [WORD_BITWIDTH-1:0] pc,
    input      [WORD_BITWIDTH-1:0] instruction,
    output reg [WORD_BITWIDTH-1:0] id_wt_pc,       //write through
    output reg [WORD_BITWIDTH-1:0] id_instruction
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      id_wt_pc       <= 0;
      id_instruction <= 0;
    end else begin
      id_wt_pc       = pc;
      id_instruction = instruction;
    end
  end
endmodule
