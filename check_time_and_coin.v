`include "vending_machine_def.v"

	

module check_time_and_coin(return_total,i_input_coin,i_select_item,clk,reset_n,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input return_total;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;
	
	integer x;
	integer y;
	integer z;
	// initiate values
	initial begin
		// TODO: initiate values
	wait_time<=100;
	reset_n<=1;
	i_input_coin<=0;
	o_return_coin<=0;
	
	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
	wait_time<=100;
		// TODO: update coin return time
	end

	always @(return_total) begin //600=500+100 700=500+200 1300=1000+300
		x=return_total/1000;
		y=(return_total%1000)/500;
		z=((return_total%1000)%500)/100
		
		if(x==0&&Y==0&&z==0)
			o_return_coin=4b'000;
		else if(x==0&&Y==0&&z!=0)
			o_return_coin=4b'001;
		else if(x==0&&Y!=0&&z==0)
			o_return_coin=4b'010;
		else if(x==0&&Y!=0&&z!=0)
			o_return_coin=4b'011;
		else if(x!=0&&Y==0&&z==0)
			o_return_coin=4b'100;
		else if(x!=0&&Y==0&&z!=0)
			o_return_coin=4b'101;
		else if(x!=0&&Y!=0&&z==0)
			o_return_coin=4b'110;
		else if(x!=0&&Y!=0&&z!=0)
			o_return_coin=4b'111;
	
		// TODO: o_return_coin
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
//RETURN CHANGE
//I_INPUT_COIN
//I_SELECT_ITEM
//WAIT TIME
//RESET_N
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