module ID_EX #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH    = 32
) (
    input clk,
    input rst,

    input       branch,
    input       memRead,
    input       memToReg,
    input [1:0] ALUOp,
    input       memWrite,
    input       ALUSrc,
    input       regWrite,
    input [3:0] inst_ALU,

    input [REG_NUM_BITWIDTH-1:0] Rs1,
    input [REG_NUM_BITWIDTH-1:0] Rs2,

    input hazard,

    input [WORD_BITWIDTH-1:0] regReadData1,
    input [WORD_BITWIDTH-1:0] regReadData2,
    input [REG_NUM_BITWIDTH-1:0] regToWrite,
    input [WORD_BITWIDTH-1:0] imm,
    input [6:0] opcode,

    output reg [1:0] ex_ALUOp,
    output reg       ex_ALUSrc,

    output reg [WORD_BITWIDTH-1:0] ex_regReadData1,
    output reg [WORD_BITWIDTH-1:0] ex_regReadData2,
    output reg [WORD_BITWIDTH-1:0] ex_imm,
    output reg [              6:0] ex_opcode,
    output reg [              3:0] ex_inst_ALU,

    output reg [REG_NUM_BITWIDTH-1:0] fd_Rs1,
    output reg [REG_NUM_BITWIDTH-1:0] fd_Rs2,

    //write through
    output reg ex_wt_branch,
    output reg ex_wt_memRead,
    output reg ex_wt_memToReg,
    output reg ex_wt_memWrite,
    output reg ex_wt_regWrite,

    output reg [REG_NUM_BITWIDTH-1:0] ex_wt_regToWrite

);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      {ex_wt_branch, ex_wt_memRead, ex_wt_memToReg, ex_ALUOp, ex_wt_memWrite, ex_ALUSrc, ex_wt_regWrite} <= 0;
    end else begin
      {ex_wt_branch, ex_wt_memRead, ex_wt_memToReg, ex_ALUOp, ex_wt_memWrite, ex_ALUSrc, ex_wt_regWrite} <= hazard ? 
      0 :
      {branch, memRead, memToReg, ALUOp, memWrite, ALUSrc, regWrite};
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_regReadData1 <= 0;
    end else begin
      ex_regReadData1 <= regReadData1;
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_regReadData2 <= 0;
    end else begin
      ex_regReadData2 <= regReadData2;
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_wt_regToWrite <= 0;
    end else begin
      ex_wt_regToWrite <= regToWrite;
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_imm <= 0;
    end else begin
      ex_imm <= imm;
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_opcode <= 0;
    end else begin
      ex_opcode <= opcode;
    end
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_inst_ALU <= 0;
    end else begin
      ex_inst_ALU <= inst_ALU;
    end
  end
endmodule
