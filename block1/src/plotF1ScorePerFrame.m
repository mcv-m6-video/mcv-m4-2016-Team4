function plotF1ScorePerFrame( f1ScoreArray )
%PLOTF1SCOREPERFRAME plot the f1score per frame
%   Recieve the information:
%       * f1ScoreArray: A vector of f1score of each frame.
%   The output are:
%       * Nothing
    figure();
    plot(f1ScoreArray);
    title('F1-Score vs #frame');
    ylim([0 1]);
    xlabel('#frame');
    ylabel('F1-Score');
end

