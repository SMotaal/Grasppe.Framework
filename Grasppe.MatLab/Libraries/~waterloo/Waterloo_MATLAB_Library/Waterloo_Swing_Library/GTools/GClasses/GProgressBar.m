classdef GProgressBar < GBar
%     GProgressBar - a time-efficient progress bar with a customisable icon
%
%     GProgressBar displays a progress bar with text/graphics that are updated
%       asynchronously on a MATLAB timer. The estimated time to completion
%       of your code is automatically calculated internally and can also be
%       displayed. Updating a GProgressBar within your code does not,
%       therefore, add appreciably to the processor overhead inside a loop.
%
%     Examples
%         obj=GProgressBar(target);
%         obj=GProgressBar(target, str);
%         obj=GProgressBar(target, title, str);
%         obj=GProgressBar(target, title, str, img);
%         obj=GProgressBar(target, title, str, img, period);
%           where     target is the handle of the MATLAB parent container
%                     str    is a string to display
%                                   (default='Running...')
%                     title  is the title of the displayed item
%                                   (default='Calculating')
%                     img    is the name of an image file or a javax.swing.ImageIcon
%                            object. A default animated GIF will be used if
%                            img is not specified.  
%                     period is the time (in seconds) between updates of
%                            the displayed graphics default 0.75s);
%
%
%     The default string ('Running...'), icon and border title (none) can
%     be overridden by specifying them on construction e.g.
%               obj=GProgressBar(target, code, string, icon, border title);
%     Set unwanted arguments empty.
%     They can be changed using setText, setIcon and setTitle.
%
%     Control the progress bar with start, reset and delete:
%           start   sets the timer running
%           reset   resets the eleapsed time to zero
%           delete  removes the progress bar
%
%     setMinimum and setMaximum set the minimum and maximum for the bar and
%     are used to estimate the time remaining
%
%
% Notes:
% [1] the toc/toc sequences here have no affect on user-called tic/tocs
%----------------------------------------------------------------------
% Part of Project Waterloo and the sigTOOL Project at King's College
% London.
% Author: Malcolm Lidierth 07/11
% Copyright © The Author & King's College London 2011-
% Email: sigtool (at) kcl.ac.uk
% ---------------------------------------------------------------------


        
    properties
        Components;
        Value=[];
        ShowETA=true;
        Type='GProgressBar';
        Parent;
    end
    
    properties (Access=private)
        StartTime=uint64(0);
        Timer;
        TextAsync;
        QueryOnClose=false;
        ClosingCallback=@DefaultClosingCallback;
    end
    
    methods
    
        function obj=GProgressBar(target, bordertitle, str, img, period)
            % Create a JFrame
            if nargin<1
                target=0;
            end
            if nargin<2
                bordertitle='';
            end
            obj=obj@GBar(target, bordertitle);
            
            obj.Object.setResizable(true);
            
            obj.Components{2}=javaObjectEDT(obj.Components{1}.add(javax.swing.JButton()));
            if nargin<4
                img=[];
            end
            img=obj.setIcon(img);
            obj.Components{2}.setPreferredSize(java.awt.Dimension(img.getIconWidth()+2, img.getIconHeight()+2));

            
            obj.Components{3}=javaObjectEDT(obj.Components{1}.add(javax.swing.JPanel()));
            obj.Components{3}.setBackground(obj.Components{3}.getParent().getBackground())
            obj.Components{3}.setPreferredSize(java.awt.Dimension(2.5*img.getIconWidth()+2, img.getIconHeight()+2));
            
            
            obj.Components{4}=javaObjectEDT(obj.Components{3}.add(javax.swing.JLabel()));  
            obj.Components{4}.setHorizontalAlignment(javax.swing.SwingUtilities.CENTER); 
            
            obj.Components{5}=javaObjectEDT(obj.Components{3}.add(javaObjectEDT(javax.swing.JProgressBar(0,100)))); 
            obj.Components{5}.setPreferredSize(java.awt.Dimension(100,20));
            obj.Components{5}.setBorderPainted(true);
            obj.Components{5}.setStringPainted(true);
            obj.Components{5}.setMinimum(0);
            obj.Components{5}.setMaximum(100);
            


            if nargin<3 || isempty(str)
                str='Running...';
            end
            obj.setText(str);
            obj.Object.pack();

            
            if nargin<5 || isempty(period) || period==0
                period=0.75;
            end
            
            if (period>0)
            obj.Timer=timer('TimerFcn', {@LocalTimer, obj},'ExecutionMode','fixedSpacing', 'Period', period,'Tag', 'GTool:Timer');
            obj.Components{5}.setIndeterminate(true);
            obj.setQueryOnClose(true);
            obj.start();
            else
                obj.Components{5}.setIndeterminate(true);
            end
            
                function LocalTimer(tobj, EventData, obj) %#ok<INUSL>
                    obj.updateValue();
                    return
                end
                
            return
        end
        
        function delete(obj)
            if ~isempty(obj.Timer) && isvalid(obj.Timer)
                stop(obj.Timer)
                set(obj.Timer,'TimerFcn',[]);
                delete(obj.Timer);
            end
            return
        end
        
        function setText(obj, str)
            obj.Components{4}.setText(str);
            metrics=obj.Components{4}.getFontMetrics(obj.Components{4}.getFont());
            w=max(110,metrics.stringWidth(obj.Components{4}.getText()));
            obj.Components{1}.setPreferredSize(java.awt.Dimension(w+200, obj.Components{1}.getHeight()));
            obj.Components{3}.setPreferredSize(java.awt.Dimension(w+20, obj.Components{1}.getHeight()-2));
            obj.Components{4}.setPreferredSize(java.awt.Dimension(w+10, obj.Components{4}.getHeight()));
            obj.Components{5}.setPreferredSize(java.awt.Dimension(w+10, obj.Components{5}.getHeight()));
            obj.Object.pack();
            obj.TextAsync=str;
            return
        end
        
        function setTextAsync(obj, str)
            obj.TextAsync=str;
            return
        end
        
        function setValue(obj, val)
            warning('GProgressBar:setValue','Use direct assignment for Value, e.g. obj.Value=10 - its ~10x faster');
            obj.Value=val;
        end
        
        function setMinimum(obj, val)
            obj.Components{5}.setMinimum(val);
            return
        end
        
        function setMaximum(obj, val)
            obj.Components{5}.setMaximum(val);
            return
        end
        
        function setQueryOnClose(obj, flag)
            % setQueryOnClose(false) - just dispose of the JFrame
            % setQueryOnClose(true) - invoke WindowClosingCallback
            obj.QueryOnClose=flag;
            if flag==true
                obj.Object.setDefaultCloseOperation(javax.swing.JFrame.DO_NOTHING_ON_CLOSE);
                set(handle(obj.Object, 'callbackproperties'), 'WindowClosingCallback', {@WindowClosingCallback, obj});
            else
                obj.Object.setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
                set(handle(obj.Object, 'callbackproperties'), 'WindowClosingCallback', []);  
            end
            return
        end
        
        function setClosingCallback(obj, func_handle)
            if isempty(func_handle)
                obj.ClosingCallback=@DefaultClosingCallback;
            else
                obj.ClosingCallback=func_handle;
            end
            return
        end
        
        function start(obj)
            if obj.StartTime==0
                obj.StartTime=tic();
                start(obj.Timer);
            end
            obj.Components{5}.setIndeterminate(false);
            return
        end
        
        function reset(obj)
            stop(obj.Timer);
            drawnow();
            obj.ShowETA=true;
            obj.Value=obj.Components{5}.getMinimum();
            obj.StartTime=uint64(0);
            obj.Components{5}.setString('');
            obj.Components{5}.setIndeterminate(true);
            return
        end
        
    end
    
    methods(Access=private)
        
        function updateValue(obj)
            val1=obj.Value;
            val2=obj.Components{5}.getValue();
            if val1~=val2
                obj.Components{5}.setValue(val1);
                if obj.ShowETA==true
                    prop=(val1-obj.Components{5}.getMinimum())/(obj.Components{5}.getMaximum()-obj.Components{5}.getMinimum());
                        t=(1-prop)*toc(obj.StartTime)/prop;
                        if t<180
                            obj.Components{5}.setString(sprintf('%3.0fs left', t));
                        elseif t<60*60
                            mins=floor(t/60);
                            s=rem(t,60);
                            obj.Components{5}.setString(sprintf('%2.0fm %2.0fs left', mins, s));
                        elseif t<60*60*24
                            hrs=floor(t/60^2);
                            mins=floor((t-(hrs*60^2))/60);
                            s=rem(t,60);
                            obj.Components{5}.setString(sprintf('%2.0fh %2.0fm %2.0fs to go', hrs, mins, s));
                        else
                            obj.Components{5}.setString('More the 1 day left');
                        end
                end
                obj.Components{4}.setText(obj.TextAsync);
                drawnow();
            end
            return
        end
        
    end
    
end
    

function WindowClosingCallback(hObject, EventData, obj)
% This coordinates what happens if the JFrame is closed. Users can replace
% the default callback
if iscell(obj.ClosingCallback)
    if numel(obj.ClosingCallback)>1
        obj.ClosingCallback{1}(hObject, EventData, obj, obj.ClosingCallback{2:end});
    else
        obj.ClosingCallback{1}(hObject, EventData, obj);
    end
else
    obj.ClosingCallback(hObject, EventData, obj);
end
return
end

function DefaultClosingCallback(hObject, EventData, obj)
% Show a dialog in the JFrame
x=javaObjectEDT(javax.swing.JOptionPane(javaObjectEDT(javax.swing.JLabel('Do you really want to stop processing?')),...
    javax.swing.JOptionPane.PLAIN_MESSAGE,...
    javax.swing.JOptionPane.YES_NO_OPTION));
set(handle(x, 'callbackproperties'), 'PropertyChangeCallback', {@valueSelectedCallback, hObject, obj});
sz=hObject().getSize();
x.setSize(sz.getWidth(),100);
hObject.add(x);
obj.Object.setSize(obj.Object.getWidth(),obj.Object.getHeight()+200);
obj.Object.validate();
return
end

function valueSelectedCallback(hObject, EventData, frame, obj)
% Callback for the dialog
switch char(EventData.getPropertyName())
    case 'value'
        switch hObject.getValue()
            case javax.swing.JOptionPane.NO_OPTION
                sz=frame.getSize();
                frame.remove(hObject);
                frame.setSize(sz.getWidth(), sz.getHeight()-200);
            case javax.swing.JOptionPane.YES_OPTION
                delete(obj);
        end
    otherwise
end
return
end

