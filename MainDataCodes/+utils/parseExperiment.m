function [imaging_dir,impale_dir,tosca_dir,camera_dir,matching_dir,mat_dir] = parseExperiment(d_c)
% Function by Tomas Suarez Omedas 12/16/2022. This parses the field of the
% table output from choose_experiment.m into different fields ready for
% post-processing
% Input
    % d_c: Table output of choose_experiment

d_c.Properties.VariableNames = regexprep(d_c.Properties.VariableNames, ' ', '');
d_c.Properties.VariableNames = regexprep(d_c.Properties.VariableNames, '#', '');
allExp = table2struct(d_c);
[imaging_dir,impale_dir,tosca_dir,camera_dir,matching_dir,mat_dir] = deal(strings(numel(allExp),1));
for ii = 1:numel(allExp)
    exp = allExp(ii);
    if (exp.Date) < 100000
        imaging_dir(ii) = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\0', num2str(exp.Date), '\',exp.Suite2PParameterFile);
        impale_dir(ii)  = strcat(exp.MainPath, exp.CellType, '\Impale\', exp.Animal, '\0', num2str(exp.Date));
        tosca_dir(ii)   = strcat(exp.MainPath, exp.CellType, '\Tosca\', exp.Animal, "\Session ", num2str(exp.ToscaSession));
        camera_dir(ii)  = strcat(exp.MainPath, exp.CellType, '\Camera\', exp.Animal, '\0', num2str(exp.Date));
        matching_dir(ii) = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\Matching Files\');
        mat_dir(ii)     = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\0', num2str(exp.Date), '\',exp.ImpaleParameterFile, '\MAT');
    else
        imaging_dir(ii) = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\', num2str(exp.Date), '\',exp.Suite2PParameterFile);
        impale_dir(ii)  = strcat(exp.MainPath, exp.CellType, '\Impale\', exp.Animal, '\', num2str(exp.Date));
        tosca_dir(ii)   = strcat(exp.MainPath, exp.CellType, '\Tosca\', exp.Animal, "\Session ", num2str(exp.ToscaSession));
        camera_dir(ii)  = strcat(exp.MainPath, exp.CellType, '\Camera\', exp.Animal, '\', num2str(exp.Date));
        matching_dir(ii) = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\Matching Files\');
        mat_dir(ii)     = strcat(exp.MainPath, exp.CellType, '\2P\', exp.Animal, '\', num2str(exp.Date), '\',exp.ImpaleParameterFile, '\MAT');
    end
end