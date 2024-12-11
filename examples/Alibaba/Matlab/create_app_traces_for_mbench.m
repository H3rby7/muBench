function mb_trace_stats = create_app_traces_for_mbench(apps,dir_name,entry_service_id,parallel)
% app_trace{i} traces concerning the i-th app
% for each app on app_traces, create a directory with JSON files of traces and a service_graph.json that can be used by µBench
% entry_service_id: downstream_ms microservice id called by the user, this value is specified below
% parallel = 1 means that a microservice carryout parallels calls to downstream microservices 
% mb_trace_stats{i} is a struct containing statistics (only length) of the traces of the i-th app 
[upstream_is_user_id] = constants();

app_count = height(apps);

mkdir(dir_name);
mb_trace_stats = cell(app_count, 1);

% Static JS body string to be used in the loop later
jsbody = ": {" + char(34)+"external_services"+char(34)+": [{";
jsbody = jsbody + char(34)+"seq_len"+char(34)+": 10000,";
jsbody = jsbody + char(34)+"services"+char(34)+": []}]}";

for t=1:app_count
    app_trace = apps.traces{t};
    app_trace_dir = "app"+num2str(t);
    mkdir(dir_name+"/"+app_trace_dir);

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
        js = js + char(34) + "s"+num2str(i-1)+char(34)+jsbody;
        if i~=length(involved_ms)
            js = js + ",";
        end
    end
    js = js + "}";
    % js = prettyjson(js);
    % TODO: how to write many files with matlab!
    fid = fopen(dir_name+"/"+app_trace_dir+"/service_graph.json",'w');
    fprintf(fid,"%s",js);
    fclose(fid);
    
    trace_ids = unique(app_trace.trace_id);
    for i = 1:length(trace_ids)
        single_trace = app_trace((strcmp(app_trace.trace_id,trace_ids(i))>0),:);
        js="{";
        js = js+get_json_mubench('0.1',single_trace,involved_ms,parallel);
        %js = prettyjson(js);
        js=js+"}";
        fid = fopen(dir_name+"/"+app_trace_dir+"/trace"+num2str(i, '%0.5d')+".json",'w');
        fprintf(fid,"%s",js);
        fclose(fid);
        mb_trace_stats{t}.len(i) = height(single_trace)-1;
    end 
 end    
end