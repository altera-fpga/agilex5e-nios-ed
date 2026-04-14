// (C) 2001-2026 Altera Corporation. All rights reserved.
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


`default_nettype none

module emif_axi_handler (
    input  wire          clk_i,
    input  wire          rst_n_i,

    // Core
    input  wire          core_axi_arlock_i,
    input  wire  [2:0]   core_axi_arprot_i,
    input  wire  [3:0]   core_axi_arqos_i,
    output logic         core_axi_arready_o,
    input  wire          core_axi_arvalid_i,
    input  wire  [32:0]  core_axi_araddr_i,
    input  wire  [1:0]   core_axi_arburst_i,
    input  wire  [6:0]   core_axi_arid_i,
    input  wire  [7:0]   core_axi_arlen_i,
    input  wire  [2:0]   core_axi_arsize_i,
    input  wire  [3:0]   core_axi_aruser_i,

    input  wire          core_axi_rready_i,
    output logic         core_axi_rvalid_o,
    output logic         core_axi_rlast_o,
    output logic [255:0] core_axi_rdata_o,
    output logic [6:0]   core_axi_rid_o,
    output logic [1:0]   core_axi_rresp_o,
    output logic [63:0]  core_axi_ruser_o,

    input  wire          core_axi_awlock_i,
    input  wire  [2:0]   core_axi_awprot_i,
    input  wire  [3:0]   core_axi_awqos_i,
    output logic         core_axi_awready_o,
    input  wire          core_axi_awvalid_i,
    input  wire  [32:0]  core_axi_awaddr_i,
    input  wire  [1:0]   core_axi_awburst_i,
    input  wire  [6:0]   core_axi_awid_i,
    input  wire  [7:0]   core_axi_awlen_i,
    input  wire  [2:0]   core_axi_awsize_i,
    input  wire  [3:0]   core_axi_awuser_i,

    input  wire          core_axi_wlast_i,
    output logic         core_axi_wready_o,
    input  wire          core_axi_wvalid_i,
    input  wire  [255:0] core_axi_wdata_i,
    input  wire  [31:0]  core_axi_wstrb_i,
    input  wire  [63:0]  core_axi_wuser_i,

    input  wire          core_axi_bready_i,
    output logic         core_axi_bvalid_o,
    output logic [6:0]   core_axi_bid_o,
    output logic [1:0]   core_axi_bresp_o,

    // EMIF
    output logic         emif_axi_arlock_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [2:0]   emif_axi_arprot_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [3:0]   emif_axi_arqos_o   /* synthesis dont_merge syn_preserve = 1 */,
    input  wire          emif_axi_arready_i,
    output logic         emif_axi_arvalid_o /* synthesis dont_merge syn_preserve = 1 */,
    output logic [32:0]  emif_axi_araddr_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [1:0]   emif_axi_arburst_o /* synthesis dont_merge syn_preserve = 1 */,
    output logic [6:0]   emif_axi_arid_o    /* synthesis dont_merge syn_preserve = 1 */,
    output logic [7:0]   emif_axi_arlen_o   /* synthesis dont_merge syn_preserve = 1 */,
    output logic [2:0]   emif_axi_arsize_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [3:0]   emif_axi_aruser_o  /* synthesis dont_merge syn_preserve = 1 */,

    output logic         emif_axi_rready_o  /* synthesis dont_merge syn_preserve = 1 */,
    input  wire          emif_axi_rvalid_i,
    input  wire          emif_axi_rlast_i,
    input  wire  [255:0] emif_axi_rdata_i,
    input  wire  [6:0]   emif_axi_rid_i,
    input  wire  [1:0]   emif_axi_rresp_i,
    input  wire  [63:0]  emif_axi_ruser_i,

    output logic         emif_axi_awlock_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [2:0]   emif_axi_awprot_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [3:0]   emif_axi_awqos_o   /* synthesis dont_merge syn_preserve = 1 */,
    input  wire          emif_axi_awready_i,
    output logic         emif_axi_awvalid_o /* synthesis dont_merge syn_preserve = 1 */,
    output logic [32:0]  emif_axi_awaddr_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [1:0]   emif_axi_awburst_o /* synthesis dont_merge syn_preserve = 1 */,
    output logic [6:0]   emif_axi_awid_o    /* synthesis dont_merge syn_preserve = 1 */,
    output logic [7:0]   emif_axi_awlen_o   /* synthesis dont_merge syn_preserve = 1 */,
    output logic [2:0]   emif_axi_awsize_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [3:0]   emif_axi_awuser_o  /* synthesis dont_merge syn_preserve = 1 */,

    output logic         emif_axi_wlast_o   /* synthesis dont_merge syn_preserve = 1 */,
    input  wire          emif_axi_wready_i,
    output logic         emif_axi_wvalid_o  /* synthesis dont_merge syn_preserve = 1 */,
    output logic [255:0] emif_axi_wdata_o   /* synthesis dont_merge syn_preserve = 1 */,
    output logic [31:0]  emif_axi_wstrb_o   /* synthesis dont_merge syn_preserve = 1 */,
    output logic [63:0]  emif_axi_wuser_o   /* synthesis dont_merge syn_preserve = 1 */,

    output logic         emif_axi_bready_o  /* synthesis dont_merge syn_preserve = 1 */,
    input  wire          emif_axi_bvalid_i,
    input  wire  [6:0]   emif_axi_bid_i,
    input  wire  [1:0]   emif_axi_bresp_i
);

    logic         ar_fifo_wr;
    logic [62:0]  ar_fifo_wdata;
    logic         ar_fifo_rd;
    logic [62:0]  ar_fifo_rdata;
    logic         ar_fifo_empty;
    logic         ar_fifo_almost_full;

    logic         r_fifo_wr;
    logic [329:0] r_fifo_wdata;
    logic         r_fifo_rd;
    logic [329:0] r_fifo_rdata;
    logic         r_fifo_empty;
    logic         r_fifo_almost_full;

    logic         aw_fifo_wr;
    logic [62:0]  aw_fifo_wdata;
    logic         aw_fifo_rd;
    logic [62:0]  aw_fifo_rdata;
    logic         aw_fifo_empty;
    logic         aw_fifo_almost_full;

    logic         w_fifo_wr;
    logic [352:0] w_fifo_wdata;
    logic         w_fifo_rd;
    logic [352:0] w_fifo_rdata;
    logic         w_fifo_empty;
    logic         w_fifo_almost_full;

    logic         b_fifo_wr;
    logic [8:0]   b_fifo_wdata;
    logic         b_fifo_rd;
    logic [8:0]   b_fifo_rdata;
    logic         b_fifo_empty;
    logic         b_fifo_almost_full;


    //-----------------------------------------------------------------------
    // AR Channel
    //-----------------------------------------------------------------------
    assign ar_fifo_wr    = core_axi_arvalid_i && core_axi_arready_o;

    assign ar_fifo_wdata = {core_axi_arlock_i,
                            core_axi_arprot_i,
                            core_axi_arqos_i,
                            core_axi_araddr_i,
                            core_axi_arburst_i,
                            core_axi_arid_i,
                            core_axi_arlen_i,
                            core_axi_arsize_i,
                            core_axi_aruser_i};

    scfifo # (
        .add_ram_output_register ("ON"),
        .almost_empty_value      (1),
        .almost_full_value       (4),
        .enable_ecc              ("FALSE"),
        .intended_device_family  ("Agilex 5"),
        .lpm_numwords            (8),
        .lpm_showahead           ("ON"),
        .lpm_type                ("scfifo"),
        .lpm_width               (63),
        .lpm_widthu              ($clog2(8)),
        .overflow_checking       ("ON"),
        .underflow_checking      ("ON"),
        .use_eab                 ("ON")
    ) ar_fifo (
        .aclr         (1'b0),
        .clock        (clk_i),
        .data         (ar_fifo_wdata),
        .rdreq        (ar_fifo_rd),
        .sclr         (~rst_n_i),
        .wrreq        (ar_fifo_wr),
        .almost_empty (/* Unused */),
        .almost_full  (ar_fifo_almost_full),
        .empty        (ar_fifo_empty),
        .full         (/* Unused */),
        .q            (ar_fifo_rdata),
        .usedw        (/* Unused */),
        .eccstatus    (/* Unused */)
    );

    always_ff @ (posedge clk_i) begin
        core_axi_arready_o <= ~ar_fifo_almost_full;
    end

    always_ff @ (posedge clk_i) begin
        if (~rst_n_i) begin
            emif_axi_arvalid_o <= 1'b0;
            ar_fifo_rd         <= 1'b0;
        end
        else begin
            if ((~ar_fifo_empty) && (~ar_fifo_rd)) begin
                emif_axi_arvalid_o <= 1'b1;
            end

            if (emif_axi_arvalid_o && emif_axi_arready_i) begin
                emif_axi_arvalid_o <= 1'b0;
                ar_fifo_rd         <= 1'b1;
            end

            if (ar_fifo_rd) begin
                ar_fifo_rd         <= 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i) begin
        emif_axi_arlock_o  <= ar_fifo_rdata[62];
        emif_axi_arprot_o  <= ar_fifo_rdata[61:59];
        emif_axi_arqos_o   <= ar_fifo_rdata[58:55];
        emif_axi_araddr_o  <= ar_fifo_rdata[54:24];
        emif_axi_arburst_o <= ar_fifo_rdata[23:22];
        emif_axi_arid_o    <= ar_fifo_rdata[21:15];
        emif_axi_arlen_o   <= ar_fifo_rdata[14:7];
        emif_axi_arsize_o  <= ar_fifo_rdata[6:4];
        emif_axi_aruser_o  <= ar_fifo_rdata[3:0];
    end


    //-----------------------------------------------------------------------
    // R Channel
    //-----------------------------------------------------------------------
    assign r_fifo_wr    = emif_axi_rvalid_i && emif_axi_rready_o;

    assign r_fifo_wdata = {emif_axi_rlast_i,
                           emif_axi_rdata_i,
                           emif_axi_rid_i,
                           emif_axi_rresp_i,
                           emif_axi_ruser_i};

    scfifo # (
        .add_ram_output_register ("ON"),
        .almost_empty_value      (1),
        .almost_full_value       (240),
        .enable_ecc              ("FALSE"),
        .intended_device_family  ("Agilex 5"),
        .lpm_numwords            (256),
        .lpm_showahead           ("ON"),
        .lpm_type                ("scfifo"),
        .lpm_width               (330),
        .lpm_widthu              ($clog2(256)),
        .overflow_checking       ("ON"),
        .underflow_checking      ("ON"),
        .use_eab                 ("ON")
    ) r_fifo (
        .aclr         (1'b0),
        .clock        (clk_i),
        .data         (r_fifo_wdata),
        .rdreq        (r_fifo_rd),
        .sclr         (~rst_n_i),
        .wrreq        (r_fifo_wr),
        .almost_empty (/* Unused */),
        .almost_full  (r_fifo_almost_full),
        .empty        (r_fifo_empty),
        .full         (/* Unused */),
        .q            (r_fifo_rdata),
        .usedw        (/* Unused */),
        .eccstatus    (/* Unused */)
    );

    always_ff @ (posedge clk_i) begin
        emif_axi_rready_o <= ~r_fifo_almost_full;
    end

    always_ff @ (posedge clk_i) begin
        if (~rst_n_i) begin
            core_axi_rvalid_o <= 1'b0;
            r_fifo_rd         <= 1'b0;
        end
        else begin
            if ((~r_fifo_empty) && (~r_fifo_rd)) begin
                core_axi_rvalid_o <= 1'b1;
            end

            if (core_axi_rvalid_o && core_axi_rready_i) begin
                core_axi_rvalid_o <= 1'b0;
                r_fifo_rd         <= 1'b1;
            end

            if (r_fifo_rd) begin
                r_fifo_rd         <= 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i) begin
        core_axi_rlast_o <= r_fifo_rdata[329];
        core_axi_rdata_o <= r_fifo_rdata[328:73];
        core_axi_rid_o   <= r_fifo_rdata[72:66];
        core_axi_rresp_o <= r_fifo_rdata[65:64];
        core_axi_ruser_o <= r_fifo_rdata[63:0];
    end


    //-----------------------------------------------------------------------
    // AW Channel
    //-----------------------------------------------------------------------
    assign aw_fifo_wr    = core_axi_awvalid_i && core_axi_awready_o;

    assign aw_fifo_wdata = {core_axi_awlock_i,
                            core_axi_awprot_i,
                            core_axi_awqos_i,
                            core_axi_awaddr_i,
                            core_axi_awburst_i,
                            core_axi_awid_i,
                            core_axi_awlen_i,
                            core_axi_awsize_i,
                            core_axi_awuser_i};

    scfifo # (
        .add_ram_output_register ("ON"),
        .almost_empty_value      (1),
        .almost_full_value       (4),
        .enable_ecc              ("FALSE"),
        .intended_device_family  ("Agilex 5"),
        .lpm_numwords            (8),
        .lpm_showahead           ("ON"),
        .lpm_type                ("scfifo"),
        .lpm_width               (63),
        .lpm_widthu              ($clog2(8)),
        .overflow_checking       ("ON"),
        .underflow_checking      ("ON"),
        .use_eab                 ("ON")
    ) aw_fifo (
        .aclr         (1'b0),
        .clock        (clk_i),
        .data         (aw_fifo_wdata),
        .rdreq        (aw_fifo_rd),
        .sclr         (~rst_n_i),
        .wrreq        (aw_fifo_wr),
        .almost_empty (/* Unused */),
        .almost_full  (aw_fifo_almost_full),
        .empty        (aw_fifo_empty),
        .full         (/* Unused */),
        .q            (aw_fifo_rdata),
        .usedw        (/* Unused */),
        .eccstatus    (/* Unused */)
    );

    always_ff @ (posedge clk_i) begin
        core_axi_awready_o <= ~aw_fifo_almost_full;
    end

    always_ff @ (posedge clk_i) begin
        if (~rst_n_i) begin
            emif_axi_awvalid_o <= 1'b0;
            aw_fifo_rd         <= 1'b0;
        end
        else begin
            if ((~aw_fifo_empty) && (~aw_fifo_rd)) begin
                emif_axi_awvalid_o <= 1'b1;
            end

            if (emif_axi_awvalid_o && emif_axi_awready_i) begin
                emif_axi_awvalid_o <= 1'b0;
                aw_fifo_rd         <= 1'b1;
            end

            if (aw_fifo_rd) begin
                aw_fifo_rd         <= 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i) begin
        emif_axi_awlock_o  <= aw_fifo_rdata[62];
        emif_axi_awprot_o  <= aw_fifo_rdata[61:60];
        emif_axi_awqos_o   <= aw_fifo_rdata[58:55];
        emif_axi_awaddr_o  <= aw_fifo_rdata[54:24];
        emif_axi_awburst_o <= aw_fifo_rdata[23:22];
        emif_axi_awid_o    <= aw_fifo_rdata[21:15];
        emif_axi_awlen_o   <= aw_fifo_rdata[14:7];
        emif_axi_awsize_o  <= aw_fifo_rdata[6:4];
        emif_axi_awuser_o  <= aw_fifo_rdata[3:0];
    end


    //-----------------------------------------------------------------------
    // W Channel
    //-----------------------------------------------------------------------
    assign w_fifo_wr    = core_axi_wvalid_i && core_axi_wready_o;

    assign w_fifo_wdata = {core_axi_wlast_i,
                           core_axi_wdata_i,
                           core_axi_wstrb_i,
                           core_axi_wuser_i};

    scfifo # (
        .add_ram_output_register ("ON"),
        .almost_empty_value      (1),
        .almost_full_value       (240),
        .enable_ecc              ("FALSE"),
        .intended_device_family  ("Agilex 5"),
        .lpm_numwords            (256),
        .lpm_showahead           ("ON"),
        .lpm_type                ("scfifo"),
        .lpm_width               (353),
        .lpm_widthu              ($clog2(256)),
        .overflow_checking       ("ON"),
        .underflow_checking      ("ON"),
        .use_eab                 ("ON")
    ) w_fifo (
        .aclr         (1'b0),
        .clock        (clk_i),
        .data         (w_fifo_wdata),
        .rdreq        (w_fifo_rd),
        .sclr         (~rst_n_i),
        .wrreq        (w_fifo_wr),
        .almost_empty (/* Unused */),
        .almost_full  (w_fifo_almost_full),
        .empty        (w_fifo_empty),
        .full         (/* Unused */),
        .q            (w_fifo_rdata),
        .usedw        (/* Unused */),
        .eccstatus    (/* Unused */)
    );

    always_ff @ (posedge clk_i) begin
        core_axi_wready_o <= ~w_fifo_almost_full;
    end

    always_ff @ (posedge clk_i) begin
        if (~rst_n_i) begin
            emif_axi_wvalid_o <= 1'b0;
            w_fifo_rd         <= 1'b0;
        end
        else begin
            if ((~w_fifo_empty) && (~w_fifo_rd)) begin
                emif_axi_wvalid_o <= 1'b1;
            end

            if (emif_axi_wvalid_o && emif_axi_wready_i) begin
                emif_axi_wvalid_o <= 1'b0;
                w_fifo_rd         <= 1'b1;
            end

            if (w_fifo_rd) begin
                w_fifo_rd         <= 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i) begin
        emif_axi_wlast_o <= w_fifo_rdata[352];
        emif_axi_wdata_o <= w_fifo_rdata[351:96];
        emif_axi_wstrb_o <= w_fifo_rdata[95:64];
        emif_axi_wuser_o <= w_fifo_rdata[63:0];
    end


    //-----------------------------------------------------------------------
    // B Channel
    //-----------------------------------------------------------------------
    assign b_fifo_wr    = emif_axi_bvalid_i && emif_axi_bready_o;

    assign b_fifo_wdata = {emif_axi_bid_i,
                           emif_axi_bresp_i};

    scfifo # (
        .add_ram_output_register ("ON"),
        .almost_empty_value      (1),
        .almost_full_value       (4),
        .enable_ecc              ("FALSE"),
        .intended_device_family  ("Agilex 5"),
        .lpm_numwords            (8),
        .lpm_showahead           ("ON"),
        .lpm_type                ("scfifo"),
        .lpm_width               (9),
        .lpm_widthu              ($clog2(8)),
        .overflow_checking       ("ON"),
        .underflow_checking      ("ON"),
        .use_eab                 ("ON")
    ) b_fifo (
        .aclr         (1'b0),
        .clock        (clk_i),
        .data         (b_fifo_wdata),
        .rdreq        (b_fifo_rd),
        .sclr         (~rst_n_i),
        .wrreq        (b_fifo_wr),
        .almost_empty (/* Unused */),
        .almost_full  (b_fifo_almost_full),
        .empty        (b_fifo_empty),
        .full         (/* Unused */),
        .q            (b_fifo_rdata),
        .usedw        (/* Unused */),
        .eccstatus    (/* Unused */)
    );

    always_ff @ (posedge clk_i) begin
        emif_axi_bready_o <= ~b_fifo_almost_full;
    end

    always_ff @ (posedge clk_i) begin
        if (~rst_n_i) begin
            core_axi_bvalid_o <= 1'b0;
            b_fifo_rd         <= 1'b0;
        end
        else begin
            if ((~b_fifo_empty) && (~b_fifo_rd)) begin
                core_axi_bvalid_o <= 1'b1;
            end

            if (core_axi_bvalid_o && core_axi_bready_i) begin
                core_axi_bvalid_o <= 1'b0;
                b_fifo_rd         <= 1'b1;
            end

            if (b_fifo_rd) begin
                b_fifo_rd         <= 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i) begin
        core_axi_bid_o   <= b_fifo_rdata[8:2];
        core_axi_bresp_o <= b_fifo_rdata[1:0];
    end


endmodule

`default_nettype wire