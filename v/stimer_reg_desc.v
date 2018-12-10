//----------------------------------------------------------------------------------------
module_name  : stimer

//----------------------------------------------------------------------------------------
defbegin, `REG_STIMER_BASE_ADDR, 32'h4003_7000, 1024

stimer_ctrl          , `REG_ST_CTRL           , 32'h00
stimer_reset         , `REG_ST_RESET          , 32'h04
stimer_load          , `REG_ST_LOAD           , 32'h08
st0_prescaler        , `REG_ST0_PRESCALER     , 32'h0C
st1_prescaler        , `REG_ST1_PRESCALER     , 32'h10
st2_prescaler        , `REG_ST2_PRESCALER     , 32'h14
st3_prescaler        , `REG_ST3_PRESCALER     , 32'h18
st4_prescaler        , `REG_ST4_PRESCALER     , 32'h1C
st5_prescaler        , `REG_ST5_PRESCALER     , 32'h20
st0_cfg              , `REG_ST0_CFG           , 32'h24
st1_cfg              , `REG_ST1_CFG           , 32'h28
st2_cfg              , `REG_ST2_CFG           , 32'h2C
st3_cfg              , `REG_ST3_CFG           , 32'h30
st4_cfg              , `REG_ST4_CFG           , 32'h34
st5_cfg              , `REG_ST5_CFG           , 32'h38
st_tgs_ch0           , `REG_ST_TGS_CH0        , 32'h3C
st_tgs_ch1           , `REG_ST_TGS_CH1        , 32'h40
st_tgs_ch2           , `REG_ST_TGS_CH2        , 32'h44
st_tgs_ch3           , `REG_ST_TGS_CH3        , 32'h48
st_tgs_ch4           , `REG_ST_TGS_CH4        , 32'h4C
st_tgs_ch5           , `REG_ST_TGS_CH5        , 32'h50
st_tgs_ch6           , `REG_ST_TGS_CH6        , 32'h54
st_tgs_ch7           , `REG_ST_TGS_CH7        , 32'h58
st_tgs_sw_trig       , `REG_ST_TGS_SW_TRIG    , 32'h5C
st0_trin_cfg         , `REG_ST0_TRIN_CFG      , 32'h60
st1_trin_cfg         , `REG_ST1_TRIN_CFG      , 32'h64
st2_trin_cfg         , `REG_ST2_TRIN_CFG      , 32'h68
st3_trin_cfg         , `REG_ST3_TRIN_CFG      , 32'h6C
st4_trin_cfg         , `REG_ST4_TRIN_CFG      , 32'h70
st5_trin_cfg         , `REG_ST5_TRIN_CFG      , 32'h74
st0_fault_cfg        , `REG_ST0_FAULT_CFG     , 32'h78
st1_fault_cfg        , `REG_ST1_FAULT_CFG     , 32'h7C
st2_fault_cfg        , `REG_ST2_FAULT_CFG     , 32'h80
st3_fault_cfg        , `REG_ST3_FAULT_CFG     , 32'h84
st4_fault_cfg        , `REG_ST4_FAULT_CFG     , 32'h88
st5_fault_cfg        , `REG_ST5_FAULT_CFG     , 32'h8C
st0_mod0_value       , `REG_ST0_MOD0_VALUE    , 32'h90
st1_mod0_value       , `REG_ST1_MOD0_VALUE    , 32'h94
st2_mod0_value       , `REG_ST2_MOD0_VALUE    , 32'h98
st3_mod0_value       , `REG_ST3_MOD0_VALUE    , 32'h9C
st4_mod0_value       , `REG_ST4_MOD0_VALUE    , 32'hA0
st5_mod0_value       , `REG_ST5_MOD0_VALUE    , 32'hA4
st0_mod1_value       , `REG_ST0_MOD1_VALUE    , 32'hA8
st1_mod1_value       , `REG_ST1_MOD1_VALUE    , 32'hAC
st2_mod1_value       , `REG_ST2_MOD1_VALUE    , 32'hB0
st3_mod1_value       , `REG_ST3_MOD1_VALUE    , 32'hB4
st4_mod1_value       , `REG_ST4_MOD1_VALUE    , 32'hB8
st5_mod1_value       , `REG_ST5_MOD1_VALUE    , 32'hBC
st0_current_value    , `REG_ST0_CURRENT_VALUE , 32'hC0
st1_current_value    , `REG_ST1_CURRENT_VALUE , 32'hC4
st2_current_value    , `REG_ST2_CURRENT_VALUE , 32'hC8
st3_current_value    , `REG_ST3_CURRENT_VALUE , 32'hCC
st4_current_value    , `REG_ST4_CURRENT_VALUE , 32'hD0
st5_current_value    , `REG_ST5_CURRENT_VALUE , 32'hD4
stimer_flag_status   , `REG_ST_FLAG_STATUS    , 32'hD8
stimer_record_status , `REG_ST_RECORD_STATUS  , 32'hDC
stimer_ifo_clear     , `REG_ST_IFO_CLEAR      , 32'hE0

defend

//----------------------------------------------------------------------------------------
regbegin: stimer_ctrl

  st5_en , 20 , 1'b0  , rw, st5 启动使能位: 0：不启动；1：启动；
  st4_en , 16 , 1'b0  , rw, st4 启动使能位: 0：不启动；1：启动；
  st3_en , 12 , 1'b0  , rw, st3 启动使能位: 0：不启动；1：启动；
  st2_en , 8  , 1'b0  , rw, st2 启动使能位: 0：不启动；1：启动；
  st1_en , 4  , 1'b0  , rw, st1 启动使能位: 0：不启动；1：启动；
  st0_en , 0  , 1'b0  , rw, st0 启动使能位: 0：不启动；1：启动；

regend

regbegin: stimer_reset

  st5_reset , 20 , 1'b0  , w1c, st5 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值
  st4_reset , 16 , 1'b0  , w1c, st4 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值
  st3_reset , 12 , 1'b0  , w1c, st3 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值
  st2_reset , 8  , 1'b0  , w1c, st2 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值
  st1_reset , 4  , 1'b0  , w1c, st1 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值
  st0_reset , 0  , 1'b0  , w1c, st0 复位位，写1复位计数器。软件只能写1，写1后，硬件自动置回0值

regend

regbegin: stimer_load

  st5_load , 20 , 1'b0  , w1c, st5 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值
  st4_load , 16 , 1'b0  , w1c, st4 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值
  st3_load , 12 , 1'b0  , w1c, st3 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值
  st2_load , 8  , 1'b0  , w1c, st2 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值
  st1_load , 4  , 1'b0  , w1c, st1 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值
  st0_load , 0  , 1'b0  , w1c, st0 读数位，写1读取计数器当前值（有一定偏差）。软件只能写1，写1后，硬件自动置回0值

regend

regbegin: st0_prescaler

  st0_pres_cfg , 4 , 4'h0  , rw, st0 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st0_pres_en  , 0 , 1'b0  , rw, st0 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st1_prescaler

  st1_pres_cfg , 4 , 4'h0  , rw, st1 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st1_pres_en  , 0 , 1'b0  , rw, st1 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st2_prescaler

  st2_pres_cfg , 4 , 4'h0  , rw, st2 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st2_pres_en  , 0 , 1'b0  , rw, st2 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st3_prescaler

  st3_pres_cfg , 4 , 4'h0  , rw, st3 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st3_pres_en  , 0 , 1'b0  , rw, st3 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st4_prescaler

  st4_pres_cfg , 4 , 4'h0  , rw, st4 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st4_pres_en  , 0 , 1'b0  , rw, st4 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st5_prescaler

  st5_pres_cfg , 4 , 4'h0  , rw, st5 分频比设置；0000：不分频；0001：2分频；... 1000：256分频；1001…1111：512分频；
  st5_pres_en  , 0 , 1'b0  , rw, st5 分频使能位；0：不使能，不分频；1：使能；

regend

regbegin: st0_cfg

  st0_cpu_debug_req_en , 9 , 1'b0 , rw, st0 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st0_dma_sel          , 7 , 1'b0 , rw, st0 dma请求使能位；0：中断；1：dma；
  st0_int_dma_en       , 6 , 1'b0 , rw, st0 中断DMA使能位；0：不使能；1：使能；
  st0_trout_pulse      , 5 , 1'b0 , rw, st0 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲；
  st0_trout_inv        , 4 , 1'b0 , rw, st0 输出Trigger极性反向：0：正向；1：反向；
  st0_stop_freeze      , 3 , 1'b0 , rw, st0 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st0_one_shot         , 2 , 1'b0 , rw, st0 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st0_mode             , 0 , 2'b00, rw, st0 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)；

regend

regbegin: st1_cfg

  st1_cpu_debug_req_en ,  9 , 1'b0 , rw, st1 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st1_chain_en         ,  8 , 1'b0 , rw, st1 级联st0 
  st1_dma_sel          ,  7 , 1'b0 , rw, st1 dma请求使能位；0：中断；1：dma； 
  st1_int_dma_en       ,  6 , 1'b0 , rw, st1 中断DMA使能位；0：不使能；1：使能；
  st1_trout_pulse      ,  5 , 1'b0 , rw, st1 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲； 
  st1_trout_inv        ,  4 , 1'b0 , rw, st1 输出Trigger极性反向：0：正向；1：反向； 
  st1_stop_freeze      ,  3 , 1'b0 , rw, st1 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st1_one_shot         ,  2 , 1'b0 , rw, st1 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st1_mode             ,  0 , 2'b00, rw, st1 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)； 

regend

regbegin: st2_cfg

  st2_cpu_debug_req_en ,  9 , 1'b0 , rw, st2 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st2_chain_en         ,  8 , 1'b0 , rw, st2 级联st1 
  st2_dma_sel          ,  7 , 1'b0 , rw, st2 dma请求使能位；0：中断；1：dma；  
  st2_int_dma_en       ,  6 , 1'b0 , rw, st2 中断DMA使能位；0：不使能；1：使能；
  st2_trout_pulse      ,  5 , 1'b0 , rw, st2 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲；  
  st2_trout_inv        ,  4 , 1'b0 , rw, st2 输出Trigger极性反向：0：正向；1：反向；  
  st2_stop_freeze      ,  3 , 1'b0 , rw, st2 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st2_one_shot         ,  2 , 1'b0 , rw, st2 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st2_mode             ,  0 , 2'b00, rw, st2 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)；  

regend

regbegin: st3_cfg

  st3_cpu_debug_req_en ,  9 , 1'b0 , rw, st3 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st3_chain_en         ,  8 , 1'b0 , rw, st3 级联st2 
  st3_dma_sel          ,  7 , 1'b0 , rw, st3 dma请求使能位；0：中断；1：dma；   
  st3_int_dma_en       ,  6 , 1'b0 , rw, st3 中断DMA使能位；0：不使能；1：使能；
  st3_trout_pulse      ,  5 , 1'b0 , rw, st3 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲；   
  st3_trout_inv        ,  4 , 1'b0 , rw, st3 输出Trigger极性反向：0：正向；1：反向；   
  st3_stop_freeze      ,  3 , 1'b0 , rw, st3 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st3_one_shot         ,  2 , 1'b0 , rw, st3 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st3_mode             ,  0 , 2'b00, rw, st3 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)；   

regend

regbegin: st4_cfg

  st4_cpu_debug_req_en ,  9 , 1'b0 , rw, st4 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st4_chain_en         ,  8 , 1'b0 , rw, st4 级联st3 
  st4_dma_sel          ,  7 , 1'b0 , rw, st4 dma请求使能位；0：中断；1：dma；   
  st4_int_dma_en       ,  6 , 1'b0 , rw, st4 中断DMA使能位；0：不使能；1：使能；
  st4_trout_pulse      ,  5 , 1'b0 , rw, st4 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲；   
  st4_trout_inv        ,  4 , 1'b0 , rw, st4 输出Trigger极性反向：0：正向；1：反向；   
  st4_stop_freeze      ,  3 , 1'b0 , rw, st4 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st4_one_shot         ,  2 , 1'b0 , rw, st4 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st4_mode             ,  0 , 2'b00, rw, st4 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)；   

regend

regbegin: st5_cfg

  st5_cpu_debug_req_en ,  9 , 1'b0 , rw, st5 cpu debug req 暂停计数；0：cpu debug req 起来后继续计数；1：cpu debug req 起来后暂停计数；
  st5_chain_en         ,  8 , 1'b0 , rw, st5 级联st4 
  st5_dma_sel          ,  7 , 1'b0 , rw, st5 dma请求使能位；0：中断；1：dma；   
  st5_int_dma_en       ,  6 , 1'b0 , rw, st5 中断DMA使能位；0：不使能；1：使能；
  st5_trout_pulse      ,  5 , 1'b0 , rw, st5 输出是否为一拍st0时钟的脉冲：0：保持，需要ifo_clear清除；1：脉冲；   
  st5_trout_inv        ,  4 , 1'b0 , rw, st5 输出Trigger极性反向：0：正向；1：反向；   
  st5_stop_freeze      ,  3 , 1'b0 , rw, st5 进入STOP功耗模式后，计数器是否暂停计数；0：继续计数，不暂停；1：暂停计数；
  st5_one_shot         ,  2 , 1'b0 , rw, st5 count/pwm 工作在one-shot模式还是continus模式；0：continus模式；1：one-shot模式；
  st5_mode             ,  0 , 2'b00, rw, st5 工作模式；00：模计数(MODCount)；01：自由计数(FreeCount)；10：脉宽调制(PWM) ；11：外部触发(Trigger)；   

regend

regbegin: st_tgs_ch0

  ch0_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch0_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch0_pad_filter,  4 , 4'h0 , rw, ch0 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch0_pad_edge  ,  2 , 2'b00, rw, ch0 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch0_pad_inv   ,  1 , 1'b0 , rw, ch0 输入pad反向：0：不反向；1：反向；
  ch0_in_en     ,  0 , 1'b0 , rw, ch0 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch1

  ch1_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch1_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch1_pad_filter,  4 , 4'h0 , rw, ch1 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch1_pad_edge  ,  2 , 2'b00, rw, ch1 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch1_pad_inv   ,  1 , 1'b0 , rw, ch1 输入pad反向：0：不反向；1：反向；
  ch1_in_en     ,  0 , 1'b0 , rw, ch1 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch2

  ch2_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch2_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch2_pad_filter,  4 , 4'h0 , rw, ch2 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch2_pad_edge  ,  2 , 2'b00, rw, ch2 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch2_pad_inv   ,  1 , 1'b0 , rw, ch2 输入pad反向：0：不反向；1：反向；
  ch2_in_en     ,  0 , 1'b0 , rw, ch2 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch3

  ch3_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch3_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch3_pad_filter,  4 , 4'h0 , rw, ch3 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch3_pad_edge  ,  2 , 2'b00, rw, ch3 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch3_pad_inv   ,  1 , 1'b0 , rw, ch3 输入pad反向：0：不反向；1：反向；
  ch3_in_en     ,  0 , 1'b0 , rw, ch3 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch4

  ch4_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch4_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch4_pad_filter,  4 , 4'h0 , rw, ch4 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch4_pad_edge  ,  2 , 2'b00, rw, ch4 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch4_pad_inv   ,  1 , 1'b0 , rw, ch4 输入pad反向：0：不反向；1：反向；
  ch4_in_en     ,  0 , 1'b0 , rw, ch4 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch5

  ch5_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch5_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch5_pad_filter,  4 , 4'h0 , rw, ch5 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch5_pad_edge  ,  2 , 2'b00, rw, ch5 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch5_pad_inv   ,  1 , 1'b0 , rw, ch5 输入pad反向：0：不反向；1：反向；
  ch5_in_en     ,  0 , 1'b0 , rw, ch5 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch6

  ch6_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch6_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch6_pad_filter,  4 , 4'h0 , rw, ch6 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch6_pad_edge  ,  2 , 2'b00, rw, ch6 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch6_pad_inv   ,  1 , 1'b0 , rw, ch6 输入pad反向：0：不反向；1：反向；
  ch6_in_en     ,  0 , 1'b0 , rw, ch6 输入使能：0: 不使能；1: 使能；

regend


regbegin: st_tgs_ch7

  ch7_in_source ,  11, 5'h0 , rw, ch0 输入源选择；详见源选择表
  ch7_in_clk_sel,  8 , 3'h0 , rw, ch0 输入同步时钟选择：000: st0_clk; 001: st1_clk; ... 101: st5_clk; 110: bus_clk; 111: sys_clk;
  ch7_pad_filter,  4 , 4'h0 , rw, ch7 输入pad毛刺滤波周期数配置；0000：不滤波；0001：1个周期；... 1111：15个周期；
  ch7_pad_edge  ,  2 , 2'b00, rw, ch7 输入pad触发边沿：00：高电平；01: 上升沿；10：下降沿；11：上升沿或下降沿；
  ch7_pad_inv   ,  1 , 1'b0 , rw, ch7 输入pad反向：0：不反向；1：反向；
  ch7_in_en     ,  0 , 1'b0 , rw, ch7 输入使能：0: 不使能；1: 使能；

regend

regbegin: st_tgs_sw_trig

  ch7_sw_trig    ,  28, 1'b0 , w1c, tgs ch7 软件触发，软件写1，硬件自动清零
  ch6_sw_trig    ,  24, 1'b0 , w1c, tgs ch6 软件触发，软件写1，硬件自动清零
  ch5_sw_trig    ,  20, 1'b0 , w1c, tgs ch5 软件触发，软件写1，硬件自动清零
  ch4_sw_trig    ,  16, 1'b0 , w1c, tgs ch4 软件触发，软件写1，硬件自动清零
  ch3_sw_trig    ,  12, 1'b0 , w1c, tgs ch3 软件触发，软件写1，硬件自动清零
  ch2_sw_trig    ,  8 , 1'b0 , w1c, tgs ch2 软件触发，软件写1，硬件自动清零
  ch1_sw_trig    ,  4 , 1'b0 , w1c, tgs ch1 软件触发，软件写1，硬件自动清零
  ch0_sw_trig    ,  0 , 1'b0 , w1c, tgs ch0 软件触发，软件写1，硬件自动清零

regend


regbegin: st0_trin_cfg

  st0_trin_action ,  4 , 2'b00, rw, st0 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st0_trin_tgs_ch ,  1 , 3'h0 , rw, st0 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st0_trin_en     ,  0 , 1'b0 , rw, st0 触发使能：0：不使能；1：使能；

regend

regbegin: st1_trin_cfg

  st1_trin_action ,  4 , 2'b00, rw, st1 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st1_trin_tgs_ch ,  1 , 3'h0 , rw, st1 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st1_trin_en     ,  0 , 1'b0 , rw, st1 触发使能：0：不使能；1：使能；

regend


regbegin: st2_trin_cfg

  st2_trin_action ,  4 , 2'b00, rw, st2 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st2_trin_tgs_ch ,  1 , 3'h0 , rw, st2 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st2_trin_en     ,  0 , 1'b0 , rw, st2 触发使能：0：不使能；1：使能；

regend


regbegin: st3_trin_cfg

  st3_trin_action ,  4 , 2'b00, rw, st3 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st3_trin_tgs_ch ,  1 , 3'h0 , rw, st3 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st3_trin_en     ,  0 , 1'b0 , rw, st3 触发使能：0：不使能；1：使能；

regend


regbegin: st4_trin_cfg

  st4_trin_action ,  4 , 2'b00, rw, st4 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st4_trin_tgs_ch ,  1 , 3'h0 , rw, st4 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st4_trin_en     ,  0 , 1'b0 , rw, st4 触发使能：0：不使能；1：使能；

regend


regbegin: st5_trin_cfg

  st5_trin_action ,  4 , 2'b00, rw, st5 触发动作：00:Stop; 01:Start; 10:Pause; 11:Count
  st5_trin_tgs_ch ,  1 , 3'h0 , rw, st5 触发通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st5_trin_en     ,  0 , 1'b0 , rw, st5 触发使能：0：不使能；1：使能；

regend

regbegin: st0_fault_cfg

  st0_fault_reset  ,  4 , 1'b0 , rw, st0 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st0_fault_tgs_ch ,  1 , 3'h0 , rw, st0 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st0_fault_en     ,  0 , 1'b0 , rw, st0 故障急停使能：0：不使能；1：使能；

regend

regbegin: st1_fault_cfg

  st1_fault_reset  ,  4 , 1'b0 , rw, st1 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st1_fault_tgs_ch ,  1 , 3'h0 , rw, st1 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st1_fault_en     ,  0 , 1'b0 , rw, st1 故障急停使能：0：不使能；1：使能；

regend

regbegin: st2_fault_cfg

  st2_fault_reset  ,  4 , 1'b0 , rw, st2 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st2_fault_tgs_ch ,  1 , 3'h0 , rw, st2 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st2_fault_en     ,  0 , 1'b0 , rw, st2 故障急停使能：0：不使能；1：使能；

regend

regbegin: st3_fault_cfg

  st3_fault_reset  ,  4 , 1'b0 , rw, st3 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st3_fault_tgs_ch ,  1 , 3'h0 , rw, st3 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st3_fault_en     ,  0 , 1'b0 , rw, st3 故障急停使能：0：不使能；1：使能；

regend

regbegin: st4_fault_cfg

  st4_fault_reset  ,  4 , 1'b0 , rw, st4 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st4_fault_tgs_ch ,  1 , 3'h0 , rw, st4 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st4_fault_en     ,  0 , 1'b0 , rw, st4 故障急停使能：0：不使能；1：使能；

regend

regbegin: st5_fault_cfg

  st5_fault_reset  ,  4 , 1'b0 , rw, st5 故障急停重置：0：不重置，计数器保留当前计数值,同时清除en; 1: 计数器复位清零，同时清除en;
  st5_fault_tgs_ch ,  1 , 3'h0 , rw, st5 故障急停通道选择：000：tgs_ch0; 001: tgs_ch1; ... 111: tgs_ch7;
  st5_fault_en     ,  0 , 1'b0 , rw, st5 故障急停使能：0：不使能；1：使能；

regend

regbegin: st0_mod0_value 

  st0_mod0,  0, 32'h0000_0000, rw, st0 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend

regbegin: st1_mod0_value 

  st1_mod0,  0, 32'h0000_0000, rw, st1 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend

regbegin: st2_mod0_value 

  st2_mod0,  0, 32'h0000_0000, rw, st2 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend

regbegin: st3_mod0_value 

  st3_mod0,  0, 32'h0000_0000, rw, st3 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend


regbegin: st4_mod0_value 

  st4_mod0,  0, 32'h0000_0000, rw, st4 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend

regbegin: st5_mod0_value 

  st5_mod0,  0, 32'h0000_0000, rw, st5 模值0：模计数模式时为模值，PWM模式时为PWM 0值的计数长度值

regend

regbegin: st0_mod1_value 

  st0_mod1,  0, 32'h0000_0000, rw, st0 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st1_mod1_value 

  st1_mod1,  0, 32'h0000_0000, rw, st1 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st2_mod1_value 

  st2_mod1,  0, 32'h0000_0000, rw, st2 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st3_mod1_value 

  st3_mod1,  0, 32'h0000_0000, rw, st3 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st4_mod1_value 

  st4_mod1,  0, 32'h0000_0000, rw, st4 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st5_mod1_value 

  st5_mod1,  0, 32'h0000_0000, rw, st5 模值1：仅在PWM模式时有效，为PWM 1值的计数长度值

regend

regbegin: st0_current_value

  st0_cval,  0, 32'h0000_0000, ro, st0 当前计数值：st0_load后有效

regend

regbegin: st1_current_value

  st1_cval,  0, 32'h0000_0000, ro, st1 当前计数值：st1_load后有效

regend

regbegin: st2_current_value

  st2_cval,  0, 32'h0000_0000, ro, st2 当前计数值：st2_load后有效

regend

regbegin: st3_current_value

  st3_cval,  0, 32'h0000_0000, ro, st3 当前计数值：st3_load后有效

regend

regbegin: st4_current_value

  st4_cval,  0, 32'h0000_0000, ro, st4 当前计数值：st4_load后有效

regend

regbegin: st5_current_value

  st5_cval,  0, 32'h0000_0000, ro, st5 当前计数值：st5_load后有效

regend

regbegin: stimer_flag_status

  st5_flag ,  20 , 1'b0 , ro, st5 标志位
  st4_flag ,  16 , 1'b0 , ro, st4 标志位
  st3_flag ,  12 , 1'b0 , ro, st3 标志位
  st2_flag ,  8  , 1'b0 , ro, st2 标志位
  st1_flag ,  4  , 1'b0 , ro, st1 标志位
  st0_flag ,  0  , 1'b0 , ro, st0 标志位

regend


regbegin: stimer_record_status

  st5_record ,  20 , 1'b0 , ro, st5 标志记录  
  st4_record ,  16 , 1'b0 , ro, st4 标志记录  
  st3_record ,  12 , 1'b0 , ro, st3 标志记录  
  st2_record ,  8  , 1'b0 , ro, st2 标志记录  
  st1_record ,  4  , 1'b0 , ro, st1 标志记录  
  st0_record ,  0  , 1'b0 , ro, st0 标志记录  

regend

regbegin: stimer_ifo_clear

  st5_ifo_clear ,  20 , 1'b0 , w1c, st5 标志位/中断 清除位，软件写1，硬件自动清零
  st4_ifo_clear ,  16 , 1'b0 , w1c, st4 标志位/中断 清除位，软件写1，硬件自动清零
  st3_ifo_clear ,  12 , 1'b0 , w1c, st3 标志位/中断 清除位，软件写1，硬件自动清零
  st2_ifo_clear ,  8  , 1'b0 , w1c, st2 标志位/中断 清除位，软件写1，硬件自动清零
  st1_ifo_clear ,  4  , 1'b0 , w1c, st1 标志位/中断 清除位，软件写1，硬件自动清零
  st0_ifo_clear ,  0  , 1'b0 , w1c, st0 标志位/中断 清除位，软件写1，硬件自动清零

regend




