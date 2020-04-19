%filtro notch selettivo, inputs: x,fs,f_rumore
function x_f=f_notch_sel(x,fs,f_rumore)

%% progettazione filtro:
%come prima ma ora i poli!=0, avranno modulo quasi unitario
%e la stessa fase degli zeri.
f_norm=f_rumore/(fs/2);

%zero_1=pol2cart(f_norm*pi,1);
%zero_2=pol2cart(-f_norm*pi,1);
%zero_2=zero_1';

%polo_1=pol2cart(f_norm*pi,0.95); %meglio non troppo selettivo per diversi motivi
%polo_2=pol2cart(-f_norm*pi,0.95);
%polo_2=polo_1';

%H(Z)=[(zero_1-z)*(zero_2-z)]/[(polo_1-z)*(polo_2-z)]
%H(Z)=[(zero_1*zero_1')-2*cos(f_norm*pi)*z+z^2]/(polo_1*....]
%H(Z)=   [1*z^-2          -2*cos(f_norm*pi)* z^-1         + 1 ]/
%       [0.95^2*z^-2      -2*0.95*cos(f_norm*pi)*z^-1     + 1 ]

b=[1 -2*cos(f_norm*pi)  1];
a=[1 -2*0.99*cos(f_norm*pi)  0.99^2];

%% G unitario:
if f_norm>1/2
   Gmax=sum(b)/sum(a);    %come filtro passa basso
else
    b_pi=b;              
    b_pi(2:2:end)=b_pi(2:2:end)*(-1);
    a_pi=a;
    a_pi(2:2:end)=a_pi(2:2:end)*(-1);
    Gmax=sum(b_pi)/sum(a_pi);
end
b=b/Gmax;

%% filtro:
% figure('Name','poli e zeri notch selett')
% zplane(b,a)
% figure('Name','risp freq notch selett')
% freqz(b,a)

%% applicazione filtro:
%x=load('ecg2x60.dat','-ascii');
x_f=filter(b,a,x);

% figure('Name','notch selettivo applicato')
% subplot(2,2,1)
% plot(x,'r')
% hold on
% plot(x_f,'b')
% grid on
% subplot(2,2,3)
% plot(x_f,'b')
% grid on
% subplot(2,2,2)
% X=fftshift(abs(fft(x)))/length(x);
% f=((0:length(x)-1)-floor(length(x)/2))*fs/length(x);
% plot(f,X,'r')
% subplot(2,2,4)
% X_f=fftshift(abs(fft(x_f)))/length(x);
% plot(f,X_f,'b')
return

