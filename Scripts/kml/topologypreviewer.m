%Topology Previewer

if ~isempty(app.paneltopologyplot.Children(:))
    delete(app.paneltopologyplot.Children(:))
end
[long,lat,z]=read_kml(app.KMLfileDropDown.Value); %read kml file
gx = geoaxes(app.paneltopologyplot);
app.paneltopologyplot.Children.Basemap = app.BasemapstyleButtonGroup.SelectedObject.Text;
geoscatter(gx,lat,long,"filled","^","k");

app.paneltopologyplot.Children.Title.String = "Geograpghic Topology of the selected KML file";
app.paneltopologyplot.Children.LongitudeAxis.FontWeight = "bold";
app.paneltopologyplot.Children.LatitudeAxis.FontWeight = "bold"
clear  lat long z
