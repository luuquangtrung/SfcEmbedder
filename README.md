# sfc_embedding

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

**References:**
Please consider to cite the following papers if you use this code as your cornerstone
* [Luu2020] Q.-T. Luu, S. Kerboeuf, A. Mouradian, and M. Kieffer, "Coverage-Aware Resource Provisioning Method for Network Slicing," in *IEEE/ACM Transactions on Networking*, 2020. [URL]()
* [Luu2018] Q.-T. Luu, M. Kieffer, A. Mouradian, and S. Kerboeuf, "Aggregated Resource Provisioning for Network Slices," in *Proc. IEEE Global Communications Conference (GLOBECOM)*, Abu Dhabi, UAE, Dec. 2018, pp. 1-6. [URL](https://ieeexplore.ieee.org/abstract/document/8648039)
