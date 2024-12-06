function [T] = emptyTraceTable()
    varnames = {'Var1', 'traceid', 'timestamp', 'rpcid', 'um', 'rpctype', 'dm', 'interface', 'rt'};
    vartypes = {'uint64', 'string', 'uint32', 'string', 'string', 'string', 'string', 'string', 'int16'};
    T = table('Size', [0 9], 'VariableTypes',vartypes, 'VariableNames',varnames);
end
% testme = emptyTraceTable();