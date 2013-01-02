classdef GJDial < GTool
    
    methods
        
        function obj=GJDial(target, varargin)
            obj.Object=jcontrol(target, kcl.waterloo.widget.GJDial(),varargin{:});
            % see below
%             set(obj.Object, 'MouseDraggedCallback', {@MouseDraggedCallback});
%             set(obj.Object, 'MousePressedCallback', {@MousePressedCallback});
%             set(obj.Object, 'MouseClickedCallback', {@MouseClickedCallback});
            return
        end

    end
    
end


% % % Needs finishing and these Callbacks need to be added to the Java
% % % Class
% % 
% function MouseClickedCallback(hObject, EventData)
% hObject.setTheta(mouseTheta(hObject, EventData)+hObject.getThetaOffset());
% return
% end
% 
% function MousePressedCallback(hObject, EventData)
% hObject.setMouseThetaAtDragStart(mouseTheta(hObject, EventData));
% hObject.setThetaAtDragStart(hObject.getTheta());
% return
% end
% 
% function MouseDraggedCallback(hObject, EventData)
% thisArc=arclength(mouseTheta(hObject, EventData), hObject.getMouseThetaAtDragStart);
% newTheta=hObject.getThetaAtDragStart()-thisArc;
% oldTheta=hObject.getTheta();
% hObject.setTheta(newTheta);
% if abs(newTheta)<pi/10
%     if oldTheta<0 && newTheta >0
%         hObject.setTurnCount(hObject.getTurnCount()-1);
%     elseif oldTheta>0 && newTheta<0
%         hObject.setTurnCount(hObject.getTurnCount()+1);
%     end
% end
% %fprintf('%5f\n', hObject.getTurnCount);
% return
% end
% 
% function theta=mouseTheta(hObject, EventData)
% x=EventData.getX()-hObject.getWidth()/2;
% y=hObject.getHeight()-EventData.getY()-hObject.getHeight()/2;
% sintheta=y/sqrt(x.^2+y.^2);
% theta=getTheta(sintheta,x,y);
% return
% end
% 
% function theta=getTheta(sintheta,x,y)
% if x>=0 && y>=0
%     theta=asin(sintheta);
% elseif x<=0 && y>=0
%     theta=pi-asin(sintheta);
% elseif x<=0 && y<=0
%     theta=-(pi+asin(sintheta));
% else
%     theta=asin(sintheta);
% end
% return
% end
% 
% function arc=arclength(theta1, theta2)
% arc=theta2-theta1;
% return
% end




    
    
    
