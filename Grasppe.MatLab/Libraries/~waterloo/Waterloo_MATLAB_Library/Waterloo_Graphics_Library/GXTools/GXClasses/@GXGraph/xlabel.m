function str=xlabel(target, str, pos)

if nargin<3 || strcmpi(pos,'bottom')
    if (target.getObject().getView().isBottomAxisPainted)
        target.getObject().getView().getBottomAxis().setText(str);
        str=target.getObject().getView().getBottomAxis().getText();
    end
end

if nargin<3 || strcmpi(pos,'top')
    if (target.getObject().getView().isTopAxisPainted)
        target.getObject().getView().getTopAxis().setText(str);
        str=target.getObject().getView().getTopAxis().getText();
    end
end

return
end