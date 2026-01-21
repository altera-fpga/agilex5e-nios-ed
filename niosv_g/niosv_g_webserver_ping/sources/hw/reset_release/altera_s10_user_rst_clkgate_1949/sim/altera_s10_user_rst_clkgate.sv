// (C) 2001-2025 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ns
module altera_s10_user_rst_clkgate (
	output logic ninit_done
);

	localparam USER_RESET_DELAY = 0;
	
	initial begin
		#0 ninit_done = 1;
		#1 ninit_done = 0;
	end
					
	
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "/u+ms/doVY4QSF55p2v2MvPVdyUfmPyj11hrxvinFoKxwd904KA16HTeAnYuC2XfTGO4qXimKo4joehsnx2xgIIg0o6reJ9HrHGrwM/sf8EsxqBRKrNiOkVLyUeUzxI5StWhlWt/ijs5U2IfzTwtl1Bo5wqi+oSv/LX+CNQEbkVuy2QmonKXO9ipRzfOXrVHwX4yvDsSQD3QI1ihK09+l4XclvEP68nO/WFpP6wXWVrXeZguIy2LRH/J2O60I63khQczq8kOPcmfmzUmHUGF5dEKIeY6Ru6AviVweEUu3U60lHW7yr8f+WkvVGKXihTJ62OHKATwCbGGJ6TVqhlBEHhnMUm/lyukcniuIXfCEFxQ8ffhQR/cqmeIWdYq+gnyC2CToFtV1MFu7FsI9FQETjL84fXHIUHbZV+GcecKwk74Akt2xMoqgX0vyrBfcJuB6mltXnUDJo8tFX0twPqFe/RJYxC8ERkZBcLWIhe3Mvf9q862xKnSaTP+ey19mCvBZhtXZfgv3yoqAtPIIfyX8zB6Iw2/EJpQQQuVo6IosDFRSX7Rc9X9BskqoWBm4ABwaZSaXCV/rOZyjxTuTI/ah9oaPZqzkUbPZ1LYSXr0d+Rv9r4eFkR9UB0F++d+Mobhg86yE0//4bjBkmVN8yhT0bXPVdFY2MnLCnhG7/6sLGuGA2OhgG0rpkS0SJjV3ZXxUYmnWXZr5dhueOuXdgOPskGX2+RGHDrr1QhT308TqDe7cYVeC11TMwl3wPJ71hg9GoyV2zOjRFPTNZtdkBlASRM8stZGVAv9qQRKw2/L/QMUY38BANgXVME8tuca0WlQhiQpqXMsUxa3hqoJodZECdxcmySRZXz/CiIowHnIWjmeLQABBrxhs6FA2Is7Nw+7WQPQlxTHUDN8j6+AqmVvB85Ae6ig4Z/db55gNVCFhaEFPsvrhqJqOgVX1mFAh3jRwP2tJylfPUVIdFXa4BbVcFnRNlszOVDf/ZCbiDDZVPhFgbXzxAc4P5E/CAAYmsUA"
`endif