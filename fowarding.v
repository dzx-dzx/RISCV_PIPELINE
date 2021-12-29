module Forwarding #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH    = 32
) (
    input [REG_NUM_BITWIDTH-1:0] id_Rs1,
    input [REG_NUM_BITWIDTH-1:0] id_Rs2,
    input [REG_NUM_BITWIDTH-1:0] ex_Rd,
    input [REG_NUM_BITWIDTH-1:0] mem_Rd,
    input mem_regWrite,
    input ex_regWrite,

    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
  always @(*) begin
    if (ex_regWrite && ex_Rd != 0 && ex_Rd == id_Rs1) begin
      forwardA = 2'b10;
    end else if (mem_regWrite && mem_Rd != 0 &&/*Comparion logic redundant since in else clause*/ mem_Rd == id_Rs1) begin
      forwardA = 2'b01;
    end else forwardA = 2'b00;
  end
  always @(*) begin
    if (ex_regWrite && ex_Rd != 0 && ex_Rd == id_Rs2) begin
      forwardB = 2'b10;
    end else if (mem_regWrite && mem_Rd != 0 && mem_Rd == id_Rs2) begin
      forwardB = 2'b01;
    end else forwardB = 2'b00;
  end
endmodule
