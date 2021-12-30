module Hazard #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input                         id_memRead,
    input  [REG_NUM_BITWIDTH-1:0] id_Rd     ,
    input  [REG_NUM_BITWIDTH-1:0] if_Rs1    ,
    input  [REG_NUM_BITWIDTH-1:0] if_Rs2    ,
    output                        if_write  ,
    output                        PCWrite   , //Implementation yet to be confirmed.
    output                        id_doNOP
);
    assign id_doNOP = id_memRead && ((id_Rd == if_Rs1) || (id_Rd == if_Rs2));
    assign if_write = id_doNOP;
    assign PCWrite  = id_doNOP;
endmodule
