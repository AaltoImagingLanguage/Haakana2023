function megdata_filt = apply_filter(megdata, fbandname, fbp, fs)

    fprintf(sprintf("Filtering to %s band...\n", fbandname));

    fn = fs/2; % nyquist frequency

    % determine filter order based on frequency band
    order = 3*fix(fs / fbp(1));
    b = fir1(order, [min(fbp)/fn max(fbp)/fn]);
    a = 1;

    megdata_filt = filtfilt(b, a, megdata);

    fprintf("Filtering finished.\n");
        
end