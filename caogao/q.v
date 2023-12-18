`timescale 1ns/1ps
`define IN_TOTAL 10000  // 最大シミュレーション時間 = 10000 クロックサイクル

module top_test;
    //*** 参数声明 ***//
    parameter CYCLE = 10;                       // 时钟周期时间 = 10ns
    parameter HALF_CYCLE = 5;                   // 时钟周期时间的一半 = 5ns
    parameter STB = 8;
    parameter SKEW = 2;
    parameter BIT_WIDTH = 32;                   // 1 word = 32bit
    parameter BYTE_SIZE = 8;                    // 1 byte = 8bit
    parameter IMEM_LATENCY = 1;                 // 指令内存的延迟 = 1时钟周期
    parameter DMEM_LATENCY = 1;                 // 数据内存的延迟 = 1时钟周期
    parameter IMEM_SIZE = 8000000;              // 指令内存的大小 = 8000000 byte
    parameter DMEM_SIZE = 8000000;              // 数据内存的大小 = 8000000 byte
    parameter STDOUT_ADDR = 32'hf0000000;       // 用于输出的特殊地址。当执行 sb 指令将内容作为字符输出到屏幕时，将使用此地址
    parameter EXIT_ADDR = 32'hff000000;         // 用于结束模拟的特殊地址。执行针对该地址的存储指令将结束模拟

    //*** reg,wire 声明 ***//
    reg clk,rst;                                // 时钟信号，复位信号
    reg ACKD_n;                                 // 数据内存的应答信号（低电平有效）
    reg ACKI_n;                                 // 指令内存的应答信号（低电平有效）
    reg [BIT_WIDTH-1:0] IDT;                    // 指令内存的32位数据总线
    reg [2:0] OINT_n;                           // 外部中断信号（低电平有效）
    reg [BIT_WIDTH-1:0] Reg_temp;               // 输出寄存器内容时使用的临时变量

    wire [BIT_WIDTH-1:0] IAD;                   // 指令内存的32位地址总线
    wire [BIT_WIDTH-1:0] DAD;                   // 数据内存的32位地址总线
    wire MREQ;                                  // 数据内存请求信号
    wire WRITE;                                 // 数据内存写请求信号
    wire [1:0] SIZE;                            // 用于指定数据内存访问单位（bit, half word, word）的信号
    wire IACK_n;                                // 外部中断的应答信号
    wire [BIT_WIDTH-1:0] DDT;                   // 数据内存的32位数据总线

    integer i;
    integer CIL, CDLL, CDSL;                    // 为了模拟指令内存，数据内存的延迟，从访问开始到保持时间的计数器。
   integer              Reg_data, Dmem_data;  // ファイルポインタ．Reg_data はファイル Reg_out.dat, Dmem_data はファイル Dmem_out.dat に出力するために用いる
   integer              Max_Daddr;            // データメモリへアクセスのあった最大アドレスを保持．(Dmem_out.dat には 0 〜 Max_Daddr までの内容のみを出力）
   reg [BIT_WIDTH-1:0]  Daddr, Iaddr;         // データメモリへのアクセスアドレス，命令メモリへのアクセスアドレスを一時的に保持しておくためのレジスタ

   reg [BYTE_SIZE-1:0]   DATA_Imem[0:IMEM_SIZE];   // 命令メモリ
   reg [BYTE_SIZE-1:0]   DATA_Dmem[0:DMEM_SIZE];   // データメモリ

   //*** top  ***//
   top u_top_1(//Inputs
               .clk(clk), .rst(rst),
               .ACKD_n(ACKD_n), .ACKI_n(ACKI_n), 
               .IDT(IDT), .OINT_n(OINT_n),
      
               //Outputs
               .IAD(IAD), .DAD(DAD), 
               .MREQ(MREQ), .WRITE(WRITE), 
               .SIZE(SIZE), .IACK_n(IACK_n), 
      
               //Inout
               .DDT(DDT)
               );

   
     //*** 时钟生成 ***//
     always begin
        clk = 1'b1;
        #(HALF_CYCLE) clk = 1'b0;
        #(HALF_CYCLE);
     end


    //*** 初始化 ***//
    initial begin
        //*** 读取输入数据 ***//
        $readmemh("./Dmem.dat", DATA_Dmem);  // 将数据内存的内容（Dmem.dat中的内容）存储到 DATA_Dmem
        $readmemh("./Imem.dat", DATA_Imem);  // 将指令内存的内容（Imem.dat中的内容）存储到 DATA_Imem

        Max_Daddr = 0;  // 将 Max_Daddr 初始化为 0

        //*** 重置 OINT_n, ACKI_n, ACKD_n, CIL, CDL ***//
        OINT_n = 3'b111;  // 没有外部中断
        ACKI_n = 1'b1;    // 初始化指令内存的应答信号
        ACKD_n = 1'b1;    // 初始化数据内存的应答信号
        CIL = 0;          // 初始化用于模拟指令内存延迟的计数器
        CDLL = 0;         // 初始化用于模拟数据内存读取延迟的计数器
        CDSL = 0;         // 初始化用于模拟数据内存写入延迟的计数器

        //*** 执行复位 ***//
        rst = 1'b1;
        #1 rst = 1'b0;
        #CYCLE rst = 1'b1;
    end



     //*** プログラムの実行 ***//
    initial begin
        #HALF_CYCLE;  // 延迟半个时钟周期。为了避免信号在关键时刻（时钟上升沿）发生跳变。

        //*** 执行最大 IN_TOTAL 个时钟周期的程序 ***//
        for (i = 0; i < `IN_TOTAL; i =i +1)
        begin

            Iaddr = u_top_1.IAD;  // 将指令内存访问地址存储到 Iaddr
            fetch_task1;          // 从指令内存中获取指令

            Daddr = u_top_1.DAD;  // 将数据内存访问地址存储到 Daddr
            load_task1;           // 执行加载（如果有内存访问请求）
            store_task1;          // 执行存储（如果有内存访问请求）
            
            // #(STB);
            #CYCLE;               // 推进1个时钟周期时间
            release DDT;          // 释放之前用 force 固定的 DDT 值（详见下面的 load_task1）

        end // for (i = 0; i < `IN_TOTAL; i =i +1)

        $display("¥nReach IN_TOTAL.");    // 输出消息。已达到最大仿真时间，结束

        dump_task1;   // 将数据内存内容输出到 Dmem_out.dat，通用寄存器内容输出到 Reg_out.dat

        $finish;      // 结束仿真

    end // initial begin


   //*** description for wave form ***//
   initial begin
      $monitor($stime," PC=%h", IAD);   // PC の値を monitor する．
      $shm_open("waves.shm");
      $shm_probe("AS");
   end



    //*** 以下为 task（类似于 C 语言中的函数） ***//

    task fetch_task1; // 用于从指令内存中取指的任务
        begin
        CIL = CIL + 1; // 计数从指令内存访问开始的时间
        if(CIL == IMEM_LATENCY) // 当 CIL 达到指令内存延迟时，在指令内存数据总线上放入指令
            begin
                IDT = {DATA_Imem[Iaddr], DATA_Imem[Iaddr+1], DATA_Imem[Iaddr+2], DATA_Imem[Iaddr+3]}; // 将指令放入指令内存数据总线上
                ACKI_n = 1'b0; // 将应答信号设为有效
                CIL = 0; // 重置 CIL
            end
        else // CIL 尚未达到指令内存延迟
            begin
                IDT = 32'hxxxxxxxx; // 指令数据总线的值不确定
                ACKI_n = 1'b1; // 将应答信号设为无效
            end // else: !if(CIL == IMEM_LATENCY)
        end
    endtask // fetch_task1

    task load_task1; // 用于从数据内存中读取的任务
    begin
        if(u_top_1.MREQ && !u_top_1.WRITE) // 如果有数据内存请求且非写入操作
            begin
            if (Max_Daddr < Daddr)    // 更新 Max_Daddr
                begin
                Max_Daddr = Daddr;
                end

            CDLL = CDLL + 1;  // 计数从读取访问开始的时间
            CDSL = 0;         // 将写入访问开始的时间设为 0
            if(CDLL == DMEM_LATENCY)  // 当 CDLL 达到数据内存延迟时，在数据内存数据总线上放入数据
                begin
                if(SIZE == 2'b00)
                    begin
                        force DDT[BIT_WIDTH-1:0] = {DATA_Dmem[Daddr], DATA_Dmem[Daddr+1],     // 从数据内存中读取（word）
                                                    DATA_Dmem[Daddr+2], DATA_Dmem[Daddr+3]};  // 强制更改 DDT 的内容（wire 类型），设为读取到的数据值
                    end              
                else if(SIZE == 2'b01)
                    begin
                        force DDT[BIT_WIDTH-1:0] = {{16{1'b0}}, DATA_Dmem[Daddr], DATA_Dmem[Daddr+1]};  // 从数据内存中读取（half word）
                    end
                else
                    begin
                        force DDT[BIT_WIDTH-1:0] = {{24{1'b0}}, DATA_Dmem[Daddr]};  // 从数据内存中读取（byte）
                    end

                    end // else: !if(SIZE == 2'b01)

                ACKD_n = 1'b0;  // 将应答信号设为有效
                CDLL = 0;       // 重置 CDLL

                end // if (CDLL == DMEM_LATENCY)
            else  // CDLL 尚未达到数据内存延迟
                begin
                ACKD_n = 1'b1;  // 将应答信号设为无效
                end // else: !if(CDLL == DMEM_LATENCY)
        end // if (u_top_1.MREQ && !u_top_1.WRITE)
    end

endtask // load_task1


   task store_task1;  // データメモリへの書き込み用のタスク
      begin
         if(u_top_1.MREQ && u_top_1.WRITE)  //  データメモリにリクエストがあり，書き込みであったら
           begin

              if (Daddr == EXIT_ADDR)    // アクセスアドレスが EXIT_ADDR と一致したら
                begin
                   $display("¥nExited by program.");  // メッセージを出力．プログラムによって，シミュレーションが終了させられた
                   dump_task1;  // データメモリの内容を Dmem_out.dat に，汎用レジスタの内容を Reg_out.dat に出力
                   $finish;     // シミュレーションを終了
                end
              else if (Daddr != STDOUT_ADDR)  // アクセスアドレスが STDOUT_ADDR と一致していなかったら
                begin
                   if (Max_Daddr < Daddr)     // Max_Daddr の更新
                     begin
                        Max_Daddr = Daddr;
                     end
                end

              CDSL = CDSL + 1;  // 書き込みアクセス開始からの時間をカウントアップ
              CDLL = 0;         // 読み出しアクセス開始からの時間を 0 にする

              if(CDSL == DMEM_LATENCY)  // CDSL がデータメモリのレイテンシに達したら，データをメモリに書き込む
                begin
                   if(SIZE == 2'b00)
                     begin
                        DATA_Dmem[Daddr]   = DDT[BIT_WIDTH-1:BIT_WIDTH-8];     //
                        DATA_Dmem[Daddr+1] = DDT[BIT_WIDTH-9:BIT_WIDTH-16];    //  データメモリへの書き込み（word）
                        DATA_Dmem[Daddr+2] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];   //
                        DATA_Dmem[Daddr+3] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];   //
                     end
                   else if(SIZE == 2'b01)
                     begin
                        DATA_Dmem[Daddr] = DDT[BIT_WIDTH-17:BIT_WIDTH-24];     //  データメモリへの書き込み（half word）
                        DATA_Dmem[Daddr+1] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];   //
                     end
                   else
                     begin
                        if (Daddr == STDOUT_ADDR)  // アドレスが STDOUT_ADDR と一致していたら
                          begin
                             $write("%c", DDT[BIT_WIDTH-25:BIT_WIDTH-32]);  // ストアする内容を画面に出力
                          end
                        else
                          begin
                             DATA_Dmem[Daddr] = DDT[BIT_WIDTH-25:BIT_WIDTH-32];  // データメモリへの書き込み（byte）
                          end
                     end // else: !if(SIZE == 2'b01)
                   
                   ACKD_n = 1'b0;  // アクノリッジ信号をアクティブにする
                   CDSL = 0;       // 書き込みアクセス開始からの時間を 0 にする

                end // if (CDSL == DMEM_LATENCY)
              else  // CDSL がデータメモリのレイテンシに達していなかったら
                begin
                   ACKD_n = 1'b1;  // アクノリッジ信号をインアクティブにする
                end // else: !if(CDSL == DMEM_LATENCY)
           end // if (u_top_1.MREQ && u_top_1.WRITE)             
      end
   endtask // store_task1

   task dump_task1;  // データメモリの内容を Dmem_out.dat に，汎用レジスタの内容を Reg_out.dat に出力
      begin

        Dmem_data = $fopen("./Dmem_out.dat");  // Dmem_out.dat を開く
        for (i = 0; i <= Max_Daddr && i < DMEM_SIZE; i = i+4)  // データメモリの内容（アドレス 0 〜 Max_Daddr）を Dmem_out.dat に出力
          begin
             $fwrite(Dmem_data, "%h :%h %h %h %h¥n", i, DATA_Dmem[i], DATA_Dmem[i+1], DATA_Dmem[i+2], DATA_Dmem[i+3]);
          end
        $fclose(Dmem_data);  // Dmem_out.dat を閉じる

        Reg_data = $fopen("./Reg_out.dat");  // Reg_out.dat を開く
        for (i =0; i < 32; i = i+1)          // レジスタの内容を Reg_out.dat 出力
          begin
             Reg_temp = u_top_1.u_rf32x32.u_DW_ram_2r_w_s_dff.mem >> (BIT_WIDTH * i);
             $fwrite(Reg_data, "%d:%h¥n", i, Reg_temp);
          end
        $fclose(Reg_data);
      end

   endtask // dump_task1

endmodule // top_test
