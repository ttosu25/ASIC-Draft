//default values for membrane potentials should be imposed on reset (rst)
//in this implementation, word length has been parametised as W

module neuron_state_W #(parameter M, W) // M is the number of membranes and thus also the number of neurons
(output logic signed [W-1:0] dout, input logic signed [W-1:0] din , input logic [$clog2(M)-1:0]addr, input logic we, clk, rst);
	
	//membranes of each neuron
	logic signed [W-1:0] membranes[M-1:0]; 
	
	//membrane initialisation parameters
	localparam int MIN_VAL = -(1 << (W-1));
	localparam int MAX_VAL =  (1 << (W-1)) - 1;
	
	always_ff@(posedge clk, posedge rst)
	
		begin
		
			if(rst)
			
				begin
					//initialise membrane values
					for(int i = 1; i <= M; i++) begin
						//evenly spread membranes
						membranes[i-1] <= MIN_VAL + ( (MAX_VAL - MIN_VAL) * i) /M;
					end
					
					dout <= '0;
						
				end
			
			else begin
		
					if(we) //we = 1 is a reading operation
						dout <= membranes[addr];
					else// we = 0 is a writing operation
						membranes[addr] <= din;	
					
			end
		end
	

endmodule