%% Phase linearity measurement (PLM) (see Baselice et al. 2019)

function plm = plm(roidata, nrois, fs)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    
    plm = zeros(nrois, nrois); % phase linearity measurement

    epsilon = 0.1; % phase threshold for leakage suppression 
    B = 1; % frequency range for integrating the energy 

    tsamples = size(analytic, 1); % number of time samples
    f = 0:fs/tsamples:fs-fs/tsamples;
    f_ids = zeros(1, tsamples);
    f_ids(abs(f) < B | abs(f-fs) < B) = 1; % set to 1 those indices which are within the frequency range 2B
    f_ids = logical(f_ids);

    for i = 1:nrois
        
        z = bsxfun(@times, analytic, conj(analytic(:,i)));  % interferometric signal (eq. 3)
        z_phase = angle(z); % phase difference of signals i and j
        z_N = exp(1i*z_phase); %  normalized interferometric signal z, i.e. = plv (eq. 12)

        % the normalized interferometric signal z_N is decomposed into a set of phasors at fixed frequencies
        % and their relative energies within band 2B are evaluated in terms of total energy to get the PLM 

        Z_N = fft(z_N); % fourier transform of z_N (eq. 13)
        
        for j = 1:nrois
            % if the phase difference of signals i and j at f=0 is below threshold epsilon,
            % the amplitude of the fourier transformed plv at f=0 is set to zero (eq. 17)
            if abs(angle(Z_N(1,j))) < epsilon
                Z_N(1,j) = 0;   
            end
        end

        S = abs(Z_N).^2; % energy spectral density (eq. 14)

        for j = 1:nrois
            plm(i, j) = (sum(S(f_ids,j)) / sum(S(:,j)));  % percentage of the spectral energy within band 2B (eq. 15)
        end

    end   


end