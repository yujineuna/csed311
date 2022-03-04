`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	// initiate values
	initial begin
		// TODO: initiate values
	wait_time<=100;
	reset_n<=1;
	i_input_coin<=0;
	o_return_coin<=0;
	
	end


	// update coin return time
	//input? ??? select? item ??? ?? 
	always @(i_input_coin, i_select_item) begin
	wait_time<=100;
		// TODO: update coin return time
	end

	always @(*) begin
	
	if(i_input_coin==3'b001)
		o_return_coin+=100;
	else if(i_input_coin==3b'010)
		o_return_coin+=500;
	else if(i_input_coin==3b'100)
		o_return_coin+=1000;
	else if(i_select_item==4b'0001)
		o_return_coin-=400;
	else if(i_select_item==4b'0010)
		o_return_coin-=500;
	else if(i_select_item==4b'0100)
		o_return_coin-=1000;
	else if(i_select_item==4b'1000)
		o_return_coin-=2000;
	
		// TODO: o_return_coin
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
//RETURN CHANGE??
//I_INPUT_COIN???
//I_SELECT_ITEM???
//WAIT TIME???
//RESET_N??
		i_input_coin<=4b'0000;
		i_select_item<=4b'0000;
		wait_time<=100;
		resent_n<=1;
		
		
		
		end
		else begin
		// TODO: update all states.
		i_input_coin<=4b'0000;
		i_select_item<=4b'0000;
		wait_time=wait_time-1;

		end
	end
endmodule 