`include "pc_reg.v"
`include "decoder.v"
`include "ex_alu.v"
`include "rf32x32.v"
`include "other_modules.v"

`define START 32'h0001_0000

module Datapath(
    // in
    input  [0 :0 ] clk,
    input  [0 :0 ] rst_n,
    input  [0 :0 ] is_type_l,

    // i_mem io
    input  [31:0 ] inst_i,
    output [31:0 ] pc_out_o,

    // d_mem io
    input  [31:0 ] mem_read_data_i,
    output [31:0 ] mem_address_o,
    output [2 :0 ] wr_width_o,
    output [0 :0 ] mem_read_ctrl_o,
    output [0 :0 ] mem_write_ctrl_o,
    output [31:0 ] mem_write_data_o
);

    /* * * * * * *  wires   * * * * * * */
    // pc_reg
    // pc_in from plus4_plusimm_mux in PC_handle_part
    wire [31:0 ] pc_out;            //  to   PC_handle_part & I_mem            // maybe module Datapath output
    wire [31:0 ] pc_out_;            

    // I_mem
    wire [31:0 ] inst;              //  to   decoder                           // maybe module Datapath input

    // decoder
    wire [4 :0 ] rs1, rs2, rd;      //  to   regfile
    wire [31:0 ] imm_exten;         //  to   PC_handle_part & reg_imm_mux
    wire [9 :0 ] jbs_flag_cache;    //  to   B_J_Jr_judge
    wire [2 :0 ] wr_width;          //  to   D_mem                             // maybe module Datapath output        // var width need be correct to 2
    wire [3 :0 ] alu_ctrl;          //  to   ALU       
    wire [0 :0 ] alu_dataB_sel;     //  to   reg_imm_mux
    wire [0 :0 ] reg_w_ctrl;        //  to   regfile 
    wire [0 :0 ] reg_w_data_sel;    //  to   ALU_Dmem_mux
    wire [0 :0 ] mem_read_ctrl;     //  to   D_mem                             // maybe module Datapath output
    wire [0 :0 ] mem_write_ctrl;    //  to   D_mem                             // maybe module Datapath output

    // regfile
    wire [31:0 ] reg_dataA;         //  to   PC_handle_part & ALU
    wire [31:0 ] reg_dataB;         //  to   reg_imm_mux

    // reg_imm_mux
    wire [31:0 ] mux_ALU_dataB;     //  to   ALU

    // ALU
    wire [31:0 ] alu_dataC;         //  to   D_mem
    wire [0 :0 ] compare_res;       //  to   B_J_Jr_judge
    wire [0 :0 ] alu_zero;          //  to   B_J_Jr_judge

    // D_mem
    wire [31:0 ] r_data;            //  to   ALU_Dmem_mux

    // ALU_Dmem_mux
    wire [31:0 ] ALU_Dmem_mux_data; //  to   data_pc_mux

    // data_pc_mux
    wire [31:0 ] rd_data;           //  to   regfile

    // B_J_Jr_judge
    wire [0 :0 ] judge_a;           //  to   pc_reg_mux
    wire [0 :0 ] judge_b;           //  to   plus4_plusimm_mux
    wire [0 :0 ] judge_c;           //  to   data_pc_mux
    wire [0 :0 ] judge_d, judge_e;  //  to   typeu_1_mux; typeu_2_mux

    // pc_reg_mux
    wire [31:0 ] pc_reg_data;       //  to   pcoreg_imm_add

    // typeu_1_mux
    wire [31:0 ] typeu_1_wire;

    // pc_4_add
    wire [31:0 ] pc_plus4;          //  to  plus4_plusimm_mux &  data_pc_mux

    // pcoreg_imm_add
    wire [31:0 ] pcreg_plusimm;     //  to   plus4_plusimm_mux

    // plus4_plusimm_mux
    wire [31:0 ] pc_in;             //  to   pc_reg

    // typeu_2_mux
    wire [31:0 ] typeu_2_wire;

    /* * * * * * *  wires   * * * * * * */



    /* * * * * * * modules  * * * * * * */
    // pc_reg
    Pc_reg pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .pc_in(pc_in),
        .pc_out(pc_out),
        .pc_out_(pc_out_),
        .is_type_l(is_type_l)
    );

    // I_mem
    // in : pc_out
    // out: inst
    assign inst = inst_i;
    assign pc_out_o = pc_out;



    // decoder
    Decoder decoder(
        .inst(inst),
        .is_type_l(is_type_l),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm_exten(imm_exten),
        .jbs_flag_cache(jbs_flag_cache),
        .wr_width(wr_width),                   
        .alu_ctrl(alu_ctrl),              
        .alu_dataB_sel(alu_dataB_sel),  
        .reg_w_ctrl(reg_w_ctrl),
        .reg_w_data_sel(reg_w_data_sel),
        .mem_read_ctrl(mem_read_ctrl),
        .mem_write_ctrl(mem_write_ctrl),
        .alu_op(),.pc_add_sel()
    );


    
    rf32x32 rf(
        .clk(clk),
        .reset(rst_n),

        //.wr_n(rst_n & (is_type_l | reg_w_ctrl)),      
        .wr_n(reg_w_ctrl),
		.rd1_addr(rs1), 
        .rd2_addr(rs2), 
        .wr_addr(rd),
		.data_in(rd_data),

		.data1_out(reg_dataA), 
        .data2_out(reg_dataB)
    );


    // reg_imm_mux
    Mux reg_imm_mux(
        .select(alu_dataB_sel),
        .dataA(reg_dataB),
        .dataB(imm_exten),
        .dataC(mux_ALU_dataB)
    );

    // ALU
    Ex_alu alu(
        //.clk(clk),
        .rst_n(rst_n),
        .alu_ctrl(alu_ctrl),
        .alu_dataA(reg_dataA),
        .alu_dataB(mux_ALU_dataB),
        .alu_dataC(alu_dataC),
        .alu_zero(alu_zero),
        .alu_overflow(alu_overflow),
        .compare_res(compare_res)
    );


    // D_mem
    // in : 
    // out: mem_read_data
    assign mem_address_o = alu_dataC;
    assign wr_width_o = wr_width;
    assign mem_read_ctrl_o = mem_read_ctrl;
    assign mem_write_ctrl_o = mem_write_ctrl;
    assign mem_write_data_o = reg_dataB;


    // ALU_Dmem_mux
    Mux ALU_Dmem_mux(
        .select(reg_w_data_sel),
        .dataA(alu_dataC),
        .dataB(mem_read_data_i),
        .dataC(ALU_Dmem_mux_data)
    );

    // data_pc_mux
    Mux data_pc_mux(
        .select(judge_c),
        .dataA(ALU_Dmem_mux_data),
        .dataB(typeu_2_wire),
        .dataC(rd_data) //rd_data
    );

    /* * * * * * * modules  * * * * * * */



    // Judger B_J_Jr_judge(
    //     .jbs_flag_cache(jbs_flag_cache),
    //     .compare_res(compare_res),
    //     .alu_zero(alu_zero),
    //     .judge_a(judge_a),
    //     .judge_b(judge_b),
    //     .judge_c(judge_c),
    //     .judge_d(judge_d),
    //     .judge_e(judge_e)
    // );



    // --------------------------- 
    //    devide Judger into     
    //    JJrU_Judger & Branch_Judger
    // ---------------------------

    wire judge_b1, judge_b2, jjruF;
    JJrUJudger jjru_judger(
        .jjru_flag_cache(jbs_flag_cache[3:0]),
        .judge_a(judge_a),
        .judge_b1(judge_b1),
        .judge_d(judge_d),
        .judge_e(judge_e),
        .jjruF(jjruF)
        );
    BranchJudger branch_judger(
        .jjruF(jjruF),
        .b_flag_cache(jbs_flag_cache[9:4]),
        .compare_res(compare_res),
        .alu_zero(alu_zero),
        .judge_b2(judge_b2),
        .judge_c(judge_c)
    );
    assign judge_b = judge_b1 | judge_b2;



    /* * * * * * PC handle part* * * * * */
    // pc_reg_mux
    Mux pc_reg_mux(
        .select(judge_a),
        .dataA(pc_out_),
        .dataB(reg_dataA),           // reg_dataA
        .dataC(pc_reg_data)
    );

    // typeu_1_mux
    Mux typeu_1_mux(
        .select(judge_d),
        .dataA(pc_reg_data),
        .dataB(32'b0),           
        .dataC(typeu_1_wire)
    );

    // pc_4_add
    Add pc_4_add (
        .dataA(pc_out_),
        .dataB(32'd4),
        .cin(1'd0),
        .cout(),
        .dataC(pc_plus4)
    );

    // pcoreg_imm_add
    Add pcoreg_imm_add (
        .dataA(typeu_1_wire),
        .dataB(imm_exten),           // imm << 1
        .cin(1'd0),
        .cout(),
        .dataC(pcreg_plusimm)
    );

    // plus4_plusimm_mux
    Mux plus4_plusimm_mux(
        .select(judge_b),
        .dataA(pc_plus4),
        .dataB(pcreg_plusimm),
        .dataC(pc_in)
    );

    // typeu_2_mux
    Mux typeu_2_mux(
        .select(judge_e),
        .dataA(pc_plus4),
        .dataB(pcreg_plusimm),           
        .dataC(typeu_2_wire)
    );

/*-  TEST AREA  -*/
    wire rst_n_o;
    RegCondRster rster1(
        .clk(clk),
        .rst_n_i(rst_n),
        .ctrl_sig(judge_b1),
        .times(2'b10),
        .rst_n_o(rst_n_o)
    );

endmodule   // endlodule Datapath
