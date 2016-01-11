function [auc1, auc2] = calculateAUCs(seq, results, folderFigures, legendStr, taskId)
    % calculateAUCs: calculate the Area Under the Curve (AUC) given the
    % precision and recall of each sequence.
    % Also, figures are stored at folderFigures if specified.
    
    % Change the color list depending on the number of lines to plot and
    % the colormap.
    colorList = lines(size(results.prec2,3)+1);
    
    saveFigures = true;
    if ~exist('folderFigures','var')
        saveFigures = false;
    else
        % Check and create the file where the figures should be stored
        if ~exist(folderFigures, 'dir')
            mkdir(folderFigures);
        end
    end
    
    % AUC of original sequence
    auc1 = zeros(seq.nSequences,1);
    % AUC of morpho sequence
    auc2 = zeros(seq.nSequences,size(results.prec2,3));
    
    for i=1:seq.nSequences
       p1 = results.prec1(i,:); r1 = results.rec1(i,:);
       auc1(i) = abs(trapz(r1,p1));
       if saveFigures
          fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10]);
          hold on; 
          title([getTitle(i) ' Precision Recall Curve'], 'FontWeight', 'Bold');
          xlabel('Recall'); ylabel('Precision');
          legendAux{1} = [legendStr{1} sprintf(' (AUC: %.4f)', auc1(i))];
          xlim([0 1]); ylim([0 1]);
          plot(r1, p1, 'Color', colorList(1,:));
       end
       for j=1:size(results.prec2,3)
            p2 = results.prec2(i,:,j); r2 = results.rec2(i,:,j);
            auc2(i,j) = abs(trapz(r2, p2));
            if saveFigures
               plot(r2, p2, 'Color', colorList(j+1,:)); 
               legendAux{j+1} = [legendStr{j+1} sprintf(' (AUC: %.4f , %+.4f)', auc2(i,j) , auc2(i,j)-auc1(i))];
            end
       end
       
       % Store figure, if specified
       if saveFigures
          legend(legendAux, 'Location', 'southeast'); hold off; 
          saveas(fig, [folderFigures 'Task' taskId '_' getTitle(i) '_PRCurve.fig']);
          print(fig,[folderFigures 'Task' taskId '_' getTitle(i) '_PRCurve'],'-dpng')
       end
       
    end

end