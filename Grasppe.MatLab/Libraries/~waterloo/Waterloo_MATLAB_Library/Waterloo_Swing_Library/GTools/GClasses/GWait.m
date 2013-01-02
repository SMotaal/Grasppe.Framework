classdef GWait < GBar
%     GWait provides an indeterminate wait message which may include an animation
%     
%     Examples
%         obj=GWait(target);
%         obj=GWait(target, title);
%         obj=GWait(target, title, str);
%         obj=GWait(target, title, str, img);
%           where     target is the handle of the MATLAB parent container
%                     title  is the title of the displayed item
%                                   (default='Calculating')
%                     str    is a string to display
%                                   (default='Running...')
%                     img    is the name of an image file or a javax.swing.ImageIcon
%                            object. One of several default animated GIFs
%                            from http://www.sevenoaksart.co.uk will be used if
%                            img is not specified.                                 
%     Typical use:
%               try
%                   obj=GWait(target);
%                   ...USER CODE...
%                   delete(obj);
%               catch
%                   delete(obj);
%               end
%     N.B. You can check for user-closure of the GWait object with isvalid(obj)
%     inside the USER-CODE.
%
%     Alternatively,
%               obj=GWait(target, str, title, img, code);
%     displays the GWait object and executes the specied code which can be
%     a string (executed using eval), a function handle, or a cell array
%     with a function handle in the first element and any optional
%     arguments in subsequent elements e.g. {@MyFuncion, 10, 'freq', 99}.
%     
%     If code is specified, it will be executed within a try/catch block in
%     the GWait constructor which will also take care of object
%     instantiation/deletion before returning control.
%
%     By default, the animation isselected at random from pre-defined set
%     These are copyright-free gifs from http://www.sevenoaksart.co.uk
%     
%     The default string ('Running...'), icon and border title (none) can
%     be overridden by specifying them on construction e.g.
%               obj=GWait(target, code, string, icon, border title);
%     Set unwanted arguments empty.
%     They can be changed using setText, setIcon and setTitle.
%     Icons can be a filename string or a javax.swing.ImageIcon object.
%     ----------------------------------------------------------------------
%     Part of Project Waterloo and the sigTOOL Project at King's College
%     London.
%     Author: Malcolm Lidierth 03/11
%     Copyright © The Author & King's College London 2011-
%     Email: sigtool (at) kcl.ac.uk
%     ---------------------------------------------------------------------
        
    properties
        Components;
        Type='GWait';
        Parent;
    end
    
    methods
    
        function obj=GWait(target, bordertitle, str,  img, fcn)
            % Create a JFrame
            if nargin<1
                target=0;
            end
            if nargin<2
                bordertitle='';
            end
            obj=obj@GBar(target, bordertitle);
            
            obj.Components{2}=obj.Components{1}.add(javaObjectEDT(javax.swing.JLabel()));
            if nargin<3 || isempty(str)
                str='Running...';
            end
            obj.setText(str);
            if nargin<4;
                img=[];
            end
            obj.setIcon(img);
            obj.Object.pack();
            % If user code is supplied, it will be executed here
            if nargin>4 && ~isempty(fcn)
                if ischar(fcn)
                    eval(fcn);
                else
                    if isscalar(fcn);fcn={fcn};end
                    if numel(fcn)==1
                        fcn{1}();
                    else
                        fcn{1}(fcn{2:end});
                    end
                end
                delete(obj);
            end
            return
        end
        

        function setText(obj, str)
            % setText - sets the text displayed inside the GWait object
            % Example:
            %       setText(obj, 'MyString');
            obj.Components{2}.setText(str);
            return
        end
        

    end
end

