`include "defines.v"

module EX2MEM (

        // inst 
    input      [31:0 ] inst_i,
    output reg [31:0 ] inst_o,
/*- Norm -*/
    // in 
    input  [0 :0 ] clk,    
    input  [0 :0 ] rst_n,

/*- Data -*/
/*  // typeu_res
    input      [31:0 ] typeu_res_i,
    output reg [31:0 ] typeu_res_o,
    // pc_res
    input      [31:0 ] pc_res_i ,
    output reg [31:0 ] pc_res_o,            */
    // pc_wb
    input      [31:0 ] pc_wb_i ,
    output reg [31:0 ] pc_wb_o, 
    // wr_width
    input      [2 :0 ] wr_width_i,
    output reg [2 :0 ] wr_width_o,
    // alu_dataC -> address
    input      [31:0 ] alu_dataC_i,
    output reg [31:0 ] alu_dataCaddress_o,
    // reg_dataB -> 
    input      [31:0 ] reg_dataB_i,
    output reg [31:0 ] w_data_o,
    // rd
    input      [4 :0 ] rd_i,
    output reg [4 :0 ] rd_o,

/*- Ctrl -*/
    // B_J_Jr_ judge[c]
    input      [0 :0 ] c_i,
    output reg [0 :0 ] c_o,
    // reg_w_ctrl
    input      [0 :0 ] reg_w_ctrl_i,
    output reg [0 :0 ] reg_w_ctrl_o,
    // reg_w_data_sel
    input      [0 :0 ] reg_w_data_sel_i,
    output reg [0 :0 ] reg_w_data_sel_o,
    // mem_read_ctrl
    input      [0 :0 ] mem_read_ctrl_i,
    output reg [0 :0 ] mem_read_ctrl_o,
    // mem_write_ctrl
    input      [0 :0 ] mem_write_ctrl_i,
    output reg [0 :0 ] mem_write_ctrl_o,
    // fcC
    input      [0 :0 ] fcC_i,
    output reg [0 :0 ] fcC_o
);

    always @(posedge clk or negedge rst_n) begin
    // always @(posedge clk or rst_n==1'b0) begin
        // Data
//      typeu_res_o <= ( {32{ rst_n}} & typeu_res_i ) | ( {32{~rst_n}} & `ZERO_WORD );
//      pc_res_o <= ( {32{ rst_n}} & pc_res_i ) | ( {32{~rst_n}} & `ZERO_WORD );
        pc_wb_o            <= ( {32{ rst_n}} & pc_wb_i     ) | ( {32{~rst_n}} & `ZERO_WORD );
        wr_width_o         <= ( { 3{ rst_n}} & wr_width_i  ) | ( { 3{~rst_n}} &   3'b0     );
        alu_dataCaddress_o <= ( {32{ rst_n}} & alu_dataC_i ) | ( {32{~rst_n}} & `ZERO_WORD );
        w_data_o           <= ( {32{ rst_n}} & reg_dataB_i ) | ( {32{~rst_n}} & `ZERO_WORD );
        rd_o               <= ( { 5{ rst_n}} & rd_i        ) | ( { 5{~rst_n}} &   5'b0     );

        // Ctrl
        c_o              <= ( {1{ rst_n}} & c_i              ) | ( {1{~rst_n}} & 1'b0 );
        reg_w_ctrl_o     <= ( {1{ rst_n}} & reg_w_ctrl_i     ) | ( {1{~rst_n}} & 1'b1 );    // Active low
        reg_w_data_sel_o <= ( {1{ rst_n}} & reg_w_data_sel_i ) | ( {1{~rst_n}} & 1'b0 );
        mem_read_ctrl_o  <= ( {1{ rst_n}} & mem_read_ctrl_i  ) | ( {1{~rst_n}} & 1'b0 );
        mem_write_ctrl_o <= ( {1{ rst_n}} & mem_write_ctrl_i ) | ( {1{~rst_n}} & 1'b0 );     
        fcC_o            <= ( {1{ rst_n}} & fcC_i            ) | ( {1{~rst_n}} & 1'b0 );        

        // inst
        inst_o      <= ( {32{ rst_n}} & inst_i      ) | ( {32{~rst_n}} & `ZERO_WORD );
    end
  
endmodule   // endmodule EX2MEM