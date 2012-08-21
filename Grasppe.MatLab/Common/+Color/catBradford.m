%use Bradford Linear CAT to convert XYZ from whitepoint1 to whitepoint2 
function [XYZ2] = catBradford(XYZ1, XYZn1, XYZn2)
MCAT = [0.8951, 0.2664, -0.1614;...
       -0.7502, 1.7035, 0.0367;...
        0.0389, -0.0685, 1.0296];
 
RGB1 = MCAT*XYZn1;
RGB2 = MCAT*XYZn2;
 
XYZ2 = inv(MCAT)*diag(RGB2./RGB1)*MCAT*XYZ1;
