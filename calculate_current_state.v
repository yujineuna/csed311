
`include "vending_machine_def.v"

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;	



	
	// Combinational logic for the next states
	always @(current_total or i_input_coin or i_select_item) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		case(current_total)
			4'b0000://???? 
				begin
					if(wait_time>0)
					input_total=coin_value[i_input_coin];//??????? -> mealy machine?? 
					output_total=0;
					return_total=coin_value[i_input_coin];
					current_total_nxt=4'b0001;
					else
					current_total_nxt=4'b0011//time out?? 
				end
			4'b0001://available ? item ???? ?? ?? ?? 
				begin
				if(coin_value[i_select_item]=<input_total)
					input_total=input_total-coin_value[i_select_item];
					return_total=input_total-coin_value[i_select_item];
					current_total_nxt=4'b0010;
				
				input_total=input_total+coin_value[i_input_coin];
				return_total=return_total+coin_value[i_input_coin];
									
				end
			4'b0010://available?? ??? ? ?? 
				begin
				ouput_total=coin_value[i_select_item];
				current_total_nxt=4'b0001;//2????
				end
			4'b0011://time out? ?? ?? ??? item?????? timeout??? ?? ?????+ return button state? ????.!
				begin	
				input_total=0;
				output_total=0;
				return_total=0;
				current_total_nxt=4'b000
				end
							


		
	end

	
	
	// Combinational logic for the outputs
	always @(current_total or input_total or output_total) begin
		//cs?? available?? swith?
		//input 
		// TODO: o_available_item
		// TODO: o_output_item
		
	case(current_total)
		4'b0001:
		begin	
		if(input_total<400)
		o_available_item=4'b0000;
		else if(input_total==400||(input_total>400&&input_total<500)
		o_available_item=4'b0001;
		else if(input_total==500||(input_total>500&&input_total<1000)
		o_available_item=4'b0011;	
		else if(input_total==1000||(input_total>1000&&input_total<2000)
		o_available_item=4'b0111;	
		else
		o_available_item=4'b1111;	
		end
		
		4'b0010:
		begin
		if(output_total==400)
		o_output_item=4'b0001;
		else if(output_total==500)
		o_output_item=4'b0010;
		else if(output_total==1000)
		o_output_item=4'b0100;
		else 
		o_output_item=4b'1000;
 
		end
		
	endcase
		

//input total ??
//item_price? coin_value ???? ? ???? O_AVAILABLE_ITEM?? ??

//?? i_select_item? available_item? ?? ?? o_output_item ??
	end
 
	


endmodule 