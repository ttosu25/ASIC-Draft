module core #(parameter WORD_LENGTH, NEURON_COUNT) //in this design its important to remember spike_in is the MSB of a NEURON_COUNT-bit Register
	(output logic event_out, output logic [NEURON_COUNT - 1: 0] spike_out ,output logic indicator, input logic spike_in, input logic [NEURON_COUNT - 1: 0] spike_pattern ,input logic clk, rst);

	//control signals
	logic n_we;
	logic s_we;
	logic enable;
	
	//address bus
	logic [$clog2(NEURON_COUNT)-1:0] addr;
	
	//synapses buses
	logic signed [WORD_LENGTH - 1:0] weights;
	
	//neuron buses
	logic signed [WORD_LENGTH - 1: 0] mem_read;
	logic signed [WORD_LENGTH - 1: 0] mem_write;
	
	// V_syn
	logic signed [WORD_LENGTH - 1: 0] V_syn;
	
	//lif buses
	logic spiking; // spike event
	
////////////////////////////////////////////////////  Registers
	
	
	logic signed [WORD_LENGTH - 1:0]threshold;
	logic signed [WORD_LENGTH - 1:0] leak;
	logic signed [WORD_LENGTH - 1:0] V_reset;
	
	// Maximum positive signed value for WORD_LENGTH bits
	localparam int signed MAX_VAL = (1 <<< (WORD_LENGTH-1)) - 1;

	// Quartiles of the positive range [0 .. MAX_VAL], rounded down
	localparam int signed THRESH_INT =  MAX_VAL / 4;        // lower quartile (25%)
	localparam int signed LEAK_INT   = (MAX_VAL * 3) / 4;   // upper quartile (75%)

	// Cast to proper WORD_LENGTH signed vectors
	localparam logic signed [WORD_LENGTH-1:0] THRESH = THRESH_INT[WORD_LENGTH-1:0];
	localparam logic signed [WORD_LENGTH-1:0] LEAK   = LEAK_INT[WORD_LENGTH-1:0];
		
		//	
/////////////////////////////////////////////////// 	
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        event_out <= '0;
        indicator <= '0;
        threshold <= THRESH;
        leak <= LEAK;
        V_reset <= '0;
    end else begin
        event_out <= (spike_out == spike_pattern);
        indicator <= ~indicator;
    end
end
	
/////////////////////////////////////////////initialising core units
	synapse_mem_W #(.W(WORD_LENGTH), .N(NEURON_COUNT)) synapses (
		.dout(weights),
		.din('0), //in this design we never write to synapse memory unit
		.addr(addr),
		.we(s_we),
		.clk(clk),
		.rst(rst)
	);
	
	neuron_state_W #(.W(WORD_LENGTH), .M(NEURON_COUNT)) neurons (
		.dout(mem_read),
		.din(mem_write),
		.addr(addr),
		.we(n_we),
		.clk(clk),
		.rst(rst)	
	);
	
	lif_W #(.W(WORD_LENGTH) ) LIF (
		.spike(spiking),
		.next_membrane(mem_write),
		.membrane(mem_read),
		.threshold(threshold),
		.leak(leak),
		.V_reset(V_reset),
		.V_syn(V_syn),
		.clk(clk),
		.rst(rst)
	);
	
	
	sipo #( .N(NEURON_COUNT) ) spike_reg (
		.q(spike_out),
		.a(spiking),
		.clk(clk),
		.rst(rst),
		.enable(enable)
	);
	
	control_unit_W #(.W(WORD_LENGTH), .N(NEURON_COUNT)) cu (
		.n_we(n_we),
		.s_we(s_we),
		.addr(addr),
		.V_syn(V_syn),
		.weight(weights),
		.s_i(spike_in),
		.clk(clk),
		.rst(rst),
		.enable(enable)
	);
	
	


endmodule
