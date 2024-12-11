
function [apps, services] = app_graphs(services,sanitized_traces,sharingT,napps)
    % an app is a set of "similar" services. Grouping performed according to the paper https://ieeexplore.ieee.org/abstract/document/9774016 
    % v_G_app{i} dependency graph of app #i
    % u_service_a{i} set of services that belongs to app #i
    % u_traceids_a{i} set of traces that belongs to app #i
    % services as returned by 'service_graphs' with these columns:
    % service: ID of the service ('interface')
    % trace_ids: list of trace_id that correspond to that service
    % graph: a digraph constructed using the available traces' upstream and downstream information
    % sharingT sharing threshold to declare two services as similar
    % napps number of applications to be generated, if <=0 then this number is computed as in the paper 
    
    h_services = height(services);
    
    similarity_matrix = zeros(h_services,h_services);
    for i = 1:h_services
        nodes1= services.graph{i}.Nodes;
        if height(nodes1) == 0
            continue;
        end
        for j = i+1:h_services
            nodes2= services.graph{j}.Nodes;
            if height(nodes2) == 0
                continue;
            end
            % use node names to calculate similarity between two service graphs
            names1 = nodes1.Name;
            names2 = nodes2.Name;
            common = sum(ismember(names1, names2));
            %fprintf("%d, %d common %d\n",i,j,common);
            if(common>sharingT*length(names1) && common>sharingT*length(names2))
              similarity_matrix(i,j)=1;
              similarity_matrix(j,i)=1;
            end
        end
    end
    % clustering for findings apps
    myfunc=@(X,K)(spectralcluster(X,K));
    if napps<=0
        k_opt=evalclusters(similarity_matrix,myfunc,'CalinskiHarabasz','klist',2:50);
        napps = k_opt.OptimalK;
    end
    clusters = spectralcluster(similarity_matrix,napps);
    app_graphs = cell(napps,4);

    % append a column to hold the corresponding app
    services{:,4} = 0;
    services.Properties.VariableNames(4) = "app";

    for i=1:napps
        service_idx = (clusters==i); %services idx of the cluster/app
        % add column
        services{service_idx,4} = i;
        % App Number
        app_graphs{i,1} = i;
        % Related Trace IDs
        app_graphs{i,2} = cat(1, services.trace_ids{service_idx});
        % Related Services
        app_graphs{i,3} = cat(1, services.service{service_idx});
        % App graph

        edges_table = rowfun(@getGraphEdges, ...
                           services(service_idx,:), ...
                           "InputVariables","graph", ...
                           "OutputVariableNames","edges", ...
                           "OutputFormat", "table");
        edges = vertcat(edges_table.edges{:});
        
        % TODO: here the syntax fails and only saves one digraph
        % Also if this is a cell of 2 digraphs, accessing them via .Edges
        % is not working.
        app_graphs{i,4} = digraph(edges);

        % Sanity Check
        trace_g = sanitized_traces(ismember(sanitized_traces.trace_id, unique(app_graphs{i,2})),:);
        ms = unique([trace_g.upstream_ms ; trace_g.downstream_ms]);
        u_ms_length = length(ms);
        numnodes = app_graphs{i,4}.numnodes;
        if (u_ms_length ~= numnodes)
            fprintf('Warning: App %d -> traces not consistent with service graph\n', i);
            nodenames = app_graphs{i,4}.Nodes.Name
            ms
        end
    end

    apps = cell2table(app_graphs, "VariableNames", ["app_nr", "trace_ids", "service_ids", "graph"]);
end

function [edges] = getGraphEdges(graph)
    % Return edges of the graph in a cell
    edges = {graph{:}.Edges};
end