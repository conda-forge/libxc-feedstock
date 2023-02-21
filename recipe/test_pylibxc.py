# Import pylibxc and numpy
import pylibxc
import numpy as np

# Build functional
func = pylibxc.LibXCFunctional("gga_c_pbe", "unpolarized")

# Create input
inp = {}
inp["rho"] = np.random.random((3))
inp["sigma"] = np.random.random((3))

# Compute
ret = func.compute(inp)
for k, v in ret.items():
    print(k, v)

