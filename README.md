# sfc_embedding

ILP-based algorithm to solve the problem of SFC embedding. Solver: MATLAB integrated with IBM-CPLEX

An example of embedding one SFC of 3 VNFs:

![An example of embedding one SFC of 3 VNFs](https://github.com/luuquangtrung/sfc_embedding/blob/main/example.jpg)


**Files:**
* `createGs.m`: create network infrastructure graph (`Gs`)
* `createGv.m`: generate SFC graph (`Gv`)
* `vne_solver.m`: SFC embedding solver

**Solver:**
* The SFC embedding solver is MATLAB `intlinprog` by default
* Alternative solver: `cplexmilp` (need to change `milp_solver` line `272` to `cplex`)

**References:**
Please consider to cite the following papers if you use this code as your cornerstone

* Q.-T. Luu, S. Kerboeuf, A. Mouradian, and M. Kieffer, "Coverage-Aware Resource Provisioning Method for Network Slicing," in *IEEE/ACM Transactions on Networking*, 2020. [URL]()
* Q.-T. Luu, M. Kieffer, A. Mouradian, and S. Kerboeuf, "Aggregated Resource Provisioning for Network Slices," in *Proc. IEEE Global Communications Conference (GLOBECOM)*, Abu Dhabi, UAE, Dec. 2018, pp. 1-6. [URL](https://ieeexplore.ieee.org/abstract/document/8648039)
