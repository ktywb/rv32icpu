`include "decoder.v"
`timescale 1ns/100ps

// decoder.v TEST BENCH
module ex_alu_TB ;

    reg clk,reset;
    wire [15:0] max_value;
    wire [7:0] cathodes;
    wire [3:0] ano;

    initial begin
        clk <= 0;
        reset <= 1;
        #10
        reset <= 0;
    end

    always begin//时钟信号
        #5 
        clk <= ~clk; 
    end

    initial begin
        $dumpfile("wave.vcd");//产生波形文件
        $dumpvars;//也可直接写为$dumpvars;
        #500 //仿真时间
        $finish;
    end
    
    wire [31:0 ] inst;

    wire [6 :0 ] opcode = 7'b0110011;
    wire [4 :0 ] rd     = 5'b11000;
    wire [2 :0 ] fun3   = 3'b000;
    wire [4 :0 ] rs1    = 5'b10101;
    wire [4 :0 ] rs2    = 5'b01010;
    wire [6 :0 ] fun7   = 7'b0000000;

    /*
    wire  [4 :0] rs1;
    wire  [4 :0] rs2;
    wire  [4 :0] rd;
    */
    wire  [2 :0] alu_ctrl;        // 000 ~ 111                ALUOp
    wire  [0 :0] reg_w_ctrl;      // 0->nw  ; 1->w            RegWrite
    wire  [0 :0] alu_dataB_sel;   // 0->reg ; 1->imm          ALUSrc
    wire  [0 :0] pc_add_sel;      // 0->4   ; 1->imm          PCSrc
    wire  [0 :0] reg_w_data_sel;  // 0->mem ; 1->alu          MemtoReg
    wire  [0 :0] mem_read_ctrl;   // 0->nr  ; 1->r            MemRead
    wire  [0 :0] mem_write_ctrl;  // 0->nw  ; 1->w            MemWrite
    wire  [1: 0] jal_or_jalrF;    // 1->jal ; 2->jalr; else 0 jal or jalr flag 
    wire  [31:0] imm_exten;  
    wire  [1 :0] alu_op;

    //assign inst = {fun7,rs2,rs1,fun3,rd,opcode} ;
    assign inst = 32'b00000000000000000000110001100111;

    Decoder decoder(
                // in
                .inst(inst),

                // out
                .rs1(rs1),
                .rs2(rs2),
                .rd(rd),
                .alu_ctrl(alu_ctrl),
                .reg_w_ctrl(reg_w_ctrl),
                .alu_dataB_sel(alu_dataB_sel),
                .pc_add_sel(pc_add_sel),
                .reg_w_data_sel(reg_w_data_sel),
                .mem_read_ctrl(mem_read_ctrl),
                .mem_write_ctrl(mem_write_ctrl),
                .jal_or_jalrF(jal_or_jalrF),
                .imm_exten(imm_exten),
                .alu_op(alu_op)
            );

    /*
    always @(SYSCLK)
        #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;
    */

    always @(clk) begin
        
    end
        
    
endmodule