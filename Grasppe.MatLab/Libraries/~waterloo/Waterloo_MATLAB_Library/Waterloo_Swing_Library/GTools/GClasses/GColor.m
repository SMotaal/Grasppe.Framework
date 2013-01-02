classdef GColor
    % GColor class - a library of static methods for color manipulation
    %
    % GColor has been developed for use primarily in GUI design. It
    % provides support for both MATLAB color vectors and Java color objects
    % and both RGB and HSL color representaions. Using HSL makes it much
    % easier to manipulate colors to get subtle variations.
    %
    % GColor methods can output MATLAB colormaps, which can also be
    % used to set the coloring of MATLAB graphics.
    %
    % GColor methods work with both MATLAB color vectors/strings and Java 
    % color objects as input and will return a color specified by the same
    % convention as the input except in the case of
    %       getColor: which swaps the spec between MATLAB and Java.
    % and two internal functions which are also public
    %       toHSL:    accepts MATLAB vectors or Java objects as input
    %                 always returns MATLAB vectors or matrices as output
    %       toRGB:    complement to toHSL. Accepts toHSL output on input.
    %                 Always returns java.awt.Color objects as output
    %
    % Arrays of Java color objects and MATLAB colormaps (Mx3 matrices) are
    % also handled.
    %
    % ---------------------------------------------------------------------
    % Part of the sigTOOL Project and Project Waterloo from King's College
    % London.
    % http://sigtool.sourceforge.net/
    % http://sourceforge.net/projects/waterloo/
    %
    % Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
    % 
    % Author: Malcolm Lidierth 01/11
    % Copyright The Author & King's College London 2011-
    % --------------------------------------------------------------------- 
    
    % Revisions:
    %       02.08.2011 Correct references to getArc
    
    methods(Static)
        
        function [color, alpha]=getColor(color)
            % getColor interchanges Java and MATLAB color specs
            %
            % Examples
            % color=getColor(color);
            %           returns a 3-element MATLAB color vector when the
            %           input is a java.awt.Color object (or subclass)
            %           or
            %           returns a java.awt.Color object if the input is a
            %                   MATLAB color vector or string e.g. 'yellow'
            % [color, alpha]=getColor(color);
            %           also returns alpha
            if ismatlab(color)
                alpha=[];
                color=GColor.toJava(color);
            else
                [color, alpha]=GColor.toMATLAB(color);
            end
            return
        end
        
        function [color, alpha]=toMATLAB(color)
            % toMATLAB converts Java color objects to MATLAB colors
            % Examples:
            % color=toMATLAB(color);
            % [color, alpha]=toMATLAB(color);
            % The input color is a java.awt.Color object or subclass. Color
            % output is a 3-element RGB row vector scaled 0-1.
            % Arrays of java.awt.Color objects are supported on input. The
            % output will then be a Mx3 matrix of M colors (i.e. a MATLAB
            % colormap) together with an optional column vector of alpha
            % values
            if numel(color)>1
                temp=zeros(numel(color),3);
                alpha=zeros(numel(color),1);
                for k=1:numel(color)
                    [temp(k,:), alpha(k)]=GColor.toMATLAB(color(k));
                end
                color=temp;
            else
                alpha=color.getAlpha();
                color=[color.getRed(), color.getGreen(), color.getBlue()]/255;
            end
            return
        end
        
        function [color, mlflag]=toJava(color)
            % toMATLAB converts MATLAB colors to java.awt.Color objects
            %
            % Examples:
            % color=toJava(color);
            % If the input color is a 3-element RGB row vector scaled 0-1,
            % color output will be a java.awt.Color object.
            % If the input  is a 3-element RGB color map scaled 0-1,
            % color output will be a java.awt.Color array.
            
            % [color, mlflag]=toJava(color)
            % is used internally by the CColor methods
            
            % Colormap on input, deal with each color in turn
            
            if isjava(color)
                return
            end
            
            if ismatlab(color) && size(color,1)>1
                mlflag=true;
                n=size(color,1);
                temp=cell(n,1);
                for k=1:size(color,1)
                    temp{k}=GColor.toJava(color(k,:));
                end
                color=cell2mat(temp);
                return
            end
            
            % Single color on input
            if ismatlab(color)
                mlflag=true;
                if isnumeric(color)
                    if any(color>1)
                        color=int16(color);
                    end
                    color=java.awt.Color(color(1),color(2),color(3));
                elseif ischar(color)
                    switch color
                        case {'y', 'yellow'}
                            color=java.awt.Color.yellow;%[1 1 0];
                        case {'m', 'magenta'}
                            color=java.awt.Color.magenta;%[1 0 1];
                        case {'c', 'cyan'}
                            color=java.awt.Color.cyan;%[0 1 1];
                        case {'r', 'red'}
                            color=java.awt.Color.red;%[1 0 0];
                        case {'g', 'green'}
                            color=java.awt.Color.green;%[0 1 0];
                        case {'b', 'blue'}
                            color=java.awt.Color.blue;%[0 0 1];
                        case {'w', 'white'}
                            color=java.awt.Color.white;%[1 1 1];
                        case {'k', 'black'}
                            color=java.awt.Color.black;%[0 0 0];
                        case 'MATLAB_darkBlue'
                            color=[0,47,76]/255;
                        case 'MATLAB_mediumBlue'
                            color=[20,106,161]/255;
                        case 'MATLAB_lightBlue'
                            color=[52,118,166]/255;
                        case 'MATLAB_darkGray'
                            color=[200,200,200]/255;
                        case 'MATLAB_lightGray'
                            color=[234,234,234]/255;
                        case 'MATLAB_darkOrange'
                            color=[177,66,30]/255;
                        case 'MATLAB_mediumOrange'
                            color=[247,141,51]/255;
                        case 'MATLAB_lightOrange'
                            color=[255,203,68]/255;
                        case 'darkGreen'
                            color=[74,96,23]/255;
                        case 'mediumGreen'
                            color=[70,160,80]/255;
                        case 'lightGreen'
                            color=[53,203,100]/255;
                        case 'darkRed'
                            color=[141,21,33]/255;
                        case 'mediumRed'
                            color=[238,43,51]/255;
                        case 'lightRed'
                            color=[240,68,75]/255;
                    end
                    if isnumeric(color)
                        color=java.awt.Color(color(1), color(2), color(3));
                    end
                end
            else
                mlflag=false;
            end
            return
        end
        
        % ALL REMAINING FUNCTIONS WILL ACCEPT EITHER A JAVA COLOR OBJECT OR
        % A MATLAB COLOR VECTOR ON INPUT. THE OUPUT WILL BE IN THE SAME
        % FORMAT
        % MULTIPLE COLOR OUTPUTS FOR JAVA ARE JAVA.AWT.COLOR ARRAYS
        % MULTIPLE COLOR OUTPUTS FOR MATLAB ARE Mx3 RGB MATRICES (COLORMAPS)
        
        function color=darker(color)
            % darker returns darker color(s)
            [color, mlflag]=GColor.toJava(color);
            for k=1:size(color,1)
                color(k)=color(k).darker();
            end
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=brighter(color)
            % brighter returns brighter color(s)
            [color, mlflag]=GColor.toJava(color);
            for k=1:size(color,1)
                color(k)=color(k).brighter();
            end
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function lum=getLuminance(color)
            % getLuminance returns the luminance(s)
            color=GColor.toMATLAB(color);
            lum=zeros(size(color,1),1);
            for k=1:size(color,1)
                lum(k)=color(k, 1:3)*[0.3;0.59;0.11];
            end
            if any(lum>1);lum=lum/255;end
            return
        end
        
        function theta=getTheta(color)
            % getTheta returns the angle of the color in the color circle
            hsl=GColor.toHSL(color);
            theta=hsl(1)*360;
            return
        end
        
        function color=toGray(color)
            % toGray returns grays of equal luminance to the input(s)
            [color, mlflag]=GColor.toJava(color);
            lum=GColor.getLuminance(color);
            for k=1:size(color,1)
                color(k)=java.awt.Color(lum(k),lum(k),lum(k));
            end
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        
        
        function color=getMonochrome(color, n, llim)
            % getMonochrome returns a monochrome series
            % by varying the luminance of the reference color
            % Example:
            % color=getMonochrome(color, n)
            %   where color on input is the starting color and
            %   n=number of colors to return
            %
            % Terminate the series at higher luminance by specifying llim on
            % input:
            % color=getMonochrome(color, n, llim)
            %       where llim/2=proportion of the reference color luminance
            %       to use (default=1).
            [color, mlflag]=GColor.toJava(color);
            if nargin<3
                llim=1;
            end
            hsl=GColor.toHSL(color);
            s=linspace(hsl(3)+(llim*hsl(3)), hsl(3)-(llim*hsl(3)), n);
            n2=numel(s);
            color=cell(n2,1);
            for k=1:n2
                color{k}=GColor.toRGB([hsl(1), hsl(2), s(k)]);
            end
            color=cell2mat(color);
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=getArcSeries(color, n, theta)
            % getArcSeries generates a set of colors of different hue
            % Example:
            % colors=getArcSeries(color, n, theta)
            %      where color is the central color of a set of n colors
            %      that subtend an arc of +/-(theta/2) in the color circle.
            %      Theta is specified in degrees and should be 0 to <360.
            [color, mlflag]=GColor.toJava(color);
            if ismatlab(color);color=GColor.getColor(color);end
            hsl=GColor.toHSL(color);
            theta=theta/(2*360);
            if n>1
                s=linspace(hsl(1)-theta, hsl(1)+theta, n);
            else
                s=hsl(1)+theta;
            end
            n2=numel(s);
            color=cell(n2,1);
            for k=1:n2
                color{k}=GColor.toRGB([s(k), hsl(2), hsl(3)]);
            end
            color=cell2mat(color);
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=getComplement(color)
            % getComplement returns the complement of a color
            % (rotated 180 degrees on the color circle)
            % Example:
            %   color=getComplement(color);
            [color, mlflag]=GColor.toJava(color);
            hsl=GColor.toHSL(color);
            s=hsl(1)-0.5;
            color=GColor.toRGB([s, hsl(2), hsl(3)]);
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=getSplitComplements(color)
            % getSplitComplements returns the 2 split complements of the input
            % i.e. the colors at +/- 150 degrees.
            % Example:
            %   color=getSplitComplements(color);
            color=GColor.getArcSeries(color, 2, 300);
            return
        end
        
        
        function color=getTriads(color)
            % getTriads returns the two triadic complements of the input colors
            % i.e. the colors at +/- 120 degrees.
            % Example:
            %   color=getTriads(color);
            color=GColor.getArcSeries(color, 2, 240);
            return
        end
        
        function color=getAnalagous(color, n)
            % getAnalagous returns neigbouring colors
            % i.e. the colors at  +/- 30 degrees.
            % Example:
            %   color=getAnalagous(color);
            % Alternatively, specify that a set n colors should be
            % returned:
            %   color=getAnalagous(color, n);
            % returns a set of n colors of different hue, equally spaced
            % in the color circle by rotation from the -30 degrees to
            % +30. The input color will be at the centre.
            if nargin==1
                n=2;
            end
            color=GColor.getArcSeries(color, n, 60);
            return
        end
        
        function color=getSatSeries(color, n)
            % getSatSeries generates a series of colors of different saturations
            %
            % Example:
            % colors=getSatSeries(color, n)
            %      where the output is a set of n colors whose saturations
            %      range from 0 to 1 but which have the same hue and
            %      luminance as the input
            [color, mlflag]=GColor.toJava(color);
            if ismatlab(color);color=GColor.getColor(color);end
            hsl=GColor.toHSL(color);
            s=linspace(0, 1, n);
            n2=numel(s);
            color=cell(n2,1);
            for k=1:n2
                color{k}=GColor.toRGB([hsl(1),  s(k), hsl(3)]);
            end
            color=cell2mat(color);
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=getLumSeries(color, n)
            % getLumSeries generates a set of colors of different luminance
            %
            % Example:
            % colors=getLumSeries(color, n)
            %      where the output is a set of n colors whose luminance
            %      ranges from 0 to 1 but which have the same hue and
            %      saturation as the input
            [color, mlflag]=GColor.toJava(color);
            if ismatlab(color);color=GColor.getColor(color);end
            hsl=GColor.toHSL(color);
            s=linspace(0, 1, n);
            n2=numel(s);
            color=cell(n2,1);
            for k=1:n2
                color{k}=GColor.toRGB([hsl(1),  hsl(2), s(k)]);
            end
            color=cell2mat(color);
            if mlflag;color=GColor.toMATLAB(color);end
            return
        end
        
        function color=getHueSeries(color,n)
            % getHueSeries generates a set of colors of different hue
            %
            % Example:
            % color=getHueSeries(color,n)
            %      Generates a less than subtle scheme of n colors.
            %      The input color is the reference color and is color 1 in
            %      the returned set. Colors 2 and 3 will be the triadic
            %      complements of this. 4 will be the color at 60 degrees,
            %      7 at 30 degrees, 10 at 90 degrees, 13 at 15 degrees and
            %      so on, all with their triads padding the colors between:
            %      a visually cacaphonic kaleidoscope of colors. All the
            %      colors will be unique - but not necessarily to
            %      the human eye.
            [color, mlflag]=GColor.toJava(color);
            idx=1;
            thetaStartList=zeros(nextpow2(n),1);
            while idx<=nextpow2(n);
                thetaStartList(idx)=120/2^(idx-1);
                idx=idx+1;
            end
            thetaList=zeros(n,1);
            thetaList(1)=0;
            thetaList(2)=120;
            thetaList(3)=240;
            idx=4;
            k=2;
            thisTheta=thetaStartList(k);
            while idx<=n
                while thisTheta<120
                    thetaList(idx)=thisTheta;
                    thetaList(idx+1)=thisTheta+120;
                    thetaList(idx+2)=thisTheta+240;
                    idx=idx+3;
                    thisTheta=thisTheta+thetaStartList(k);
                    while ismember(thisTheta, thetaList)
                        thisTheta=thisTheta+thetaStartList(k);
                        if thisTheta>120;break;end
                    end
                end
                k=k+1;
                if k>numel(thetaStartList);break;end
                thisTheta=thetaStartList(k);
            end
            hsl=GColor.toHSL(color);
            temp=zeros(n,3);
            for k=1:n
                temp(k,1:3)=[hsl(1)+thetaList(k)/360 hsl(2) hsl(3)];
            end
            color=GColor.toRGB(temp);
            if mlflag;color=GColor.toMATLAB(color);end
        return
        end
        
        function color=toRGB(hsl)
            % toRGB converts HSL to RGB
            % Based on source at http://www.easyrgb.com/index.php?X=MATH&H=19#text19
            if size(hsl,1)>1
                temp=cell(size(hsl,1),1);
                for k=1:size(hsl,1)
                    temp{k}=GColor.toRGB(hsl(k,:));
                end
                color=cell2mat(temp);
                return
            end
            
            H=hsl(1);
            S=hsl(2);
            L=hsl(3);
            if S==0
                R=L;
                G=L;
                B=L;
                color=java.awt.Color(R,G,B);
                return
            else
                if L<0.5
                    var2=L*(1+S);
                else
                    var2=(L+S)-(S*L);
                end
                var1=2*L-var2;
                R=Hue2RGB(var1,var2,H+1/3);
                G=Hue2RGB(var1,var2,H);
                B=Hue2RGB(var1,var2,H-1/3);
                color=java.awt.Color(R,G,B);
            end
            return
            function out=Hue2RGB(v1,v2,vH)
                if vH<0; vH=vH+1;end
                if vH>1; vH=vH-1;end
                if 6*vH<1
                    out=v1+(v2-v1)*6*vH;
                elseif 2*vH<1
                    out=v2;
                elseif 3*vH<2
                    out=v1+(v2-v1)*(2/3-vH)*6;
                else
                    out=v1;
                end
                return
            end
        end
        
        function hsl=toHSL(color)
            % toHSL converts RGB to HSL
            % Based on source at http://www.easyrgb.com/index.php?X=MATH&H=18#text18
            if size(color,1)>1
                hsl=zeros(numel(color),3);
                for k=1:size(color,1)
                    hsl(k,:)=GColor.toHSL(color(k,:));
                end
                return
            end
            color=GColor.toJava(color);
            R=color.getRed()/255;
            G=color.getGreen()/255;
            B=color.getBlue()/255;
            mn=min([R G B]);
            mx=max([R G B]);
            delta=mx-mn;
            L=(mx+mn)/2;
            if delta==0
                H=0;
                S=0;
            else
                if L<0.5
                    S=delta/(mx+mn);
                else
                    S=delta/(2-mx-mn);
                end
                deltaR=(((mx-R)/6)+(delta/2))/delta;
                deltaG=(((mx-G)/6)+(delta/2))/delta;
                deltaB=(((mx-B)/6)+(delta/2))/delta;
                if R==mx
                    H=deltaB-deltaG;
                elseif G==mx
                    H=(1/3)+deltaR-deltaB;
                elseif B==mx
                    H=(2/3)+deltaG-deltaR;
                end
            end
            if H<0;H=H+1;end
            if H>1;H=H-1;end
            hsl=[H S L];
            return
        end
        
        function demo()
            % Simple demo that draws earth of color with two monochrome series
            figure('Name', 'GColor Demo', 'Toolbar', 'figure','Units', 'normalized');
            topo=load('topo');
            [x y z]=sphere(45);
            surface(x,y,z,'FaceColor','texturemap','CData',topo.topo);
            axis tight;
            colormap([GColor.getMonochrome('b',64); GColor.getMonochrome([1 .4 0],65)]);
            campos([2 13 10]);
            camlight;
            %lighting('gouraud');
            view(-102,36);
            axis('vis3d');
            grid('on');
            return
        end
    end
    
end

% Helper function
function flag=ismatlab(color)
if isnumeric(color) || ischar(color)
    flag=true;
else
    flag=false;
end
return
end