
//in this implementation, word length has been parametised as W
module lif_W #(parameter int W)
(output logic spike, output logic signed [W-1:0] next_membrane , input logic signed [W-1:0] membrane, input logic signed [W-1:0]threshold, input logic signed [W-1:0] leak, input logic signed [W-1:0] V_reset,  input logic signed [W-1:0] V_syn,input logic clk,input logic rst);

	
	logic signed [2*W-1:0] mult;
	logic signed [W-1:0] temp_membrane;
	logic spike_next;
	
	always_comb
		begin
			mult = leak * membrane;
			temp_membrane = ($signed(mult) >>> (W/2) ) + $signed(V_syn); // we right shift by W/2 to keep in QW/2.W/2 format
			spike_next = (temp_membrane > threshold);
			
			
		end
	
	always_ff @(posedge clk , posedge rst)
	
		if (rst) begin
			spike <= '0;
			next_membrane <= '0;
			end
			
		else 
		
			begin
				spike <= spike_next;
				
				if(spike_next)
					next_membrane <= V_reset;
					
				else
					next_membrane <= temp_membrane;
				
			end
			
endmodule