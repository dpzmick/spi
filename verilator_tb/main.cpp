#include <stdlib.h>
#include <stdio.h>
#include <memory>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "build/verilator_dir/verilog/test.h"

int main(int argc, char const *argv[])
{
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  auto t = std::make_unique<test>();
  t->clk = 0;
  t->out = 0;

  VerilatedVcdC* tfp = new VerilatedVcdC;
  t->trace(tfp, 99);  // Trace 99 levels of hierarchy
  Verilated::mkdir("logs");
  tfp->open("logs/test_dump.vcd");

  for (size_t i = 0; i < 20; ++i) {
    t->clk = ~t->clk;
    t->eval();
    tfp->dump(i);
  }

  tfp->close();

  return 0;
}
