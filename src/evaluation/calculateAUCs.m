function aucs = calculateAUCs(precisions, recalls, folderFigures, legendStr, taskId)
    % calculateAUCs: calculate the Area Under the Curve (AUC) given the
    % precision and recall of each sequence.
    % Inputs:
    %         - precisions: NxM, where N is the precision of M_i set of
    %                       samples.
    %         - recalls:    NxM, where N is the recall of M_i set of
    %                       samples.
    % Also, figures are stored at folderFigures if specified.
    
    % Change the color list depending on the number of lines to plot and
    % the colormap.
    colorList = lines(size(precisions,2)+1);
    
    saveFigures = true;
    if ~exist('folderFigures','var')
        saveFigures = false;
    else
        % Check and create the file where the figures should be stored
        if ~exist(folderFigures, 'dir')
            mkdir(folderFigures);
        end
        % Initialize figure
        fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10]);
        hold on; 
        title('Precision Recall Curve', 'FontWeight', 'Bold');
        xlabel('Recall'); ylabel('Precision');
        xlim([0 1]); ylim([0 1]);
        legendAux = cell(0,0);
    end
    
    %  Initialization
    aucs = zeros(size(precisions,2),1);
    
    for i=1:size(precisions,2)
       p = precisions(:,i); r = recalls(:,i);
       aucs(i) = abs(trapz(r,p));
       if saveFigures
          plot(r, p, 'Color', colorList(i,:)); hold on;
          if i==1
            legendAux{end+1} = [legendStr{i} sprintf(' (AUC: %.4f)', aucs(i))];
          else
            legendAux{end+1} = [legendStr{i} sprintf(' (AUC: %.4f , %+.4f)', aucs(i) , aucs(i)-aucs(i-1))];
          end
       end
      
     end
       
   % Store figure, if specified
   if saveFigures
      legend(legendAux, 'Location', 'southeast'); hold off; 
      saveas(fig, [folderFigures 'Task' taskId '_' getTitle(i) '_PRCurve.fig']);
      print(fig,[folderFigures 'Task' taskId '_' getTitle(i) '_PRCurve'],'-dpng')
   end

end