function mb_trace_stats = create_app_traces_for_mbench(apps,parallel)
    % app_trace{i} traces concerning the i-th app
    % for each app on app_traces, create a directory with JSON files of traces and a service_graph.json that can be used by µBench
    % entry_service_id: downstream_ms microservice id called by the user, this value is specified below
    % parallel = 1 means that a microservice carryout parallels calls to downstream microservices 
    % mb_trace_stats{i} is a struct containing statistics (only length) of the traces of the i-th app 
    [~, ~, ~, ~, ~, ~, output_dir_sequential, output_dir_parallel] = config();
    
    app_count = height(apps);
    
    mb_trace_stats = cell(app_count, 1);
    
    if parallel~=1
        dir_root = output_dir_sequential;
    else
        dir_root = output_dir_parallel;
    end
    
    for t=1:app_count
        % TODO: move away from taking from apps.traces (as we want to have
        % more input to create traces, than we use to create the apps.
        app_trace = apps.traces{t};
        working_dir = app_trace_dir(dir_root, t);
        
        trace_ids = unique(app_trace.trace_id);
        for i = 1:length(trace_ids)
            single_trace = app_trace((strcmp(app_trace.trace_id,trace_ids(i))>0),:);
            js="{";
            js = js+get_json_mubench('0.1',single_trace,parallel);
            %js = prettyjson(js);
            js=js+"}";
            fid = fopen(working_dir+"/trace"+num2str(i, '%0.5d')+".json",'w');
            fprintf(fid,"%s",js);
            fclose(fid);
            mb_trace_stats{t}.len(i) = height(single_trace)-1;
        end 
     end    
    end