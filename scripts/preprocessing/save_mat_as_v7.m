% Specify the directory path
directory_path = '../../OFC_data';

% Get a list of all .mat files in the directory
mat_files = dir(fullfile(directory_path, '*.mat'));

% Loop through each .mat file and process it
for file_idx = 1:numel(mat_files)
    file_name = mat_files(file_idx).name;

    % Check if the file name contains "v7"
    if contains(file_name, 'v7')
        disp(['Skipping file: ', file_name]);
        continue; % Skip processing this file
    end

    full_path = fullfile(directory_path, file_name);
    
    % Load and process the .mat file
    mat_data = load(full_path);
    
    % Perform any processing or analysis on the loaded data
    % For example:
    disp(['Processing file: ', file_name]);
%     disp(mat_data);
    disp(file_name)
    disp(fullfile(directory_path, strcat('v7_', file_name)))
    
    % Your processing code here
    save(fullfile(directory_path, strcat('v7_', file_name)), "mat_data", "-v7")
    % Clear the loaded data to free up memory
    clear mat_data;
end
