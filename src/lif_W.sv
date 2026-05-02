module lif_W #(parameter int W = 8)
(
    output logic                    spike,
    output logic signed [W-1:0]     next_membrane,
    input  logic signed [W-1:0]     membrane,
    input  logic signed [W-1:0]     threshold,
    input  logic signed [W-1:0]     leak,
    input  logic signed [W-1:0]     V_reset,
    input  logic signed [W-1:0]     V_syn,
    input  logic                    clk,
    input  logic                    rst
);

    logic signed [2*W-1:0] mult;
    logic signed [2*W-1:0] scaled_mult;
    logic signed [2*W-1:0] V_syn_ext;
    logic signed [2*W-1:0] sum_ext;
    logic signed [W-1:0]   temp_membrane;
    logic                  spike_next;

    always_comb begin
        mult          = $signed(leak) * $signed(membrane);
        scaled_mult   = mult >>> (W/2);
        V_syn_ext     = {{W{V_syn[W-1]}}, V_syn};
        sum_ext       = scaled_mult + V_syn_ext;
        temp_membrane = sum_ext[W-1:0];
        spike_next    = (temp_membrane > threshold);
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            spike         <= '0;
            next_membrane <= '0;
        end else begin
            spike <= spike_next;

            if (spike_next)
                next_membrane <= V_reset;
            else
                next_membrane <= temp_membrane;
        end
    end

endmodule