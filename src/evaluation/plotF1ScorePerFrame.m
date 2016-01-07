function plotF1ScorePerFrame( f1Scores )
%PLOTF1SCOREPERFRAME plot the f1score per frame
%   Recieve the information:
%       * f1Scores: NxM matrix where N are the F1 Scores of each frame and
%                        M_i represents the F1 Score of test sequence i

    colorList = [ 'b', 'g', 'm', 'y', 'c', 'k'];
    alphabet = 'ABCDEFGHIJKLMNOPQRSTWVXZ';
    legendString = cell(1,size(f1Scores,2));
    figure();
    hold on;
    for i=1:size(f1Scores,2)
       plot(f1Scores(:,i), colorList(i)); 
       legendString{i} = ['Test ' alphabet(i)];
    end
    title('F1-Score vs #frame');
    ylim([0 1]);
    xlabel('#frame'); ylabel('F1-Score');
    legend(legendString);
end

