function str=ylabel(target, str, pos)

if nargin<3 || strcmpi(pos,'left')
    if (target.getObject().getView().isLeftAxisPainted)
        target.getObject().getView().getLeftAxis().setText(str);
        str=target.getObject().getView().getLeftAxis().getText();
    end
end

if nargin<3 || strcmpi(pos,'right')
    if (target.getObject().getView().isRightAxisPainted)
        target.getObject().getView().getRightAxis().setText(str);
        str=target.getObject().getView().getRightAxis().getText();
    end
end

return
end