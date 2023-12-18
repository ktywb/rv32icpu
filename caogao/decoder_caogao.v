`include "defines.v"

module decoder (
    input   [31:0]  inst    ,
    output  [6:0]   opcode  ,
    output  [2:0]   fun3    ,
    output  [6:0]   fun7    ,
    output  [4:0]   rs1     ,
    output  [4:0]   rs2     ,
    output  [4:0]   rd      ,
    output  [31:0]  imm_exten
);

wire TYPE_I;
wire TYPE_S;
wire TYPE_B;
wire TYPE_U;
wire TYPE_J;

assign opcode = inst[6 :0 ];
assign fun3   = inst[12:14];
assign fun7   = inst[25:31];
assign rs1    = inst[15:19];
assign rs2    = inst[20:24];
assign rd     = inst[7 :11];

assign imm_exten_I = { {20{instr[31]}}, instr[31:20]                                   };   // 20+ 12
assign imm_exten_S = { {21{instr[31]}}, instr[31:25], instr[11:7]                      };   // 21+ 7 + 4
assign imm_exten_B = { {20{instr[31]}}, instr[7]    , instr[30:25], instr[11:8] , 1'b0 };   // 20+ 1 + 6 + 3 + 1
assign imm_exten_U = { instr[31:12]   , {12{1'b0}}                                     };   // 10+ 12
assign imm_exten_J = { {12{instr[31]}}, instr[19:12], instr[20]   , instr[30:21], 1'b0 };   // 12+ 8 + 1 + 10+ 1

assign TYPE_I = (instr[6:0]==`jalr) | (instr[6:0]==`load) | (instr[6:0]==`I_type);
assign TYPE_S = (instr[6:0]==`store);
assign TYPE_B = (instr[6:0]==`B_type);
assign TYPE_U = (instr[6:0]==`lui) | (instr[6:0]==`auipc);
assign TYPE_J = (instr[6:0]==`jal);

assign imm_exten = TYPE_I ? imm_exten_I:
                    TYPE_S ? imm_exten_S:
                    TYPE_B ? imm_exten_B:
                    TYPE_U ? imm_exten_U:
                    TYPE_J ? imm_exten_J: 32'b0 ;
    
endmodule