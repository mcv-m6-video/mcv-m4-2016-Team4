function plotTP_TF_PerFrame( truePositives, totalForeground )
%PLOTP_TF_PERFRAME plot true positives and total foreground of the ground
%truth
%   Recieve the information:
%       * truePositives: NxM matrix where N are the TP of each frame and
%                        M_i represents the TP of test sequence i
    colorList = ['b', 'g', 'm', 'y', 'c', 'k'];
    alphabet = 'ABCDEFGHIJKLMNOPQRSTWVXZ';
    legendString = cell(1,size(truePositives,2)+1);
    legendString{1} = 'Total Foreground';
    figure;
    plot(totalForeground,'r');
    hold on;
    for i=1:size(truePositives,2)
       plot(truePositives(:,i), colorList(i)); 
       legendString{i+1} = ['Test ' alphabet(i) ' TP'];
    end
    
    title('True Positives & Total Foreground vs #frame');
    xlabel('#frame'); ylabel('#pixels');
    legend(legendString);
end