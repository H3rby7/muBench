function [app_traces] = create_app_traces(v_G_app,u_trace_ids_a,sanitized_traces)
    % v_G_app{i} graph of app #i
    % u_trace_ids_a service of app #i
    % Alibaba sanitized traces
    % app_traces{i} is a table that contains the subset of traces of the app #i
    
    app_traces=cell(length(v_G_app),1);
    for i=1:length(v_G_app)
        app_traces{i} = table();
        for j=1:length(u_trace_ids_a{i})
            trace_id = u_trace_ids_a{i}(j);
            app_traces{i,:} = [app_traces{i,:};sanitized_traces((strcmp(sanitized_traces.trace_id,trace_id)>0),:)];
        end

        % trace/app check
        ms = unique([app_traces{i}.upstream_ms ; app_traces{i}.downstream_ms]);
        if (length(ms)-1 ~= v_G_app{i}.numnodes)
            fprintf('Warning trace %d not consistent with app graph',i);
        end
        
    end
end