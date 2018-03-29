% High Pass Filter for EEG
Fstop = .5;         % Stopband Frequency
Fpass = 3;           % Passband Frequency
Astop = 60;          % Stopband Attenuation (dB)
Apass = 1;           % Passband Ripple (dB)
match = 'passband';  % Band to match exactly
h_hp  = fdesign.highpass(Fstop, Fpass, Astop, Apass, 2048);
Hd_hp = design(h_hp, 'cheby2', 'MatchExactly', match);
%fvtool(Hd_hp)

% Low Pass Filter for EEG
Fpass = 50;          % Passband Frequency
Fstop = 55;          % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 60;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly
h_lp  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, freq_eeg);
Hd_lp = design(h_lp, 'cheby2', 'MatchExactly', match);
%fvtool(Hd_lp)

% Low Pass Filter for pupil data
Fpass = 3;          % Passband Frequency
Fstop = 6;          % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 60;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly
h_lp_pupil  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, freq_eye);
Hd_lp_pupil = design(h_lp_pupil, 'cheby2', 'MatchExactly', match);
%fvtool(Hd_lp_pupil)