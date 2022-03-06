

`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,i_trigger_return,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;		
	input i_trigger_return;	
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;	

	initial begin
	o_available_item <= 0;
	o_output_item <= 0;
	input_total <= 0;
	output_total <= 0;
	return_total <= 0;
	current_total_nxt <= 0;
	end

	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		
		return_total=0; //initialization
		if((wait_time == 0 || i_trigger_return) && current_total!=0) begin
			for(i=0; i<3; i=i+1) begin
				if(o_return_coin[i] == 1'b1) return_total = coin_value[i];
			end
			current_total_nxt = current_total - return_total;
		end
		else begin
			input_total=0;output_total=0; // initialization
			//calculate coin and item price
			for(i=0; i<3; i=i+1) begin
				if(i_input_coin[i] == 1'b1) input_total = coin_value[i];
			end
			for(i=0; i<4; i=i+1) begin
				if(i_select_item[i] == 1'b1 && o_available_item[i]) output_total = item_price[i];
			end
			current_total_nxt = current_total + input_total - output_total;
		end
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		return_total=0;
		// TODO: o_available_item
		for(i=0; i<4; i=i+1) begin
			if(current_total >= item_price[i]) o_available_item[i] = 1;
			else o_available_item[i]=0;
			
		end
		// TODO: o_output_item
		for(i=0; i<4; i=i+1) begin
			if(i_select_item[i] == 1'b1 && o_available_item[i] == 1'b1) o_output_item[i] = 1;
			else o_output_item[i] = 0;
		end
	end
 
	


endmodule 