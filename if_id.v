module IF_ID #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input                          clk              ,
    input                          rst              ,
    input                          hz_write         ,
    input      [WORD_BITWIDTH-1:0] pc               ,
    input      [WORD_BITWIDTH-1:0] instruction  ,
    input doNOP    ,
    output reg [WORD_BITWIDTH-1:0] if_wt_pc         , //write through
    output reg [WORD_BITWIDTH-1:0] if_id_instruction
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            if_wt_pc          <= 0;
            if_id_instruction <= 0;
        end else begin
            if(doNOP)begin
                if_wt_pc          <= 0;
                if_id_instruction <= 0;
            end
            else if (hz_write) begin
                if_wt_pc          <= if_wt_pc;
                if_id_instruction <= if_id_instruction;
            end else begin
                if_wt_pc          <= pc;
                if_id_instruction <= instruction;
            end
        end
    end
endmodule
