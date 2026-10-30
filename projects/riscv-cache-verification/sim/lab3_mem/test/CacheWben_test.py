
#=========================================================================
# CacheWben Unit Test
#=========================================================================

from pathlib import Path
import subprocess
import tempfile


def test_wben(cmdline_opts):

  verilog_file = Path(__file__).resolve().parent.parent / "CacheWben.v"
  testbench = """
module tb;

  // Two-bit word offset selects one of four 32-bit words.
  reg  [1:0]  word_offset;

  // Sixteen-bit byte enable controls the 16 bytes in a cache line.
  wire [15:0] byte_en;

  // Instantiate the CacheWben decoder.
  lab3_mem_CacheWben dut (
    .word_offset(word_offset),
    .byte_en(byte_en)
  );

  initial begin

    // Word 0: Enable bytes 0-3.
    word_offset = 2'b00; #1;
    if (byte_en !== 16'h000f) $fatal(1, "Offset 0 failed");

    // Word 1: Enable bytes 4-7.
    word_offset = 2'b01; #1;
    if (byte_en !== 16'h00f0) $fatal(1, "Offset 1 failed");

    // Word 2: Enable bytes 8-11.
    word_offset = 2'b10; #1;
    if (byte_en !== 16'h0f00) $fatal(1, "Offset 2 failed");

    // Word 3: Enable bytes 12-15.
    word_offset = 2'b11; #1;
    if (byte_en !== 16'hf000) $fatal(1, "Offset 3 failed");

    // All four decoder outputs matched their expected values.
    $display("All CacheWben tests passed");
    $finish;

  end
endmodule
"""

  with tempfile.TemporaryDirectory() as tmp:

    tb_path = Path(tmp) / "tb.sv"
    sim_path = Path(tmp) / "sim.out"

    tb_path.write_text(testbench)

    subprocess.run(
      ["iverilog", "-g2012", "-s", "tb", "-o",
       str(sim_path), str(verilog_file), str(tb_path)],
      check=True
    )

    subprocess.run(["vvp", str(sim_path)], check=True)
