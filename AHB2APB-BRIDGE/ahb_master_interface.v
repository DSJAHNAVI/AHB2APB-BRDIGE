module ahb_master_interface (input hclk,hresetn, hr_readyout, 
							 input [31:0] hr_data, 
							 output reg [31:0] haddr, hwdata, 	
							 output reg hwrite,hready_in, 
							 output reg [1:0] htrans);
reg [2:0] hburst; 
reg [2:0] hsize;

task single_write();
	begin
	  @(posedge hclk)
	  #1; 
	    begin
		  hwrite=1; //to write data from master to slave
		  htrans=2'd2; //non seq cuz first transaction
		  hsize=3'b000; 
		  hburst=3'b000;  
		  hready_in=1;
		  haddr=32'h80000000;
	  end
	  
      @(posedge hclk)
      #1;
        begin
          hwdata=32'h24; //writing data
	      htrans=2'd0; //IDLE no data transfer is required
      end
	end
endtask


task single_read();
	begin
	@(posedge hclk)
	#1;
	  begin
		hwrite=0; // to read data from slave to master
		htrans=2'd2; //non seq cuz first transaction
		hsize=3'b000;
		hburst=3'b000;
		hready_in=1;
		haddr=32'h80000000;
	  end

	@(posedge hclk)
	#1;
	  begin
		htrans=2'd0;
	  end
	end
endtask

endmodule
