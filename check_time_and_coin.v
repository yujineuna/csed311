`include "vending_machine_def.v"

	

module check_time_and_coin(i_input_coin,i_select_item,clk,reset_n,wait_time,o_return_coin);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg  [`kNumCoins-1:0] o_return_coin;
	output reg [31:0] wait_time;

	reg total_cash;
	integer x, y, z;

	// initiate values
	initial begin
		// TODO: initiate values
		o_return_coin <= 3'b000;
		wait_time <= 0;
		total_cash <= 0;
		x <= 0;
		y <= 0;
		z <= 0;
	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		wait_time <= 100;
	end

	always @(*) begin
		// TODO: o_return_coin
		case(i_input_coin)
			3'b001: total_cash = total_cash + 100;
			3'b010: total_cash = total_cash + 500;
			3'b100: total_cash = total_cash + 1000;
			default: begin end
		endcase

		case(i_select_item)
			4'b0001: if(total_cash>400||total_cash==400) begin
				total_cash=total_cash-400;
			end
			4'b0010:if(total_cash>500||total_cash==500) begin
				total_cash=total_cash-500;
			end
			4'b0100:if(total_cash>1000||total_cash==1000) begin
				total_cash=total_cash-1000;
			end
			4'b1000:if(total_cash>2000||total_cash==2000) begin
				total_cash=total_cash-2000;
			end
			default: begin end
		endcase
		//? coin type? ??
		x=total_cash/1000;
		y=(total_cash%1000)/500;
		z=((total_cash%1000)%500)/100;
		
		if(x!=0) o_return_coin = 3'b100;
		else if(y!=0) o_return_coin = 3'b010;
		else o_return_coin = 3'b001;
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
		o_return_coin <= 3'b000;
		wait_time <= 0;	
		total_cash <= 0;
		end
		else begin
		// TODO: update all states.
		if(wait_time > 0) wait_time = wait_time - 1;
		end
	end
endmodule 
