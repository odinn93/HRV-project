function Hd = IIRnotch
%IIRNOTCH Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 9.6 and Signal Processing Toolbox 8.2.
% Generated on: 19-Nov-2020 18:23:52

% Butterworth Bandstop filter designed using FDESIGN.BANDSTOP.

% All frequency values are in Hz.
Fs = 200;  % Sampling Frequency

Fpass1 = 48.5;        % First Passband Frequency
Fstop1 = 49.5;        % First Stopband Frequency
Fstop2 = 50.5;        % Second Stopband Frequency
Fpass2 = 51.5;        % Second Passband Frequency
Apass1 = 1;           % First Passband Ripple (dB)
Astop  = 40;          % Stopband Attenuation (dB)
Apass2 = 1;           % Second Passband Ripple (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
                      Apass2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);

% [EOF]
