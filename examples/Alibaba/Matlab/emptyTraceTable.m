function [T] = emptyTraceTable()
    [~, ~, trace_header, trace_vartypes, ~, ~] = config();
    T = table('Size', [0 9], 'VariableTypes',trace_vartypes, 'VariableNames',trace_header);
end
% testme = emptyTraceTable();