function conn = compute_connectivity(method, roidata, nrois, fs)
    
    addpath 'connectivity_metrics';

    if method == "aec"
        conn = aec(roidata);
    elseif method == "plv"
        [conn, ~] = plv(roidata, nrois); 
    elseif method == "iplv"
        [~, conn] = plv(roidata, nrois); 
    elseif method == "coh"
        [conn, ~] = coh(roidata, nrois); 
    elseif method == "icoh"
        [~, conn] = coh(roidata, nrois); 
    elseif method == "pli"
        [conn, ~] = pli(roidata, nrois); 
    elseif method == "wpli"
        [~, conn] = pli(roidata, nrois); 
    elseif method == "aec_ortho_pair"
        conn = aec_ortho_pair(roidata, nrois); 
    elseif method == "aec_ortho_sym"
        conn = aec_ortho_sym(roidata, nrois); 
    elseif method == "plm"
        conn = plm(roidata, nrois, fs); 
    end
    

end