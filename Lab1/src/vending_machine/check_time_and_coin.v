`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,current_total,o_output_item,i_trigger_return,reset_n,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input i_trigger_return;
	input [`kNumItems-1:0] o_output_item;
	input [`kTotalBits-1:0] current_total;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	integer x, y, z;

	// initiate values
	initial begin
		// TODO: initiate values
		wait_time <= 0;
		o_return_coin <= 0;
		x <= 0;
		y <= 0;
		z <= 0;
	end
                                                                                                                                                                                                                                                                                                                                                                                                                          

	// update coin return time
	always @(i_input_coin, o_output_item) begin
		// TODO: update coin return time
		//if i_input_coin is set
		if(i_input_coin) wait_time <= 100;
		//if the item is dispensed
		if(o_output_item) wait_time <= 100;
		
	end

	always @(*) begin
		// TODO: o_return_coin

		//calculate the number of each type of coin
		x<=current_total/1000; //1000 coin 
		y<=(current_total%1000)/500; // 500 coin
		z<=((current_total%1000)%500)/100; // 100 coin
		
		if(wait_time == 0 || i_trigger_return) begin
		if(x>0) o_return_coin <= 3'b100; 
		else if(y>0) o_return_coin <= 3'b010; 
		else if(z>0) o_return_coin <= 3'b001;
		else o_return_coin <= 3'b000;
		end

	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
		wait_time <= 0;
		o_return_coin <= 0;
		end
		else begin
		// TODO: update all states.
		if(wait_time > 0) wait_time <= wait_time - 1;
		end
	end
endmodule 