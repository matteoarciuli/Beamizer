%% Modulo GENERATOR
% Inizializzazione delle variabili
clearvars -except trials accuracy r num_user tp_collect ms_collect dsms m_obj_collect served_ratio unserved_ratio dsmsd  deployment_index deployment...
    ds_served ds_unserved avg_tp_collect avg_emf_collect deployment_BS data_ms_collect exec_time numerosity filenumb  n0 M_OBJ_COLLECT ext tStart ID TEST pext pnumerosity MAX_num cb pcb cbc dinamics ctot_collect cb_net_emf cb_ctot cb_net_tp...
    alpha beta gamma sa weigths path progressbar app event Max_attempts_per_group test_mode myhome kml_import mobj_coeff_tuning mobj_calibration calibration_time

% Imposta lo spaziamento della griglia di mesh per la misura del punto di
% deployment in [m]
spacing=app.SpacingmeasurespotgridEditField.Value;
% Altezza dell'utente (m)
UE_h = app.UEheightmEditField.Value;
% Altezza BS (m)
BS_h = app.gNBheigthmEditField.Value;
% Altezza effettiva (m)
effective_h = BS_h-UE_h;
% Numero di settori
sector = 3;
% Distanza massima di servizio
dist_massima_serv = 400;
% Capacità del settore (numero massimo di punti di deployment per settore)
sector_capacity = 8;
% Chiave di deployment
dep_key = trials;
% Numero di deployment da generare
n_deployment=200;
% Carica la mappa dell'operatore
load('toload/a_s_operator.mat');
% Parte di calibrazione
if mobj_calibration == 1
    numerosity = curr_max_gNB_num; %numero massimo di gNB
    numberOfPoints_ds = 50000; %numero di punti per deployment spot
end

% Intervallo della griglia per deployment spot
min_x = -2000; %minimo asse x
max_x = 2000; %massimo asse x
min_y = -2050; %minimo asse y
max_y = 2000; %massimo asse y

% Calcolo dei confini per il deployment corrente importato
padding = dist_massima_serv; %distanza massima di servizio
if kml_import == 1
    % Il lato più lungo del quadrato sarà utilizzato come dimensione
    size_x = max(bss_candidate(:,1))-min(bss_candidate(:,1)); %dimensione asse x
    size_y = max(bss_candidate(:,2))-min(bss_candidate(:,2)); %dimensione asse y
    container = (max(size_x,size_y)) + 4*padding; %dimensione del contenitore
else
    container = 10000; %dimensione del contenitore fissata a 10000
end

%POST PROCESSING
if app.PostprocessingCheckBox.Value == 1

    cd TESTS % Cambia la directory corrente a TESTS

    D = dir; % D è una struttura che contiene i nomi dei file e delle cartelle nella directory corrente

    for k = 3:length(D) % Salta i primi due elementi . e .. utilizzati per la navigazione
        if isdir(D(k).name) % Salta il file output.txt e considera solo le cartelle dei pesi

            currD = D(k).name; % Ottieni il nome della sottodirectory corrente
            cd(currD); % Cambia la directory corrente alla sottodirectory

            load("test.mat") % Carica il file "test.mat"
            k = find(TEST(:,5) == max(TEST(:,5))) % Trova la riga della matrice di test con la migliore funzione multiobiettivo
            k = k(end); % Se più righe hanno il massimo valore di funzione multiobiettivo, scegli l'ultima trovata, in modo da installare più gNB e servire un'area più ampia
            win_key = TEST(k,3); % Ottieni la chiave di installazione vincente

            s1 = 'G'; % Primo elemento della stringa da creare
            s2 = num2str(TEST(k,2)); % Secondo elemento: trasforma il numero in stringa
            s3 = '.mat'; % Terzo elemento
            s= append(s1,s2,s3); % Concatena i tre elementi
            load(s) % Carica il file ottenuto
            n_dep = win_key; % Assegna a n_dep la chiave di installazione vincente
        end
    end
    cd .. % Torna alla directory padre
    cd .. % Torna alla directory padre
end

%% estrazione dei subset

if dsms==0
    deployment_index{n_deployment,1}={}; % creiamo un cell array vuoto per indicare i deployment
    deployment{numerosity,1} = {}; % creiamo un cell array per memorizzare le informazioni delle bss in ogni deployment

    for k = 1:n_deployment
        a = []; %lista di indici delle bss contenuti in un deployment per selezionare le bss
        for j = 1:numerosity
            i = randi([1,length(bss_candidate)]); % seleziona un indice casuale tra le bss candidate
            if ~ismember(i,a) % se l'indice non è già nella lista
                a(j)= i; % lo inseriamo
            elseif ismember(i,a) % altrimenti se l'indice è già presente
                while true % continuiamo a cercare un indice diverso finché non lo troviamo
                    b = randi([1,length(bss_candidate)]);
                    if ~ismember(b,a)
                        a(j)= b;
                        break % quando lo troviamo, interrompiamo il ciclo
                    end
                end
            end
        end
        deployment_index{k,1}={sort(a)}; %riordiniamo l'array per ottenere una lista ordinata di indici per ogni deployment
    end

    %selezione dei subset da tutti i possibili deployments
    for k = 1:n_deployment
        for j = 1:numerosity %estensione del subset pescato
            i = deployment_index{k,1}{1,1}(j); % prendiamo un indice dalla lista
            deployment{k,1}{j,1} = bss_candidate(i,1);%info bss x
            deployment{k,1}{j,2} = bss_candidate(i,2);%info bss y
        end
    end
end
if dsms==0
    if app.PostprocessingCheckBox.Value == 1 % se l'opzione di post-processing  è attivata
        deployment = deployment_BS{1,n_dep}; % impostiamo il deployment sul winner ottenuto dalla post-elaborazione
    end
    save('toload/deployment.mat','deployment'); % salva il deployment su file
end
%% Definizione del layout
if app.PostprocessingCheckBox.Value == 1 % se la casella di post-processing è selezionata
    BS = deployment; % allora il layout delle BS sarà uguale a quello presente nel deployment
else % altrimenti
    for i = 1:numerosity % ciclo per tutto il numero di elementi presenti nel deployment
        BS=cell2mat(deployment{dep_key,1}); % trasformiamo la cella del deployment in una matrice
    end
end

% Definizione del layout
for i=1:length(BS) % ciclo per la lunghezza della matrice BS
    xc = BS(i,1); % assegniamo la coordinata x del centro della BS i
    yc = BS(i,2); % assegniamo la coordinata y del centro della BS i
    center=[xc,yc]; % definiamo le coordinate del centro della BS i
end

save('toload/layout.mat','BS'); % salviamo la matrice BS in un file .mat

%% Generare i deployment spots (users-estimated-positions)

% Leggi il file kml e estrai le informazioni di longitudine, latitudine e altitudine
[long,lat,z]=read_kml(app.KMLfileDropDown.Value);
% Calcola il centro della topologia importata
long_c = mean(long);
lat_c = mean(lat);
% Imposta l'altitudine sopra il livello medio del mare
alt = 21;
% Memorizza il centro della topologia importata come origine
origin = [lat_c, long_c, alt];
% Converti la latitudine e la longitudine in est e nord in UTM WGS-84
[xEast,yNorth] = latlon2local(lat,long,alt,origin);
% Memorizza le coordinate convertite in bss_candidate
bss_candidate = [xEast,yNorth];
% Memorizza le coordinate x in allowed_sites_X e le coordinate y in allowed_sites_Y
allowed_sites_X = transpose(xEast);
allowed_sites_Y = transpose(yNorth);
% Memorizza il numero massimo di spot gNB consentiti in curr_max_gNB_num
curr_max_gNB_num = length(allowed_sites_X);
% Memorizza i punti iniziali in initialPoints
initialPoints = bss_candidate;
% Inizializza deploy_spot_pre come vuoto
deploy_spot_pre = [];
% Imposta la distanza minima e massima
minDistance = 10;
maxDistance = 500;

% Per ogni punto iniziale
for i = 1:curr_max_gNB_num
    rng(i);
    % Genera un numero specifico di punti casuali compresi tra la distanza minima e massima
    numDistributedPoints = 32;
    distances = rand(numDistributedPoints, 1) * (maxDistance - minDistance) + minDistance;

    % Genera angoli casuali
    angles = rand(numDistributedPoints, 1) * 2 * pi;

    % Calcola le coordinate dei punti distribuiti utilizzando le distanze e gli angoli casuali
    distributedPoints = [distances .* cos(angles), distances .* sin(angles)];

    % Somma le coordinate dei punti distribuiti alle coordinate del punto iniziale per ottenere le coordinate finali
    distributedPoints = distributedPoints + initialPoints(i, :);

    % Aggiunge i punti distribuiti all'elenco dei punti
    deploy_spot_pre = [deploy_spot_pre; distributedPoints];
end
% Post-elaborazione: carica le posizioni degli utenti
% Se la casella di controllo per la post-elaborazione è selezionata, allora unisci i d.s. serviti e non serviti in merged_ds_imported
if app.PostprocessingCheckBox.Value == 1
    merged_ds_imported = {ds_served{n_dep} ds_unserved{n_dep}};
    % Concatena serviti e non serviti in merged_ds_imported
    merged_ds_imported = cat(1,merged_ds_imported{2},merged_ds_imported{1});
    % Assegna merged_ds_imported a deploy_spot_pre
    deploy_spot_pre = merged_ds_imported;
end

% Salva i dati in deploy_spot_pre come file .mat in toload/deploy_spot_pre.mat
save('toload/deploy_spot_pre.mat','deploy_spot_pre')
%% Classificazione e arricchimento dati (deployment spots e measurement spots)

% Inizializzo lo spot catalogato per ogni cella per settore
spots_cat{length(BS),sector}=[];
% Inizializzo i measurement spots
measure_spot{1,size(spots_cat,2)}=[];
if dsms==0
    % Inizializzo lo spot catalogato per ogni cella x settore
    spots_cat{length(BS),sector}=[];
    % Carico i punti di distribuzione ancora non catalogati
    temp = deploy_spot_pre;
    % Inizializzo i flag per ogni deployment spot
    flags{length(temp),1} =[];
    % Inizializzo la distanza relativa per ogni deployment spot
    dist_relative{length(temp),1}=[];
    % Inizializzo le informazioni sulla distanza
    info_dist{length(temp),1}=[];
end
if dsms ==1
    %meshgrid m.s.
    % Definire la griglia di punti con lo spacing specificato
    x = min_x:spacing:max_x;
    y = min_y:spacing:max_y;
    % Calcolare la posizione X e Y di ogni punto sulla griglia
    [X,Y] = meshgrid(x,y);
    % Salvare tutti i punti sulla griglia in un array total_spots
    total_spots = [X(:), Y(:)];
    % Copiare i punti sulla griglia in temp
    temp = total_spots;
    % Inizializzare flags come un array vuoto di lunghezza temp
    flags{length(temp),1} =[];
    % Inizializzare spots_cat come un array vuoto di lunghezza BS x sector
    spots_cat{length(BS),sector}=[];
    if app.PostprocessingCheckBox.Value == 1
        % In post-processing la distanza massima di espansione di
        % measurement spots di una gNB arriva a coprire tutto il
        % contenitore
        dist_massima_serv = 2500;

    else
        % altrimenti la copertura rimane quella nominale della gNB
        dist_massima_serv = 500;
    end
    flags{length(total_spots),1} =[]; % inizializzazione dei flag per tutti gli spots
    dist_relative{length(total_spots),1}=[];% inizializzazione delle distanze relative per tutti gli spots
    info_dist{length(total_spots),1}=[]; % inizializzazione delle informazioni sulle distanze
end
%ciclo for per iterare su ogni punto di deploy
for i=1:length(temp)
    spot=[temp(i,1),temp(i,2)]; %punto di deploy corrente
    %ciclo for per iterare su ogni gNB
    for j=1:length(BS)
        %determina la posizione della gNB corrente
        if app.PostprocessingCheckBox.Value == 1
            pos_gnb = [deployment(j,1),deployment(j,2)];
        else
            pos_gnb = [cell2mat(deployment{dep_key,1}(j,1)),cell2mat(deployment{dep_key,1}(j,2))];
        end

        %calcola la distanza 2D tra punto di deploy e BS
        dist_2D_DS=norm(pos_gnb-spot);
        %calcola la distanza effettiva
        dist_eff_DS=sqrt((effective_h)^2 + (dist_2D_DS)^2);
        %verifica se la distanza è inferiore alla distanza di servizio massima
        if dist_eff_DS<=dist_massima_serv
            flag = 1; %la BS è una candidata per questo punto di deploy
        else
            flag = 0; %la BS non è una candidata per questo punto di deploy
        end
        %memorizza il flag per la gNB corrente per un deployment spot
        flags{i,1}(end+1) = flag;
        %se la stazione è una candidata per servire il deployment spot
        if flags{i,1}(j) == 1
            %memorizza la distanza relativa e l'indice della stazione di base
            dist_relative{i,1}{end+1,1}=norm(pos_gnb-spot);
            dist_relative{i,1}{end,2}=j;
            %trova l'indice della BS con la distanza minima tra le candidate
            indx=find(cell2mat(dist_relative{i,1}(:,1))==min(cell2mat(dist_relative{i,1}(:,1))));
            %verifica per i duplicati
            if length(indx)>1
                indx = indx(1);
            end
            %memorizza l'indice della migliore BS per il punto di deploy corrente
            winner(i) = cell2mat(dist_relative{i,1}(indx,2));
        end
    end
end

% se la variabile "dsms" è 0
if dsms == 0
    % inizializza un vettore vuoto per le posizioni non servite
    unserved = [];
    % per ogni vincitore (BS associato a un punto di distribuzione)
    for i = 1:length(winner)
        % prendi la posizione corrente del punto di distribuzione
        spot = [temp(i,1), temp(i,2)];
        pos = spot;
        % prendi l'indice del BS associato al punto di distribuzione
        key = winner(i);

        % se l'indice è 0 (non servito)
        if key == 0
            % se la variabile "dsms" è 0
            if dsms == 0
                % salva la posizione del punto di distribuzione non servito
                unserved{end + 1} = spot;
            end
        end

        % se l'indice è diverso da 0 (servito)
        if key ~= 0
            % se il checkbox "Postprocessing" è selezionato
            if app.PostprocessingCheckBox.Value == 1
                % prendi la posizione del BS associato al punto di distribuzione
                center = [deployment(key,1), deployment(key,2)];
            else
                % altrimenti, prendi la posizione del BS associato al punto di distribuzione dalla cella di deployment
                center = [cell2mat(deployment{dep_key,1}(key,1)), cell2mat(deployment{dep_key,1}(key,2))];
            end
            % valuta l'angolo di steering rispetto a tutti i settori
            steer(1)=evalsteer(1, pos, center);
            steer(2)=evalsteer(2, pos, center);
            steer(3)=evalsteer(3, pos, center);
            % trova il piu vicino alla normale all'array
            closer=min(abs(steer));
            % contrassegnalo
            flag=find(steer==closer);
            if isempty(flag)
                flag = find(steer==-closer);
            end
            spot = pos;
            % classificazione all'interno del primo settore 
            if flag == 1 
                if dsms ==0
                    %se il numero di d.s. in un settore non supera la
                    %capacità massima (numero di subarray)
                    if length(spots_cat{key,1})<sector_capacity 
                        if app.PostprocessingCheckBox.Value == 1
                            result = ismember(spot, ds_served{n_dep});
                            % se spot fa parte dell'array ds_served
                            if all(result(:))
                                if steer(flag)>0
                                    %spot appartenente al lato destro del settore
                                    spots_cat{key,1} = [spots_cat{key,1}; spot,1];
                                else 
                                    %spot appartenente al lato sinistro del settore
                                    spots_cat{key,1} = [spots_cat{key,1}; spot,0];
                                end

                            end
                        else
                            %in caso non stessi facendo post processing non
                            %fare il controllo sulla presenza nei ds_served
                            if steer(flag)>0
                                %spot appartenente al lato destro del settore
                                spots_cat{key,1} = [spots_cat{key,1}; spot,1]; 
                            else 
                                %spot appartenente al lato sinistro del settore
                                spots_cat{key,1} = [spots_cat{key,1}; spot,0];
                            end

                        end

                    end
                end
             % classificazione all'interno del secondo settore 
            elseif flag == 2 

                if dsms ==0
                    if length(spots_cat{key,2})<sector_capacity
                        if app.PostprocessingCheckBox.Value == 1
                            result = ismember(spot, ds_served{n_dep})
                            % se spot fa parte dell'array ds_served
                            if all(result(:))
                                if steer(flag)>0
                                    %spot appartenente al lato destro del settore
                                    spots_cat{key,2} = [spots_cat{key,2}; spot,1]; 
                                else 
                                    %spot appartenente al lato sinistro del settore
                                    spots_cat{key,2} = [spots_cat{key,2}; spot,0];
                                end
                            end
                        else
                            if steer(flag)>0
                                %spot appartenente al lato destro del settore
                                spots_cat{key,2} = [spots_cat{key,2}; spot,1];
                            else 
                                 %spot appartenente al lato sinistro del settore
                                spots_cat{key,2} = [spots_cat{key,2}; spot,0];
                            end
                        end
                    end
                end
            % classificazione all'interno del terzo settore 
            elseif flag == 3 
                if dsms ==0
                    if length(spots_cat{key,3})<sector_capacity
                        if app.PostprocessingCheckBox.Value == 1
                            result = ismember(spot, ds_served{n_dep})
                            % se spot fa parte dell'array ds_served, senno
                            if all(result(:))
                                if steer(flag)>0
                                    %spot appartenente al lato destro del settore
                                    spots_cat{key,3} = [spots_cat{key,3}; spot,1]; 
                                else 
                                     %spot appartenente al lato sinistro del settore
                                    spots_cat{key,3} = [spots_cat{key,3}; spot,0];
                                end
                            end
                        else
                            if steer(flag)>0
                                %spot appartenente al lato destro del settore
                                spots_cat{key,3} = [spots_cat{key,3}; spot,1]; 
                            else 
                                 %spot appartenente al lato sinistro del settore
                                spots_cat{key,3} = [spots_cat{key,3}; spot,0];
                            end
                        end
                    end
                end
            end
        end
    end
end
% classificazione analoga per i measurement spots
if dsms ==1

    for i=1:length(temp)
        spot=[temp(i,1),temp(i,2)];
        pos = spot;

        for j=1:length(BS)
            if app.PostprocessingCheckBox.Value == 1
                pos_gnb = [deployment(j,1),deployment(j,2)];
            else
                pos_gnb = [cell2mat(deployment{dep_key,1}(j,1)),cell2mat(deployment{dep_key,1}(j,2))];
            end
            dist_2D_DS=norm(pos_gnb-spot);
            dist_eff_DS=sqrt((effective_h)^2 + (dist_2D_DS)^2);
            if dist_eff_DS<=400 
                flag = 1;
            else
                flag = 0;
            end
            flags{i,1}(end+1) = flag;
            if flags{i,1}(j) == 1
                if app.PostprocessingCheckBox.Value == 1

                    center =  [deployment(j,1),deployment(j,2)];
                else
                    center = [cell2mat(deployment{dep_key,1}(j,1)),cell2mat(deployment{dep_key,1}(j,2))];
                end

                spot = pos;
                steer(1)=evalsteer(1, pos, center);
                steer(2)=evalsteer(2, pos, center);
                steer(3)=evalsteer(3, pos, center);
                closer=min(abs(steer));
                flag=find(steer==closer);
                if isempty(flag)
                    flag = find(steer==-closer);
                end
                spot = pos;
                % classificazione all'interno del primo settore
                if flag == 1 
                    if steer(flag)>0
                        %spot appartenente al lato destro del settore
                        spots_cat{j,1} = [spots_cat{j,1}; spot,1]; 
                    else 
                        %spot appartenente al lato sinistro del settore
                        spots_cat{j,1} = [spots_cat{j,1}; spot,0];
                    end
                % classificazione all'interno del secondo settore 
                elseif flag == 2 
                    if steer(flag)>0
                        %spot appartenente al lato destro del settore
                        spots_cat{j,2} = [spots_cat{j,2}; spot,1]; 
                    else 
                        %spot appartenente al lato sinistro del settore
                        spots_cat{j,2} = [spots_cat{j,2}; spot,0];
                    end
                % classificazione all'interno del terzo settore 
                elseif flag == 3 
                    if steer(flag)>0
                        %spot appartenente al lato destro del settore
                        spots_cat{j,3} = [spots_cat{j,3}; spot,1]; 
                    else 
                        %spot appartenente al lato sinistro del settore
                        spots_cat{j,3} = [spots_cat{j,3}; spot,0];
                    end
                end
            end
        end
    end
end
% salvataggio delle variabili
if dsms == 0
    save('toload/unserved.mat','unserved');
    save('toload/useful_spots.mat','spots_cat');
end
if dsms ==1
    measure_spot{1,size(spots_cat,2)}=[]; 
    measure_spot = spots_cat ;
    save('toload/measure.mat','measure_spot');
end
