module DECO(inst,reg_r_1,reg_r_2,reg_w,reg_w_ctrl,alu_ctrl,ctrl_1,ctrl_2,ctrl_3,mem_r,mem_w,imm,jump,branchop,MemSize,MemSignExt,s2_ctrl,jalr_ctrl);
    input [31:0] inst;

    output reg [4:0]reg_r_1;//读取的寄存器编号1
    output reg [4:0]reg_r_2;//读取的寄存器编号2
    output reg [4:0]reg_w;//写入的寄存器编号
    output reg reg_w_ctrl;//是否写入寄存器
    output reg [2:0]alu_ctrl;//ALU的控制信号
    output reg ctrl_1;//ALU的输入2作为寄存器的值或即时值
    output reg ctrl_2;//PC+4还是+立即数 也就是branch
    output reg ctrl_3;//写入寄存器的值是从存储器中读取的值还是ALU的输出
    output reg mem_r;//是否访问存储器
    output reg mem_w;//是否写入存储器
    output reg [31:0]imm;//指令中的立即数
    output reg jump;//是否无条件跳转 0:不跳转 1:跳转
    output reg [1:0]branchop; //跳转的种类
    output reg [1:0]MemSize;  //读取内存的长度，10/11:8位，01:16位，00:32位
    output reg MemSignExt;//当执行 lb、lh 等指令时，该信号需要置为 1，以对读取的数据进行符号扩展；
    //当执行 lbu、lhu 等指令时，该信号需要置为 0，以对读取的数据进行零扩展。
    output reg [2:0]s2_ctrl;//控制selector2
    output reg jalr_ctrl;



    reg [6:0] opcode ;
    reg [4:0] rd ;
    reg [4:0] rs1 ;
    reg [4:0] rs2 ;
    reg [3:0] funct3;
    reg [6:0] funct7 ;

   
// always @ (inst)
// begin
    
// end

always @ (inst)
begin

opcode = inst[6:0];
    rd = inst[11:7];
    rs1 = inst[19:15];
    rs2 = inst[24:20];
    funct3 = inst[14:12];
    funct7 = inst[31:25];




        case(opcode)
        7'b0110011:  //R-type
        begin   
            case(funct3)
            3'b000:
            begin
                if(funct7==7'b0000000)//ADD
                    begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
                else
                    begin       //SUB
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
            end
            3'b100:     //XOR
            begin
                begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b100;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
                end
            end
            3'b110:     //OR
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b010;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
            end
            3'b111:     //AND
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b011;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b001:     //Shift Left Logical
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b111;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b101:     
            begin
                if(funct7==7'b0000000)//Shift Right Logical
                    begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b110;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
                else
                    begin       //Shift Right Arith*
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b101;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
            end
            3'b010:    //Set Less Than
                    begin       
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b000;
                    end
            3'b011:     //Set Less Than（U）
                    begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_1 = 0;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        s2_ctrl = 3'b001;
                    end
            endcase
        end
        7'b0010011:  //I-type IMM
        begin
            case(funct3)
            3'b000:  //ADDI
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b100:  //XORI
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b100;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b110:  //ORI
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b010;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b111:  //ANDI
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b011;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{1'b0}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b001:  //Shift Left Logical Imm
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b111;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{27{1'b0}},inst[24:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
            end
            3'b101: 
            begin
                if(inst[31:25]==7'b0000000)//Shift Right Logical Imm
                    begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b110;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
                else //Shift Right Arith Imm
                    begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b101;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 1;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b111;
                    end
            end        
            3'b010:  //Set Less Than Imm
                    begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b010;
                    end
            3'b011:  //Set Less Than Imm(u)
                    begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        imm = {{20{1'b0}},inst[31:20]};
                        jump = 0;
                        s2_ctrl = 3'b011;
                    end
            endcase
        end
        7'b0000011: //I-type Load 
        begin
            case(funct3)
            3'b000:  //Load Byte
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 0;
                        mem_r = 1; 
                        mem_w = 0; 
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        MemSize = 2'b10;
                        MemSignExt = 1;
                        s2_ctrl = 3'b111;

            end
            3'b001:  //Load Half
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 0;
                        mem_r = 1; 
                        mem_w = 0; 
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        MemSize = 2'b01;
                        MemSignExt = 1;
                        s2_ctrl = 3'b111;
            end
            3'b010:  //Load Word
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 0;
                        mem_r = 1; 
                        mem_w = 0; 
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        MemSize = 2'b00;
                        MemSignExt = 1;
                        s2_ctrl = 3'b111;
            end
            3'b100:  //Load Byte(U)
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 0;
                        mem_r = 1; 
                        mem_w = 0; 
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        MemSize = 2'b10;
                        MemSignExt = 0;
                        s2_ctrl = 3'b111;
            end
            3'b111:  //Load Half(U)
            begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        ctrl_3 = 0;
                        mem_r = 1; 
                        mem_w = 0; 
                        imm = {{20{inst[31]}},inst[31:20]};
                        jump = 0;
                        MemSize = 2'b01;
                        MemSignExt = 0;
                        s2_ctrl = 3'b111;
            end
            endcase
        end
        7'b0100011: //S-type 
        begin
            case(funct3)
            3'b000:  //Store Byte  
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        mem_r = 1;
                        mem_w = 1;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
                        MemSize = 2'b10;
            end
            3'b001:  //Store Half
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        mem_r = 1;
                        mem_w = 1;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
                        MemSize = 2'b01;
            end
            3'b010:  //Store Word
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b000;
                        ctrl_1 = 1;
                        ctrl_2 = 0;
                        mem_r = 1;
                        mem_w = 1;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
                        MemSize = 2'b00;
            end
            endcase
        end
        7'b1100011: //B-type 
        begin
            case(funct3)
            3'b000:   // ==
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b00;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            3'b001:   // !=
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b01;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            3'b100:   // <
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b10;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            3'b101:   // >=
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b11;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            3'b110:   // <(u)
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b10;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{19{1'b0}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
            end
            3'b111:    //>=(u)
            begin
                        reg_r_1 = inst[19:15];
                        reg_r_2 = inst[24:20];
                        reg_w_ctrl = 0;
                        alu_ctrl = 3'b001;
                        ctrl_1 = 0;
                        ctrl_2 = 1;
                        branchop = 2'b11;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{19{1'b0}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
            end
            endcase
        end
        7'b1101111: //jal
        begin
                        reg_w = inst[11:7];//ok
                        reg_w_ctrl = 1;     //ok
                        mem_r = 0;   //ok
                        mem_w = 0;  //ok
                        ctrl_2 = 1;
                        jump = 1;
                        imm = {{12{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
        end
        7'b1100111: //jalr 
        begin
                        reg_r_1 = inst[19:15];
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {{20{inst[31]}},inst[31:20]};
                        jalr_ctrl = 1;
                        s2_ctrl = 3'b110;
        end
        7'b0110111: //lui左移12位  
        begin
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {inst[19:12],{24{1'b0}}};  
                        s2_ctrl = 3'b100;
        end
        7'b0010111://auipc rd=pc+(imm<<12)   
        begin
                        reg_w = inst[11:7];
                        reg_w_ctrl = 1;
                        ctrl_2 = 0;
                        mem_r = 0;
                        mem_w = 0;
                        jump = 0;
                        imm = {inst[19:12],{24{1'b0}}};
                        s2_ctrl = 3'b101;
        end
        endcase
end


endmodule