`include "defines.v"
module Decoder(
    // in
    input   [31:0] inst,
    input is_type_l,

    // out data
    output  [4 :0] rs1,
    output  [4 :0] rs2,
    output  [4 :0] rd,

    // out ctrl
    output  [3 :0] alu_ctrl,        // 0000 ~ 1001                ALUOp
    output  [0 :0] reg_w_ctrl,      // 0->nw  ; 1->w            RegWrite
    output  [0 :0] alu_dataB_sel,   // 0->reg ; 1->imm          ALUSrc

    output  [0 :0] pc_add_sel,      // 0->4   ; 1->imm          PCSrc
    
    output  [0 :0] reg_w_data_sel,  // 0->alu ; 1->mem          MemtoReg
    output  [0 :0] mem_read_ctrl,   // 0->nr  ; 1->r            MemRead
    output  [0 :0] mem_write_ctrl,  // 0->nw  ; 1->w            MemWrite

    // out other
    // output  [1: 0] jal_or_jalrF,    // 1->jal ; 2->jalr; else 0 jal or jalr flag 
    output  [9 :0] jbs_flag_cache,
                    // [beq ], [bne ], [blt ], [bge ], [bltu], [bgeu], [jal ], [jalr], [lui ], [auipc]
    output  [31:0] imm_exten, 
    output  [1 :0] alu_op,
    output  [2 :0] wr_width         // fun3  
);

    // split inst 
    wire  [6:0]   opcode ;
    wire  [2:0]   fun3 ;
    wire  [6:0]   fun7 ;
    
    assign opcode = inst[6 :0 ];
    assign fun3   = inst[14:12];
    assign fun7   = inst[31:25]; 

    wire [0 :0] is_inst;
    assign is_inst = (( inst[0] !== 1'bx ) && ( inst[0] !== 1'bz )) ? 1'b1 : 1'b0 ;
     
    // which type    
    wire [0 :0] type_I ;
    wire [0 :0] type_S ;
    wire [0 :0] type_B ;
    wire [0 :0] type_U ;
    wire [0 :0] type_J ;

    wire [31:0] imm_exten_I, 
                imm_exten_S,
                imm_exten_B,
                imm_exten_U,
                imm_exten_J;

    assign type_I = (opcode == `type_I ) | (opcode == `jalr ) | (opcode == `load_group ) | (opcode == `env_group ) ;
    assign type_S = (opcode == `type_S ) ;
    assign type_B = (opcode == `type_B ) ;
    assign type_U = (opcode ==   `lui  ) | (opcode == `auipc ) ;
    assign type_J = (opcode == `type_J ) ;

    // generate imm_exten for each type of inst
    assign imm_exten_I = { {21{inst[31]}} , inst[30:20] };                                  // 21+ 11
    assign imm_exten_S = { {21{inst[31]}} , inst[30:25] , inst[11:7] };                     // 21+ 6 + 5
    assign imm_exten_B = { {20{inst[31]}} , inst[7] , inst[30:25] , inst[11:8] , 1'b0 };    // 20+ 1 + 6 + 4 + 1
    assign imm_exten_U = { inst[31:12] , {12{1'b0}} };                                              // 20+ 12
    assign imm_exten_J = { {12{inst[31]}} , inst[19:12] , inst[20] , inst[30:21] , 1'b0 };  // 12+ 8 + 1 + 10+ 1

    // wire    [19:0]flaggggg;
    // assign flaggggg = inst[31:12];

    reg [31:0] imm_exten_r;

    // [ RegWrite ] write to rd ?
    wire [0:0] nw_to_rd;
    assign nw_to_rd = (opcode == `env_group) | (opcode == `type_S) | (opcode == `type_B) | (opcode == 7'b0000000);
    
    // [ MemtoReg ] who write to reg ? 0:alu ; 1:mem
    wire [0 :0] load_type ;
    assign load_type = (opcode == `load_group);  

    // [ MemRead  ] read from mem?

    // [ MemWrite ] write to mem?
    wire [0 :0] store_type;
    assign store_type = (opcode == `type_S);

    /* wdith of load or store data
       000-> lb,sb  read or write 1  byte，extens 8th  bit to 32 bit when read
       100-> lbu    read 1  byte，unsigned extens to 32 bit when read

       001-> lh,sh  read or write 2  byte，extens 16th bit to 32 bit when read
       101-> lhu    read 2  byte，unsigned extens to 32 bit when read     

       010-> lw ,sw read or write 32 bit  
    */ 

    /*
        1x-> byte
        01-> half
        00-> word  
    */

    // [  ALUSrc  ] who is alu_dataB? 0:reg ; 1:imm
    wire [0 :0] need_imm_type; //load store type_I jalr
    assign need_imm_type = (opcode==`load_group) | (opcode==`type_S) | (opcode==`type_I) ; //| (opcode==`jalr) | (opcode==`type_J);

    wire [0 :0] pc_imm_type;
    assign pc_imm_type = (opcode==`jal) | (opcode==`jalr) | (opcode==`type_J) | (opcode==`type_B);


    // wires which need be used now
    wire fun3eqs000 = (fun3 == 3'b000);
    wire fun3eqs001 = (fun3 == 3'b001);
    wire fun3eqs010 = (fun3 == 3'b010);
    wire fun3eqs011 = (fun3 == 3'b011);
    wire fun3eqs100 = (fun3 == 3'b100);
    wire fun3eqs101 = (fun3 == 3'b101);
    wire fun3eqs110 = (fun3 == 3'b110);
    wire fun3eqs111 = (fun3 == 3'b111);
    

    // jump or branch or special
    // [beq ], [bne ], [blt ], [bge ], [bltu], [bgeu], [jal ], [jalr], [lui ], [auipc]
    wire [0 :0 ] typeB = (opcode == `type_B) ? 1'b1 : 1'b0 ;

    // alu_ctrl generate
    /* alu_op : 00-> load/store; 
                10-> type_R; 
                01-> type_I; 
                11-> type_B
    */

    wire [3 :0] type_B_op;

    assign type_B_op = ( {4{  fun3[2] & fun3[1] }} & `SLTU )
                     | ( {4{  fun3[2] ^ fun3[1] }} & `SLT  )
                     | ( {4{~(fun3[2] & fun3[1])}} & `SUB  );

    wire [3 :0] type_RI_op;

    wire [0:0] add_sub, sra_srl, type_R_sel;
    assign add_sub = fun7[5] & opcode[5] ;          //assign add_sub = (fun7[5] == 1'b1);
    assign sra_srl = add_sub;
    
    assign type_RI_op = ( {4{fun3eqs000}} & ( ( {4{add_sub}} & `SUB ) | ( {4{~add_sub}} & `ADD ) ) )
                      | ( {4{fun3eqs001}} & `SLL  )
                      | ( {4{fun3eqs010}} & `SLT  )
                      | ( {4{fun3eqs011}} & `SLTU )
                      | ( {4{fun3eqs100}} & `XOR  )
                      | ( {4{fun3eqs101}} & ( ( {4{sra_srl}} & `SRA ) | ( {4{~sra_srl}} & `SRL ) )  )
                      | ( {4{fun3eqs110}} & `OR   )
                      | ( {4{fun3eqs111}} & `AND  );



    // wire out
    assign rd   = {5{is_inst}} & inst[11:7 ];
    assign rs1  = {5{is_inst}} & inst[19:15];
    assign rs2  = {5{is_inst}} & inst[24:20];   
                                                 // write or load mem
    wire reg_w_ctrl_temp = ( ( is_inst & (( nw_to_rd & 1'b1 ) | ( ~nw_to_rd & 1'b0 )))
                           | (~is_inst & 1'b1));            // ~(( nw_to_rd & 1'b0 ) | ( ~nw_to_rd & 1'b1 ))
    assign reg_w_ctrl = reg_w_ctrl_temp;
    assign alu_dataB_sel = is_inst & (( need_imm_type & 1'b1 ) | ( ~need_imm_type & 1'b0 ));  

    assign pc_add_sel = is_inst & (pc_imm_type ?  1'b1 : 1'b0);

    assign reg_w_data_sel = is_inst & (( load_type & 1'b1 ) | ( ~load_type & 1'b0 ));  
    assign mem_read_ctrl  = reg_w_data_sel;                                       //( load_type & 1'b1 ) | ( ~load_type & 1'b0 );
    assign mem_write_ctrl = is_inst & (( store_type & 1'b1 ) | ( ~store_type & 1'b0 ));

    assign jbs_flag_cache = {10{is_inst}} & {
            ( typeB & (fun3eqs000) ) ,        // beq
            ( typeB & (fun3eqs001) ) ,        // bne
            ( typeB & (fun3eqs100) ) ,        // blt
            ( typeB & (fun3eqs101) ) ,        // bge
            ( typeB & (fun3eqs110) ) ,        // bltu
            ( typeB & (fun3eqs111) ) ,        // bgeu
            ( opcode == `jal           ) ,    // jal
            ( opcode == `jalr          ) ,    // jalr
            ( opcode == `lui           ) ,    // lui
            ( opcode == `auipc         )      // auipc
        } ;

    assign imm_exten ={32{is_inst}} & 
               (  ( {32{type_I}} & imm_exten_I )
                | ( {32{type_S}} & imm_exten_S )
                | ( {32{type_B}} & imm_exten_B )
                | ( {32{type_U}} & imm_exten_U )
                | ( {32{type_J}} & imm_exten_J )); 
    assign alu_op    = { ( (opcode==`type_R) | (opcode==`type_B) ) , ( (opcode==`type_I) | (opcode==`type_B) ) };  
    
    assign alu_ctrl =  ( alu_op[1] ^ alu_op[0] ) ? type_RI_op :  // Type R or I
                ( alu_op[1] & alu_op[1] ) ? type_B_op  :  // Branch
                `ADD ;  
                
    assign wr_width  = fun3 ;  

endmodule // endmodule Decoder