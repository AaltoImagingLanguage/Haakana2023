%% coherence (coh) and imaginary coherence (icoh)

function [coh, icoh] = coh(roidata, nrois)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    amplitude = abs(analytic); % signal amplitude

    coh = zeros(nrois, nrois); % coherence
    icoh = zeros(nrois, nrois); % imaginary coherence
    for i = 1:nrois
        a1 = amplitude;
        a2 = amplitude(:,i);
        P = bsxfun(@times, analytic, conj(analytic(:,i))); % cross-spectrum = a1.*a2.*exp(1i*phase_diff)

        coh_temp = mean(P,1) ./ sqrt(mean(a1.^2,1)*mean(a2.^2,1));
        conn.coh(:,i) = abs(coh_temp); 
        conn.icoh(:,i) = abs(imag(coh_temp)); 
    end

end