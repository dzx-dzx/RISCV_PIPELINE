`include "if.v"
`include "if_id.v"
`include "id.v"
`include "register.v"
`include "id_ex.v"
`include "ex.v"
`include "ex_mem.v"
`include "mem.v"
`include "mem_wb.v"
`include "hazard.v"
`include "forwarding.v"
module riscv #(
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH = 32
) (

    input wire clk,
    input wire rst,  // high is reset

    // inst_mem
    input  wire [31:0] inst_i,
    output wire [31:0] inst_addr_o,
    output wire        inst_ce_o,

    // data_mem
    input  wire [31:0] data_i,       // load data from data_mem
    output wire        data_we_o,
    output wire        data_ce_o,
    output wire [31:0] data_addr_o,
    output wire [31:0] data_o        // store data to  data_mem

);
assign inst_ce_o = ~rst;

//  instance your module  below
wire [WORD_BITWIDTH-1:0] if_pc       ;
wire [WORD_BITWIDTH-1:0] if_id_pc    ;
wire                     ex_mem_PCSrc;
wire                     hz_PCWrite  ;
wire [WORD_BITWIDTH-1:0] id_imm      ;

IF #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) if_u (
    .clk       (clk         ),
    .rst       (rst         ),
    
    .PCSrc     (ex_mem_PCSrc),
    .hz_PCWrite(hz_PCWrite  ),
    .imm       (id_imm      ),
    .last_pc   (if_id_pc    ),
    
    .pc        (if_pc       )
);
assign inst_addr_o = if_pc;

wire [WORD_BITWIDTH-1:0] if_id_instruction;
wire                     hz_if_write      ;
IF_ID #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) if_id_u (
    .clk              (clk              ),
    .rst              (rst              ),
    
    .hz_write         (hz_if_write      ),
    
    .pc               (if_pc            ),
    .instruction      (inst_i           ),
    
    .id_wt_pc         (if_id_pc         ),
    .if_id_instruction(if_id_instruction)
);

wire                        id_branch    ;
wire                        id_memRead   ;
wire                        id_memToReg  ;
wire [                 1:0] id_ALUOp     ;
wire                        id_memWrite  ;
wire                        id_ALUSrc    ;
wire                        id_regWrite  ;
wire [REG_NUM_BITWIDTH-1:0] id_regToRead1;
wire [REG_NUM_BITWIDTH-1:0] id_regToRead2;
wire [REG_NUM_BITWIDTH-1:0] id_regToWrite;
wire [                 6:0] id_opcode    ;
wire [                 3:0] id_inst_ALU  ;

ID #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) id_u (
    .instruction(if_id_instruction),
    
    .branch     (id_branch        ),
    .memRead    (id_memRead       ),
    .memToReg   (id_memToReg      ),
    .ALUOp      (id_ALUOp         ),
    .memWrite   (id_memWrite      ),
    .ALUSrc     (id_ALUSrc        ),
    .regWrite   (id_regWrite      ),
    .regToRead1 (id_regToRead1    ),
    .regToRead2 (id_regToRead2    ),
    .regToWrite (id_regToWrite    ),
    .imm        (id_imm           ),
    .opcode     (id_opcode        ),
    .inst_ALU   (id_inst_ALU      )
);

wire [   WORD_BITWIDTH-1:0] id_regWriteData    ;
wire [   WORD_BITWIDTH-1:0] id_regReadData1    ;
wire [   WORD_BITWIDTH-1:0] id_regReadData2    ;
wire [REG_NUM_BITWIDTH-1:0] mem_wb_regToWrite  ;
wire [   WORD_BITWIDTH-1:0] mem_wb_regWriteData;
wire                        mem_wb_regWrite    ;

REGISTER #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) register (
    .clk       (clk                ),
    .rst       (rst                ),
    
    .regToRead1(id_regToRead1      ),
    .regToRead2(id_regToRead2      ),
    .regToWrite(mem_wb_regToWrite  ),
    .write_data(mem_wb_regWriteData),
    .doRegWrite(mem_wb_regWrite    ),
    .read_data1(id_regReadData1    ),
    .read_data2(id_regReadData2    )
);

wire fd_doNOP;

wire [                 1:0] id_ex_ALUOp        ;
wire                        id_ex_ALUSrc       ;
wire [   WORD_BITWIDTH-1:0] id_ex_regReadData1 ;
wire [   WORD_BITWIDTH-1:0] id_ex_regReadData2 ;
wire [   WORD_BITWIDTH-1:0] id_ex_imm          ;
wire [                 6:0] id_ex_opcode       ;
wire [                 3:0] id_ex_inst_ALU     ;
wire [REG_NUM_BITWIDTH-1:0] id_ex_Rs1          ;
wire [REG_NUM_BITWIDTH-1:0] id_ex_Rs2          ;
wire                        id_ex_wt_branch    ;
wire                        id_ex_wt_memRead   ;
wire                        id_ex_wt_memToReg  ;
wire                        id_ex_wt_memWrite  ;
wire                        id_ex_wt_regWrite  ;
wire [REG_NUM_BITWIDTH-1:0] id_ex_wt_regToWrite;
wire                        hz_id_doNOP        ;
ID_EX #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) id_ex_u (
    .clk             (clk                ),
    .rst             (rst                ),
    
    .branch          (id_branch          ),
    .memRead         (id_memRead         ),
    .memToReg        (id_memToReg        ),
    .ALUOp           (id_ALUOp           ),
    .memWrite        (id_memWrite        ),
    .ALUSrc          (id_ALUSrc          ),
    .regWrite        (id_regWrite        ),
    
    .inst_ALU        (id_inst_ALU        ),
    
    .Rs1             (id_regToRead1      ),
    .Rs2             (id_regToRead2      ),
    
    .doNOP           (hz_id_doNOP        ),
    .regReadData1    (id_regReadData1    ),
    .regReadData2    (id_regReadData2    ),
    .regToWrite      (id_regToWrite      ),
    .imm             (id_imm             ),
    .opcode          (id_opcode          ),
    
    .ex_ALUOp        (id_ex_ALUOp        ),
    .ex_ALUSrc       (id_ex_ALUSrc       ),
    
    .ex_regReadData1 (id_ex_regReadData1 ),
    .ex_regReadData2 (id_ex_regReadData2 ),
    .ex_imm          (id_ex_imm          ),
    .ex_opcode       (id_ex_opcode       ),
    .ex_inst_ALU     (id_ex_inst_ALU     ),
    
    .fd_Rs1          (id_ex_Rs1          ),
    .fd_Rs2          (id_ex_Rs2          ),
    
    .ex_wt_branch    (id_ex_wt_branch    ),
    .ex_wt_memRead   (id_ex_wt_memRead   ),
    .ex_wt_memToReg  (id_ex_wt_memToReg  ),
    .ex_wt_memWrite  (id_ex_wt_memWrite  ),
    .ex_wt_regWrite  (id_ex_wt_regWrite  ),
    .ex_wt_regToWrite(id_ex_wt_regToWrite)
);

wire                     ex_zero         ;
wire [WORD_BITWIDTH-1:0] ex_ALUresult    ;
wire [WORD_BITWIDTH-1:0] ex_mem_ALUresult;
wire [              1:0] forwardA        ;
wire [              1:0] forwardB        ;
EX #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) ex_u (
    .regReadData1   (id_ex_regReadData1 ),
    .regReadData2   (id_ex_regReadData2 ),
    .imm            (id_ex_imm          ),
    .ALUSrc         (id_ex_ALUSrc       ),
    .ALUOp          (id_ex_ALUOp        ),
    .inst_ALU       (id_ex_inst_ALU     ),
    .opcode         (id_ex_opcode       ),
    
    .fd_ex_mem_data1(ex_mem_ALUresult   ),
    .fd_ex_mem_data2(ex_mem_ALUresult   ),
    .fd_mem_wb_data1(mem_wb_regWriteData),
    .fd_mem_wb_data2(mem_wb_regWriteData),
    .forwardA       (forwardA           ),
    .forwardB       (forwardB           ),
    
    .zero           (ex_zero            ),
    .ALUresult      (ex_ALUresult       )
);



wire                     ex_mem_memToReg    ;
wire [WORD_BITWIDTH-1:0] ex_mem_regReadData2;
wire                     ex_mem_memRead     ;
wire                     ex_mem_memWrite    ;

wire                        ex_mem_wt_memToReg  ;
wire                        ex_mem_wt_regWrite  ;
wire [REG_NUM_BITWIDTH-1:0] ex_mem_wt_regToWrite;

EX_MEM #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) ex_mem_u (
    .clk              (clk                 ),
    .rst              (rst                 ),
    
    .memToReg         (id_ex_wt_memToReg   ),
    .regWrite         (id_ex_wt_regWrite   ),
    .branch           (id_ex_wt_branch     ),
    .memRead          (id_ex_wt_memRead    ),
    .memWrite         (id_ex_wt_memWrite   ),
    
    .ALUresult        (ex_ALUresult        ),
    .zero             (ex_zero             ),
    .regReadData2     (id_ex_regReadData2  ), //Also write through
    .regToWrite       (id_ex_wt_regToWrite ),
    
    .mem_memToReg     (ex_mem_memToReg     ),
    .mem_ALUresult    (ex_mem_ALUresult    ),
    .mem_regReadData2 (ex_mem_regReadData2 ),
    .mem_memRead      (ex_mem_memRead      ),
    .mem_memWrite     (ex_mem_memWrite     ),
    
    .PCSrc            (ex_mem_PCSrc        ),
    .mem_wt_memToReg  (ex_mem_wt_memToReg  ),
    .mem_wt_regWrite  (ex_mem_wt_regWrite  ),
    .mem_wt_regToWrite(ex_mem_wt_regToWrite)
);

assign data_we_o = ex_mem_memWrite;
assign data_ce_o = ex_mem_memRead;
wire [WORD_BITWIDTH-1:0] mem_regWriteData;
MEM #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) mem_u (
    .ALUresult   (ex_mem_ALUresult   ),
    .regReadData2(ex_mem_regReadData2),
    .memReadData (data_i             ),
    .memToReg    (ex_mem_memToReg    ),
    
    .regWriteData(mem_regWriteData   ),
    .address     (data_addr_o        ),
    .memWriteData(data_o             )
);


MEM_WB #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) mem_wb (
    .clk            (clk                 ),
    .rst            (rst                 ),
    
    .regWrite       (ex_mem_wt_regWrite  ),
    .memToReg       (ex_mem_wt_memToReg  ),
    .ALUresult      (ex_mem_ALUresult    ), //Also write through
    .memReadData    (data_i              ),
    .regToWrite     (ex_mem_wt_regToWrite),
    
    .wb_regWriteData(mem_wb_regWriteData ),
    .wb_regToWrite  (mem_wb_regToWrite   ),
    .wb_regWrite    (mem_wb_regWrite     )
);

Hazard #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) hazard_u (
    .id_memRead(id_ex_wt_memRead   ),
    .id_Rd     (id_ex_wt_regToWrite),
    .if_Rs1    (id_regToRead1      ),
    .if_Rs2    (id_regToRead2      ),
    
    .if_write  (hz_if_write        ),
    .PCWrite   (hz_PCWrite         ),
    .id_doNOP  (hz_id_doNOP        )
);

Forwarding #(
    .REG_NUM_BITWIDTH(REG_NUM_BITWIDTH),
    .WORD_BITWIDTH   (WORD_BITWIDTH   )
) forwarding_u (
    .id_Rs1      (id_ex_Rs1           ),
    .id_Rs2      (id_ex_Rs2           ),
    .ex_Rd       (ex_mem_wt_regToWrite),
    .mem_Rd      (mem_wb_regToWrite   ),
    .mem_regWrite(mem_wb_regWrite     ),
    .ex_regWrite (ex_mem_wt_regWrite  ),
    .forwardA    (forwardA            ),
    .forwardB    (forwardB            )
);
endmodule
