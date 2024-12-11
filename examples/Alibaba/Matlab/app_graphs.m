
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

    % append a column to the services table 
    % to hold the corresponding app (cluster)
    services = [services table(clusters)];
    services.Properties.VariableNames(4) = "app";

    for i=1:napps
        service_idx = (clusters==i); %services idx of the cluster/app
        % add column
        services{service_idx,4} = i;
        % App Number
        app_graphs{i,1} = i;
        % Related Trace IDs
        related_trace_ids = cat(1, services.trace_ids{service_idx});
        app_graphs{i,2} = sanitized_traces(ismember(sanitized_traces.trace_id, related_trace_ids),:);
        % Related Services
        app_graphs{i,3} = cat(1, services.service{service_idx});
        % App graph

        % Get edges of services.graphs
        edges_table = rowfun(@getGraphEdges, ...
                           services(service_idx,:), ...
                           "InputVariables","graph", ...
                           "OutputVariableNames","edges", ...
                           "OutputFormat", "table");
        edges = vertcat(edges_table.edges{:});

        % construct 'app' graph by using the services.graphs edges
        app_graphs{i,4} = digraph(edges);

        % Verify result
        ms_from_trace = unique([app_graphs{i,2}.upstream_ms ; app_graphs{i,2}.downstream_ms]);
        ms_count_graph = app_graphs{i,4}.numnodes;
        if (length(ms_from_trace) ~= ms_count_graph)
            fprintf('Warning: MS count for App %d -> count of MS in app graph and count of MS from trace differ!\n', i);
            % nodenames = app_graphs{i,4}.Nodes.Name
            % ms_from_trace
        end
    end

    apps = cell2table(app_graphs, "VariableNames", ["app_nr", "traces", "service_ids", "graph"]);
end

function [edges] = getGraphEdges(graph)
    % Return edges of the graph in a cell
    edges = {graph{:}.Edges};
end