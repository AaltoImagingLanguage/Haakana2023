%% pairwise orthogonalization of AEC (see Brookes et al. 2012)

function aec_ortho_pair = aec_ortho_pair(roidata, nrois)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    amplitude = abs(analytic); % signal amplitude

    aec_ortho_pair = zeros(nrois, nrois); 
    for i = 1:nrois
        y = roidata(:, i);
        for j = 1:nrois
            x = roidata(:, j);
            if i ~= j
                x_pinv = pinv(x); % pseudo-inverse of x
                beta_uv = real(x_pinv*y); % a univariate projection of signal x on signal y (eq. 3)
                y_r = y - x*beta_uv; % orthogonalized signal y (eq. 4)

                analytic_y_ortho = hilbert(y_r); 
                amplitude_y_ortho = abs(analytic_y_ortho); % amplitude envelope of orthogonalized signal y
 
                aec_ortho_pair(i, j) = corr(amplitude_y_ortho, amplitude(:, j));
            end
        end
    end
   aec_ortho_pair_ave = (aec_ortho_pair + aec_ortho_pair') ./ 2; % average between directions (s1->s2, s2->s1) 
   aec_ortho_pair = aec_ortho_pair_ave; % pairwise orthogonalized amplitude envelope correlation 

end