//========================================================================
// MusicMem_RTL.v
//========================================================================
// A staff-provided memory to supply memory values to play music

`ifndef MUSIC_MEM_RTL_V
`define MUSIC_MEM_RTL_V

module MusicMem_RTL
(
  (* keep=1 *) input  logic        mem_val,
  (* keep=1 *) input  logic [15:0] mem_addr,
  (* keep=1 *) output logic [31:0] mem_rdata
);

  localparam REST     = 32'h00000000;
  localparam NOTE_G   = 32'h00000001;
  localparam NOTE_A   = 32'h00000002;
  localparam NOTE_B   = 32'h00000003;
  localparam NOTE_C   = 32'h00000004;
  localparam NOTE_D   = 32'h00000005;
  localparam NOTE_E   = 32'h00000006;
  localparam NOTE_F   = 32'h00000007;
  localparam SONG_END = 32'h0000ffff;

  always_comb begin
    case( mem_addr )

      //----------------------------------------------------------------
      // Song 0
      //----------------------------------------------------------------

      16'h0000: mem_rdata = NOTE_B;
      16'h0004: mem_rdata = REST;
      16'h0008: mem_rdata = NOTE_A;
      16'h000C: mem_rdata = REST;
      16'h0010: mem_rdata = NOTE_G;
      16'h0014: mem_rdata = REST;
      16'h0018: mem_rdata = NOTE_A;
      16'h001C: mem_rdata = REST;

      16'h0020: mem_rdata = NOTE_B;
      16'h0024: mem_rdata = REST;
      16'h0028: mem_rdata = NOTE_B;
      16'h002C: mem_rdata = REST;
      16'h0030: mem_rdata = NOTE_B;
      16'h0034: mem_rdata = REST;
      16'h0038: mem_rdata = REST;
      16'h003C: mem_rdata = REST;

      16'h0040: mem_rdata = NOTE_A;
      16'h0044: mem_rdata = REST;
      16'h0048: mem_rdata = NOTE_A;
      16'h004C: mem_rdata = REST;
      16'h0050: mem_rdata = NOTE_A;
      16'h0054: mem_rdata = REST;
      16'h0058: mem_rdata = REST;
      16'h005C: mem_rdata = REST;

      16'h0060: mem_rdata = NOTE_B;
      16'h0064: mem_rdata = REST;
      16'h0068: mem_rdata = NOTE_D;
      16'h006C: mem_rdata = REST;
      16'h0070: mem_rdata = NOTE_D;
      16'h0074: mem_rdata = REST;
      16'h0078: mem_rdata = REST;
      16'h007C: mem_rdata = REST;

      16'h0080: mem_rdata = NOTE_B;
      16'h0084: mem_rdata = REST;
      16'h0088: mem_rdata = NOTE_A;
      16'h008C: mem_rdata = REST;
      16'h0090: mem_rdata = NOTE_G;
      16'h0094: mem_rdata = REST;
      16'h0098: mem_rdata = NOTE_A;
      16'h009C: mem_rdata = REST;

      16'h00A0: mem_rdata = NOTE_B;
      16'h00A4: mem_rdata = REST;
      16'h00A8: mem_rdata = NOTE_B;
      16'h00AC: mem_rdata = REST;
      16'h00B0: mem_rdata = NOTE_B;
      16'h00B4: mem_rdata = REST;
      16'h00B8: mem_rdata = NOTE_B;
      16'h00BC: mem_rdata = REST;

      16'h00C0: mem_rdata = NOTE_A;
      16'h00C4: mem_rdata = REST;
      16'h00C8: mem_rdata = NOTE_A;
      16'h00CC: mem_rdata = REST;
      16'h00D0: mem_rdata = NOTE_B;
      16'h00D4: mem_rdata = REST;
      16'h00D8: mem_rdata = NOTE_A;
      16'h00DC: mem_rdata = REST;

      16'h00E0: mem_rdata = NOTE_G;
      16'h00E4: mem_rdata = NOTE_G;
      16'h00E8: mem_rdata = NOTE_G;
      16'h00EC: mem_rdata = NOTE_G;
      16'h00F0: mem_rdata = REST;
      16'h00F4: mem_rdata = REST;
      16'h00F8: mem_rdata = REST;
      16'h00FC: mem_rdata = SONG_END;

      //----------------------------------------------------------------
      // Song 1
      //----------------------------------------------------------------

      16'h0200: mem_rdata = NOTE_B;
      16'h0204: mem_rdata = REST;
      16'h0208: mem_rdata = NOTE_B;
      16'h020C: mem_rdata = REST;
      16'h0210: mem_rdata = NOTE_B;
      16'h0214: mem_rdata = REST;
      16'h0218: mem_rdata = REST;
      16'h021C: mem_rdata = REST;

      16'h0220: mem_rdata = NOTE_B;
      16'h0224: mem_rdata = REST;
      16'h0228: mem_rdata = NOTE_B;
      16'h022C: mem_rdata = REST;
      16'h0230: mem_rdata = NOTE_B;
      16'h0234: mem_rdata = REST;
      16'h0238: mem_rdata = REST;
      16'h023C: mem_rdata = REST;

      16'h0240: mem_rdata = NOTE_B;
      16'h0244: mem_rdata = REST;
      16'h0248: mem_rdata = NOTE_D;
      16'h024C: mem_rdata = REST;
      16'h0250: mem_rdata = NOTE_G;
      16'h0254: mem_rdata = REST;
      16'h0258: mem_rdata = NOTE_A;
      16'h025C: mem_rdata = REST;

      16'h0260: mem_rdata = NOTE_B;
      16'h0264: mem_rdata = NOTE_B;
      16'h0268: mem_rdata = NOTE_B;
      16'h026C: mem_rdata = NOTE_B;
      16'h0270: mem_rdata = REST;
      16'h0274: mem_rdata = REST;
      16'h0278: mem_rdata = REST;
      16'h027C: mem_rdata = REST;

      16'h0280: mem_rdata = NOTE_C;
      16'h0284: mem_rdata = REST;
      16'h0288: mem_rdata = NOTE_C;
      16'h028C: mem_rdata = REST;
      16'h0290: mem_rdata = NOTE_C;
      16'h0294: mem_rdata = REST;
      16'h0298: mem_rdata = NOTE_C;
      16'h029C: mem_rdata = REST;

      16'h02A0: mem_rdata = NOTE_C;
      16'h02A4: mem_rdata = REST;
      16'h02A8: mem_rdata = NOTE_B;
      16'h02AC: mem_rdata = REST;
      16'h02B0: mem_rdata = NOTE_B;
      16'h02B4: mem_rdata = REST;
      16'h02B8: mem_rdata = NOTE_B;
      16'h02BC: mem_rdata = REST;

      16'h02C0: mem_rdata = NOTE_D;
      16'h02C4: mem_rdata = REST;
      16'h02C8: mem_rdata = NOTE_D;
      16'h02CC: mem_rdata = REST;
      16'h02D0: mem_rdata = NOTE_C;
      16'h02D4: mem_rdata = REST;
      16'h02D8: mem_rdata = NOTE_A;
      16'h02DC: mem_rdata = REST;

      16'h02E0: mem_rdata = NOTE_G;
      16'h02E4: mem_rdata = NOTE_G;
      16'h02E8: mem_rdata = NOTE_G;
      16'h02EC: mem_rdata = NOTE_G;
      16'h02F0: mem_rdata = REST;
      16'h02F4: mem_rdata = REST;
      16'h02F8: mem_rdata = REST;
      16'h02FC: mem_rdata = SONG_END;

      //----------------------------------------------------------------
      // Song 2
      //----------------------------------------------------------------
      // OPTIONAL: Replace note values to make a new song!

      16'h0400: mem_rdata = SONG_END;
      16'h0404: mem_rdata = SONG_END;
      16'h0408: mem_rdata = SONG_END;
      16'h040C: mem_rdata = SONG_END;
      16'h0410: mem_rdata = SONG_END;
      16'h0414: mem_rdata = SONG_END;
      16'h0418: mem_rdata = SONG_END;
      16'h041C: mem_rdata = SONG_END;

      16'h0420: mem_rdata = SONG_END;
      16'h0424: mem_rdata = SONG_END;
      16'h0428: mem_rdata = SONG_END;
      16'h042C: mem_rdata = SONG_END;
      16'h0430: mem_rdata = SONG_END;
      16'h0434: mem_rdata = SONG_END;
      16'h0438: mem_rdata = SONG_END;
      16'h043C: mem_rdata = SONG_END;

      16'h0440: mem_rdata = SONG_END;
      16'h0444: mem_rdata = SONG_END;
      16'h0448: mem_rdata = SONG_END;
      16'h044C: mem_rdata = SONG_END;
      16'h0450: mem_rdata = SONG_END;
      16'h0454: mem_rdata = SONG_END;
      16'h0458: mem_rdata = SONG_END;
      16'h045C: mem_rdata = SONG_END;

      16'h0460: mem_rdata = SONG_END;
      16'h0464: mem_rdata = SONG_END;
      16'h0468: mem_rdata = SONG_END;
      16'h046C: mem_rdata = SONG_END;
      16'h0470: mem_rdata = SONG_END;
      16'h0474: mem_rdata = SONG_END;
      16'h0478: mem_rdata = SONG_END;
      16'h047C: mem_rdata = SONG_END;

      16'h0480: mem_rdata = SONG_END;
      16'h0484: mem_rdata = SONG_END;
      16'h0488: mem_rdata = SONG_END;
      16'h048C: mem_rdata = SONG_END;
      16'h0490: mem_rdata = SONG_END;
      16'h0494: mem_rdata = SONG_END;
      16'h0498: mem_rdata = SONG_END;
      16'h049C: mem_rdata = SONG_END;

      16'h04A0: mem_rdata = SONG_END;
      16'h04A4: mem_rdata = SONG_END;
      16'h04A8: mem_rdata = SONG_END;
      16'h04AC: mem_rdata = SONG_END;
      16'h04B0: mem_rdata = SONG_END;
      16'h04B4: mem_rdata = SONG_END;
      16'h04B8: mem_rdata = SONG_END;
      16'h04BC: mem_rdata = SONG_END;

      16'h04C0: mem_rdata = SONG_END;
      16'h04C4: mem_rdata = SONG_END;
      16'h04C8: mem_rdata = SONG_END;
      16'h04CC: mem_rdata = SONG_END;
      16'h04D0: mem_rdata = SONG_END;
      16'h04D4: mem_rdata = SONG_END;
      16'h04D8: mem_rdata = SONG_END;
      16'h04DC: mem_rdata = SONG_END;

      16'h04E0: mem_rdata = SONG_END;
      16'h04E4: mem_rdata = SONG_END;
      16'h04E8: mem_rdata = SONG_END;
      16'h04EC: mem_rdata = SONG_END;
      16'h04F0: mem_rdata = SONG_END;
      16'h04F4: mem_rdata = SONG_END;
      16'h04F8: mem_rdata = SONG_END;
      16'h04FC: mem_rdata = SONG_END;

      //----------------------------------------------------------------
      // Song 17
      //----------------------------------------------------------------

      16'h2200: mem_rdata = NOTE_C;
      16'h2204: mem_rdata = NOTE_C;
      16'h2208: mem_rdata = NOTE_C;
      16'h220C: mem_rdata = NOTE_D;
      16'h2210: mem_rdata = NOTE_E;
      16'h2214: mem_rdata = NOTE_E;
      16'h2218: mem_rdata = NOTE_E;
      16'h221C: mem_rdata = NOTE_D;

      16'h2220: mem_rdata = NOTE_C;
      16'h2224: mem_rdata = REST;
      16'h2228: mem_rdata = NOTE_A;
      16'h222C: mem_rdata = REST;
      16'h2230: mem_rdata = NOTE_A;
      16'h2234: mem_rdata = REST;
      16'h2238: mem_rdata = NOTE_G;
      16'h223C: mem_rdata = REST;

      16'h2240: mem_rdata = NOTE_D;
      16'h2244: mem_rdata = NOTE_D;
      16'h2248: mem_rdata = NOTE_D;
      16'h224C: mem_rdata = NOTE_C;
      16'h2250: mem_rdata = NOTE_B;
      16'h2254: mem_rdata = NOTE_B;
      16'h2258: mem_rdata = NOTE_C;
      16'h225C: mem_rdata = NOTE_C;

      16'h2260: mem_rdata = NOTE_D;
      16'h2264: mem_rdata = NOTE_D;
      16'h2268: mem_rdata = NOTE_D;
      16'h226C: mem_rdata = NOTE_D;
      16'h2270: mem_rdata = REST;
      16'h2274: mem_rdata = REST;
      16'h2278: mem_rdata = REST;
      16'h227C: mem_rdata = REST;

      16'h2280: mem_rdata = NOTE_C;
      16'h2284: mem_rdata = NOTE_C;
      16'h2288: mem_rdata = NOTE_C;
      16'h228C: mem_rdata = NOTE_D;
      16'h2290: mem_rdata = NOTE_E;
      16'h2294: mem_rdata = NOTE_E;
      16'h2298: mem_rdata = NOTE_E;
      16'h229C: mem_rdata = NOTE_D;

      16'h22A0: mem_rdata = NOTE_C;
      16'h22A4: mem_rdata = REST;
      16'h22A8: mem_rdata = NOTE_A;
      16'h22AC: mem_rdata = REST;
      16'h22B0: mem_rdata = NOTE_A;
      16'h22B4: mem_rdata = REST;
      16'h22B8: mem_rdata = NOTE_G;
      16'h22BC: mem_rdata = REST;

      16'h22C0: mem_rdata = NOTE_D;
      16'h22C4: mem_rdata = NOTE_D;
      16'h22C8: mem_rdata = NOTE_D;
      16'h22CC: mem_rdata = NOTE_E;
      16'h22D0: mem_rdata = NOTE_F;
      16'h22D4: mem_rdata = NOTE_F;
      16'h22D8: mem_rdata = NOTE_B;
      16'h22DC: mem_rdata = NOTE_B;

      16'h22E0: mem_rdata = NOTE_C;
      16'h22E4: mem_rdata = NOTE_C;
      16'h22E8: mem_rdata = NOTE_C;
      16'h22EC: mem_rdata = NOTE_C;
      16'h22F0: mem_rdata = REST;
      16'h22F4: mem_rdata = REST;
      16'h22F8: mem_rdata = REST;
      16'h22FC: mem_rdata = REST;

      16'h2300: mem_rdata = NOTE_E;
      16'h2304: mem_rdata = NOTE_E;
      16'h2308: mem_rdata = REST;
      16'h230C: mem_rdata = NOTE_E;
      16'h2310: mem_rdata = NOTE_D;
      16'h2314: mem_rdata = REST;
      16'h2318: mem_rdata = NOTE_D;
      16'h231C: mem_rdata = REST;

      16'h2320: mem_rdata = NOTE_C;
      16'h2324: mem_rdata = NOTE_C;
      16'h2328: mem_rdata = REST;
      16'h232C: mem_rdata = NOTE_C;
      16'h2330: mem_rdata = NOTE_B;
      16'h2334: mem_rdata = REST;
      16'h2338: mem_rdata = NOTE_B;
      16'h233C: mem_rdata = REST;

      16'h2340: mem_rdata = NOTE_A;
      16'h2344: mem_rdata = NOTE_A;
      16'h2348: mem_rdata = REST;
      16'h234C: mem_rdata = NOTE_A;
      16'h2350: mem_rdata = NOTE_G;
      16'h2354: mem_rdata = REST;
      16'h2358: mem_rdata = NOTE_C;
      16'h235C: mem_rdata = REST;

      16'h2360: mem_rdata = NOTE_D;
      16'h2364: mem_rdata = NOTE_D;
      16'h2368: mem_rdata = NOTE_D;
      16'h236C: mem_rdata = NOTE_D;
      16'h2370: mem_rdata = REST;
      16'h2374: mem_rdata = REST;
      16'h2378: mem_rdata = REST;
      16'h237C: mem_rdata = REST;

      16'h2380: mem_rdata = NOTE_C;
      16'h2384: mem_rdata = NOTE_C;
      16'h2388: mem_rdata = NOTE_C;
      16'h238C: mem_rdata = NOTE_D;
      16'h2390: mem_rdata = NOTE_E;
      16'h2394: mem_rdata = NOTE_E;
      16'h2398: mem_rdata = NOTE_E;
      16'h239C: mem_rdata = NOTE_D;

      16'h23A0: mem_rdata = NOTE_C;
      16'h23A4: mem_rdata = REST;
      16'h23A8: mem_rdata = NOTE_A;
      16'h23AC: mem_rdata = REST;
      16'h23B0: mem_rdata = NOTE_A;
      16'h23B4: mem_rdata = REST;
      16'h23B8: mem_rdata = NOTE_G;
      16'h23BC: mem_rdata = REST;

      16'h23C0: mem_rdata = NOTE_D;
      16'h23C4: mem_rdata = NOTE_D;
      16'h23C8: mem_rdata = NOTE_D;
      16'h23CC: mem_rdata = NOTE_E;
      16'h23D0: mem_rdata = NOTE_F;
      16'h23D4: mem_rdata = NOTE_F;
      16'h23D8: mem_rdata = NOTE_B;
      16'h23DC: mem_rdata = NOTE_B;

      16'h23E0: mem_rdata = NOTE_C;
      16'h23E4: mem_rdata = NOTE_C;
      16'h23E8: mem_rdata = NOTE_C;
      16'h23EC: mem_rdata = NOTE_C;
      16'h23F0: mem_rdata = REST;
      16'h23F4: mem_rdata = REST;
      16'h23F8: mem_rdata = REST;
      16'h23FC: mem_rdata = SONG_END;

      default:  mem_rdata = SONG_END;
    endcase

    if ( !mem_val )
      mem_rdata = 32'b0;

    `ECE2300_XPROP( mem_rdata, $isunknown(mem_val) );

  end

endmodule

`endif /* MUSIC_MEM_RTL_V */

