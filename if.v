// `include "mux/mux.v"
module IF #(
        parameter REG_NUM_BITWIDTH = 5,
        parameter WORD_BITWIDTH = 32
    )(
        input clk,
        input rst,
        input PCSrc,
        input [WORD_BITWIDTH-1:0]imm,
        output reg [WORD_BITWIDTH-1:0] pc
    );
    reg [WORD_BITWIDTH-1:0] next_pc;

    always @(PCSrc)
    begin
        next_pc=(PCSrc)?(pc+(imm)):(pc+4);
    end
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            pc <= 0;
        else
            pc <= next_pc;
    end
endmodule
