%% phase lag index (pli) and weighted phase lag index (wpli)

function [pli, wpli] = pli(roidata, nrois)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    phase = angle(analytic); % signal phase

    pli = zeros(nrois, nrois); % phase lag index
    wpli = zeros(nrois, nrois); % weighted phase lag index
    for i = 1:nrois
        phase_diff = bsxfun(@minus, phase, phase(:,i));
        P = bsxfun(@times, analytic, conj(analytic(:,i))); % cross-spectrum = a1.*a2.*exp(1i*phase_diff)

        pli(:,i) = abs(mean(sign(phase_diff),1)); 
        wpli(:,i) = abs(mean(imag(P),1)) ./ mean(abs(imag(P)),1); % eq. 14 from Palva et al. (2018)
    end

end