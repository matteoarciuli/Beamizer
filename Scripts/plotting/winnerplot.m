%%% WINNERPLOT
%%% LAVORAZIONE MIGLIOR SOLUZIONE %%%%
close all
load("test.mat")

k = find(TEST(:,5) == max(TEST(:,5))) %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
k = k(end);% se piu' id hanno valore funzione multiobiettivo massimo prendi l'ultima trovata tra le tante, cosi installo di piu e copro di piu 
key = TEST(k,3)
% TEST(k,:)
% TEST(k,2)
% TEST(k,3)
% % % % % % % % % % % % % s1 = '0.1_0.45_0.45/G';
% % % % % % % % % % % % % s2 = num2str(TEST(k,2));
% % % % % % % % % % % % % s3 = '.mat';
% % % % % % % % % % % % % s= append(s1,s2,s3);
% % % % % % % % % % % % % load(s)
%ora devo accedere alle cartelle salvate e salvare tutto sotto un winner
n_dep =key; % questo plottava solo per un deployment, quindi la logica va bene, ma deve farlo per il migliore che devo passargli

% figure; %figure porta in primo piano l'immagine
% grid on;
% hold on;
% 
% %plot(ds_served{n_dep,1}(:,1), ds_served{n_dep,1}(:,2),'o','color',[0.4660 0.6740 0.1880]);
% scatter(ds_served{1,n_dep}(:,1), ds_served{1,n_dep}(:,2), 'o', 'MarkerEdgeColor',[0 .5 .5],...
%               'MarkerFaceColor',[0 .7 .7],...
%               'LineWidth',1.5)
% hold on;
% plot(ds_unserved{1,n_dep}(:,1),ds_unserved{1,n_dep}(:,2),'*','color',[0.6350 0.0780 0.1840]);
%  hold on;
% 
% x_site=(deployment_BS{1,n_dep}(:,1)); %tutte le righe che contengono le x delle gNB
% y_site=(deployment_BS{1,n_dep}(:,2)); %tutte le righe che contengono le y delle gNB
% plot(x_site,y_site, 'm^', 'MarkerEdgeColor',[0 0 0],...
%               'MarkerFaceColor',[1 0 1]);
% % for i=1:length(unserved)
% % plot(unserved{1,i}(1),unserved{1,i}(2),'*','color',[0.6350 0.0780 0.1840]);
% % end
% title("Winner Deployment (Best MOBJ among the TEST)")

%PLOT FUNZIONE MULTIOBIETTIVO NON MI INTERESSA QUI
% figure
% plot(TEST(:,1),TEST(:,5))
% title("Andamento della funzione multiobiettivo durante il Test completo")
% xlabel('ID')
% ylabel('MOBJ-Value')
% % % CURRENT BEST NON MI INTERESSA TANTO C'E GIA IL LIVEPLOT
% % % 
% % % figure
% % % plot(TEST(:,1),TEST(:,6))
% % % title("Progressione del current best objective, con plateau. rappr dynamics")
% % % xlabel('ID')
% % % ylabel('CURRENT BEST MOBJ-Value')


figure 
hold on
plot(TEST(:,1),TEST(:,7))
hold on
plot(TEST(:,1),TEST(:,8))
hold on
plot(TEST(:,1),TEST(:,9))
legend('f1','f2','f3')
xlabel('ID')
title("Progressione f1,f2,f3")
%plot net tp in funzione dell'id (best net tp vs id)
%una volta che sai i current best con id e gruppo cicli su id e gruppo e ti
%vai a plottare il contenuto del net tp

%cbnetemf va importato qua oppure aggiungi una colonna a test


figure 
plot(TEST(:,1),TEST(:,11))
xlabel('ID')
ylabel('$')
title("Progressione costo di istallazione")

figure
plot(TEST(:,1),TEST(:,12))
xlabel('ID')
ylabel('V/m TOT')
title("Progressione EMF")
figure 
plot(TEST(:,1),TEST(:,13))
xlabel('ID')
ylabel('bps TOT')
title("Progressione Throughput")



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