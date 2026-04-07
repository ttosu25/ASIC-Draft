module core_tb #(parameter W = 8, N = 4);

	logic event_out;
	logic [N-1:0] spike_pattern;
	logic clk;
	logic rst;
	logic spike_in;
	
	
	//clock pulse
	initial begin
		clk = 1'b0;
		forever #10 clk = ~clk;
	end
	
	//intialise default system
	initial begin
		rst = 1'b0;
		#5 rst = 1'b1;
		#5 rst = 1'b0;
	end
	
	
	//event out test
	initial begin
		spike_pattern = 4'b0000;
		spike_in = 1'b0;
		// each computation cycle is two clock cycles, we will need 4 computation cycles to get event_out result
		#80 spike_in = 1'b1;
	end
	
	core #(.WORD_LENGTH(W), .NEURON_COUNT(N)) test(
		.event_out(event_out),
		.spike_in(spike_in),
		.spike_pattern(spike_pattern),
		.clk(clk),
		.rst(rst)
	);
	

endmodule