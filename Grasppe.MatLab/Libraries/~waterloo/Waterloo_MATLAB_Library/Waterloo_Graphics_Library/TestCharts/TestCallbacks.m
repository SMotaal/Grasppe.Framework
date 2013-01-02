function a1=TestCallbacks()
% TestCallbacks
% Demonstrates how to install property change callbacks for:
%       X and Y data objects
%       The plots that contain them
%       The graph that shows the plot
%       The container for the graph
%
% All nodes in Waterloo graphics hierarchy are observable via property
% change callbacks because they implement the GJObservable interface.
%
% That GJObservable also supports object linking, illustrated here with a
% trivial example by connecting the state of a JCheckBox to the selected
% status of the plot
%
% ---------------------------------------------------------------------
% Part of the sigTOOL Project and Project Waterloo from King's College
% London.
% http://sigtool.sourceforge.net/
% http://sourceforge.net/projects/waterloo/
%
% Contact: ($$)sigtool(at)kcl($$).ac($$).uk($$)
%
% Author: Malcolm Lidierth 12/11
% Copyright The Author & King's College London 2011-
% ---------------------------------------------------------------------
%   
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU Lesser General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%  
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%  
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% ---------------------------------------------------------------------

% Set up and create some data
f=GXFigure();
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8], 'Name', mfilename());


% Create a line plot with no data
a1=line(gxgca, [], [], 'LineSpec','-om', 'LineColor', java.awt.Color.darkGray);

% Insert some callbacks on the data objects...
xobject=handle(a1.getObject().getXData(), 'callbackproperties');
set(xobject, 'PropertyChangeCallback', @XDataCallback);
yobject=handle(a1.getObject().getYData(), 'callbackproperties');
set(yobject, 'PropertyChangeCallback', @YDataCallback);
% ... and the plot. The data objects forward any PropertyChangeEvents to
% the plot so we have a choice of listening to changes on the data objects
% or the plot or, as here, both.
plotobject=handle(a1.getObject(), 'callbackproperties');
set(plotobject, 'PropertyChangeCallback', @PlotCallback);

% Now add a callback on the graph.
grobject=handle(f.CurrentAxes.getObject().getView(), 'callbackproperties');
set(grobject, 'PropertyChangeCallback', @GraphCallback);

% % For good measure we could install a callback on the graph container also.
% % Note this is in a jcontrol object so we do not need to (and should
% % not) call handle.
% % UNCOMMENT THE NEXT LINE IF YOU WANT TO ACTIVATE THIS CALLBACK
 set(f.CurrentAxes.getObject(), 'PropertyChangeCallback', @ContainerCallback);

% Now we'll add some data. 
% Create some data...
t= 0:.035:2*pi;
[a,b]=pol2cart(t,sin(2*t).*cos(2*t));

a1.getObject().setXData(a);
a1.getObject().setYData(b);
f.CurrentAxes.getObject().getView().updatePlots();

% For illustration let's create a JCheckBox, add it graph and link to to
% the Selected property of the plot. Selecting the plot will also select
% the check box. We will  make the link bidirectional using the state
% change callback of the JCheckBox
% First flush the event queue so the layout is up-to-date
drawnow();
% Create a checkbox and add it to the graph (we could also add it to the
% graph container). The layout is up-to-date, so we can use graph units
% when adding the component (Waterloo graphs support that).
chkbx=f.CurrentAxes.getObject().getView().add(javax.swing.JCheckBox('This is the linked checkbox'), 0.35, 0.3);
javaObjectEDT(chkbx);
% Revalidate the layout to position the new component
% Create a link to the plot
a1.getObject().addLink(chkbx);
% Install bidirectional control
chkbx=handle(chkbx, 'callbackproperties');
set(chkbx, 'StateChangedCallback', {@CheckBoxSynch, a1.getObject()});
f.CurrentAxes.getObject().getView().revalidate();


% Be tidy... clear the circular reference via the check box callback on
% figure deletion so MATLAB can clean up. Note this is only needed when
% Java objects are created independently - the GX class objects do this
% automatically.
set(f.getParent(), 'DeleteFcn', {@CleanLeaks, chkbx});
drawnow();
return
end


function XDataCallback(hObj, EventData)
disp('');
disp('XData update callback has been called');
disp('The source of the property change event is:');
disp(EventData.getSource());
return
end

function YDataCallback(hObj, EventData)
disp('');
disp('YData update callback has been called');
disp('The source of the property change event is:');
disp(EventData.getSource());
return
end

function PlotCallback(hObj, EventData)
disp('The property change on the the data has been sent "upwards" to the plot');
disp('The source of the property change event is:');
disp(EventData.getSource());
% Update check the linked check box state
if hObj.getLinks().size()>0
    hObj.getLinks().get(0).setSelected(hObj.isSelected());
end

return
end

function GraphCallback(hObj, EventData)
disp('')
disp('IN THE GRAPH CALLBACK. MAY BE HERE THROUGH CHANGES TO THE GRAPH OR TO NODES FURTHER DOWN THE CHAIN.');
disp('The source of the current property change event is:');
disp(EventData.getSource());
return
end

function ContainerCallback(hObj, EventData) %#ok<DEFNU>
disp('')
disp('IN THE GRAPH CONTAINER CALLBACK. MAY BE HERE THROUGH CHANGES TO THE CONTAINER OR TO NODES FURTHER DOWN THE CHAIN.');
disp('The source of the current property change event is:');
disp(EventData.getSource());
return
end

function CheckBoxSynch(hObj, EventData, plot)
plot.setSelected(hObj.isSelected());
return
end

function CleanLeaks(hObj, EventDatam, chk)
set(chk, 'StateChangedCallback',[]);
return
end
