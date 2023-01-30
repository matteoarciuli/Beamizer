%Plot extractor
%Matteo Arciuli
%with this code you can extract the results generated in previous
%simulations of the LOCPLAN

close all
load('D:\WORK_HEAVY_FILES\DEBUG\Debugmode\MasterThesis\TESTS\17-Oct-2022\0.2_0.4_0.4\G1.mat')

%ECDF OF THE EMF STRENGTH [V/M] ON THE MEASURE SPOTS VS. THE VARIATION OF
%THE SUBSETS

figure
for i = 1:length(deployment_BS)
h=cdfplot(ms_collect{1,i});
  set(h,'Color','red')
%   set(h,'Color','blue')
hold on
end
xlabel('EMF Strength [V/m]')
ylabel('ECDF')
title('ECDF of the EMF Strength vs. variation of the selected subset of gNB')

%ECDF OF THE THROUGHPUT OVER THE DEPLOYMENT SPOT
figure
for i = 1:length(deployment_BS)
h=cdfplot(tp_collect{1,i}/10e6);
  set(h,'Color','red')
%   set(h,'Color','blue')
hold on
end

xlabel('Throughput[Mbps]')
ylabel('ECDF')
title('ECDF of the througput over the deployment spots vs. variation of the selected subset of gNB')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PLOT MEASURE SPOT
load('toload/measure.mat')  %QUESTO TOLOAD NON SEMBRA FUNZIONARE BENE
figure
for j =1:size(measure_spot,1)
    for i=1:size(measure_spot,2)
        
        for k=1:length(measure_spot{j,i})
            plot(measure_spot{j,i}(k,1),measure_spot{j,i}(k,2),'k.');
            hold on
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PLOT DEPLOYMENT WITH SERVED AND UNSERVED SPOTS
n_dep =1;

figure; %figure porta in primo piano l'immagine
grid on;
hold on;

%plot(ds_served{n_dep,1}(:,1), ds_served{n_dep,1}(:,2),'o','color',[0.4660 0.6740 0.1880]);
scatter(ds_served{n_dep,1}(:,1), ds_served{n_dep,1}(:,2), 'o', 'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
hold on;
plot(ds_unserved{n_dep,1}(:,1),ds_unserved{n_dep,1}(:,2),'*','color',[0.6350 0.0780 0.1840]);
 hold on;

x_site=(deployment_BS{n_dep,1}(:,1)); %tutte le righe che contengono le x delle gNB
y_site=(deployment_BS{n_dep,1}(:,2)); %tutte le righe che contengono le y delle gNB
plot(x_site,y_site, 'm^', 'MarkerEdgeColor',[0 0 0],...
              'MarkerFaceColor',[1 0 1]);
% for i=1:length(unserved)
% plot(unserved{1,i}(1),unserved{1,i}(2),'*','color',[0.6350 0.0780 0.1840]);
% end
title("Deployment, gNB and deploy spots")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PLOT BEAMS
figure
pointsize = 12;
hold on


figure
scatter(data_ms_collect{1,n_dep}(:,1), data_ms_collect{1,n_dep}(:,2), pointsize, data_ms_collect{1,n_dep}(:,4), 'filled');
% figure
%scatter(data_ms_cat{1,1}(:,1), data_ms_cat{1,1}(:,2), pointsize, data_ms_cat{1,1}(:,4), 'filled');
 hold on
% end

x_site=deployment_BS{1,n_dep}(:,1); %tutte le righe che contengono le x delle gNB
y_site=deployment_BS{1,n_dep}(:,2); %tutte le righe che contengono le y delle gNB
plot(x_site,y_site, 'm^');
title('Beam plot for a given subset');
colorbar
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %plot della multiobjective dato il trial
% figure
% 
% for i  = 1:trials
% bar(i,m_obj_collect{i});
% hold on
% end