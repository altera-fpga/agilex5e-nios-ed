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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module altera_avalon_sysid_qsys #(
    parameter USE_MANUAL_ID = 1,
    parameter MANUAL_ID = 1,
    parameter HASH_ID = 1,
    parameter TIMESTAMP = 1
)(
    // inputs:
     address,
     clock,
     reset_n,
    
    // outputs:
     readdata
)
;

  output  [ 31: 0] readdata;
  input            address;
  input            clock;
  input            reset_n;

  wire    [ 31: 0] readdata /* synthesis keep */;
  
  //control_slave, which is an e_avalon_slave
  assign readdata = address ? TIMESTAMP : ( USE_MANUAL_ID ? MANUAL_ID : HASH_ID );

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NSkVF3POA2Ob58BV731agipv/AWMgxvREJSHJE1U6uPg+FlmRHp3BzscyhP0a9ZRFlH5AG87wuwv9cFnTppqsW3YU3WkoNvtLo0Kz/wm/y3c5yRLkjmggQP9eSnCNYbjh3jOIdFHnw2vOlZVp+UstoDqlSjIGpz+tbpgQcCwaiHWUM1yIEOHTql/cMzfpezY43p5cLhGaNpYWVJ97bC+VUfaFzcFliHig6rrRNHCl5klyfqRAYp69ECV/t9tz/Rvz1vmd4wkGMSyphMpDv249jqH+7oqzPbpY8GTqWrfcSbNKAgEKsMwd2Sj2ahyNR3eeGsnr9lmfetTF0kpytP3btRkT0CyMyzV90019tqgvU++TsL+EkmhZZr0KB8QreUAJMgNwwHhcblyx+iabJT4n/s0Y4tWlL+7tXPIqeEXfNUYSr/NADefRlp7PJWn8/K4nB8Pgd9WfpkU57g3HXC8uunf5dPghIQdI2kJefpm3e5DdkbcA91Px/XPB/0ZxCRkbV/cNZ8Os0b7EK1wnHWoqyuCIELuSBM2DQ/UEoc2viO28OFVdBlq9RBBOXd/u5GrBSWL4SQu7nqGrjR2zgVvXR3+OLQdO6+naNCTP6urMUF8o8DFnTIbbgPHqdMp6KXAkkDYYv8ZMV/C0ecsPcsk5QgViZmKvQJZgUItOmp4Ukiko2SCHMM4BY5Pg4pckd+IfuQWgtxcni459WiZrE3ks2qsxr6/B6Ebdv4XojvX1Nb8KmkyL6xQ8sCOc9Dfym8l5Efvez8nD9teRRkM8UIgwOK"
`endif