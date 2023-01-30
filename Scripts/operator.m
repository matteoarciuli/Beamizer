%% Modulo operator

% controlla se è stato importato un file kml
if kml_import == 1
    % imposta il seed per la generazione random
    rng(1);

    % genera 75 punti random tra x = [1, 1800] e y = [1, 1800]
    x = 1 + (1800-1) .* rand(75, 1)-900;
    y = 1 + (1800-1) .* rand(75, 1)-900;

    % imposta la distanza minima consentita
    minAllowableDistance = 130;
    % imposta il numero massimo di punti generabili
    numberOfPoints = 75;
    % inizializza le variabili per tenere traccia dei punti
    keeperX = x(1);
    keeperY = y(1);
    counter = 2;
    % Per ogni punto dal 2 al numero massimo di punti
    for k = 2 : numberOfPoints
        % Ottieni un punto sperimentale.
        thisX = x(k);
        thisY = y(k);
        % Guarda quanto è lontano da punti esistenti.
        distances = sqrt((thisX-keeperX).^2 + (thisY - keeperY).^2);
        minDistance = min(distances);
        % Se la distanza minima è maggiore della distanza consentita, lo salva
        if minDistance >= minAllowableDistance
            keeperX(counter) = thisX;
            keeperY(counter) = thisY;
            counter = counter + 1;
        end
    end

    %assegnamento dei candidati a possibili siti
    bss_candidate = zeros(length(keeperX),2);
    for k = 1 :length(keeperX)
        ss_candidate(k,1) =keeperX(k);
        ss_candidate(k,2) =keeperY(k);
    end

    %coordinate dei siti permessi
    allowed_sites_X = keeperX;
    allowed_sites_Y = keeperY;
else

    % Legge il file kml
    [long,lat,z]=read_kml(app.KMLfileDropDown.Value);

    % Trova il centro (punto di riferimento originale) dei dati kml
    long_c = mean(long);
    lat_c = mean(lat);

    % Imposta l'altitudine sopra il livello medio del mare
    alt = 21;

    % Centro della topologia importata
    origin = [lat_c, long_c, alt];

    % Converte le coordinate da latitudine e longitudine a est-nord (utm WGS-84)
    [xEast,yNorth] = latlon2local(lat,long,alt,origin);

    % Memorizza le coordinate convertite nella variabile bss_candidate
    bss_candidate = [xEast,yNorth];

    % Trasponi le variabili xEast e yNorth e memorizzale in allowed_sites_X e allowed_sites_Y
    allowed_sites_X = transpose(xEast);
    allowed_sites_Y = transpose(yNorth);
end
% Salva il numero massimo di spot gNB consentiti
curr_max_gNB_num = length(allowed_sites_X);

% Carica il layout (BS, cell, settori)
save('toload/layout.mat');

% Salva la variabile curr_max_gNB_num
save('cache/Normalization/curr_max_gNB_num.mat',"curr_max_gNB_num")

% Salva le variabili allowed_sites_X, allowed_sites_Y, bss_candidate e curr_max_gNB_num
save('toload/a_s_operator.mat','allowed_sites_X', 'allowed_sites_Y','bss_candidate',"curr_max_gNB_num");