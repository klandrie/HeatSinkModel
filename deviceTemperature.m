% The following function predicts the temperature
% of a finned array as a function of heat dissapation
% for a constant air speed.

% Parameter Description                         Units
% q         Heat dissipation                    W
% Tmax      Maximum allowable temperature       K
% T         Temperature of electical device     K
% Tair      Temperature of surrounding air      K
% h         Convection coefficient              W/(Km^2)

% Square Base Plate Parameters:
% k         conduction coefficient              W/mK
% t         Thickness                           m   
% w         Width                               m

% Fins
% N         Number of Fins
% D         Diameter                            m
% L         Length                              m

% Resistances Unit: K/W
% Rtc1      Contact resistance between base plate 
%           and electronic device
% Rtc2      Contact resistance between N fins and 
%           base plate
% Rbcond    Conduction resistance of  base plate
% Rbconv    Convection Resistance of base plate
% Rf        Resistance of N fins 
% Ro        Resistance of finned array
% RT        Total resistance of thermal circuit

function T = deviceTemperature(q, airSpeedMetersPerSecond, TairC, plateString)
    Tmax = convtemp(60, 'C', 'K');
    Tair = convtemp(TairC, 'C', 'K');

    % Read Finned Array Parameters from File
    % File Format: N	D(in)	L(in)	w(in) 	t(in) 	k(W/mk)	Rtc1''(m^2K/W)	Rtc2''(m^2k/W)
    finnedArrayParameters = importdata(plateString);

    %Fin Parameters
    N = finnedArrayParameters.data(1);
    D = convlength(finnedArrayParameters.data(2), 'in', 'm'); 
    L = convlength(finnedArrayParameters.data(3), 'in', 'm');

    % Base Plate Parameters
    w = convlength(finnedArrayParameters.data(4), 'in', 'm');
    t = convlength(finnedArrayParameters.data(5), 'in', 'm');
    k = finnedArrayParameters.data(6);

    %Areas
    A = w^2;
    Ac = pi*D^2/4;
    Ab = A - N*Ac;

    % Contact Resistances
    Rtc1Area = finnedArrayParameters.data(7);
    Rtc2Area = finnedArrayParameters.data(8);
    Rtc1 = Rtc1Area/A;
    Rtc2 = Rtc2Area/(N*Ac);

    [hf,hb] = convectionCoefficients(airSpeedMetersPerSecond,Tair,w,D)

    % Resistances
    Rbcond = t/(k*A);
    Rbconv = 1/(hb*Ab);
    nf = finEfficiency(hf,k,D,L);
    Rf = finsResistance(hf, nf, N, D, L);
    Ro = (1/(1/(Rf + Rtc2) + 1/(Rbconv)));
    RT = Rtc1 + Rbcond + Ro;
    Tkelvin = q*RT + Tair;
    T = convtemp(Tkelvin, 'K','C'); 
end

function nf = finEfficiency(h, k, D, L)
    p = pi*D;
    Ac = pi*D^2/4;
    Af = pi*D*L + Ac;
    m = sqrt(h*p/(k*Ac));
    nf = (sqrt(h*p*k*Ac)/(h*Af))*(sinh(m*L) + (h/(m*k))*cosh(m*L))/(cosh(m*L) + (h/(m*k))*sinh(m*L));
end

function Rf = finsResistance(hf, finEfficiency, numberOfFins, finDiameter, finLength)
    N = numberOfFins;
    L = finLength;
    D = finDiameter;
    nf = finEfficiency;
    Ac = pi*D^2/4;
    Af = pi*D*L + Ac;
    Rf = 1/(N*nf*hf*Af);    
end

