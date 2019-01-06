#include <stdlib.h>
#include <stdio.h>
#include <verilated.h>
#include <memory>

#include "build/verilator_dir/verilog/spi.h"

using SpiPtr = std::unique_ptr<spi>;

int main(int argc, char const *argv[])
{
  Verilated::commandArgs(argc, argv);

  SpiPtr _spi(new spi);

  // while (!Verilated::gotFinish()) {
  //   // FIXME need to run a clock
  //   spi->eval();
  // }

  // FIXME need to run a finish somehow
  return 0;
}
