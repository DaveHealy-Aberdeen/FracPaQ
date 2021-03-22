function guiFracPaQ2Dangle(traces, northCorrection, nHistoBins, nRoseBins, ...
                flag_histoangle, flag_roseangle, flag_revY, flag_revX, flag_cracktensor, ...
                flag_roselengthweighted, flag_rosemean, flag_rosecolour, sColour)
%   guiFracPaQ2Dangle.m 
%       calculates and plots statistics of trace segment angles  
%       
%   David Healy
%   July 2014 
%   d.healy@abdn.ac.uk 

%% Copyright
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

global sTag ; 

numTraces = length(traces) ; 
traceAngles = [ traces.segmentAngle ]' ; 
traceLengths = [ traces.segmentLength ]' ; 

v = ver('MATLAB') ; 
iRelease = regexp(v.Release, 'R.....') ; 
nReleaseYear = str2num(v.Release(iRelease+1:iRelease+4)) ; 

%   double the trace angle data over 360 degrees 
traceAngles2 = doubleAngles(traceAngles, northCorrection) ; 

%   double the length data too, for length weighting of rose plot 
traceLengths2 = [ traceLengths ; traceLengths ] ; 

%   change angles if axis flipped 
if flag_revX 
    traceAngles2 = reverseAxis(traceAngles2) ; 
end ; 

if flag_revY 
    traceAngles2 = reverseAxis(traceAngles2) ; 
end ; 

%   write the trace angles to a text file for EZ-ROSE plotting
sorted_traceAngles2 = sort(traceAngles2) ; 
fn = ['FracPaQ2DEZROSE', sTag, '.txt'] ; 
fidRose = fopen(fn, 'wt') ; 
for i = 1:max(size(traceAngles2)) 
    fprintf(fidRose, '%6.2f\n', sorted_traceAngles2(i)) ; 
end ; 
fclose(fidRose) ; 

if flag_roseangle 
    
    f = figure ; 
    %   might implement linear scaling later, if demand exists; equal area is better though 
    flag_equalarea = 1 ;
    
    if ~flag_roselengthweighted
        traceLengths2 = 0 ; 
    end ; 
    
    if flag_equalarea 
        if flag_rosecolour
            roseEqualAreaColour(traceAngles2, nRoseBins, 0, traceLengths2, flag_rosemean, sColour) ; 
        else
            roseEqualArea(traceAngles2, nRoseBins, 0, traceLengths2, flag_rosemean, sColour) ; 
        end ; 
        if flag_roselengthweighted 
            title({['Segment angles (equal area, length weighted), n=', num2str(length(traceLengths))];''}) ; 
        else
            title({['Segment angles (equal area), n=', num2str(length(traceLengths))];''}) ; 
        end ; 
        %   save to file 
        guiPrint(f, 'FracPaQ2D_roseangleEqArea') ; 
    else
        roseLinear(traceAngles2, nRoseBins, 0, traceLengths2, flag_rosemean, sColour) ; 
        if flag_roselengthweighted 
            title({['Segment angles (linear, length weighted), n=', num2str(length(traceLengths))];''}) ; 
        else
            title({['Segment angles (linear), n=', num2str(length(traceLengths))];''}) ; 
        end ; 
        %   save to file 
        guiPrint(f, 'FracPaQ2D_roseangleLinear') ; 
    end ; 
    
end ; 

if flag_histoangle 
    
    %   histogram of trace angles 
    f = figure ; 
    [ nAngles, binAngles ] = hist(traceAngles2, 0:360/nHistoBins:360) ; 
    if nReleaseYear < 2016 
        h = msgbox('Warning: FracPaQ needs MATLAB release of R2016a, or later, to plot double y-axis plots.', 'Warning!') ;  
        uiwait(h) ; 
        bar(binAngles, nAngles, 1, 'FaceColor', sColour) ; 
        ylabel('Frequency') ; 
        ylim([0 max(nAngles)*1.1]) ; 
    else
        yyaxis left ; 
        bar(binAngles, nAngles, 1, 'FaceColor', sColour) ; 
        ylabel('Frequency') ; 
        ylim([0 max(nAngles)*1.1]) ; 
        yyaxis right ; 
        hold on ; 
        bar(binAngles, (nAngles/sum(nAngles))*100, 1, 'FaceColor', sColour) ; 
        hold off ; 
        ylim([0 max((nAngles/sum(nAngles))*100)*1.1]) ; 
        ylabel('Frequency, %') ; 
    end 
    xlabel('Trace segment angle, degrees') ; 
    xlim([-10 370]) ; 
    set(gca,'XTick', 0:60:360) ; 
    axis on square ; 
    box on ; 
    grid on ; 
    title({['Trace segment angles, n=', num2str(length(traceLengths))];''}) ; 

    %   save to file 
    guiPrint(f, 'FracPaQ2D_histoangle') ; 
    
end ; 

if flag_cracktensor 
    
    guiFracPaQ2Dcracktensor(traces, northCorrection, flag_revY, flag_revX) ; 

end ;

end 
