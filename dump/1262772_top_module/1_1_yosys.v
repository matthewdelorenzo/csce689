/* Generated by Yosys 0.38+92 (git sha1 84116c9a3, x86_64-conda-linux-gnu-cc 11.2.0 -fvisibility-inlines-hidden -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -fdebug-prefix-map=/root/conda-eda/conda-eda/workdir/conda-env/conda-bld/yosys_1708682838165/work=/usr/local/src/conda/yosys-0.38_93_g84116c9a3 -fdebug-prefix-map=/mnt/shared-scratch/Rajendran_J/matthewdelorenzo/miniconda3/envs/rltf=/usr/local/src/conda-prefix -fPIC -Os -fno-merge-constants) */

module top_module(a, b, c, d, out);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  wire _08_;
  wire _09_;
  wire _10_;
  wire _11_;
  wire _12_;
  wire _13_;
  wire _14_;
  input a;
  wire a;
  input b;
  wire b;
  input c;
  wire c;
  input d;
  wire d;
  output out;
  wire out;
  INV_X1 _15_ (
    .A(c),
    .ZN(_14_)
  );
  NAND2_X1 _16_ (
    .A1(_14_),
    .A2(d),
    .ZN(_00_)
  );
  INV_X1 _17_ (
    .A(d),
    .ZN(_01_)
  );
  NAND2_X1 _18_ (
    .A1(_01_),
    .A2(c),
    .ZN(_02_)
  );
  NAND2_X1 _19_ (
    .A1(_00_),
    .A2(_02_),
    .ZN(_03_)
  );
  INV_X1 _20_ (
    .A(a),
    .ZN(_04_)
  );
  NAND2_X1 _21_ (
    .A1(_04_),
    .A2(b),
    .ZN(_05_)
  );
  INV_X1 _22_ (
    .A(b),
    .ZN(_06_)
  );
  NAND2_X1 _23_ (
    .A1(_06_),
    .A2(a),
    .ZN(_07_)
  );
  NAND2_X1 _24_ (
    .A1(_05_),
    .A2(_07_),
    .ZN(_08_)
  );
  NAND2_X1 _25_ (
    .A1(_03_),
    .A2(_08_),
    .ZN(_09_)
  );
  NAND2_X1 _26_ (
    .A1(_13_),
    .A2(_09_),
    .ZN(_10_)
  );
  INV_X1 _27_ (
    .A(_10_),
    .ZN(out)
  );
  XNOR2_X1 _28_ (
    .A(d),
    .B(c),
    .ZN(_11_)
  );
  XNOR2_X1 _29_ (
    .A(b),
    .B(a),
    .ZN(_12_)
  );
  NAND2_X1 _30_ (
    .A1(_11_),
    .A2(_12_),
    .ZN(_13_)
  );
endmodule