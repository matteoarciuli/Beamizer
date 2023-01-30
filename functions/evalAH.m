%%A_H and A_V are computed according to
%%https://ieeexplore.ieee.org/document/7465794
function A_H = evalAH(deploy_spot_comp, cell_id, sector_id, ds, steer, az3dB, Am )
A_H = 12*(((steer-deploy_spot_comp{cell_id,sector_id}(ds,5))/az3dB).^2);  %Horizontal pattern -da steer
A_H=-(min(A_H,Am));
A_H=10^(A_H/10);
end