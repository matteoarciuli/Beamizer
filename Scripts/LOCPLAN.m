%% Modulo LOCPLAN

% Inizializzazione delle variabili
clearvars -except trials accuracy r num_user tp_collect ms_collect m_obj_collect served_ratio unserved_ratio exec_time ds_served ds_unserved ...
    avg_tp_collect avg_emf_collect deployment_BS data_ms_collect numerosity filenumb n0 M_OBJ_COLLECT ext tStart ID TEST pext pnumerosity MAX_num cb pcb cbc dinamics ctot_collect cb_net_emf cb_ctot cb_net_tp...
    alpha beta gamma sa weigths path progressbar app event Max_attempts_per_group test_mode kml_import mobj_coeff_tuning mobj_calibration max_tp_emf_cal calibration_time

% Altezza dell'utente (m)
UE_h =app.UEheightmEditField.Value ;
% Altezza della BS (m)
BS_h = app.gNBheigthmEditField.Value;
% Altezza effettiva (m)
effective_h = BS_h-UE_h;
% Frequenza portante (GHz)
fq=app.CarrierfrequencyGHzEditField.Value;
% Velocità della luce
c = 3*10^8;
% Lunghezza d'onda
lambda = c/(fq*10^9);
% NLOS (1) o LOS (0)
NLOS_on=app.PropagationconditionDropDown.Value;
% Scenario (UMi o UMa)
Scenario = app.ScenarioDropDown.Value;
% Angolo minimo (gradi)
angle_min=app.Minimum3dBangledegEditField.Value;
% Rapporto front-back (dB)
Am = app.FronttoBackRatioAmdBEditField.Value;
% Limite livello lobo laterale (dB)
SLAv = app.SidelobelevellimitSLAvdBEditField.Value;
% Dimensione dell'array (64 elementi)
nrow = app.ArraysizerowEditField.Value;
ncol = app.ArraysizecolumnEditField.Value;
% Guadagno massimo (dB)
Gbf=10*log10(nrow*ncol);
% Guadagno antenna (dBi)
Gtx=app.TxGainantennaelementdBiEditField.Value;
% Guadagno antenna piccola cella (dBi)
GdB = 15;
% Guadagno antenna piccola cella (lineare)
G = 10^(GdB/10);
% Potenza trasmissiva totale (dBm)
txPowerDBm = app.ArraytotaltransmitpowerdBmEditField.Value;
% Potenza trasmissiva totale (W)
txPower = (10.^((txPowerDBm-30)/10));
% Potenza trasmissiva di ciascun elemento dell'antenna
txPowerSE = txPower/(ncol);
%Inizializzazione delle variabili
int_intrasec=app.IntrasectorinterferenceSwitch.Value; %1 per considerare l'interferenza intra-settore, 0 per disattivare
% Definisci i parametri del ricevitore utilizzando la Tabella 8-2 (b) del Report ITU-R
% M.[IMT-2020.EVAL] https://www.itu.int/md/R15-SG05-C-0057/es
bw = (app.BandwidthMHzEditField.Value)*10e5; % Larghezza di banda di 80 MHz  500MHz GHANT
rxNoiseFigure = app.ReceivernoisefiguredBEditField.Value; % dB %aggiornamento
rxNoisePowerdB = -174 + 10*log10(bw) + rxNoiseFigure;
rxNoisePower = 10^(rxNoisePowerdB/10);
Z0=app.MediumImpedenceOhmEditField.Value; %Impedenza d'onda dello spazio libero
%settore = app.NumberofsectorspercellEditField.Value;
accuracy =app.LocalizationAccuracymEditField.Value;% [epsilon]
c_eq = 60000; %costo dell'equipaggiamento
beamforming = app.BeamformingSwitch.Value; % se l'interruttore è spento, si può recuperare il caso senza beamforming
fixed_angles = app.FixedanglesSwitch.Value ; % se l'interruttore è acceso, gli angoli az3db el3db vengono forzati sugli angoli fissi specificati
M = 8; % numero di stream MIMO per un array (spaziali)
%
if mobj_calibration == 1
    if max_tp_emf_cal == 0
        accuracy = 20; %peggiore per calcolare il livello massimo di EMF netto
    else
        accuracy = 2; %migliore accuratezza per calcolare il livello massimo di TP
    end
end

%% Caricamento delle variabili dal generatore di layout

% Caricamento del layout (BS, cell, settori)
load('toload/layout.mat');

% Caricamento deployment spot
load('toload/deployment.mat');

% Caricamento del punto di misura
load('toload/measure.mat');

% Caricamento di tutti i punti all'interno delle celle
load('toload/useful_spots.mat');

% Caricamento di deployment spot catalogati
load('toload/deploy_spot_pre.mat')

% Caricamento dei punti non serviti
load('toload/unserved.mat')

%% Compute Steer, Tilt, Path loss for Deploy spot and Users


deploy_spot_comp{size(spots_cat,1),size(spots_cat,2)}=[]; %per memorizzare tutti i dati del punto di deploy

for j=1:size(spots_cat,1) %ciclo su righe
    for i=1:size(spots_cat,2) %ciclo su colonne
        for k=1:size(spots_cat{j,i},1) %ciclo sui punti all'interno di ogni cella
            pos=[spots_cat{j,i}(k,1), spots_cat{j,i}(k,2)]; %posizione del punto di deploy corrente
            center=[BS(j,1), BS(j,2)]; %coordinate della BS corrente
            dist_2D=norm(pos-center); %distanza 2D tra il punto di deploy e la BS
            dist_eff_ds=sqrt((effective_h)^2 + (dist_2D)^2); %distanza effettiva
            dist_eff_ds_km = dist_eff_ds*0.001; %conversione in km per applicare FSPL in dB

            if Scenario == 0
                % Calcola la perdita di segnale LOS in dB utilizzando la formula 3GPP TR 38.901 version 17.0.0 Release 17
                PL_ds = 28.0+ 22*log10(dist_eff_ds) + 20*log10(fq);
                % Imposta lo standard deviation per la shadow fading
                SF_std = 4;
                % Se NLOS_on è uguale a 1, applica il modello NLOS
                if NLOS_on ==1
                    % Calcola la perdita di segnale NLOS in dB utilizzando la formula specificata
                    PL_nlos_ds= 13.54 + 39.08*log10(dist_eff_ds)+20*log10(fq)-0.6*(UE_h-1.5);
                    % utilizza la perdita di segnale più grande tra quella LOS e quella NLOS
                    PL_ds=max(PL_nlos_ds,PL_ds);
                    % Imposta lo standard deviation per la shadow fading
                    SF_std = 6;
                end
            else
                % Calcola la perdita di segnale LOS in dB utilizzando la formula specificata
                PL_ds = 32.4+ 21*log10(dist_eff_ds) + 20*log10(fq);
                % Imposta lo standard deviation per la shadow fading
                SF_std = 4;
                % Se NLOS_on è uguale a 1, applica il modello NLOS
                if NLOS_on ==1
                    % Calcola la perdita di segnale NLOS in dB utilizzando la formula specificata
                    PL_nlos_ds= 35.3*log10(dist_eff_ds)+22.4+21.3*log10(fq)-0.3*(UE_h-1.5);
                    % utilizza la perdita di segnale più grande tra quella LOS e quella NLOS
                    PL_ds=max(PL_nlos_ds,PL_ds);
                    % Imposta lo standard deviation per la shadow fading
                    SF_std = 7.82;
                end
            end

            %Calcola l'angolo di inclinazione per il punto di deploy utilizzando la formula specificata
            tilt=atan2d(effective_h,dist_2D);

            %Calcola l'angolo di orientamento per il punto di deploy utilizzando la funzione evalsteer
            steer=evalsteer(i,pos,center);

            %Salva tutte le informazioni sul punto di deploy in un array
            deploy_spot_comp{j,i}=[deploy_spot_comp{j,i}; spots_cat{j,i}(k,:), tilt, steer, PL_ds, dist_eff_ds];
        end
    end
end

number_samples=1000; %imposta il numero di campioni
sf_values=normrnd(0,SF_std,[number_samples,1]); %valori di shadow fading generati in base alla deviazione standard SF_std

%salvataggio multipiattaforma
s1 = pwd; %cartella corrente
s2 = '\cache\deploy_comp.mat'; %nome del file da salvare
if ismac
    s2(strfind(s2,'')) = '/'; %se sistema operativo è Mac, sostituisci i caratteri '' con '/'
    % codice per piattaforma Mac
elseif isunix
    s2(strfind(s2,'')) = '/'; %se sistema operativo è Linux, sostituisci i caratteri '' con '/'
    % codice per piattaforma Linux
elseif ispc
    % codice per piattaforma Windows
else
    disp('Platform not supported') %se il sistema operativo non è supportato
end
s = append(s1,s2); %concatena s1 e s2 per ottenere il percorso completo del file da salvare
save(s,'deploy_spot_comp'); %salva il file deploy_spot_comp con il nome "s"

%%SERVED UNSERVED RATIO
%Inizializzo il contatore per contare i punti di copertura
count = 1;
%Ciclo su ogni riga della matrice deploy_spot_comp
for j=1:size(deploy_spot_comp,1)
    %Ciclo su ogni colonna della matrice deploy_spot_comp
    for i=1:size(deploy_spot_comp,2)
        %Ciclo su ogni elemento della cella j,i della matrice deploy_spot_comp
        for k=1:size(deploy_spot_comp{j,i},1) %UPDATE PER FARLO FUNZIONARE
            %Se la cella non è vuota
            if ~isempty(deploy_spot_comp{j,i})
                %Salvo la posizione x e y del punto di copertura
                deploy_spot_comp_served(count,1) = deploy_spot_comp{j,i}(k,1);
                deploy_spot_comp_served(count,2) = deploy_spot_comp{j,i}(k,2);
                %Incremento il contatore
                count = count+1;
            end
        end
    end
end
%UNSERVED SPOTS
%Inizializzo la matrice per i punti non coperti
deploy_spot_unserved = [];
%Inizializzo il contatore
count = 1;
%Ciclo su ogni elemento della matrice deploy_spot_pre
for i =1:length(deploy_spot_pre)
    %se non fa parte dei punti coperti
    if ~ismember(deploy_spot_pre(i,1),deploy_spot_comp_served)
        %salvo la posizione x e y del punto non coperto
        deploy_spot_unserved(count,1) = deploy_spot_pre(i,1);
        deploy_spot_unserved(count,2) = deploy_spot_pre(i,2);
        %Incremento il contatore
        count = count+1;
    end
end
%percentuale punti non coperti
ratio_unserved = length(deploy_spot_unserved)/length(deploy_spot_pre);
%percentuale punti coperti
ratio_served = length(deploy_spot_comp_served)/length(deploy_spot_pre);
%% Beam Synthesize


% Inizializzo un array vuoto chiamato angle_3dB con dimensioni "length(BS)" righe e 3 colonne
angle_3dB{length(BS),3}=[];
% Inizializzo un array vuoto chiamato tp_ds con 1 riga e "size(deploy_spot_comp,2)" colonne
tp_ds{1,size(deploy_spot_comp,2)}=[];

% Ciclo per ogni riga di deploy_spot_comp
for j=1:size(deploy_spot_comp,1)
    % Ciclo per ogni colonna di deploy_spot_comp
    for i=1:size(deploy_spot_comp,2)
        % Ciclo per ogni elemento della cella j, i di deploy_spot_comp
        for k=1:size(deploy_spot_comp{j,i},1)
            % Imposto una variabile chiamata center con le coordinate x e y del punto j-esimo di BS
            center=[BS(j,1), BS(j,2)];
            % Imposto una variabile chiamata pos con le coordinate x e y dell'elemento k-esimo della cella j, i di spots_cat
            pos=[spots_cat{j,i}(k,1), spots_cat{j,i}(k,2)];
            % Calcolo la distanza tra pos e center
            dis=norm(pos-center);
            % Imposto una variabile rc pari alla metà della variabile accuracy
            rc=accuracy/2;

            % Calcolo i punti xout e yout che descrivono un cerchio con centro in center, raggio dis e che interseca un cerchio con centro in pos, raggio rc
            [xout,yout]=circcirc(center(1,1),center(1,2),dis,pos(1,1),pos(1,2),rc);
            % Se xout e yout sono NaN, allora calcolo nuovamente i punti xout e yout con centro spostato di 10 unità
            if isnan(xout)
                [xout,yout]=circcirc(center(1,1)-10,center(1,2),dis,pos(1,1),pos(1,2),rc);
            end
            % Imposto due punti p1 e p2 con coordinate xout e yout
            p1=[xout(1,1),yout(1,1)];
            p2=[xout(1,2),yout(1,2)];
            % Calcolo la distanza tra i punti e il centro
            dp1=norm(center-p1); dp2=norm(center-p2);
            % Calcolo la distanza tra i punti p1 e p2
            dpp=norm(p1-p2);
            % Calcolo la distanza effettiva tra i punti e il centro, considerando anche l'altezza effective_h
            dp1_eff=sqrt((dp1^2)+(effective_h^2));
            %calcola la distanza efficace tra il punto di interesse e il centro della circonferenza
            dp2_eff=sqrt((dp2^2)+(effective_h^2));

            %calcola l'angolo azimutale 3dB utilizzando l'arcocoseno e la distanza efficace calcolata sopra
            az3dB=acosd(((dp1_eff^2)+(dp2_eff^2)-(dpp^2))/(2*dp1_eff*dp2_eff));

            %se l'angolo calcolato è minore dell'angolo minimo, imposta l'angolo a quello minimo
            if az3dB < angle_min
                az3dB = angle_min;
            end

            %se gli angoli sono fissi, imposta l'angolo azimutale a quello specificato nel valore del campo di input
            if fixed_angles ==1
                az3dB=app.AzimuthBeamwidthdegEditField.Value; %Reference at the beginning of this section
            end

            %inizia il calcolo dell'angolo elevazionale 3dB
            theta = 0 : 0.01 : 2*pi;
            xc = pos(1,1) + rc * cos(theta);
            yc = pos(1,2) + rc * sin(theta);

            %calcola il punto più vicino e quello più lontano della circonferenza rispetto alla BS
            near=dis;
            far=near;
            for n=1:length(xc)
                point=[xc(1,n) yc(1,n)];
                tmp=norm(center-point);
                if tmp<near
                    near=tmp;
                    nearestp=point;
                end
                if tmp>far
                    far=tmp;
                    farthest=point;
                end
            end

            %calcola la distanza tra i due punti più lontani e più vicini
            dpp=norm(farthest-nearestp); %point-point distance

            %calcola la distanza efficace tra i punti più vicini e più lontani e l'altezza efficace
            near_eff=sqrt((near^2)+(effective_h^2)); %effective distance from center
            far_eff=sqrt((far^2)+(effective_h^2));

            %calcola l'angolo elevazionale utilizzando l'arcocoseno e le distanze efficaci calcolate sopra
            el3dB=acosd(((near_eff^2)+(far_eff^2)-(dpp^2))/(2*near_eff*far_eff));

            %se l'angolo calcolato è minore dell'angolo minimo, imposta l'angolo a quello minimo
            if el3dB < angle_min
                el3dB = angle_min;
            end
            if fixed_angles ==1 % se beamforming statico
                el3dB=app.ElevationBeamwidthdegEditField.Value; % allora prendiamo il valore dell'angolazione specificata nel campo apposito
            end

            angle_3dB{j,i}=[angle_3dB{j,i}; az3dB, el3dB]; % aggiungiamo alla matrice angle_3dB l'angolazione appena calcolata
        end
    end
end
%% Calcola SINR e tp sui deployment spots
tp_ds_unw= []; %unwrapped
for i=1:size(deploy_spot_comp,2) %Ciclo per ogni colonna di deploy_spot_comp
    for j=1:size(deploy_spot_comp,1) %Ciclo per ogni riga di deploy_spot_comp
        for k=1:size(deploy_spot_comp{j,i},1) %Ciclo per ogni elemento della cella j,i
            I_ds_co_so=[]; %Inizializzazione del vettore delle interferenze sull'elemento k
            I_ds_co_s=[]; %Inizializzazione del vettore delle interferenze sull'elemento k
            I_ds_c_s=[]; %Inizializzazione del vettore delle interferenze sull'elemento k
            pos=[deploy_spot_comp{j,i}(k,1),deploy_spot_comp{j,i}(k,2)]; %Posizione dell'elemento k

            %Definisce il pattern di radiazione dell'antenna
            A_H = evalAH(deploy_spot_comp, j, i, k, deploy_spot_comp{j,i}(k,5), angle_3dB{j,i}(k,1), Am ); %pattern di radiazione azimutale
            A_H=10*log10(A_H); %da lineare a dB
            A_V = evalAV(deploy_spot_comp, j, i, k, deploy_spot_comp{j,i}(k,4), angle_3dB{j,i}(k,2), SLAv ); %pattern di radiazione elevazione
            A_V=10*log10(A_V); %da lineare a dB
            A_tx=A_H+A_V; %pattern di radiazione complessivo in dB
            A_tx(A_tx<-Am) = -Am; %pattern di radiazione complessivo
            %calcola guadagno di beamforming
            BF = 10*log10(real(sinc(((deploy_spot_comp{j,i}(k,5)-deploy_spot_comp{j,i}(k,5))/(1.13*angle_3dB{j,i}(k,1))).^2))) +...
                10*log10(real(sinc(((deploy_spot_comp{j,i}(k,4)-deploy_spot_comp{j,i}(k,4))/(1.13*angle_3dB{j,i}(k,2))).^2)));
            BF=real(BF);
            PL_ds=deploy_spot_comp{j,i}(k,6); %Perdita di propagazione in dB
            P_s = txPowerDBm-3*log2(2)-3*log2(4); %

            rng(9);
            SF = sf_values(randi([1,1000])); % genera un valore casuale per la spreading factor SF tra 1 e 1000
            P_ds_co = P_s - PL_ds - SF + A_tx + Gtx + BF + Gbf; %calcola la potenza del segnale desiderato
            P_ds_co = 10^((P_ds_co-30)/10); %da dBm a lineare

            %calcola l'interferenza intra settore
            for m=1:size(deploy_spot_comp{j,i},1)
                if m~=k %se non siamo nel punto di trasmissione corrente
                    A_H = evalAH(deploy_spot_comp, j, i, m, deploy_spot_comp{j,i}(k,5), angle_3dB{j,i}(m,1), Am ); %pattern di radiazione azimutale
                    A_H=10*log10(A_H); %da lineare a dB
                    A_V = evalAV(deploy_spot_comp, j, i, m, deploy_spot_comp{j,i}(k,4), angle_3dB{j,i}(m,2), SLAv ); %pattern di radiazione elevazionale
                    A_V=10*log10(A_V); %da lineare a dB
                    A_tx=A_H+A_V; %pattern di radiazione complessivo in dB
                    A_tx(A_tx<-Am) = -Am; %pattern di radiazione complessivo
                    %calcola il guadagno di beamforming
                    BF = 10*log10(sinc(((deploy_spot_comp{j,i}(k,5)-deploy_spot_comp{j,i}(m,5))/(1.13*angle_3dB{j,i}(m,1))).^2)) +...
                        10*log10(sinc(((deploy_spot_comp{j,i}(k,4)-deploy_spot_comp{j,i}(m,4))/(1.13*angle_3dB{j,i}(m,2))).^2));
                    BF=real(BF);
                    P_s = txPowerDBm-3*log2(2)-3*log2(4); %calcola la potenza
                    SF = sf_values(randi([1,1000]));
                    I = P_s - PL_ds -SF + A_tx + Gtx + BF + Gbf; %interferenza intra settore
                    I = 10^((I-30)/10); %da dB a lineare
                    I_ds_co_so = [I_ds_co_so, I];
                end
            end

            % Calcola l'interferenza tra settori (nella stessa cella)
            for l = 1:size(deploy_spot_comp, 2) % poiché ci saranno sempre 3 i settori
                if l ~= i
                    for m = 1:size(deploy_spot_comp{j, l}, 1)
                        center = [BS(j, 1), BS(j, 2)]; % coordinate della BS corrente
                        steer = evalsteer(l, pos, center); % calcola steer
                        A_H = evalAH(deploy_spot_comp, j, l, m, steer, angle_3dB{j, l}(m, 1), Am); % pattern di radiazione azimutale
                        A_H = 10*log10(A_H); % da lineare a dB
                        A_V = evalAV(deploy_spot_comp, j, l, m, deploy_spot_comp{j, i}(k, 4), angle_3dB{j, l}(m, 2), SLAv); % pattern di radiazione di elevazione
                        A_V = 10*log10(A_V); % da lineare a dB
                        A_tx = A_H + A_V; % pattern di radiazione complessivo in dB
                        A_tx(A_tx < -Am) = -Am; % pattern di radiazione complessivo
                        % Calcola guadagno di formazione del fascio
                        BF = 10*log10(real(sinc(((steer-deploy_spot_comp{j, l}(m, 5))/(1.13*angle_3dB{j, l}(m, 1))).^2))) + ...
                            10*log10(real(sinc(((deploy_spot_comp{j, i}(k, 4)-deploy_spot_comp{j, l}(m, 4))/(1.13*angle_3dB{j, l}(m, 2))).^2)));
                        BF = real(BF);
                        % Calcola interferenza
                        P_s = txPowerDBm-3*log2(2)-3*log2(4);
                        SF = sf_values(randi([1, 1000]));
                        I = P_s - PL_ds - SF + A_tx + Gtx + BF + Gbf; % interferenza tra settori
                        I = 10^((I-30)/10); % da dB a lineare
                        I_ds_co_s = [I_ds_co_s, I];
                    end
                end
            end




            %cosi posso ciclare su tutte tranne la servente attuale
            cells = 1:size(deploy_spot_comp,1);
            cells(j)=[]; %svuoto la bss corrente
            other_cell = cells;



            % Calcoliamo l'interferenza tra celle
            for n=transpose(other_cell(:))
                for l=1:size(deploy_spot_comp,2)
                    for m=1:size(deploy_spot_comp{n,l},1)
                        % Coordinate della BS corrente
                        center=[BS(n,1),BS(n,2)];
                        % Distanza 2D tra il punto di deploy e la BS
                        d=norm(pos-center);
                        % Distanza efficace
                        d_eff=sqrt((effective_h)^2 + (d)^2);
                        % Angolo di inclinazione
                        tilt=atan2d(effective_h,d);
                        % Calcola l'angolo di puntamento
                        steer = evalsteer(l, pos, center);
                        % Calcola il modello di radiazione azimutale
                        A_H = evalAH(deploy_spot_comp, n, l, m, steer, angle_3dB{n,l}(m,1), Am );
                        A_H=10*log10(A_H); %da lineare a dB
                        % Calcola il modello di radiazione elevazione
                        A_V = evalAV(deploy_spot_comp, n, l, m, tilt, angle_3dB{n,l}(m,2), SLAv );
                        A_V=10*log10(A_V); %da lineare a dB
                        % Calcola il modello di radiazione complessivo in dB
                        A_tx=A_H+A_V;
                        A_tx(A_tx<-Am) = -Am; %modello di radiazione complessivo
                        % Calcola il guadagno di formazione del fascio
                        BF = 10*log10(real(sinc(((steer-deploy_spot_comp{n,l}(m,5))/(1.13*angle_3dB{n,l}(m,1))).^2))) +...
                            10*log10(real(sinc(((tilt-deploy_spot_comp{n,l}(m,4))/(1.13*angle_3dB{n,l}(m,2))).^2)));
                        BF=real(BF);

                        if Scenario == 0
                            %Calcola la perdita di percorso in LOS
                            PL_ext = 28.0+ 22*log10(d_eff) + 20*log10(fq) ; %Path loss LOS dB , 3GPP TR 38.901 version 17.0.0 Release
                            SF_std = 4;
                            %se l'opzione NLOS è attiva
                            if NLOS_on==1
                                %calcola la perdita di percorso NLOS
                                PL_nlos_ext= 13.54 + 39.08*log10(d_eff)+20*log10(fq)-0.6*(UE_h-1.5);
                                %sceglie la perdita di percorso più grande tra LOS e NLOS
                                PL=max(PL_nlos_ext,PL_ext);
                                SF_std = 6;
                            end
                        else
                            %Calcola la perdita di percorso in LOS
                            PL_ext = 32.4+ 21*log10(d_eff) + 20*log10(fq) ; %Path loss LOS dB , 3GPP TR 38.901 version 17.0.0 Release
                            SF_std = 4;
                            %se l'opzione NLOS è attiva
                            if NLOS_on==1
                                %calcola la perdita di percorso NLOS
                                PL_nlos_ext= 35.03*log10(d_eff)+22.4+21.3*log10(fq)-0.3*(UE_h-1.5);
                                %sceglie la perdita di percorso più grande tra LOS e NLOS
                                PL=max(PL_nlos_ext,PL_ext);
                                SF_std = 7.82;
                            end
                        end

                        %calcola l'interferenza
                        P_s = txPowerDBm-3*log2(2)-3*log2(4); %
                        SF = sf_values(randi([1,1000]));
                        I = P_s - PL_ext - SF + A_tx + Gtx + BF + Gbf; % inter sector interference
                        I = 10^((I-30)/10); %da dB a lineare
                        I_ds_c_s = [I_ds_c_s, I];
                    end
                end
            end

            % Calcolo del SINR
            if int_intrasec==1
                SINR = P_ds_co / (sum(I_ds_co_so)+sum(I_ds_co_s)+sum(I_ds_c_s)+rxNoisePower);
                %
            else

                SINR = P_ds_co /(sum(I_ds_co_s)+rxNoisePower);
            end
            instant_ach_rate = real(log2(1+(SINR))); %
            tp_ds{j,i}(k)=M*bw*instant_ach_rate; % throughput computed over deployment spot
            tp_ds_unw(end+1)=tp_ds{j,i}(k); % unwrapped version to extract the average throughput
        end
    end
end
avg_tp=mean(tp_ds_unw,'omitnan');%  throughput medio
net_tp = sum(tp_ds_unw,'omitnan');% throughput totale


%% CALCOLO CAMPO ELETTRICO

% Inizializzazione del contatore per il numero di punti di misura
numb_ms=0;

% Calcolo del numero totale di punti di misura considerando tutte le stazioni base e i settori
for j = 1:length(BS)
    for i=1:size(measure_spot,2)
        numb_ms=numb_ms+size(measure_spot{j,i},1);
    end
end

% Inizializzazione delle variabili per la memorizzazione dei contributi di ogni punto di misura, dei valori di campo elettrico e dei dati relativi ai punti di misura
Seq_ms{1,numb_ms}=[]; %un contributo ogni measure spot
emf_ms=[];
data_ms=[];
data_ms_cat = cell(1,length(BS));
ms_unwp{1,numb_ms} =[]; %measure spots unwrapped
indx = 0;

% Calcolo dei valori di campo elettrico su ogni punto di misura e memorizzazione dei relativi dati
for j= 1:length(BS)
    for i=1:size(measure_spot,2) %settori
        for k=1:length(measure_spot{j,i})
            pos=[measure_spot{j,i}(k,1),measure_spot{j,i}(k,2)];
            indx = indx+1;
            ms_unwp{1,indx}=pos;
            data_ms =[data_ms; [measure_spot{j,i}(k,1),measure_spot{j,i}(k,2),j]];
            data_ms_cat{j} = [data_ms];
        end
    end
    data_ms = [];
end

% Concatenazione dei dati relativi ai punti di misura di tutte le stazioni base
data_ms = [vertcat(data_ms_cat{:})];

% Non utilizzare il beamforming, utilizzare la modalità punto-sorgente dell'ITU: il gNB viene ridotto a una stazione base omnidirezionale che emette sempre a txPower
if beamforming == 0
    EIRP = txPower*G;
    for l=1:length(BS) %ciclo per ogni BS
        for m = 1:numb_ms %ciclo per ogni measure spot
            center=[BS(l,1),BS(l,2)]; %coordinate del centro del BS
            pos=[ms_unwp{1,m}(1), ms_unwp{1,m}(2)]; %coordinate del measure spot
            dist_ms=norm(pos-center); %calcolo della distanza tra il measure spot e il centro del BS
            dist_eff=sqrt((dist_ms)^2+(effective_h)^2); %calcolo della distanza effettiva considerando l'altezza del BS
            Seq=(EIRP/(4*pi*(dist_eff)^2)); %calcolo del valore di Seq
            Seq_ms{m}=[Seq_ms{m}; Seq]; %aggiunta del valore di Seq al measure spot
        end
    end
else
    %Caso beamforming abilitato
    for l=1:length(BS) %ciclo che scorre tutte le stazioni base
        for m = 1:numb_ms %ciclo che scorre tutti i dispositivi mobili
            center=[BS(l,1),BS(l,2)]; %coordinate del centro della stazione base
            pos=[ms_unwp{1,m}(1), ms_unwp{1,m}(2)]; %coordinate del dispositivo mobile
            dist_ms=norm(pos-center); %calcolo della distanza tra il dispositivo mobile e la stazione base
            dist_eff=sqrt((dist_ms)^2+(effective_h)^2); %calcolo della distanza effettiva considerando anche l'altezza effettiva
            tilt_ms=atan2d(effective_h,dist_ms); %calcola l'angolo di inclinazione

            if Scenario == 0  %Scenario 0
                PL_ms = 28.0+ 22*log10(dist_eff) + 20*log10(fq) ; %Path loss LOS dB , 3GPP TR 38.901 version 17.0.0 Release 17
                SF_std = 4;

                if NLOS_on==1 %se NLOS_on è attivo, applica il modello NLOS
                    PL_nlos_ms= 13.54 + 39.08*log10(dist_eff)+20*log10(fq)-0.6*(UE_h-1.5);
                    PL_ms=max(PL_nlos_ms,PL_ms);
                    SF_std = 6;
                end
            else %Scenario diverso dallo 0
                PL_ms = 32.4+ 21*log10(dist_eff) + 20*log10(fq) ; %Path loss LOS dB , 3GPP TR 38.901 version 17.0.0 Release 17
                SF_std = 4;
                if NLOS_on==1 %se NLOS_on è attivo, applica il modello NLOS
                    PL_nlos_ms= 35.3*log10(dist_eff)+22.4+21.3*log10(fq)-0.3*(UE_h-1.5);
                    PL_ms=max(PL_nlos_ms,PL_ms);
                    SF_std = 7.82;
                end
            end




            j=l;
            %ciclo su tutte le posizioni di misura
            for sec=1:size(measure_spot,2)
                %calcola la direzione di puntamento
                steer = evalsteer(sec, pos, center);

                %ciclo su tutte le posizioni di deploy
                for ds=1:size(deploy_spot_comp{j,sec},1)
                    %calcola il guadagno del pattern di radiazione in orizzontale
                    A_H = evalAH(deploy_spot_comp, j, sec, ds, steer, angle_3dB{j,sec}(1,1), Am );
                    A_H=10*log10(A_H); %da lineare a dB
                    %calcola il guadagno del pattern di radiazione in verticale
                    A_V = evalAV(deploy_spot_comp, j, sec, ds, tilt_ms, angle_3dB{j,sec}(1,2), SLAv );
                    A_V=10*log10(A_V); %da lineare a dB
                    A_tx=A_H+A_V; %guadagno complessivo del pattern di radiazione in dB
                    A_tx(A_tx<-Am) = -Am; %guadagno complessivo del pattern di radiazione
                    %calcola il guadagno del beamforming
                    BF = 10*log10(real(sinc(((steer-deploy_spot_comp{j,sec}(ds,5))/(1.13*angle_3dB{j,sec}(ds,1))).^2))) +...
                        10*log10(real(sinc(((tilt_ms-deploy_spot_comp{j,sec}(ds,4))/(1.13*angle_3dB{j,sec}(ds,2))).^2)));
                    BF=real(BF);
                    %calcola la potenza ricevuta
                    P_s = txPowerDBm-10*log10(8); %
                    SF = sf_values(randi([1,1000]));
                    P_r = P_s - PL_ms - SF + A_tx + BF + Gtx + Gbf;
                    P_r= 10^((P_r-30)/10); %da dBm a potenza in watt
                    Seq=P_r/((lambda^2)/4*pi); %AH e AV non li possiamo toccare altrimenti no beamforming
                    %aggiungi la potenza ricevuta alla lista delle potenze ricevute del mobile station
                    Seq_ms{m}=[Seq_ms{m}; Seq];
                end
            end

        end
    end
end

% Inizializzazione di una variabile vuota per la somma delle sequenze
Seq_sum=[];

% Calcolo della lunghezza della variabile Seq_ms
variable_len=size(Seq_ms,2);

% Inizializzazione del contatore per il ciclo while
i=1;

% Ciclo while per sommare le sequenze di ogni elemento di Seq_ms
while i<=variable_len
    % Somma della sequenza corrente con le sequenze già sommate
    Seq_sum=[Seq_sum sum(Seq_ms{1,i})];
    % Calcolo del valore EMF come quarta colonna del vettore data_ms
    data_ms(i,4) =sqrt(sum(Seq_ms{1,i})*Z0);
    % Incremento del contatore
    i=i+1;
end

% Ciclo for per assegnare i valori EMF al vettore data_ms_cat
for j =1:length(BS)
    % Trovare gli indici delle righe con colonna 3 uguale a j
    indici =find(data_ms(:,3)==j);
    % Creazione di una variabile temporanea con i valori di EMF per le righe trovate
    temp =data_ms(indici,4);
    % Assegnazione dei valori EMF alla quarta colonna di data_ms_cat per i corrispondenti elementi
    for i = 1:length(data_ms_cat{j})
        data_ms_cat{1,j}(i,4) =temp(i);
    end
end


% Calcola il campo elettrico [V/m]
E=sqrt(Seq_sum*Z0);

% Calcola il campo elettrico medio (Da rimpiazzare con totale)
avg_emf=mean(E,'omitnan');

% Calcola il campo elettrico totale della rete
net_emf= sum(E,'omitnan');

% Imposta la directory corrente come s1
s1 = pwd;

% Imposta la directory dei dati di emf come s2
s2 = '\Data\emf';

% Verifica su quale piattaforma è in esecuzione il codice e modifica s2 di conseguenza
if ismac
    s2(strfind(s2,'\')) = '/';
    % Codice per piattaforma Mac
elseif isunix
    s2(strfind(s2,'\')) = '/';
    % Codice per piattaforma Linux
elseif ispc
    % Codice per piattaforma Windows
else
    disp('Platform not supported')
end

% Concatena s1 e s2 per ottenere la directory completa
s = append(s1,s2);

% Crea un nome di file unendo la directory e la precisione dei dati
fname=join([s,num2str(accuracy),'.mat']);

% Salva i dati di avg_emf e E nel file
save(fname,'avg_emf','E');

% Imposta la directory corrente come s1
s1 = pwd;

% Imposta la directory cache per l'angolo 3dB come s2
s2 = '\cache\angle_3dB';

% Verifica su quale piattaforma è in esecuzione il codice e modifica s2 di conseguenza
if ismac
    s2(strfind(s2,'\')) = '/';
    % Codice per piattaforma Mac
elseif isunix
    s2(strfind(s2,'\')) = '/';
    % Codice per piattaforma Linux
elseif ispc
    % Codice per piattaforma Windows
else
    disp('Platform not supported')
end

% Concatena s1 e s2 per ottenere la directory completa
s = append(s1,s2);

% Salva i dati di angle_3dB nella directory specificata
save(s, 'angle_3dB');

% Imposta la directory corrente come s1
s1 = pwd;

% Imposta la directory cache per i dati di emf come s2
s2 = '\cache\emf_data';

% Verifica su quale piattaforma è in esecuzione il codice e modifica s2 di conseguenza
if ismac
    s2(strfind(s2,'\')) = '/';
    % Codice per piattaforma Mac
elseif ispc
    % Codice per piattaforma Windows
else
    disp('Platform not supported')
end

% Concatena s1 e s2 per ottenere la directory completa
s = append(s1,s2);
% Salva i dati di data_ms nella directory specificata
save(s,'data_ms');

% Salvataggio dei termini di normalizzazione
if mobj_calibration == 1
    % Carica il file di normalizzazione "curr_max_gNB_num.mat"
    load cache\Normalization\curr_max_gNB_num.mat

    % Calcola cmax come prodotto di curr_max_gNB_num e c_eq
    cmax = curr_max_gNB_num * c_eq;

    % Se max_tp_emf_cal è uguale a 0
    if max_tp_emf_cal == 0
        % Assegna tot_emf a net_emf
        tot_emf = net_emf;
        % Definizione della directory corrente
        s1 = pwd;
        % Definizione della directory di salvataggio
        s2 = '\cache\Normalization\f3_normalization';
        % Verifica la piattaforma utilizzata
        if ismac
            % Sostituisci il carattere di escape con / per Mac
            s2(strfind(s2,'\')) = '/';
        elseif isunix
            % Sostituisci il carattere di escape con / per Linux
            s2(strfind(s2,'\')) = '/';
        elseif ispc
            % Utilizza il carattere di escape per Windows
        else
            disp('Platform not supported')
        end
        % Concatena s1 e s2 per ottenere la directory completa
        s = append(s1,s2);
        % Salva tot_emf nella directory specificata
        save(s,'tot_emf');
    else
        % Altrimenti, assegna tp_max a net_tp
        tp_max= net_tp;
        % Definizione della directory corrente
        s1 = pwd;
        % Definizione della directory di salvataggio
        s2 = '\cache\Normalization\f2_normalization';
        % Verifica la piattaforma utilizzata
        if ismac
            % Sostituisci il carattere di escape con / per Mac
            s2(strfind(s2,'\')) = '/';
        elseif isunix
            % Sostituisci il carattere di escape con / per Linux
            s2(strfind(s2,'\')) = '/';
        elseif ispc
            % Utilizza il carattere di escape per Windows
        else
            disp('Platform not supported')
        end
        % Concatena s1 e s2 per ottenere la directory completa
        s = append(s1,s2);
        % Salva tp_max nella directory specificata
        save(s,'tp_max');

        % Crea una stringa per il percorso del file da salvare
        s1 = pwd; % Recupera il percorso corrente
        s2 = '\cache\Normalization\f1_normalization'; % Specifica la cartella di destinazione e il nome del file

        % Controlla la piattaforma in uso e sostituisce il separatore di cartelle '\' con '/' se necessario
        if ismac
            s2(strfind(s2,'\')) = '/'; % Codice da eseguire su piattaforma Mac
        elseif isunix
            s2(strfind(s2,'\')) = '/'; % Codice da eseguire su piattaforma Linux
        elseif ispc
            % Codice da eseguire su piattaforma Windows
        else
            disp('Platform not supported') % Se la piattaforma non viene riconosciuta
        end

        % Concatena s1 e s2 per ottenere il percorso completo
        s = append(s1,s2);

        % Salva il contenuto di cmax nel file specificato dalla stringa s
        save(s,'cmax');
    end

end

%% Valore della funzione multi-obiettivo

if mobj_calibration == 0
    % Caricamento dei termini di normalizzazione
    load cache\Normalization\curr_max_gNB_num.mat
    load cache\Normalization\f1_normalization.mat
    load cache\Normalization\f2_normalization.mat
    load cache\Normalization\f3_normalization.mat
    % Calcola il costo massimo
    c_max = cmax;
    % Numero di BSS (il numero dovrebbe essere adattativo in base al caso d'uso)
    N_bss = numerosity; 
    % Calcola il costo totale
    c_tot = N_bss *c_eq; 
    % Calcola il valore della fitness function dei costi
    f_1 = real(1-(c_tot)/c_max); 
    % Calcola il valore della fitness function del throughput
    f_2 = real((net_tp)/tp_max); 
    % Calcola il valore della fitness function del campo elettrico
    f_3 = real(1-(net_emf)/tot_emf); %net emf
    % Calcola il valore della funzione multi-obiettivo
    m_obj_sol2 = alpha*f_1 + beta*f_2 + gamma*f_3;


end
