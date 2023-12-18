`include "defines.v"
/*        code
operate   3 210 
  add     0 000
  sub     0 001

  or      0 010
  and     0 011
  xor     0 100

  sra     0 111  
  srl     0 101
  sll     0 110

  slt     1 000
  sltu    1 001
*/

module Ex_alu (
    // in
    //input   [0 :0]      clk          ,
    input   [0 :0]      rst_n         ,
    
//  input   [2 :0]      alu_ctrl     ,
    input   [3 :0]      alu_ctrl     ,
    input   [31:0]      alu_dataA    ,
    input   [31:0]      alu_dataB    ,

    // out
    output  [31:0]      alu_dataC    ,
    output  [0 :0]      alu_zero     ,
    output  [0 :0]      alu_overflow ,
    output  [0 :0]      compare_res
    );


    //reg [31:0] result
    wire [31:0] add_result;
    wire [31:0] logic_result;
    wire [31:0] shift_result;
    wire [1 :0] OpF;
    wire [1 :0] ShiftOpF;
    wire [1 :0] LogiOpF;

    wire [31:0] add_result_temp;
    wire [31:0] shift_result_temp;
    wire [31:0] slt_result;

    // OPeration Flag
    assign OpF1 = (alu_ctrl[2] | alu_ctrl[1]); 
    assign OpF2 = ((alu_ctrl[2] & alu_ctrl[0]) | (alu_ctrl[2] & alu_ctrl[1]));
    assign OpF  = {OpF1, OpF2};                                         //   00->add ;  10->logic ;  11->shift

    assign Ovctr = (alu_ctrl == 4'b0001) ;                        //& alu_ctrl[0];    when 'add' , 'sub' 
    assign LogiOpF = alu_ctrl[1:0];
    assign ShiftOpF = alu_ctrl[1:0];
    assign SubOpF = ( alu_ctrl == 3'b001 ) | ( alu_ctrl[3] );           //  assign SubOpF = ( alu_ctrl == 3'b001 );

    // ADD OPERATE
    wire [0 :0] add_carry ;
    wire [0 :0] add_overflow;
    // assign dataB = ( {32{ SubOpF}} & ((~alu_dataB)+ 1) )
    //              | ( {32{~SubOpF}} & alu_dataB         );
    //assign dataB = ({32{SubOpF}}) ^ alu_dataB;
    Adder adder(
        .alu_dataA(alu_dataA),
        .alu_dataB(alu_dataB),
        .SubOpF(SubOpF),
        .add_ctrl(SubOpF),
        .add_carry(add_carry),
        .add_result(add_result_temp),
        .add_zero(alu_zero),
        .add_overflow(add_overflow)
    );  
    assign alu_overflow = add_overflow  & Ovctr;

/**/
    wire [0 :0 ] slt_add;
    // slt        
    wire [0 :0 ] unsign;       // for slt&sltu : unsigned->0 ; signed->1   
    wire [0 :0 ] us_op;
    wire [0 :0 ] s_op;
    wire [0 :0 ] selected_result;
                                     //                       1xx0        1xx1
    assign unsign = !alu_ctrl[0];     // for slt&sltu : unsigned->0 ; signed->1    

    assign us_op = add_carry ^ SubOpF ;             // 
    assign s_op  = add_overflow ^ add_result_temp[31];


    assign selected_result = (  unsign ) & us_op
                           | ( ~unsign ) & s_op ;

    assign slt_result = ( {32{ selected_result}} ) & 32'h00000001       // a <  b
                      | ( {32{~selected_result}} ) & 32'h00000000;      // a >= b
    //assign slt_result = 32'h11111111;

/*    assign add_result = (({32{ alu_ctrl[3]}}) & slt_result
                      | ({32{~alu_ctrl[3]}}) & add_result_temp) ;*/
    assign slt_add = alu_ctrl[3];
    assign add_result = ( {32{ rst_n}} & (({32{ slt_add}}) & slt_result
                                        | ({32{~slt_add}}) & add_result_temp) )
                      | ( {32{~rst_n}} & `ZERO_WORD );



    // logic
    assign logic_result = ( {32{ rst_n}} & (( {32{LogiOpF == 2'b10}} & (alu_dataA | alu_dataB) )
                                          | ( {32{LogiOpF == 2'b11}} & (alu_dataA & alu_dataB) )
                                          | ( {32{LogiOpF == 2'b00}} & (alu_dataA ^ alu_dataB) )) )
                        | ( {32{~rst_n}} & `ZERO_WORD );
                                

    // SHIFT OPERATE
    wire [4:0] bit_num;
    assign bit_num = alu_dataB[4:0];
    Shifter shifter(
        .alu_dataA(alu_dataA) ,
        .bit_num(bit_num),
        .ShiftOpF(ShiftOpF),
        .shift_result(shift_result_temp)
    );
    assign shift_result = ( {32{ rst_n}} & shift_result_temp )
                        | ( {32{~rst_n}} & `ZERO_WORD );


    // RESULT OUT
    reg [31: 0] alu_dataC_r ;
    always @ (*) 
        alu_dataC_r = ( {32{OpF == 2'b00}} & add_result   )
                    | ( {32{OpF == 2'b10}} & logic_result )
                    | ( {32{OpF == 2'b11}} & shift_result )
                    | ( {32{   ~rst_n   }} & `ZERO_WORD   );
    assign alu_dataC = alu_dataC_r ;

    

    assign compare_res = alu_dataC[0];

endmodule // endmodule ex_alu



// --------- modules --------- //

// Shifter
module Shifter (
    input   [31:0]  alu_dataA   ,
    input   [4 :0]  bit_num     ,
    input   [1 :0]  ShiftOpF    ,

    output  [31:0]  shift_result
    );

    assign shift_result  =  (ShiftOpF == 2'b11) ? ( ({32{alu_dataA[31]}} << (6'd32-{1'b0, bit_num})) | (alu_dataA >> bit_num) ) :   // sra 11
                            (ShiftOpF == 2'b01) ? alu_dataA>>bit_num :   // srl 01
                            (ShiftOpF == 2'b10) ? alu_dataA<<bit_num :   // sll 10
                            `ZERO_WORD ;
    // assign shift_result = ( {32{ShiftOpF == 2'b01}} & ( alu_dataA>>>bit_num ) )
    //                     | ( {32{ShiftOpF == 2'b10}} & ( alu_dataA>>bit_num ) )
    //                     | ( {32{ShiftOpF == 2'b11}} & ( alu_dataA<<bit_num ) );

endmodule   // endmodule Shifter

// Adder
module Adder (                          // [ ! ]
    input   [31:0]  alu_dataA ,
    input   [31:0]  alu_dataB ,
    input   [0 :0]  SubOpF ,
    input   [0 :0]  add_ctrl ,

    output  [0 :0]  add_carry,
    output  [31:0]  add_result,
    output  [0 :0]  add_zero,
    output  [0 :0]  add_overflow
    );

    wire [32:0] full_res ; 
    wire [31:0] dataB;

    assign dataB = ({32{SubOpF}}) ^ alu_dataB;
    assign full_res   = alu_dataA + dataB + SubOpF;      
    assign add_carry  = full_res[32];
    assign add_result = full_res[31:0] ;

    assign add_zero = ~( |add_result );
    assign add_overflow = (add_ctrl == 3'b0) & ~alu_dataA[31] & ~alu_dataB[31] &  add_result[31]      // + + + = -
                        | (add_ctrl == 3'b0) &  alu_dataA[31] &  alu_dataB[31] & ~add_result[31]      // - + - = +
                        | (add_ctrl == 3'b1) & ~alu_dataA[31] &  alu_dataB[31] &  add_result[31]      // + - - = -
                        | (add_ctrl == 3'b1) &  alu_dataA[31] & ~alu_dataB[31] & ~add_result[31];     // - - + = +

endmodule   // endmodule Adder
