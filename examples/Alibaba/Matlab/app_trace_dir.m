function [path] = app_trace_dir(output_dir, app_nr)
    % utility function to have consistent output DIRs
    % across file creating code
    app_trace_dir = "app"+num2str(app_nr);
    path = output_dir+"/"+app_trace_dir;
end