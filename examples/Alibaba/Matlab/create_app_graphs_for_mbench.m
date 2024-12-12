function mb_trace_stats = create_app_graphs_for_mbench(apps)
    % app_trace{i} traces concerning the i-th app
    % for each app on app_traces, create a directory with JSON files of traces and a service_graph.json that can be used by µBench
    % entry_service_id: downstream_ms microservice id called by the user, this value is specified below
    % mb_trace_stats{i} is a struct containing statistics (only length) of the traces of the i-th app 
    [upstream_is_user_id] = constants();
    [~, ~, ~, ~, entry_service_id, ~, output_dir_sequential, output_dir_parallel] = config();
    
    app_count = height(apps);
    
    mb_trace_stats = cell(app_count, 1);
    
    % Static JS body string to be used in the loop later
    jsbody = ": {" + char(34)+"external_services"+char(34)+": [{";
    jsbody = jsbody + char(34)+"seq_len"+char(34)+": 10000,";
    jsbody = jsbody + char(34)+"services"+char(34)+": []}]}";
    
    for t=1:app_count
        app_trace = apps.traces{t};
        dir_sequential = app_trace_dir(output_dir_sequential, t);
        dir_parallel = app_trace_dir(output_dir_parallel, t);
    
        % Get involved microservices
        involved_ms = unique([app_trace.upstream_ms ; app_trace.downstream_ms]);
        % Remove our synthetic user upstream and 
        % put entry_service_id in position 1
        idx = strcmp(entry_service_id,involved_ms)==0 & strcmp(upstream_is_user_id,involved_ms)==0;
        involved_ms=[entry_service_id;involved_ms(idx)];
        
        % create a dummy service_graph.json file to be used with workmodel generator
        % and traces
        js = "{";
        for i = 1:length(involved_ms)
            js = js + char(34)+involved_ms(i)+char(34)+jsbody;
            if i~=length(involved_ms)
                js = js + ",";
            end
        end
        js = js + "}";
        % js = prettyjson(js);
        fid = fopen(dir_sequential+"/service_graph.json",'w');
        fprintf(fid,"%s",js);
        fclose(fid);
        fid = fopen(dir_parallel+"/service_graph.json",'w');
        fprintf(fid,"%s",js);
        fclose(fid);
    end
end