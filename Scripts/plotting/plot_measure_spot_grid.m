%% PLOT MEASURE SPOT
close all
load('cache/myhomedata.mat'); %load home path
cd(myhome)
cd TESTS

D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.

for k = 3:length(D) % in questo modo salto . e ..
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights

        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        load('G1.mat');
    end 
end

load('toload/measure.mat')

plot_outside_gui =app.ShowoutsideGUICheckBox.Value;


if plot_outside_gui == 1
    figure
    for j =1:size(measure_spot,1)
        for i=1:size(measure_spot,2)

            for k=1:length(measure_spot{j,i})
                plot(measure_spot{j,i}(k,1),measure_spot{j,i}(k,2),'k.');
                hold on
            end
        end
    end
    grid on
else
    f = figure;
    for j =1:size(measure_spot,1)
        for i=1:size(measure_spot,2)

            for k=1:length(measure_spot{j,i})
                m = plot(measure_spot{j,i}(k,1),measure_spot{j,i}(k,2),'k.');
                h = gca;
                h.Children.Parent=app.UIAxes;
                hold on
            end
        end
    end
    grid(app.UIAxes,"on")
    app.UIAxes.XLabel.String = 'X[m]'
    app.UIAxes.YLabel.String = 'Y[m]'
    app.UIAxes.Title.String = 'Location of the measurement spots'
    close(f)
end
cd ..
cd ..