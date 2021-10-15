classdef EventOptions
    properties
        % refer to V2E Paper: "v2e: From Video Frames to Realistic DVS Events"
        InputPath {mustBeText} = "" % path to input video.
        FPS {mustBeReal, mustBePositive} = 960 % (FPS) original FPS of video, not the FPS while playing it.
        LinLogCutoff {mustBeReal} = 20 % (DP) cutoff point for lin-log mapping.; , mustBeNonnegative, mustBeLessThanOrEqual(LinLogCutoff, 255)
        ThetaMean {mustBeReal} = 0.3 % (Log Luma) average theta magnitude for On and Off thresholds over log luma across al pixels. |theta_nominal| in Sec. 4F.; , mustBeNonnegative
        ThetaStd {mustBeReal} = 0.03 % (Log Luma) standard deviation of theta across all pixels. sigma_theta in Sec. 4F.; , mustBeNonnegative
        ThetaMin {mustBeReal} = 0.01 % (Log Luma) minimum theta magnitude across all pixels.; , mustBeNonnegative
        ShotNoiseRate {mustBeReal} = 1 % (Hz) Noise Event Rate R_n in Sec. 4G.; , mustBeNonnegative
        ShotNoiseReduction {mustBeReal} = 0.25 % Arbitrary scaler c in Sec. 4G. Reduces shot noise by this amount at white. If black, no reduction occurs. , mustBePositive, mustBeLessThan(ShotNoiseReduction, 1)
        LeakNoiseRate {mustBeReal} = 0.1 % (Hz) Leak noise rate f_leak over C2 junction in Eqn (11) of "Temperature and Parasitic Photocurrent Effects in Dynamic Vision Sensors", but applied to mem instead. , mustBeNonnegative
        LPFMaxCutoff {mustBeReal} = 200 % (Hz) 0 for no low pass effect. -3dB cutoff frequency of passive (inf. impulse) LPF at white pixels. f_3dBmax in 4E.; , mustBeNonnegative
        LPFMinCutoffFraction {mustBeReal} = 0.1 % -3dB cutoff frequency of LPF at black pixels as a factor of LPFCutoff; , mustBePositive, mustBeLessThanOrEqual(LPFMinCutoffFraction, 1)
        Noisy {mustBeNumericOrLogical} = true % set false to ignore theta std, theta min, shot noise, leak noise and LPFs
    end
end