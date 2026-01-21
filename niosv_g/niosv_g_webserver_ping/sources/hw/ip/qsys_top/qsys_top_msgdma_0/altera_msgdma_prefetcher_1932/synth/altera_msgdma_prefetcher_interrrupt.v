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

module altera_msgdma_prefetcher_interrupt (
    input           clk,
    input           reset,
    input           write_back_done,
    input           transfer_complete_irq_mask,
    input [7:0]     error_irq_mask,
    input           early_termination_irq_mask,
    input [7:0]     error,
    input           early_termination,
    input           clear_irq,
    input           global_interrupt_enable_mask,

    output reg      irq

);

wire set_irq;

always @(posedge clk) begin
    if (reset)
        irq <= 0;
    else begin
        case ({clear_irq, set_irq})
            2'b00: irq <= irq;
            2'b01: irq <= 1'b1;
            2'b10: irq <= 1'b0;
            2'b11: irq <= 1'b1;
        endcase
    end
end

assign set_irq  = (global_interrupt_enable_mask == 1) & (write_back_done == 1) &       // transfer ended and interrupts are enabled
                   ((transfer_complete_irq_mask == 1) |                        // transfer ended and the transfer complete IRQ is enabled
                    ((error & error_irq_mask) != 0) |                          // transfer ended with an error and this IRQ is enabled
                    ((early_termination & early_termination_irq_mask) == 1));  // transfer ended early due to early termination and this IRQ is enabled

                    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "SHCy1ZEC3RcMJzAL7Q+rRm+cdJsKJMIyfr9KgOf02eoU9n8AOz3s3ReuiHq6qvshOlFTAZYip6v/U81abJ+mWgQB2mWKwK901kIDcI8tlPaXKh8QfvpaQBpHIqntrpyb+c6xULWEdh4X8l8/WwgJyx0w3NJHVHwp0TWkFy3wA8yM7fOT8BMmx6/muz2lu4dBGOAndk8owv7nOF3ij+wS2ra49SFbb2CMhS+1JSP73NT3RcooQ8n8uj3UQSg+UpT4/3xLmsFyUMa63w+LxdZqP8zAQOWd6rQ0Hsm5YHR2rI2L4M6UzbCdtswD42/4CLRFhFZXvS09ZTDoglw3f2S6Zli715EvbBW3v4WA2dzDrWXUpfKGYt2rPeQd6smhrgNcS7LunjRQXMfDin7cE/noSNjZu0mkqXd5hKxhizTa10Ho/IT7kiiU3M8tSW6bF0POEBN38TG6YstjWZhSAZriduxTgS+RGJc851i52mLXG3DC1qbLGn6/NgpApRJFiA/2/yfzrpQHGd/h25f2Ii6d/u8WGDNhaUd9+3gE2v7xViHA1Z0odaxxSmU8I8fArwr83Bu3fUBzEaP7cf353iCTuh62su3zoQ9/iDgMSxtFVQfElagW99S1bG0SbpdSB0YIA5e/3i3V7I0l/D4E7VnW8jBzg5X63ZHiDwl1KCO8uinc6nzo1oWG6oatkjHKI+4xXFUf93CwgcIiuzEkZvv5ARjRdu8+bAnTvcyIKOlt6w3XpxiFCCcbjjSftHoff7VjDNv8B2OE5DY/80xqjgNqoWfWeHoKUV4JNYFW+KfCGT5ZL4fWLfYQRN6B3KmRXGe48EtwoM9QJV464ZfaUcz7uXgu2mJGxz3bfdEw38AuGmG0JA6QnRW6Kf5jAN2gCfU9M5kuuoR5y2W5Dr5QLwdSNBERRY35tBsui3gT5XXgXwAabaLThB5X8pC4UIDPgt7LGMux8ZcoAEPNXAlT2vM5385aeIAmyLlJWgifFblrk93wMt4vjy9DeKqQcTJ6fo0Q"
`endif