/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */
/* verilator lint_off BLKSEQ */
/* verilator lint_off WIDTH */
/* verilator lint_off UNDRIVEN */
module gpioemu(n_reset,
    saddress[15:0], srd, swr,
    sdata_in[31:0], sdata_out[31:0],
    gpio_in[31:0], gpio_latch,
    gpio_out[31:0],
    clk,
    gpio_in_s_insp[31:0]);

    input           clk;
    input           n_reset;

    input [15:0]    saddress;
    input           srd;
    input           swr;
    input [31:0]    sdata_in;
    output[31:0]    sdata_out;
    reg [31:0]      sdata_out_s;


    input [31:0]    gpio_in;
    reg [31:0]      gpio_in_s;
    input           gpio_latch;
    output[31:0]    gpio_in_s_insp;

    output[31:0]    gpio_out;
    reg [31:0]      gpio_out_s;

    reg unsigned [48:0] result;
    reg unsigned [48:0] temp_result;
    reg unsigned[23:0] A2;
    reg unsigned[23:0] A1;
    reg unsigned[31:0] W;
    reg unsigned[23:0] L;
    reg unsigned[1:0] B;
    reg unsigned[15:0] operation_count;
    reg unsigned[3:0] state;
	reg unsigned valid;
    reg unsigned[23:0] tmp_ones_count;
    reg ready;
	reg done;
	

    localparam IDLE = 0,
              MULT = 1,
              COUNT_ONES = 2,
              DONE = 3;

    always @(negedge n_reset)
	begin
        gpio_in_s <= 0;
        gpio_out_s <= 0;
        sdata_out_s <= 0;
		
		valid =1;
        state <= IDLE;
        result =49'b0;
		W = 32'b0;
        tmp_ones_count = 0;
        operation_count <= 0;
        ready <= 1'b1;
        A1 <= 0;
        A2 <= 0;
        L = 0;
        B = 2'b01;
		done =1'b0;
    end
	
	
	

    always @(posedge swr) 
	begin   
			
			if (saddress == 16'h0380)
			begin	// adres pierwszego argumentu
			A1 <= sdata_in;
			end
    else if (saddress == 16'h0388)begin // adres drugiego argumentu
		A2 <= sdata_in;
        ready <= 1'b0;
			done =0;
			valid =1'b1;
			B = 2'b01;
			state <= IDLE;
			gpio_out_s <= gpio_out_s + 1; //licznik
		end
	end



always @(posedge srd) 
begin
    if (saddress == 16'h0390) 
	
     //  if (B == 2'b11) begin  //jeszcze sprawdzić to
	    sdata_out_s <= W[31:0];
     //   end
    
		else if (saddress == 16'h03A0) 
		
			sdata_out_s <= {30'b0, B};																	
	
		else if (saddress == 16'h0398) 
		
			sdata_out_s <= {8'h0, L};
		
		else 
		
			sdata_out_s <= 'h0;
		
end



always @(posedge clk) begin 
    case (state)
        IDLE: begin
            result = 0;
			ready <= 1'b0;
			valid =1'b1;
			B = 2'b01;
			done = 0;
            tmp_ones_count = 0;
            state <= MULT;
        end
        MULT: begin
			ready <= 0;
			result =49'b0;
			temp_result ={25'h0, A1};
            for (integer i = 0; i < 24; i = i + 1)
			begin
			if(i!=0) begin
			      temp_result= temp_result<<1;
				  end
                if (A2[i]) begin
                    result = result + temp_result;
                end
            end
			valid = (result[48:32] == 0);
			B ={ready,valid};
			W = result [31:0];
            state <= COUNT_ONES;
        end
        COUNT_ONES: begin
		 ready <=0;
		 B ={ready,valid};
		 tmp_ones_count = 0;
            for (integer i = 0; i < 32; i = i + 1) begin
                if (result[i]) begin
                    tmp_ones_count = tmp_ones_count + 1;
                end
            end
            L = tmp_ones_count;
			B ={ready,valid};
            state <= DONE;
        end
        DONE: begin
		done = 1'b1;		
		B = 2'b11;
        operation_count <= operation_count + 1;
		state<=IDLE;
           
        end
    endcase
end

assign gpio_out = {16'h0, operation_count[15:0]};
assign gpio_in_s_insp = gpio_in_s;
assign sdata_out = sdata_out_s;
//assign gpio_out =gpio_out_s;
endmodule
//for commit
