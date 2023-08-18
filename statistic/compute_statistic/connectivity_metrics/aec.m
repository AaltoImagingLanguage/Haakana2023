function aec = aec(roidata)

    analytic = hilbert(roidata); % analytic signal = x + i*y = amplitude*exp(i*phase)
    amplitude = abs(analytic); % signal amplitude

    aec = corr(amplitude); % amplitude envelope correlation

end