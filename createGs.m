%% SUBSTRATE GRAPH 
        % Create graph: Gs = (Ns, Es); (|Ns|, |Es|) = (Gs.numnodes, Gs.numedges)
        % Direct way: G = graph(ap, gw, mWeights, mLabels);

function Gs = createGs(Ss, Ts)

    Gs = digraph(Ss, Ts);  
    Ns = Gs.numnodes;   % |Ns|: number of Gs nodes
    Es = Gs.numedges;   % |Es|: number of Gs edges

    % Assign node attributes:
    Gs.Nodes.CPUs = 1000*ones(Ns, 1);   % Available CPU resources at node (operations/s)
    Gs.Nodes.CPUcost = ones(Ns, 1);     % Cost for CPU resources at node 

    % Assign edges attributes:
    Gs.Edges.BWs = 100*ones(Es, 1);     % Available BW resource at edge (Mbps)    
    Gs.Edges.BWcost = ones(Es, 1);      % Cost for BW resources at edge 
    
end