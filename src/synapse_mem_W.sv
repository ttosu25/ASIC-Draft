
//N specifies the number of synapses in the memory unit
//default values for weights should be imposed on reset (rst)
//in this implementation, word length has been parametised as W


module synapse_mem_W #(parameter int N, W)
(output logic signed [W-1:0] dout, input logic signed [W-1:0] din , input logic [$clog2(N)-1:0]addr, input logic we, clk, rst);

	//weights for memory
	logic signed [W-1:0] weights[N-1:0]; 
	
	//weight initialisation parameters
	localparam int MIN_VAL = -(1 << (W-1));
	localparam int MAX_VAL =  (1 << (W-1)) - 1;
	
	always_ff@(posedge clk, posedge rst)
	
		begin
			if(rst)
				begin
					//initialise weight values
					for(int i = 1; i <= N; i++) begin
						//evenly spread weights
						weights[i-1] <= MIN_VAL + ( (MAX_VAL - MIN_VAL) * i) /N;
					end
					dout <= '0;
				end
				
			else begin
			
				if(we) //we = 1 is a reading operation
					dout <= weights[addr];
				else// we = 0 is a writing operation
					weights[addr] <= din;

			end
		end

endmodule