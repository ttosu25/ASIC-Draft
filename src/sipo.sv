module sipo #(parameter N) //SERIAL-IN-PARALLEL-OUT N BIT REGISTER
(output logic [N-1:0] q, input logic a, clk , rst, enable);

	always_ff @(posedge clk, posedge rst) begin
		if (rst)
			q <= '0;
		else if (enable) begin 
			if(N == 1)
				q <= a;
			else
				q <= {q[N-2:0], a};
			
		end
	end

endmodule