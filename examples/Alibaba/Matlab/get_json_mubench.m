function js = get_json_mubench(rpc_id,app_trace,names_map,parallel)
idx = find(strcmp(app_trace.rpc_id,rpc_id)>0,1);
if isempty(idx)
    js = "";
    return
end
ms = app_trace.upstream_ms{idx};
ms_id = find(strcmp(names_map,ms)>0,1)-1;
js = char(34)+"s"+num2str(ms_id)+"__"+num2str(randi([0 1e5]))+char(34)+":[";    
rpcid_child = convertCharsToStrings(rpc_id)+".1";
if not(any(strcmp(app_trace.rpc_id,rpcid_child)))
    child_id = find(strcmp(names_map,app_trace.downstream_ms{idx})>0,1)-1;
    js = char(34)+"s"+num2str(child_id)+"__"+num2str(randi([0 1e5]))+char(34)+":[{}]";
    return;
else
    if parallel~=1
        js = js + "{";
    end
    for i=1:1000
        %recursion on childs
        rpcid_child = convertCharsToStrings(rpc_id)+"."+num2str(i);
        if not(any(strcmp(app_trace.rpc_id,rpcid_child)))
            break
        else
            if parallel==1
                js = js + "{"+get_json_mubench(rpcid_child,app_trace,names_map,parallel)+"},";
            else    
                js = js + get_json_mubench(rpcid_child,app_trace,names_map,parallel)+",";            
            end
        end
    end
end
js = convertStringsToChars(js);
if (js(end)==',')
    js=js(1:end-1);
end
js = convertCharsToStrings(js);
if parallel~=1
    js = js + "}";
end
js = js + "]";
end