function [service_graphs,services,trace_ids_by_service] = service_graphs(sanitized_traces)
    % v_G_serv{i} is the graph of a service where a service is identified by the interface name of the first call
    % services{i} interface name of the service i-th
    % trace_ids_by_service{i} set of trace_ids that regards service i-th
    % sanitized_trace, Alibaba trace sanitized 
    
    service_graphs = {}; % graphs of services, a service is identified by the interface name of the first call
    trace_id_idx_1 = strcmp(sanitized_traces.rpc_id,"0")>0;
    interfaces = sanitized_traces.interface(trace_id_idx_1);
    trace_ids = sanitized_traces.trace_id(trace_id_idx_1);
    services = unique(interfaces);  % unique service id
    trace_ids_by_service = cell(length(services),1); % trace id of the services
    for i=1:length(services)
        trace_ids_by_service{i} = strings(0);
        % service_graphs{i} = digraph();
    end

    l = length(trace_ids);
    for i = 1:l
        trace_id = trace_ids{i};
        interface = interfaces{i};

        trace_g = sanitized_traces((strcmp(sanitized_traces.trace_id,trace_id)>0),:);

        % index of the interface in the unique service list 
        u_service_idx = find(strcmp(services,interface),1,'first');

        % append this trace_id to the list of related trace_ids for this service
        trace_ids_by_service{u_service_idx} = [trace_ids_by_service{u_service_idx}; trace_id];

        % Add nodes to the service graph.
        % TODO: following this approach we would need to append to the graph
        % however as we end up adding all nodes that refer to a specific interface we could iterate that instead?!
        service_graphs{u_service_idx} = digraph(trace_g.upstream_ms', trace_g.downstream_ms');

%         for j = 1 : height(trace_g)
%             % add um,dm nodes
%             if strcmp(trace_g.rpc_id{j},'0')
%                 continue
%             end
%             upstream_ms = trace_g.upstream_ms{j};
%             downstream_ms = trace_g.downstream_ms{j};
%             % add nodes
%             if numnodes(service_graphs{u_service_id})==0
%                 service_graphs{u_service_id} = addnode(service_graphs{u_service_id},upstream_ms);
%             elseif not(findnode(service_graphs{u_service_id},upstream_ms))
%                 service_graphs{u_service_id} = addnode(service_graphs{u_service_id},upstream_ms);
%             end
%             if not(findnode(service_graphs{u_service_id},downstream_ms))
%                 service_graphs{u_service_id} = addnode(service_graphs{u_service_id},downstream_ms);
%             end
%             % add edges
%             service_graphs{u_service_id} = addedge(service_graphs{u_service_id},upstream_ms,downstream_ms); % add one edge x call
% %             if strcmp(um,dm)
% %                 %skip autocall
% %                 continue
% %             end
% %             if findedge(v_G_serv{u_service_id},um,dm) == 0
% %                 v_G_serv{u_service_id} = addedge(v_G_serv{u_service_id},um,dm); % add one edge x call
% %             end
%         end
    end

    alt_trace_ids_by_service = cell(length(services),1); % trace id of the services
    % alt_str_mat = cell(length(services),1); % verification
    % str_mat = cell(length(services),1); % verification
    alt_l = length(services);
    for i = 1:alt_l
        interface = services{i};
        alt_trace_ids_by_service{i} = unique(sanitized_traces.trace_id((strcmp(sanitized_traces.interface,interface)>0) & strcmp(sanitized_traces.rpc_id,"0")>0,:));

        % tmp = sort(alt_trace_ids_by_service{i});
        % alt_str_mat{i} = convertStringsToChars(strjoin(tmp, ', '));

        % tmp = sort(trace_ids_by_service{i});
        % str_mat{i} = convertStringsToChars(strjoin(tmp, ', '));
    end
    % alt_str_mat = sort(alt_str_mat);
    % str_mat = sort(str_mat);

end
    
    