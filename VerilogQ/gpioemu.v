/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */
/* verilator lint_off BLKSEQ */
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

    always @(negedge n_reset) begin
        gpio_in_s <= 0;
        gpio_out_s <= 0;
        sdata_out_s <= 0;
        state <= 4;
        result =49'b0;
		W = 32'b0;
        tmp_ones_count = 0;
        operation_count <= 0;
        ready <= 1'b1;
        A1 <= 0;
        A2 <= 0;
        L <= 0;
        B = 2'b11;
		done <=1'b0;
    end
	
	
	

    always @(posedge swr) begin   // może być błąd
       
    if (saddress == 16'h03A0 ) begin
        ready <= 1'b0;
		done <=0;
		valid =1'b1;
		B = 2'b01;
        state <= IDLE;
        gpio_out_s <= gpio_out_s + 1; //licznik
    end
    if (saddress == 16'h37F) // adres pierwszego argumentu
        A1 <= sdata_in[23:0];
    else if (saddress == 16'h0388) // adres drugiego argumentu
        A2 <= sdata_in[23:0];
end



always @(posedge srd) begin
    if (saddress == 16'h390) begin
        if (done) begin
		W = result[31:0];
            sdata_out_s <= W[31:0];
        end
    end 
	else if (saddress == 16'h3A0) begin
        sdata_out_s <= {30'b0, B};																	
    end 
	else if (saddress == 16'h398) begin
        sdata_out_s <= {8'h0, tmp_ones_count};
    end 
	else begin
        sdata_out_s <= 0;
    end
end



always @(posedge clk) begin
    case (state)
        IDLE: begin
            result = 0;
			ready <= 1'b0;
			valid =1'b1;
			B = 2'b01;
			done <= 0;
            tmp_ones_count = 0;
            state <= MULT;
        end
        MULT: begin
			ready <= 0;
            for (integer i = 0; i < 24; i = i + 1) begin
                if (A2[i]) begin
                    result = result + ({25'h0, A1} << i);
                end
            end
			valid = (result[48:32] == 0);
			W = result [31:0];
			B ={ready,valid};
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
		done <= 1'b1;
		
           
				B = 2'b11;
                operation_count <= operation_count + 1;
           
        end
    endcase
end

assign gpio_out = {16'h0, operation_count[15:0]};
assign gpio_in_s_insp = gpio_in_s;
assign sdata_out = sdata_out_s;
endmodule
