clear all
close all
clc
%% data
fs=2000; % sampling frequency
data=load ('EM_EMG_SQUEEZE1.txt','-ascii');
% plot(data(:,1))
% figure
% plot(data(:,2))
% figure
% plot(data(:,3))
x=data(:,3);

%% Spectral analysis:
X=fftshift(abs(fft(x)))/length(x);
f=((0:length(x)-1)-floor(length(x)/2))*fs/length(x);
figure('Name','Spectrum orignal signal')
plot(f,X)
% It's visible that there's noise at 60 Hz and all its armonics.

%% filtering
% Noise remotion with a notch filter.
i=60;
x_f=x;
while i<fs/2-60
    x_f=f_notch_sel(x_f,fs,i);
    i=i+60;
end

% check the filtering effect:
% X=fftshift(abs(fft(x_f)))/length(x);
% f=((0:length(x)-1)-floor(length(x)/2))*fs/length(x);
% figure('Name','spettro segnale originale')
% plot(f,X)

subplot(2,1,1)
title('non filtrato')
plot(x)
subplot(2,1,2)
plot(x_f)
title('filtrato')
hold on

%% threshold
% threshold=2*RMS(portion of noise)
% for instance a portion of noise is individuated between the samples 1.2e4 e 1.5e4
rms_value=rms(x_f(1.2e4:1.5e4,1));
threshold=2*rms_value;
yline(threshold);

%% inviluppo
% most of the techiques need the signal rectified:
x_rett=abs(x_f);

% IEMG: integrated EMG (Equivalent to applying the Average Mobile Mean, not dividing
% by N).
N=fs*0.3; % N = window of 3 seconds
b=ones(N,1);
a=1; %%
inv_IEMG=filter(b,a,x_rett);
figure('Name','inviluppi')
plot(x_rett,'k')
hold on
plot(inv_IEMG,'r')

% ARV method (Equivalent to the Average Mobile Mean application).
N=fs*0.3; % N= window of 3 seconds
b=ones(N,1);
a=N; 
inv_ARV=filter(b,a,x_rett);
hold on
plot(inv_ARV,'b')

% RMS method (equivalent to the square root of the ARV applied to the signal squared)
x_quad=x_rett.^2;
N=fs*0.3; % N= window of 3 seconds
b=ones(N,1);
a=N;
inv_partial_RMS=filter(b,a,x_quad);
inv_RMS=sqrt(inv_partial_RMS);
hold on
plot(inv_RMS,'y')
hold on



%CROSSING RATE
x_f_mod=[zeros(floor(N/2),1);x_f]; % Zero padding on the left end of the signal
%x_f_mod=[x_f;zeros(floor(N/2),1)]; 
for i=floor(N/2):length(x_f)-1
    window=x_f_mod(i-floor(N/2)+1:i+floor(N/2));
    count=0;
    for j=2:length(window)-1
        if window(j)>threshold && (window(j+1)<threshold || window(j-1)-threshold)
            count=count+1;
        end
    end
    inv_CR(i-floor(N/2)+1)=count;
    inv_CR=inv_CR';
end
inv_CR=[inv_CR;zeros(floor(N/2),1)];
plot(inv_CR,'m')
legend('segnale','inv. IEMG','inv. ARV','inv.RMS','inv.CR')


%% normalization to the range 0 - 100
% Note that ARV and IEMG after the normalization are equivalent
inv_IEMG_normalized=(inv_IEMG./max(inv_IEMG))*100;
inv_ARV_normalized=(inv_ARV./max(inv_ARV))*100;inv_RMS_normalized=(inv_RMS./max(inv_RMS))*100;
inv_CR_normalized=(inv_CR./max(inv_CR))*100;

figure('Name','inviluppi normalizzati')
plot(x_rett,'k')
hold on
plot(inv_IEMG_normalized,'r')
hold on
plot(inv_ARV_normalized,'b')
hold on
plot(inv_RMS_normalized,'y')
hold on
plot(inv_CR_normalized,'m')
legend('segnale','inv. IEMG','inv. ARV','inv.RMS','inv.CR')