% this script lets you import the kml file with a list of bss location
clf
%close all
%clear
%import Spinaceto file

[long,lat,z]=read_kml('SRB_Simulazioni_Spinaceto.kml');
%import Navona file
%[long,lat,z]=read_kml('Navona.kml');

%find the center (reference point origin)
long_c = mean(long);
lat_c = mean(lat);
%plot the scenario
p=scatter(long,lat);
p.Marker= 's';
hold on 
c = scatter(long_c,lat_c);
title("Scatter plot latitudine e longitudine di ogni gNB")
c.Marker = 'x';
hold off
%find the relative positions wrt the centroid (ref.point)

%altezza media a Roma 
alt = 21;
origin = [lat_c, long_c, alt];

%ottenimento delle coordinate 
[xEast,yNorth] = latlon2local(lat,long,alt,origin);
%to revert the operation 
[r_lat,r_lon] = local2latlon(xEast,yNorth,alt,origin);
% is totally revertible the operation

figure

geoscatter(lat,long);
title("Rappresentazione topologia importata da file .kml su GeoScatter")
hold on 
geoscatter(lat_c,long_c);
hold off 
figure
converted = scatter(xEast,yNorth);
title("Rappresentazione topologia post conversione, in metri East North utm WGS-84")



