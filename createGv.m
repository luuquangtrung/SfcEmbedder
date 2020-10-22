%% SERVICE FUNCTION CHAIN GRAPH
        % NOTE: Different from vne_v1, in this code the SFC graph is directed (digraph)
        % Create graph: Gv = (Nv, Ev); (|Nv|, |Ev|) = (Gv.numnodes, Gv.numedges)
        % Direct way: G = graph(ap, gw, mWeights, mLabels);
        % Q = 30;     % Number of SFC requests
        % Request = zeros(Nv, Ns, Q);  % Request(i, j, q) = 1 if the q-th request exist between i and j
        
function Gv = createGv(Sv, Tv)

    Gv = digraph(Sv, Tv); 
    Nv = Gv.numnodes;   % |Nv|: number of Gs nodes
    Ev = Gv.numedges;   % |Ev|: number of Gs edges

    % Assign node attributes:
    Gv.Nodes.CPUv = 100*ones(Nv, 1); % Available CPU resources at node (operations/s)

    % Assign edge attributes:
    Gv.Edges.BWv = 20*ones(Ev, 1);   % Available BW resource at edge (Mbps)  

end
