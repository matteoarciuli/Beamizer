%% PLOT ECDF EMF STRENGTH
close all
load('cache/myhomedata.mat'); %load home path
cd(myhome)
cd TESTS

D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.

for k = 3:length(D) % in questo modo salto . e ..
 if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights
        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        if app.ModeButtonGroup.Buttons(1).Value == 1
        load('G1.mat'); %carico sempre la prima, ma in realta' devo segnarmi il gruppo cosi da caricarlo
        n_dep = 1; %nel caso single test
        end
        if app.ModeButtonGroup.Buttons(2).Value == 1
        load("test.mat")
        id_sel = app.IDEditField.Value;
        k = id_sel+1;
        key = TEST(k,3)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s)
        n_dep = key; %nel caso single test
        end
    end 
end


%ECDF OF THE EMF STRENGTH [V/M] ON THE MEASURE SPOTS VS. THE VARIATION OF
%THE SUBSETS
plot_outside_gui =app.ShowoutsideGUICheckBox.Value;

if plot_outside_gui == 1
    figure
  
        h=cdfplot(ms_collect{1,n_dep});
        set(h,'Color','red')
        %   set(h,'Color','blue')
        hold on

    grid on
    xlabel('E[V/m]')
    ylabel('Prob[E < abscisse]')
    title('Downlink CDF of EMF strength over the measure spots')
    set(gca,'XScale','log')
else
    f = figure;
   
        m = cdfplot(ms_collect{1,n_dep});
        h = gca;
        h.Children.Parent=app.emfecdf;
        hold on
        set(m,'Color','red')
        grid(app.UIAxes,"on")
   
    app.emfecdf.XLabel.String = 'E[V/m]'
    app.emfecdf.YLabel.String = 'Prob[E < abscisse]'
    app.emfecdf.Title.String = 'Downlink EMF exposure'
    axis(app.emfecdf, 'tight')
    set(app.emfecdf,'XScale','log')
    close(f)
end

cd ..
cd ..