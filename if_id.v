module IF_ID #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input clk,
    input rst,

    input hz_write,

    input      [WORD_BITWIDTH-1:0] pc,
    input      [WORD_BITWIDTH-1:0] instruction,
    output reg [WORD_BITWIDTH-1:0] id_wt_pc,       //write through
    output reg [WORD_BITWIDTH-1:0] if_id_instruction
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      id_wt_pc       <= 0;
      if_id_instruction <= 0;
    end else begin
      if (hz_write) begin
        id_wt_pc       <= id_wt_pc;
        if_id_instruction <= if_id_instruction;
      end else begin
        id_wt_pc       <= pc;
        if_id_instruction <= instruction;
      end
    end
  end
endmodule
