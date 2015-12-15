function plotTP_TF_PerFrame( truePositives, totalForeground )
%PLOTP_TF_PERFRAME plot true positives and total foreground of the ground
%truth
%   Recieve the information:
%       * f1ScoreArray: A vector of f1score of each frame.
%   The output are:
%       * Nothing
    figure;
    plot(truePositives, 'b');
    hold on;
    plot(totalForeground,'r');
    
    title('True Positives & Total Foreground vs #frame');
    xlabel('#frame');
    legend('True Positives', 'Total Foreground', 'Location' , 'SouthEast')
end