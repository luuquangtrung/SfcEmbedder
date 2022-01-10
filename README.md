# SfcEmbedder

ILP-based algorithm to solve the problem of SFC embedding.

**Example:**
An example of embedding one SFC of 3 VNFs:

![An example of embedding one SFC of 3 VNFs](https://github.com/luuquangtrung/sfc_embedding/blob/main/example.jpg)


**Files:**
* `createGs.m`: create network infrastructure graph (`Gs`)
* `createGv.m`: generate SFC graph (`Gv`)
* `vne_solver.m`: SFC embedding solver

**Solver:**
* The default SFC embedding solver is the MATLAB's function `intlinprog`
* Alternative solver: `cplexmilp` (need to change `milp_solver` in line `272` of `vne_solver.m` to `cplex`)

**Prerequisites:**
* This code uses `graph`, an object that needs MATLAB R2015b or earlier versions to properly operate.
* If `cplexmilp` is chosen as solver, an installation of IBM CPLEX is required. IBM offers free licence to students/academic researchers. See [here](https://www.ibm.com/support/pages/downloading-ibm-ilog-cplex-optimization-studio-v1290) for more.

**References:**
Please consider to cite the following papers if you use this code as your cornerstone
* [Luu2020] Q.-T. Luu, S. Kerboeuf, A. Mouradian, and M. Kieffer, "Coverage-Aware Resource Provisioning Method for Network Slicing," in *IEEE/ACM Transactions on Networking*, vol. 28, no. 6, pp. 2393-2406, Dec. 2020, doi: 10.1109/TNET.2020.3019098 [URL](https://ieeexplore.ieee.org/document/9187556)
* [Luu2018] Q.-T. Luu, M. Kieffer, A. Mouradian, and S. Kerboeuf, "Aggregated Resource Provisioning for Network Slices," in *Proc. IEEE Global Communications Conference (GLOBECOM)*, Abu Dhabi, UAE, Dec. 2018, pp. 1-6. [URL](https://ieeexplore.ieee.org/abstract/document/8648039)
