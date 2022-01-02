module MEM #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input      [WORD_BITWIDTH-1:0] ALUresult     ,
    input      [WORD_BITWIDTH-1:0] readData2,
    input      [WORD_BITWIDTH-1:0] memReadData   ,
    input                          memToReg      ,
     
    output reg [WORD_BITWIDTH-1:0] address       ,
    output reg [WORD_BITWIDTH-1:0] memWriteData
);
    always @(*)
        begin
            memWriteData = readData2;
            address      = ALUresult;
        end
endmodule
