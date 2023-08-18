%% phase locking value (PLV) and imaginary phase locking value (iPLV)

function [plv, iplv] = plv(roidata, nrois)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    phase = angle(analytic); % signal phase

    plv = zeros(nrois, nrois); % phase locking value
    iplv = zeros(nrois, nrois); % imaginary phase locking value
    for i = 1:nrois
        phase_diff = bsxfun(@minus, phase, phase(:,i));
        plv_temp = mean(exp(1i*phase_diff),1);
        plv(:,i) = abs(plv_temp); 
        iplv(:,i) = abs(imag(plv_temp)); 
    end

end