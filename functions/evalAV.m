%%A_H and A_V are computed according to
%%https://ieeexplore.ieee.org/document/7465794
function A_V = evalAV(deploy_spot_comp, cell_id, sector_id, ds, tilt_ms, el3dB, SLAv )
A_V = 12*(((tilt_ms-deploy_spot_comp{cell_id,sector_id}(ds,4))/el3dB).^2); %vertical pattern -da tilt
A_V=-(min(A_V,SLAv)); %saturated at maximum attenuation
A_V=10^(A_V/10);
end
