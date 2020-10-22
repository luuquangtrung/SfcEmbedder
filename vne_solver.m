%% FORMULATE THE ILP PROBLEM
%{
=============================================================================
Attributes: (obj, lb, ub, ctype, A, lhs, rhs)
-----------------------------------------------------------------------------
      minimize obj*x
      s.t     lhs <= A*x <= rhs
              lb <= x <= ub (bounds)
      and:    ctype = 'B' (binary)
-----------------------------------------------------------------------------
      minimize f*x
      s.t     Aineq*x <= bineq
              Aeq*x = beq
              lb <= x <= ub (bounds)
      and:    ctype = 'B' (binary)
Function call: cplexmilp
https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.2/ilog.odms.cplex.help/
                                          refmatlabcplex/html/cplexmilp-m.html
-----------------------------------------------------------------------------
x = [phi(n',n); phi(e',e)]
total cost = obj*x 
Type of each column in the CONSTRAINT matrix, specifying whether a 
variable is continuous, integer, binary, semi-continuous or semi-integer. 
The possible char vales are 'B','I','C','S','N'. Set ctype(j) to 'B', 'I',
'C', 'S', or 'N' to indicate that x(j) should be binary, general integer, 
continuous, semi-continuous or semi-integer (respectively).
=============================================================================
%}

function [x, isRejected] = vne_solver(Gs, Gv)

    Ns = Gs.numnodes;   % |Ns|: number of Gs nodes
    Es = Gs.numedges;   % |Es|: number of Gs edges
    Nv = Gv.numnodes;   % |Nv|: number of Gs nodes
    Ev = Gv.numedges;   % |Ev|: number of Gs edges


    %% Define obj (objective function shall be: obj*x)
    obj1 = ones(Nv, Ns);

    for v = 1:Nv
        for i = 1:Ns
            obj1(v,i) = Gv.Nodes.CPUv(v) * Gs.Nodes.CPUcost(i);
        end
    end

    obj2 = ones(Ev, Es);
    for ev = 1:Ev
        for es = 1:Es
            obj2(ev,es) = Gv.Edges.BWv(ev) * Gs.Edges.BWcost(es);
        end
    end

    % Combine obj
    obj = [reshape(obj1, [1, Nv*Ns]) reshape(obj2, [1, Ev*Es])];


    %% Define constraint parameters: 
            % lhs <= A*x <= rhs 
            % nrows(A) = ncols(lhs) = ncols(rhs)

    %% CONSTRAINT 1: Node resource limit
            % A1: Ns x (Nv*Ns + Ev*Es) matrix

    % Initialize A1 as matrix for phi(n)
    A1 = [repmat(Gv.Nodes.CPUv', [Ns,1]) zeros(Ns, Nv*(Ns-1))];
    for i = 2:size(A1,1)
        A1(i,:) = circshift(A1(i,:), [-1 (i-1)*Nv]);
    end

    % Add columns to the right of A1 for phi(e)
    A1 = [A1 zeros(Ns, Ev*Es)];

    % Bounds of A1: -inf <= A1 <= CPUs
    lhs1 = -inf*ones(Ns, 1);
    rhs1 = Gs.Nodes.CPUs;


    %% CONSTRAINT 2: Link resource limit
            % A2: Es x (Nv*Ns + Ev*Es) matrix

    % Initialize A2 as matrix for phi(e)
    A2 = [repmat(Gv.Edges.BWv', [Es, 1]) zeros(Es, Ev*(Es-1))];
    for i = 2:size(A2,1)
        A2(i,:) = circshift(A2(i,:), [-1 (i-1)*Ev]);
    end

    % Add columns to the left of A2 for phi(n)
    A2 = [zeros(Es, Nv*Ns) A2];

    % Bounds of A2: -inf <= A2*x <= BWs
    lhs2 = -inf*ones(Es, 1);
    rhs2 = Gs.Edges.BWs;


    %% CONSTRAINT 3: All VNF shall be mapped only once
            % A3: Nv x [Nv*Ns] matrix

    A3 = [ones(Nv, 1) zeros(Nv, Nv-1)];
    A3 = repmat(A3, [1, Ns]);

    for i = 2:size(A3,1)
        A3(i,:) = circshift(A3(i,:), [-1 (i-1)]); 
    end

    % Add columns to the right of A3 for phi(e)
    A3 = [A3 zeros(Nv, Ev*Es)];
    rhs3 = ones(Nv, 1);     % A3*x = 1

    %% CONSTRAINT 4: All VNFs shall be mapped to different nodes
            % A4: Ns x (Nv*Ns + Ev*Es) matrix (same size as A1)

    % Initialize A4 as matrix for phi(n)
    A4 = [ones(Ns, Nv) zeros(Ns, Nv*(Ns-1))];

    for i = 2:size(A4,1)
        A4(i,:) = circshift(A4(i,:), [-1 (i-1)*Nv]);
    end

    % Add columns to the right of A4 for phi(e)
    A4 = [A4 zeros(Ns, Ev*Es)];     

    % Bounds of A4: -inf <= A4 <= 1
    lhs4 = -inf*ones(Ns, 1);
    rhs4 = ones(Ns, 1);


    %% CONSTRAINT 5: Routing condition
            % findedge(G,s,t): return the edge index, return 0 if edge not exist
            % G.Edges.EndNodes(i,j), j={1,2}: return the endnode j (1 or 2) of the edge i
            % A5 = [Ns*Ev] x [Ev*Es] matrix

    % Initialization
    A5 = []; 
    eij_id = [];
    eji_id = [];


    % Loop for each i in Ns
    for i = 1:Ns

        % Rules for each i in Ns:
                % (1) para[phi(n,i)] = 1            (2) para[phi(m,i)] = -1
                % (3) para[phi(e^nm, e^ij)] = -1    (4) para[phi(e^nm, e^ji)] = 1

        % Find all endnode j that connects to startnode i:
        j = [];
        for es = 1:Es
            if Gs.Edges.EndNodes(es, 1) == i
                j = [j Gs.Edges.EndNodes(es, 2)];   
            end   
        end

        % Loop for each e^nm in Ev
        for ev = 1:Ev
            nmat = zeros(Nv, Ns);   % Matrix for phi_n
            emat = zeros(Ev, Es);   % Matrix for phi_e
            [n, m] = findedge(Gv, ev);

            % Update matrix nmat as rules (1) & (2)
            nmat(n, i) = 1;
            nmat(m, i) = -1;

            % Update matrix emat as rules (3) & (4) for all j
            for id = 1:length(j)
                emat(ev, findedge(Gs, i, j(id))) = -1;
                emat(ev, findedge(Gs, j(id), i)) = 1;
            end

            % Reshape nmat, emat and add to the final matrix A5
            A5 = [A5; reshape(nmat, [1, Nv*Ns]) reshape(emat, [1, Ev*Es])];

        end  



    end

    rhs5 = zeros(size(A5,1), 1);    % A5*x = 0


    %% CONSTRAINT 6 (VIZARRETA):  Prevent loops (for linear SFCs)
            % A6: [Ns*Ev] x [Ev*Es] matrix

    % CONSTRAINT A6-A ========================================================

    % Initialization
    A6 = []; 
    eij_id = [];
    eji_id = [];

    % Loop for each i in Ns. Rule: para[phi(e^nm, e^ij)] = 1  
    for i = 1:Ns
        nmat = zeros(Nv, Ns);   % Matrix for phi_n
        emat = zeros(Ev, Es);   % Matrix for phi_e

        % Find all endnode j that connects to startnode i:
        for es = 1:Es
            if Gs.Edges.EndNodes(es, 1) == i
                j = Gs.Edges.EndNodes(es, 2);   

                % Find the corresponding index of e^ij 
                eij_id = [eij_id findedge(Gs, i, j)];   
            end
        end

        % Loop for each e^nm in Ev
        for ev = 1:Ev
            [n, m] = findedge(Gv, ev);

            % Update matrix emat as: para[phi(e^nm, e^ij)] = 1  
            for es = 1:length(eij_id)
                emat(ev, eij_id(es)) = 1;
            end

            % Reshape nmat, emat and add to the final matrix A6
            A6 = [A6; reshape(nmat, [1, Nv*Ns]) reshape(emat, [1, Ev*Es])];
        end    
    end

    % CONSTRAINT A6-B ========================================================

    % Loop for each j in Ns. Rule: para[phi(e^nm, e^ij)] = 1  
    for j = 1:Ns
        nmat = zeros(Nv, Ns);   % Matrix for phi_n
        emat = zeros(Ev, Es);   % Matrix for phi_e

        % Find all startnode i that connects to endnode j:
        for es = 1:Es
            if Gs.Edges.EndNodes(es, 2) == j
                i = Gs.Edges.EndNodes(es, 1);   

                % Find the corresponding index of e^ij 
                eij_id = [eij_id findedge(Gs, i, j)];   
            end
        end

        % Loop for each e^nm in Ev
        for ev = 1:Ev
            [n, m] = findedge(Gv, ev);

            % Update matrix emat as: para[phi(e^nm, e^ij)] = 1  
            for es = 1:length(eij_id)
                emat(ev, eij_id(es)) = 1;
            end

            % Reshape nmat, emat and add to the final matrix A6
            A6 = [A6; reshape(nmat, [1, Nv*Ns]) reshape(emat, [1, Ev*Es])];
        end     
    end

    % Bounds of A6: -inf <= A6*x <= 1
    lhs6 = -inf*ones(size(A6,1), 1);
    rhs6 = ones(size(A6,1), 1);


    %% COMBINE MATRICES INTO f, Aineq, bineq, Aeq, beq, lb, ub
            % Aineq: A1, A2, A4
            % Aeq: A3, A5, A6

    f = obj;
    Aineq = [A1; A2; A4];   bineq = [rhs1; rhs2; rhs4];
    Aeq = [A3; A5];         beq = [rhs3; rhs5];
    % Aeq = A3;             beq = rhs3;

    % Aineq = [A1; A2; A5; A6];
    % bineq = [rhs1; rhs2; rhs5; rhs6];
    ctype = char(ones([1, length(f)])*('B'));  % Set all phi to binary
    
    lb = zeros(1, length(f));
    ub = ones(1, length(f));
    
    %% SOLVING PROBLEM
    
    milp_solver = 'matlab'; % alternative: 'cplex'
    
    if strcmp(milp_solver, 'matlab')  
        % options = [];
        options = optimoptions('intlinprog');
        options.Display = 'off';
        intcon = find(ctype == 'B' | ctype == 'I');
        [x, fval, ~, ~] = intlinprog(f, intcon, ...
            Aineq, bineq, Aeq, beq, lb, ub, options);   

    elseif 	strcmp(milp_solver, 'cplex')   
        options = [];
        [x, fval] = cplexmilp (f, Aineq, bineq, Aeq, beq, ...
                [], [], [], [], [], ctype, [], options); 
    end
    
    isRejected = 0;     % Reject count
    
    % If a feasible result is found
    if isempty(x) == 0   
        disp('Result: Accepted');
        fprintf ('fval = %f \n', fval);
    else
        isRejected = 1;
        disp('Result: Rejected');
        % fprintf('Rejected count = %d\n', reject); %disp(reject);
        % fprintf ('\nRejected time ',cplex.Solution.statusstring); 
    end   
    disp('---------------------------------------------------------');

end
