module EX_MEM #(
    parameter REG_NUM_BITWIDTH = 5 ,
    parameter WORD_BITWIDTH    = 32
) (
    input                             clk              ,
    input                             rst              ,
    input                             memToReg         ,
    input                             regWrite         ,
    input                             branch           ,
    input                             memRead          ,
    input                             memWrite         ,
    input      [   WORD_BITWIDTH-1:0] ALUresult        ,
    input                             zero             ,
    input      [   WORD_BITWIDTH-1:0] readData2        ,
    input      [REG_NUM_BITWIDTH-1:0] regToWrite       ,
    input      [   WORD_BITWIDTH-1:0] ex_pc            ,
    input      [   WORD_BITWIDTH-1:0] ex_imm           ,
    // input                             doNOP             ,
    output reg                        mem_memToReg     ,
    output reg [   WORD_BITWIDTH-1:0] mem_ALUresult    ,
    output reg [   WORD_BITWIDTH-1:0] mem_readData2    ,
    output reg                        PCSrc            ,
    output reg                        mem_memRead      ,
    output reg                        mem_memWrite     ,
    output reg                        mem_wt_memToReg  ,
    output reg                        mem_wt_regWrite  ,
    output reg [REG_NUM_BITWIDTH-1:0] mem_wt_regToWrite,
    output reg [   WORD_BITWIDTH-1:0] ex_mem_branch_pc
);
    //Note that they are combinational!
    always @(*) begin
        ex_mem_branch_pc = ex_pc+ex_imm;
    end
    always @(*) begin
        PCSrc = branch & zero;
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_memToReg <= 0;
        end else begin
            mem_memToReg <= memToReg;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_ALUresult <= 0;
        end else begin
            mem_ALUresult <= ALUresult;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_readData2 <= 0;
        end else begin
            mem_readData2 <= readData2;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_memRead <= 0;
        end else begin
            mem_memRead <= memRead;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_memWrite <= 0;
        end else begin
            mem_memWrite <= memWrite;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wt_memToReg <= 0;
        end else begin
            mem_wt_memToReg <= memToReg;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wt_regWrite <= 0;
        end else begin
            mem_wt_regWrite <= regWrite;
        end
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wt_regToWrite <= 0;
        end else begin
            mem_wt_regToWrite <= regToWrite;
        end
    end

endmodule
