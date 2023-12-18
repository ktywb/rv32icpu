[20230514]
 - [修正] top.v 中 D_mem 模块的 size 计算方法
 - [发现问题]最后的jalr不跳转，pc_in高阻态，但本应为100b4，查明Judger的a线控制信号出错，怀疑逻辑本身有问题

[20230515]
 - [修正问题][20230514]pc_reg_mux的b端口没接reg_data_a导致没有数据，导致不能生成新pc
 - [可以运行] c 和 Mibench 文件夹中的程序

[20230521]
 - [修正]流水线中 load 指令只需一周期即可读出数据，故删除所有与 is_type_l 信号有关的端口和操作

[20230523]
 - [发现问题]指令顺序(1)(2)(j)，(1)和(2)存在数据冲突需要停顿，停顿期间(j)指令后重制寄存器，导致重新执行的[2]被清零

[20230524]
 - [修正问题][20230523]增加数据选择器 tempMux，重新选择一次 PC
 - [修正]
	(1)增加 Mux 模块 tempMux

[20230528]
 - [发现问题]指令顺序(1)(2)(3)，(1)->(3)的数据前递存在问题，少一条线

[20230529]
 - [修正问题][20230528]问题发现因为从 ID2EX.regdataB_o 的数据到 ID2EX.regdataB_i 之间的数据连线有问题，本应由 data_b_mux31.dataD 选出的数据送到 ID2EX.regdataB_i
 - [修正]
	(1)删除输出信号 FwdCtrler.fcE
	(2)删除 Mux 模块 dmem_w_mux
	(3)更改 ex2mem.reg_dataB_i 的连线，由 dmem_w_mux.dataC 改为 data_b_mux31.dataD
 - [待处理]
	 - [处理事项]更改 load-use 型冒险的处理方式：flush->stall
		 - [处理方案]
			(1)更改 Pc_reg 和 IF2ID 收到  fcD 信号后的动作，由“清零”改为“保持上一次的输出”
			(2)预计需要删除 tempMux
			(3)更改 id2ex.times 的数据，judge_b2 重置 2 次，fcD 重置 1 次
			(4)更改 rster2.ctrl_sig 的数据为 judge_b2
		 - [预计效果]load-use型冒险的流水线延迟由 2 周期缩短为 1 周期
 - [修正]尝试修正 load-use 型冒险的处理方式：flush->stall
	- [发现问题] switch 语句似乎存在问题

[20230530]
 - [发现问题][20230529]
	(1)j 指令的动作似乎和 load-use 冲突的处理动作存在冲突，导致不能跳转，j 指令会先对if2id清零，导致因load-use原因再次生成的j指令被清零
	(2)jump 后的pc不正常，变成Dmem的地址
		 - [发现问题] jalr 的数据处理被提前，导致遇到 load- use(jalr) 的情况即便 stall 了一个周期也不能得到前递的数据
		 - [处理方案]预计更改 FwdCtrler.fcD 的生成逻辑，增加 “(原逻辑)｜(is_jr & rs1==memwb_rd)”
		 - [预计效果] load-use 冲突的处理缩短为两周期
 - [修正问题][20230529] load-use 冲突的处理缩短为两周期，但 load- use(jalr) 作为例外 stall 两次，因此为三个周期
 - [处理事项]分支前移
 - [处理事项]分支预测
	 - [处理方案]增加分支预测模块，修改 PC_reg 周围的连线
	 - [预计效果]缩短部分分支行为的流水线延迟
[20230602]
 - [修正]bne 和 beq 判断前移，如果不存在前递不能解决的数据冲突则在 ID 阶段处理跳转，否则停顿一周期再在 ID 阶段跳(ID:bneq;EX:write_reg)或者延后到EX判断跳转(ID:bneq;EX:load)