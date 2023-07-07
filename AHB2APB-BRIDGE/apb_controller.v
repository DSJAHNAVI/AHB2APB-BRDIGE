module apb_controller (input hclk,hresetn,hwrite_reg,hwrite,valid,
					   input [31:0]haddr,hwdata,hwdata1,hwdata2,haddr1,haddr2,pr_data, 
				       input [2:0] temp_selx, 
					   output reg penable, pwrite, 
					   output reg hr_readyout,
					   output reg [2:0] psel, 
					   output reg [31:0] paddr,pwdata);
	  
parameter ST_IDLE=3'b000;
parameter ST_READ=3'b001;
parameter ST_RENABLE=3'b010;
parameter ST_WWAIT=3'b011;
parameter ST_WRITE=3'b100;
parameter ST_WRITEP=3'b101;
parameter ST_WENABLE=3'b110;
parameter ST_WENABLEP=3'b111;
reg [2:0]next_state,present_state;
reg penable_temp,pwrite_temp,hr_readyout_temp; //p related stuff taking temparory 
reg [2:0] psel_temp;
reg [31:0] paddr_temp,pwdata_temp;
 
always @(posedge hclk)
  begin
    if(!hresetn==1) //(means hresetn = 0)
      present_state<=ST_IDLE;
    else
      present_state<=next_state;
  end
  
always @(*)
  begin
	case(present_state)
      ST_IDLE:begin
        if(valid==1 && hwrite==1)
          next_state=ST_WWAIT;
        else if(valid==1 && hwrite==0)
          next_state=ST_READ;
        else if(valid==0)
          next_state=ST_IDLE;
	   end
	 
      ST_READ: next_state=ST_RENABLE;
	  
      ST_RENABLE:begin 
	    if(valid==1&&hwrite==1)
          next_state=ST_WWAIT;
        else if(valid==1&&hwrite==0)
          next_state=ST_READ;
        else if(valid==0)
          next_state=ST_IDLE;
	  end

      ST_WWAIT:begin	  
	    if (valid==1)
          next_state=ST_WRITEP;
        else if(valid==0)
          next_state=ST_WRITE;
	  end
	  
      ST_WRITE: begin
        if (valid==1)
          next_state=ST_WENABLEP;
        else if(valid==0)
          next_state=ST_WENABLE;
	  end
		
      ST_WRITEP: next_state=ST_WENABLEP;
	   
      ST_WENABLEP: begin
        if (valid==1&&hwrite_reg==1)
          next_state=ST_WRITEP;
        else if (valid==0&&hwrite_reg==1)
          next_state=ST_WRITE;
        else if(hwrite_reg==0)
          next_state=ST_READ;
	  end
	  
      ST_WENABLE: begin
        if (valid==1 && hwrite==1)
          next_state=ST_WWAIT;
        else if (valid==1 && hwrite==0)
          next_state=ST_READ;
        else if(valid == 0)
          next_state=ST_IDLE;
	  end
	endcase
  end	 
  
always @(*) begin
 case(present_state)
  ST_IDLE: begin
	if(valid==1&&hwrite==0)
	  begin
		paddr_temp=haddr;
		pwrite_temp=hwrite;
		psel_temp=temp_selx;
		penable_temp=0;
		hr_readyout_temp=0;
	  end
	else if(valid==1&&hwrite==1)
	  begin
		psel_temp=0;
		penable_temp=0;
		hr_readyout_temp=1;
	  end 
	else
	  begin
		psel_temp=0;
		penable_temp=0;
		hr_readyout_temp=1;
	  end
  end
 
  ST_READ: begin
	penable_temp=1;
	hr_readyout_temp=1;
  end

  ST_RENABLE: begin
	if(valid==1&&hwrite==0)
	  begin
		paddr_temp=haddr;
		pwrite_temp=hwrite;
		psel_temp=temp_selx;
		penable_temp=0;
		hr_readyout_temp=0;
	  end
	else if(valid==1&&hwrite==1)
	  begin
		psel_temp=0;
		penable_temp=0;
		hr_readyout_temp=1;
      end 
	else
	  begin
		psel_temp=0;
		penable_temp=0;
		hr_readyout_temp=1;
	  end
  end

  ST_WWAIT: begin
	paddr_temp=haddr1;
	pwdata_temp=hwdata;
	pwrite_temp=hwrite;
	psel_temp=temp_selx;
	penable_temp=0;
	hr_readyout_temp=0;
  end

  ST_WRITE:begin
	penable_temp=1;
	hr_readyout_temp=1; 
   end

  ST_WRITEP:begin
	penable_temp=1;
	hr_readyout_temp=1; 
  end

  ST_WENABLE:begin
	hr_readyout_temp=1; 
	penable_temp=0;
	psel_temp=0;
  end

  ST_WENABLEP:begin
	paddr_temp=haddr2;
	hr_readyout_temp=0; 
	pwdata_temp=hwdata; 
	penable_temp=1; 
  end
 endcase
end

always @(posedge hclk)
  begin
	if(!hresetn)
      begin
        paddr<=0;
	    pwdata<=0;
	    pwrite<=0;
	    psel<=0;
	    penable<=0;
	    hr_readyout<=1;
	  end
	else
	  begin
		paddr<=paddr_temp;
		pwdata<=pwdata_temp;
		pwrite<=pwrite_temp;
		psel<=psel_temp;
		penable<=penable_temp;
		hr_readyout<=hr_readyout_temp;
	  end
  end
endmodule

			