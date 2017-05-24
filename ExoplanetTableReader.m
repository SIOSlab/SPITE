function [PwMsini,PwMass] = ExoplanetTableReader
%% Read Data from Exoplanetary Orbital Database File
%Running this function generates, filters, and saves as struct variables
%tables of the orbital parameters of the known exoplanets. It reads these
%values from a csv file obtained through the procedure described in the
%documentation. Only exoplanets with semimajor axis, eccentricity, argument
%of periastron, star mass, and star distance parameterized are saved. The
%data is saved into PwMass if the true mass of the exoplanet is known and
%PwMsini if only msin(i) is known.

P = readtable('EODData.csv');
[m,n] = size(P);        %Calculate the Size of the Table

P = table2cell(P);      %Convert the Table to Cell Format
nsini = 1;              %Initialize Indice Variable for Planets with Msini Known
nmass = 1;              %Initialize Indice Variable for Planets with Mass Known

for j = 1:m                                
    if strcmp(P(j,11),'Mass')               %Check if True Mass is Known 
        a  = cell2mat(P(j,7));              %Read Semimajor Axis (Au)
        e  = cell2mat(P(j,8));              %Read Eccentricity
        i  = cell2mat(P(j,9));              %Read Inclination (Deg)
        om = cell2mat(P(j,38));             %Read Argument of Periastron (Deg)
        mp = cell2mat(P(j,10));             %Read Planet mass (Jupiter Masses)
        ms = cell2mat(P(j,27))/0.000954265748;  %Read Star Mass and Convert from Solar Masses to Jupiter Masses(Jupiter Masses)
        d  = cell2mat(P(j,22));             %Read Star Distance from Earth (Pc)
        system = cell2mat(P(j,2));          %Read Name of Exoplanet
        if  ~isnan(a)                       %Check that Semimajor Axis is Known       
            if  ~isnan(e)                   %Check that Eccentricity is Known
                if  ~isnan(i)               %Check that Inclination is Known
                    if  ~isnan(om)          %Check that Argument of Periastron is Known
                        if ~isnan(d)        %Check that Distance from Earth is Known
                            %Create a Struct for the Exoplanet
                            sys1.d  = d;
                            sys1.ms = ms;
                            sys1.mp = mp;
                            sys1.a  = a;
                            sys1.e  = e;
                            sys1.i  = i;
                            sys1.om = om;
                            sys1.system = system;
                            %Log the Planet for the Output Table
                            PwMass(nmass) = sys1;
                            %Refresh the Indice Value for Exoplanets with Mass
                            nmass = nmass + 1;
                        end
                    end
                end
            end
        end
    elseif strcmp(P(j,11),'Msini')          %Check if Msini is Known
        a  = cell2mat(P(j,7));              %Read Semimajor Axis (Au)
        e  = cell2mat(P(j,8));              %Read Eccentricity
        om = cell2mat(P(j,38));             %Read Argument of Periastron (Deg)
        mpsini = cell2mat(P(j,10));         %Read Msini (Jupiter Masses)
        ms = cell2mat(P(j,27))/0.000954265748; %Read Star Mass and Convert from Solar Masses to Jupiter Masses(Jupiter Masses)
        d  = cell2mat(P(j,22));             %Read Star Distance from Earth (Pc)
        system = cell2mat(P(j,2));          %Read Name of Exoplanet
        if  ~isnan(a)                       %Check that Semimajor Axis is Known
            if  ~isnan(e)                   %Check that Eccentricity is Known
                if  ~isnan(om)              %Check that Argument of Periastron is Known
                    if ~isnan(d)            %Check that Star Distance from Earth is Known
                        %Create a Struct for the Exoplanet
                        sys2.d  = d;
                        sys2.ms = ms;
                        sys2.mpsini = mpsini;
                        sys2.a  = a;
                        sys2.e  = e;
                        sys2.om = om;
                        sys2.system = system;
                        %Log the Planet for the Output Table
                        PwMsini(nsini) = sys2;
                        %Refresh the Indice Value for Exopllanets with Msini
                        nsini = nsini + 1;
                    end
                end              
            end
        end 
    end
end

%Save the Tables for Future Use
save('PwMass','PwMass')
save('PwMsini','PwMsini')
