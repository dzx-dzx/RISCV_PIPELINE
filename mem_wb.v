module MEM_WB #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH = 32
) (
    input clk,
    input rst,

    input regWrite,
    input memToReg,

    input [WORD_BITWIDTH-1:0] ALUresult,
    input [WORD_BITWIDTH-1:0] memReadData,
    input [REG_NUM_BITWIDTH-1:0] regToWrite,

    output reg [WORD_BITWIDTH-1:0] wb_regWriteData,
    output reg [REG_NUM_BITWIDTH-1:0] wb_regToWrite,
    output reg wb_regWrite
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wb_regWriteData <= 0;
    end else begin
      wb_regWriteData <= (memToReg ? memReadData : ALUresult);
    end
  end
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wb_regToWrite <= 0;
    end else begin
      wb_regToWrite <= regToWrite;
    end
  end
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wb_regWrite <= 0;
    end else begin
      wb_regWrite <= regWrite;
    end
  end
endmodule
