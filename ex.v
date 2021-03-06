`include "alu.v"
module EX #(
    parameter AND = 4'b0000,
    parameter OR = 4'b0001,
    parameter ADD = 4'b0010,
    parameter SUBTRACT = 4'b0110,
    parameter XOR = 4'b0011,
    parameter SLL = 4'b0100,
    parameter SRL = 4'b0101,
    parameter LESS_THAN = 4'b0111,
    parameter JAL = 4'b1000,

    parameter UNDEFINED = 4'b1111,

    parameter INST_R = 7'b0110011,
    parameter INST_I_LD = 7'b0000011,
    parameter INST_I_IMM = 7'b0010011,
    parameter INST_S = 7'b0100011,
    parameter INST_B = 7'b1100011,
    parameter INST_J = 7'b1101111,
    parameter INST_U = 7'b0010011,
    parameter REG_NUM_BITWIDTH = 5,
    parameter WORD_BITWIDTH = 32

) (
    input [WORD_BITWIDTH-1:0] regReadData1,
    input [WORD_BITWIDTH-1:0] regReadData2,
    input [WORD_BITWIDTH-1:0] imm,
    input ALUSrc,
    input [6:0] opcode,
    input [1:0] ALUOp,
    input [3:0] inst_ALU,  //(part of)funct7+funct3

    input [WORD_BITWIDTH-1:0] fd_ex_mem_data,
    input [WORD_BITWIDTH-1:0] fd_mem_wb_data,
    input [1:0] forwardA,
    input [1:0] forwardB,

    input [WORD_BITWIDTH-1:0] pc,

    output zero,
    output [WORD_BITWIDTH-1:0] ALUresult,
    output reg [WORD_BITWIDTH-1:0] readData2
);
wire [WORD_BITWIDTH-1:0] addend1  ;
wire [WORD_BITWIDTH-1:0] addend2  ;
reg  [WORD_BITWIDTH-1:0] readData1;
always @(*) begin
    case (forwardA)
        2'b00   : readData1 = regReadData1;
        2'b01   : readData1 = fd_mem_wb_data;
        2'b10   : readData1 = fd_ex_mem_data;
        default : readData1 = 32'hDEADBEEF;
    endcase
end
always @(*) begin
    case (forwardB)
        2'b00   : readData2 = regReadData2;
        2'b01   : readData2 = fd_mem_wb_data;
        2'b10   : readData2 = fd_ex_mem_data;
        default : readData2 = 32'hDEADBEEF;
    endcase
end
assign addend1        = opcode==INST_J?pc:readData1;
assign addend2        = opcode==INST_J?4:(ALUSrc?imm:readData2);


reg [3:0] operation;

always @(opcode or inst_ALU or ALUOp) begin//ALUOp stems from these two value, but isn't redundant?
    case (opcode)
        INST_R, INST_I_LD, INST_I_IMM, INST_S: begin
            case (ALUOp)
                2'b00 : operation = ADD;
                2'b01 : operation = SUBTRACT;
                2'b10, 2'b11: begin
                    case (inst_ALU[2:0])
                        3'b111  : operation = AND;
                        3'b110  : operation = OR;
                        3'b000  : operation = inst_ALU[3] ? SUBTRACT : ADD;
                        3'b100  : operation = XOR;
                        3'b001  : operation = SLL;
                        3'b101  : operation = SRL;
                        // default : operation = UNDEFINED;
                    endcase
                end
                // default : operation = UNDEFINED;
            endcase


        end
        INST_B : begin
            case (inst_ALU[2:0])
                3'b0    : operation = SUBTRACT;
                3'b100  : operation = LESS_THAN;
                // default : operation = UNDEFINED;
            endcase
        end
        INST_J : begin
            operation = JAL;
        end
        // default : operation = UNDEFINED;
    endcase
end
wire[WORD_BITWIDTH-1:0] result;
ALU #(
    .AND      (AND      ),
    .OR       (OR       ),
    .ADD      (ADD      ),
    .SUBTRACT (SUBTRACT ),
    .XOR      (XOR      ),
    .SLL      (SLL      ),
    .SRL      (SRL      ),
    .LESS_THAN(LESS_THAN),
    .JAL     (JAL     )
) alu (
    .operation(operation),
    .addend1  (addend1  ),
    .addend2  (addend2  ),
    .zero     (zero     ),
    .result   (result)
);
assign ALUresult=result;
endmodule
