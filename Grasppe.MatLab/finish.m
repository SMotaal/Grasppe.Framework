function finish()
t = GrasppeKit.DelayedCall(@(s, e)forceQuit,5,'start');

Yes = getString(message('MATLAB:finishdlg:Yes'));
No = getString(message('MATLAB:finishdlg:No'));
button = questdlg(getString(message('MATLAB:finishdlg:ReadyToQuit')), ...
                  getString(message('MATLAB:finishdlg:ExitingDialogTitle')),Yes,No,No);
switch button
  case Yes,
    disp(getString(message('MATLAB:finishdlg:ExitingMATLAB')));
      forceQuit;
  case No,
    try stop(t); end
    try delete(t); end
    quit cancel;
end
end

function forceQuit()
  close all;
  cleardebug; cleardebug;
  quit('force');
end
