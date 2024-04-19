module gpioemu (
    input wire clk,
    input wire reset,
    input wire [23:0] A1,
    input wire [23:0] A2,
    output wire [31:0] W,
    output wire [23:0] L,
    output wire [1:0] B,
    output wire valid,
	output wire  ready,
    output wire [15:0] gpio
);

    reg [48:0] result;
    reg [23:0] wA2;
    reg [23:0] wA1;
    reg [15:0] operation_count;
    reg [3:0] state;
    reg [23:0] ones_count;
    reg [23:0] tmp_ones_count;
	

    localparam IDLE = 0,
              MULT = 1,
              COUNT_ONES = 2,
              DONE = 3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            result <= 0;
            ones_count <= 0;
            tmp_ones_count <= 0;
            operation_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    result <= 0;
                    wA2 <= A2;
                    wA1 <= A1;
                    tmp_ones_count <= 0;
                    if (ready) begin
                        state <= MULT;
                    end
                end
   MULT: begin
    for (integer i = 0; i < 24; i = i + 1) begin
        if (wA2[i]) begin
            result <= result + ({24'b0,wA1} << i);
        end
		
    end
    state <= COUNT_ONES;
end 
                COUNT_ONES: begin
                    for (integer i = 0; i < 32; i++) begin
                       if (result[i] == 1) begin
						tmp_ones_count = tmp_ones_count + 1;
						end
                    end
                    ones_count <= tmp_ones_count;
                    state <= DONE;
                end
                DONE: begin
                    operation_count <= operation_count + 1;
                    if (ready) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign W = result[31:0];
    assign L = ones_count;
    assign ready = (state == IDLE || state == DONE);
    assign valid = (result[48:32] == 0);
	assign B = {ready,valid};
    assign gpio = operation_count[15:0];

endmodule
