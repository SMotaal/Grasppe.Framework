function finish()
  
  persistent T M
  %t = GrasppeKit.DelayedCall(@(s, e)forceQuit,5,'start');
  
  % Yes = getString(message('MATLAB:finishdlg:Yes'));
  % No = getString(message('MATLAB:finishdlg:No'));
  % button = questdlg(getString(message('MATLAB:finishdlg:ReadyToQuit')), ...
  %                   getString(message('MATLAB:finishdlg:ExitingDialogTitle')),Yes,No,No);
  % switch button
  %   case Yes,
  %     disp(getString(message('MATLAB:finishdlg:ExitingMATLAB')));
  %       forceQuit;
  %   case No,
  %     try stop(t); end
  %     try delete(t); end
  %     quit cancel;
  % end
  if isempty(M), M = 0; end
  
  if isempty(T) || toc(T)>3
    T = tic;
    M = 1;
    fprintf(2, '\b\n\n\tQuit:');
    fprintf(1, '\tPress CMD+Q once again in the next 3 seconds to quit.\n\n');
    isQuitting(true);    
    GrasppeKit.DelayedCall(@(s, e)abort(),4,'start');
    pause(0.1);
    cancel();
    return;
  else
    if M==1
      fprintf(2, '\b\n\tQuit:');
      fprintf(1, '\tPress CMD+Q once again to force quit.\n\n');
      %GrasppeKit.DelayedCall(@(s, e)terminate,[],'start');
      pause(0.1);
      terminate();
      M = 2;
    elseif M==2
      force;
    end
  end
end

function abort()
  isQuitting(false);
  fprintf(2, '\b\n\tQuit:');
  fprintf(1, '\tTermination is aborted. To quit, you must press CMD+Q twice within three seconds.\n\n');
end

function cancel()
  isQuitting(false);
  quit('cancel');
end

function terminate()
  close all;
  cleardebug; cleardebug;
  pause(1);
end

function force()
  quit('force');
end
