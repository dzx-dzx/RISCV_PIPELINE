module Hazard #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input                         id_memRead,
    input  [REG_NUM_BITWIDTH-1:0] id_Rd     ,
    input  [REG_NUM_BITWIDTH-1:0] if_Rs1    ,
    input  [REG_NUM_BITWIDTH-1:0] if_Rs2    ,
    input                         PCSrc     ,
    output                        if_write  ,
    output                        PCWrite   , //Implementation yet to be confirmed.
    output                        if_doNOP  ,
    output                        id_doNOP  ,
    output                        ex_doNOP
);
    wire dataHazard   ;
    wire controlHazard;
    assign dataHazard    = id_memRead && ((id_Rd == if_Rs1) || (id_Rd == if_Rs2));
    assign controlHazard = PCSrc;

    assign id_doNOP = dataHazard|controlHazard;
    // always @(*) begin
    //     id_doNOP = id_memRead && ((id_Rd == if_Rs1) || (id_Rd == if_Rs2));
    // end
    assign if_write = dataHazard;
    assign PCWrite  = dataHazard;

    assign if_doNOP = controlHazard;
    assign ex_doNOP = controlHazard;
endmodule
