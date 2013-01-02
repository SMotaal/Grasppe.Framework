function setZOrder(obj, Z)
breakout=5;
MLComponentContainer=javax.swing.SwingUtilities.getAncestorNamed('fComponentContainer', obj.hgcontrol);
if Z>MLComponentContainer.getComponentCount()-1
    Z=MLComponentContainer.getComponentCount()-1;
end
toMove=obj.hgcontrol.getParent();
while ~toMove.getParent().equals(MLComponentContainer)
    toMove=toMove.getParent();
    breakout=breakout-1;
    if breakout<=0
        return;
    end
end
if MLComponentContainer.getComponentZOrder(toMove)~=Z
    MLComponentContainer.add(toMove,Z);
end
return
end

