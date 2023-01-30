%evalsteer computes steer angle which is the angle computed w.r.t. sector bisector
%sector 1 -> bisector=90°, sector 2 -> bisector = 210°, sector 3 -> bisector=330°
function steer = evalsteer(sector_id, pos, center)
sign=0;
%Compute the angle of the spot characterized by coordinates in "pos" vector
%in a cartesian coordinate system centered in the base station
%characterized by coordinates in "center" vector
angle = atan2d(pos(1,2)-center(1,2), pos(1,1)-center(1,1));

%Report the angle in a positive 0-360° notation
if angle<0
    angle= 360+angle;
    sign=1;
end

if sector_id ==1
    if  angle> 270 && sign==1
        angle = angle - 360;
    end
    steer= 90-angle;
elseif sector_id ==2
    if  angle < 30
        angle = 360 + angle;
    end
    steer = 210-angle;
elseif sector_id ==3
    if  angle < 150 && sign==0
        angle=360+angle;
    end
    steer = 330-angle;
end
end
