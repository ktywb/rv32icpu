`include "defines.v"

module IF2ID (
/*- Norm -*/
    // in
    input  [0 :0 ] clk,    
    input  [0 :0 ] rst_n,

/*- Data -*/
    // pc_out_
    input      [31:0 ] pc_out_i,
    output reg [31:0 ] pc_out_o,
    // inst 
    input      [31:0 ] inst_i,
    output reg [31:0 ] inst_o,

/*- Ctrl -*/    
    // is_jjru
    input      [0 :0 ] is_jjru_i,
    output reg [0 :0 ] is_jjru_o,
    // fcD
    input      [0 :0 ] fcD_i,
    output reg [0 :0 ] fcD_o,
    // b2
    input      [0 :0 ] b2_i,
    output reg [0 :0 ] b2_o     
);

    always @(posedge clk or rst_n==1'b0) begin
    // always @(posedge clk or negedge rst_n) begin
        // pc_out_
        pc_out_o    <= ( {32{ rst_n}} & pc_out_i    ) | ( {32{~rst_n}} & `ZERO_WORD );
        // inst
        inst_o      <= ( {32{ rst_n}} & inst_i      ) | ( {32{~rst_n}} & `ZERO_WORD );
        // is_jjru
        is_jjru_o   <= ( { 1{ rst_n}} & is_jjru_i   ) | ( { 1{~rst_n}} &   1'b0     );
        // fcD
        fcD_o       <= ( { 1{ rst_n}} & fcD_i       ) | ( { 1{~rst_n}} &   1'b0     );
        // b2
        b2_o        <= ( { 1{ rst_n}} & b2_i        ) | ( { 1{~rst_n}} &   1'b0     );
    end
    
endmodule   // endmodule IF2ID

module IF2IDWithStall (
/*- Norm -*/
    // in
    input  [0 :0 ] clk,    
    input  [0 :0 ] rst_n,

/*- Data -*/
    // pc_out_
    input      [31:0 ] pc_out_i,
    output reg [31:0 ] pc_out_o,
    // inst 
    input      [31:0 ] inst_i,
    output reg [31:0 ] inst_o,

/*- Ctrl -*/    
    // is_jjru
    input      [0 :0 ] is_jjru_i,
    output reg [0 :0 ] is_jjru_o,
    // is_jr
    input      [0 :0 ] is_jr_i,
    output reg [0 :0 ] is_jr_o,
    // fcD
    input      [0 :0 ] fcD_i,
    output reg [0 :0 ] fcD_o,
    // b2
    input      [0 :0 ] b2_i,
    output reg [0 :0 ] b2_o     
);

    always @(posedge clk or rst_n==1'b0) begin
    // always @(posedge clk or negedge rst_n) begin
        // pc_out_
        pc_out_o    <= ( {32{ rst_n}} & pc_out_i    ) | ( {32{~rst_n}} & `ZERO_WORD );
        // inst
        inst_o      <= ( {32{ rst_n}} & ( {32{ fcD_i}} & inst_o
                                        | {32{~fcD_i}} & inst_i ) ) 
                     | ( {32{~rst_n}} & `ZERO_WORD );

        // is_jjru
        is_jjru_o   <= ( { 1{ rst_n}} & ( { 1{ fcD_i}} & is_jjru_o
                                        | { 1{~fcD_i}} & is_jjru_i ) ) 
                     | ( { 1{~rst_n}} &   1'b0     );

        // is_jr
        is_jr_o     <= ( { 1{ rst_n}} & ( { 1{ fcD_i}} & is_jr_o
                                        | { 1{~fcD_i}} & is_jr_i ) ) 
                     | ( { 1{~rst_n}} &   1'b0     );

        // fcD
        fcD_o       <= ( { 1{ rst_n}} & ( { 1{ fcD_i}} & fcD_o
                                        | { 1{~fcD_i}} & fcD_i ) ) 
                     | ( { 1{~rst_n}} &   1'b0     );

        // b2
        b2_o        <= ( { 1{ rst_n}} & ( { 1{ fcD_i}} & b2_o
                                        | { 1{~fcD_i}} & b2_i ) ) 
                     | ( { 1{~rst_n}} &   1'b0     );
    end
    
endmodule   // endmodule IF2IDWithStall