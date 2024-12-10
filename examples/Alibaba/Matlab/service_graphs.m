function [services] = service_graphs(sanitized_traces)
    % v_G_serv{i} is the graph of a service where a service is identified by the interface name of the first call
    % services{i} interface name of the service i-th
    % trace_ids_by_service{i} set of trace_ids that regards service i-th
    % sanitized_trace, Alibaba trace sanitized 
    
    % all trace entries, where rpc_id = '0'
    trace_rpc_ids_0_idx = strcmp(sanitized_traces.rpc_id,"0")>0;

    % extract interface property as unique list -> these will represent a 'service'
    interfaces = unique(sanitized_traces.interface(trace_rpc_ids_0_idx,:));
    l_interfaces = length(interfaces);

    % service_graph will be a table with these columns:
    % service: ID of the service ('interface')
    % trace_ids: list of trace_id that correspond to that service
    % graph: a digraph constructed using the available traces' upstream and downstream information
    service_graphs = cell(l_interfaces,3);

    for i = 1:l_interfaces
        interface = interfaces{i};
        service_graphs{i,1} = interface;

        % trace_ids that have this service/interface as root (rpc_id=='0')
        related_trace_ids = unique(sanitized_traces.trace_id((strcmp(sanitized_traces.interface,interface)>0) & trace_rpc_ids_0_idx,:));
        service_graphs{i,2} = related_trace_ids;

        % trace_g = all trace entries of the related_trace_ids
        trace_g = sanitized_traces(ismember(sanitized_traces.trace_id, related_trace_ids),:);

        % Create directed graph
        % using the trace upstream and downstream combinations to describe its edges
        service_graphs{i,3} = digraph(trace_g.upstream_ms', trace_g.downstream_ms');
    end

    services = cell2table(service_graphs, "VariableNames", ["service", "trace_ids", "graph"]);
end
    
    