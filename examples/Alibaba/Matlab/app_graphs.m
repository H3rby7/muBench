
function [apps] = app_graphs(services_a)
    napps = max(services_a.app);
    app_graphs = cell(napps,4);

    for i=1:napps
        fprintf('Generating graph for app %d\n', i);
        service_idx = (services_a.app==i); %services idx of the cluster/app
        entries = services_a.Value(service_idx,:);
        entries = cat(1, entries{:});

        % App Number
        app_graphs{i,1} = i;
        % Related Trace IDs
        app_graphs{i,2} = cat(1, entries.traces{:});
        % Related Services
        app_graphs{i,3} = services_a.Key(service_idx,:);
        % App graph

        % Get edges of services.graphs
        edges_table = rowfun(@getGraphEdges, ...
                           entries, ...
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