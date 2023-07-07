module bridge_top(input hclk,hresetn,hwrite,hready_in,input [1:0] htrans,
				  input [31:0] hwdata,haddr,pr_data,
				  output penable, pwrite, hr_readyout,output [2:0] psel, 
				  output [1:0] hresp, output [31:0] paddr,pwdata,hr_data);

wire [31:0] hwdata1,hwdata2,haddr1,haddr2;
wire [2:0] temp_selx;
wire hwrite_reg,hwrite_reg1;
wire valid;

ahb_slave_interface  A1(hclk,hresetn,hwrite,hready_in,htrans,hwdata,haddr,pr_data,hwrite_reg,hwrite_reg1,valid,
hwdata1,hwdata2,haddr1,haddr2,hr_data,temp_selx);

apb_controller  A2(hclk,hresetn,hwrite_reg,hwrite,valid,haddr,hwdata,hwdata1,hwdata2,haddr1,haddr2,pr_data,temp_selX,penable,pwrite,hr_readyout,psel,paddr,pwdata);

endmodule
