//N specifies the number of synapses in the SNN
//in this implementation, word length has been parametised as W,
//We assume the mapping of neurons to synapses in this system is 1 to 1
//n_we refers neutron read/write line
module control_unit_W #(parameter W, N)
(output logic s_we, output logic n_we, output logic enable, output logic [$clog2(N)-1:0] addr, output logic signed [W-1:0] V_syn, input logic signed [W-1:0] weight, input logic s_i, clk, rst);

	always_ff @(posedge clk, posedge rst) begin
	
		if(rst) begin
		
			//set initial parameter values
			addr <= '0;
			V_syn <= '0;
			s_we <= 1'b1; //read from synapse memory only
			n_we <= 1'b1; //lif reads from neuron state memory
			enable <= 1'b1;
			
		
		end
		
		//main program
		
		else begin
			n_we <= ~n_we; // this will split the computation cycle into two stages giving us a latency of 2 clock cycles
			enable <= ~enable;
			
			if(!n_we)//we're updating the membrane value from lif in this stage
			//increment address
			addr <= addr + 1;

			else
				if(s_i) V_syn <= weight; // weight is equal to V_syn if spike
				else V_syn <= 0;
			
			
		
		end
	
	end

endmodule