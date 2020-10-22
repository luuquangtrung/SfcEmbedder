% Set this path to MATLAB in order to use the help of CPLEX
% addpath('D:\Workspace\Install\IBM\ILOG\CPLEX_Studio1271\cplex\matlab\x64_win64');

clc
% clear all; 
% close all;

%% INITIALIZATION 
Ss = [1 1 2 2 2 3 3 4 5 2 6 3 5 6 4 5 5 6 1 5 2 4];
Ts = [2 6 3 5 6 4 5 5 6 1 1 2 2 2 3 3 4 5 5 1 4 2];
Sv = [1 2];
Tv = [2 3];

% Substrate graph
Gs = createGs(Ss, Ts);
Ns = Gs.numnodes;   % |Ns|: number of Gs nodes
Es = Gs.numedges;   % |Es|: number of Gs edges

% Virtual graph
nb_chains = 1;      % Total number of SFC chains

Gv = repmat([], 1, nb_chains);
for i = 1:nb_chains
    Gv{i} = createGv(Sv, Tv);   % SFC array Gv
end


%% SOLVING PROBLEM

reject_count = 0;     % Count rejected times

for i = 1:nb_chains
    
    fprintf ('Mapping of SFC %d\n', i);
    
    Nv = Gv{i}.numnodes;   % |Nv|: number of Gs nodes
    Ev = Gv{i}.numedges;   % |Ev|: number of Gs edges
    
    % Solve SFC embedding problem (try to embed SFC Gv{i} on Gs)
    [x, isRejected] = vne_solver(Gs, Gv{i});

    if isRejected == 1
        reject_count = reject_count + 1;
    else
        %% Extract phi(n) and phi(e) from x
        pn = x(1 : Nv*Ns)'; 
        pn = reshape(pn, [Nv, Ns]);     
        pe = x(Nv*Ns+1 : Nv*Ns + Ev*Es)';
        pe = reshape(pe, [Ev, Es]);  
        
        pn = round(pn);
        pe = round(pe);

        [nv_mapped, ns_mapped] = find(pn == 1);
        [ev_mapped, es_mapped] = find(pe == 1);
        [es_s, es_t] = findedge(Gs, es_mapped);
        
        %% Update remaining resource on nodes and edges of Gs     
        % For nodes
        Gs.Nodes.CPUs(ns_mapped) = Gs.Nodes.CPUs(ns_mapped) - Gv{i}.Nodes.CPUv(nv_mapped);
        % For edges
        Gs.Edges.BWs(es_mapped) = Gs.Edges.BWs(es_mapped) - Gv{i}.Edges.BWv(ev_mapped);    
        
        %% Visualize graphs
        % p1 = plot(Gs, 'NodeLabel', Gs.Nodes.CPUs, 'EdgeLabel', Gs.Edges.BWs);
        
        figure;
        %subplot(1,2,1);
        pos1 = [0.1 0.1 0.2 0.2];
        subplot('Position', pos1)  
        p1 = plot(Gv{i}, 'EdgeLabel', Gv{i}.Edges.BWv, ...
            'NodeColor', 'k', 'EdgeColor', 'k');
        title('SFC to be embedded');
        p1.XData = 1:1:Gv{i}.numnodes;
        p1.YData = i*ones(1,Gv{i}.numnodes);
        axis([0, Gv{i}.numnodes+1, 0, nb_chains+1])
        
        %subplot(1,2,2);  
        pos2 = [0.4 0.1 0.5 0.8];
        subplot('Position', pos2)
        p2 = plot(Gs, 'EdgeLabel', Gs.Edges.BWs, ...
            'NodeColor', 'k', 'EdgeColor', 'k');
        title('Embedding result');

        % Highlight mapped nodes and links
        highlight(p2, ns_mapped, 'NodeColor', 'red');   
        for id = 1:length(es_s)
            highlight(p2, [es_s(id), es_t(id)], 'EdgeColor', 'red');
        end
        
        highlight(p1, [1 2 3], 'NodeColor', 'red');
        highlight(p1, [[1 2],[2,3]], 'EdgeColor', 'red');
        
    end  
end

% Gs.Nodes
% Gs.Edges




