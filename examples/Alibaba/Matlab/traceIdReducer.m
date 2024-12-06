function traceIdReducer(trace_id, intermValIter, outKVStore)
    T = emptyTraceTable();
    while hasnext(intermValIter)
        t_traces = getnext(intermValIter);
        T = [T;t_traces];
    end
    add(outKVStore, trace_id, sortrows(T,'rpcid','ascend'));
end