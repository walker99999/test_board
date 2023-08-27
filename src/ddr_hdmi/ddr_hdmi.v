module ddr_hdmi#(
	parameter MEM_ROW_ADDR_WIDTH   = 15         ,
	parameter MEM_COL_ADDR_WIDTH   = 10         ,
	parameter MEM_BADDR_WIDTH      = 3          ,
	parameter MEM_DQ_WIDTH         =  32        ,
	parameter MEM_DQS_WIDTH        =  32/8      ,
    parameter CTRL_ADDR_WIDTH = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH,//28
    parameter TH_1S = 27'd33000000
)(
    input                                pix_clk                   ,    
    input                                core_clk                  ,
    input                                ddr_init_done             ,
//ddr接口
    output       [CTRL_ADDR_WIDTH-1:0]                        axi_awaddr                ,
    output       [3:0]                        axi_awuser_id             ,
    output       [3:0]                        axi_awlen                 ,
    input                                axi_awready               ,
    output                               axi_awvalid               ,
    output       [MEM_DQ_WIDTH*8-1:0]                        axi_wdata                 ,
    output       [MEM_DQ_WIDTH*8/8-1:0]                        axi_wstrb                 , 
    input                                axi_wready                ,
    input                                axi_wusero_last           ,
    output       [CTRL_ADDR_WIDTH-1:0]                        axi_araddr                ,
    output       [3:0]                        axi_aruser_id             ,
    output       [3:0]                        axi_arlen                 ,
    input                                axi_arready               ,
    output                               axi_arvalid               ,
    input        [MEM_DQ_WIDTH*8-1:0]                        axi_rdata                 ,
    input        [3:0]                        axi_rid                   ,
    input                                axi_rlast                 ,
    input                                axi_rvalid                ,

//输入接口
    input               pclk_in,                            
    input               vs_in, 
    input               de_in,
    input       [15:0]  i_rgb565,

//输出接口
    output     reg                       vs_out                    , 
    output     reg                       hs_out                    , 
    output     reg                       de_out                    ,
    output     reg[7:0]                  r_out                     , 
    output     reg[7:0]                  g_out                     , 
    output     reg[7:0]                  b_out         
);

    wire     [15:0]    o_rgb565;
//修改ddr读写模块v1
    fram_buf fram_buf_hdmi(
        .ddr_clk        (  core_clk             ),//input                         ddr_clk,
        .ddr_rstn       (  ddr_init_done        ),//input                         ddr_rstn,
        //data_in                                  
        .vin_clk        (  pclk_in         ),//input                         vin_clk,
        .wr_fsync       (  vs_in           ),//input                         wr_fsync,
        .wr_en          (  de_in           ),//input                         wr_en,
        .wr_data        (  i_rgb565             ),//input  [15 : 0]  wr_data,
        //data_out
        .vout_clk       (  pix_clk           ),//input                         vout_clk,
        .rd_fsync       (  vs_o               ),//input                         rd_fsync,
        .rd_en          (  de_re                ),//input                         rd_en,
        .vout_de        (  de_o               ),//output                        vout_de,
        .vout_data      (  o_rgb565             ),//output [PIX_WIDTH- 1'b1 : 0]  vout_data,
        .init_done      (  init_done            ),//output reg                    init_done,
        //axi bus
        .axi_awaddr     (  axi_awaddr           ),// output[27:0]
        .axi_awid       (  axi_awuser_id        ),// output[3:0]
        .axi_awlen      (  axi_awlen            ),// output[3:0]
        .axi_awsize     (                       ),// output[2:0]
        .axi_awburst    (                       ),// output[1:0]
        .axi_awready    (  axi_awready          ),// input
        .axi_awvalid    (  axi_awvalid          ),// output               
        .axi_wdata      (  axi_wdata            ),// output[255:0]
        .axi_wstrb      (  axi_wstrb            ),// output[31:0]
        .axi_wlast      (  axi_wusero_last      ),// input
        .axi_wvalid     (                       ),// output
        .axi_wready     (  axi_wready           ),// input
        .axi_bid        (  4'd0                 ),// input[3:0]
        .axi_araddr     (  axi_araddr           ),// output[27:0]
        .axi_arid       (  axi_aruser_id        ),// output[3:0]
        .axi_arlen      (  axi_arlen            ),// output[3:0]
        .axi_arsize     (                       ),// output[2:0]
        .axi_arburst    (                       ),// output[1:0]
        .axi_arvalid    (  axi_arvalid          ),// output
        .axi_arready    (  axi_arready          ),// input
        .axi_rready     (                       ),// output
        .axi_rdata      (  axi_rdata            ),// input[255:0]
        .axi_rvalid     (  axi_rvalid           ),// input
        .axi_rlast      (  axi_rlast            ),// input
        .axi_rid        (  axi_rid              ) // input[3:0]         
    );

     always@(posedge pix_clk) begin
        r_out<={o_rgb565[15:11],3'b0   };
        g_out<={o_rgb565[10:5],2'b0    };
        b_out<={o_rgb565[4:0],3'b0     }; 
        vs_out<=vs_o;
        hs_out<=hs_o;
        de_out<=de_o;
     end

/////////////////////////////////////////////////////////////////////////////////////
//产生visa时序 
     sync_vg sync_vg(                            
        .clk            (  pix_clk              ),//input                   clk,                                 
        .rstn           (  init_done            ),//input                   rstn,                            
        .vs_out         (  vs_o                 ),//output reg              vs_out,                                                                                                                                      
        .hs_out         (  hs_o                 ),//output reg              hs_out,            
        .de_out         (                       ),//output reg              de_out, 
        .de_re          (  de_re                )    
    );                 
/////////////////////////////////////////////////////////////////////////////////////

endmodule