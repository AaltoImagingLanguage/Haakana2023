%% symmetric orthogonalization of AEC (see Colclough et al. 2015)

function aec_ortho_sym = aec_ortho_sym(roidata, nrois)

   Z = roidata; 
   D = eye(nrois);    
   niter = 20;
   for i = 1:niter
        [U, ~, V] = svd(Z*D, 'econ'); % (eq. 4)
        O = U*transpose(V); % (eq. 6)
        d = diag(transpose(Z)*O); % (eq. 8)
        D = diag(d);
        P = O*D; % unique closest orthonormal matrix of Z, i.e. corrected timecourse (eq. 2)
        %err = norm(Z-P,'fro'); % Frobenius norm (eq. 1)
        %fprintf(sprintf("Frobenius norm=%d (%d/%d)\n", err, i, niter));
   end
   orthogonalized_megdata = P;

   analytic_ortho_sym = hilbert(orthogonalized_megdata);
   amplitude_ortho_sym = abs(analytic_ortho_sym);
   aec_ortho_sym = corr(amplitude_ortho_sym);
        
end