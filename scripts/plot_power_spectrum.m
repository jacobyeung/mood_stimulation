load("v7_EC125_TimeAveragedSpectraPower_6mA.mat")



% Assuming power is your data matrix and stim_start, stim_end are defined
plt_data = squeeze(power_stim(1, 1:21, :)); % Extract the first row of the power matrix

plt_data = zscore(plt_data, 1, 2);

% Create a figure and axis
fig = figure;
ax = gca;

% Display the image with automatic aspect ratio adjustment
im = imagesc(plt_data); % plot lower frequency at bottom

% Set colormap to "viridis"
% colormap(ax);

% Set the aspect ratio to "auto"
% daspect(ax, [1, 1, 1]);

% Add vertical lines at stim_start and stim_end
hold on;
line([stimStartSample, stimStartSample], ylim, 'Color', 'white');
line([stimEndSample, stimEndSample], ylim, 'Color', 'white');
hold off;

% Add colorbar
colorbar;

% Invert y-axis to plot lower frequency at the bottom
set(ax, 'YDir', 'reverse');

% Show the plot
title('Normalized and Scaled Data');
xlabel('X-axis');
ylabel('Y-axis');