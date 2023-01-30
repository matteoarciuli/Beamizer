%plot sensitivity analisys
%fopen('output.txt','w'); %cancello tutto nel file di output
%clc questo cancella tutta la command window
%diary output.txt
%diary on
%clear
clc
close all
cd ..
cd ..
cd TESTS

%cd MasterThesis
D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
figure
for k = 3:length(D) % in questo modo salto . e ..
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights

        currD = D(k).name; % Get the current subdirectory name
        cd(currD);
        disp(k-2) % decommentalo solo per capire il ciclo
        disp(currD)
        load('test.mat', 'TEST');
        k = find(TEST(:,5) == max(TEST(:,5))); %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3);

        X = ['ID:',num2str(sprintf('%3.0f',TEST(k,1))),'  GRUPPO:',num2str(sprintf('%3.0f',TEST(k,2))),'  TENTATIVO:',num2str(sprintf('%3.0f',TEST(k,3))),' AMPIEZZA-SUBSET:',num2str(sprintf('%3.0f',TEST(k,4))),'  MOBJ:', num2str(sprintf('%0.4f',TEST(k,5))),'  CURRENT-BEST:',num2str(sprintf('%0.4f',TEST(k,6))),'  f1/f2/f3:',num2str((sprintf('%0.4f',TEST(k,7)))),'/',num2str((sprintf('%0.4f',TEST(k,8))))];
        disp(X)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s) % cosi faccio il load della G.mat associata al max per il coefficente attuale
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold on
        plot(TEST(:,1),TEST(:,5)) %plot id sulle x e current best obj sulle y
        title("Andamento della funzione multiobiettivo durante il Test completo")
        xlabel('ID')
        ylabel('MOBJ-Value')


        cd ..

    end
    %cd(currD) % change the directory (then cd('..') to get back)
    %fList = dir(currD); % Get the file list in the subdirectory
end

diary off

D = dir; % A is a struct ... first elements are '.' and '..' used for navigation.
figure
for k = 3:length(D) % avoid using the first ones
    if isdir(D(k).name) % cosi salto il file output.txt e navigo solo le cartelle dei weights
        currD = D(k).name % Get the current subdirectory name
        cd(currD)
        disp(k-2) % decommentalo solo per capire il ciclo
        load('test.mat', 'TEST')
        k = find(TEST(:,5) == max(TEST(:,5))) %restituisce la riga della matrice di test con la funzione multiobiettivo migliore
        key = TEST(k,3)
        s1 = 'G';
        s2 = num2str(TEST(k,2));
        s3 = '.mat';
        s= append(s1,s2,s3);
        load(s)
        % Run your function. Note, I am not sure on how your function is written,
        % but you may need some of the following
        n_dep =key;

        hold on
        plot(TEST(:,1),TEST(:,6))
        title("Progressione del current best objective, con plateau. rappr dynamics")
        xlabel('ID')
        ylabel('CURRENT BEST MOBJ-Value')
        cd ..
    end
end



