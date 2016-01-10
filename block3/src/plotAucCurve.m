function plotAucCurve(seq, pixels, AUC, folderFigures, taskId)

    % Check and create the folder where the figures should be stored
    if ~exist(folderFigures, 'dir')
        mkdir(folderFigures);
    end
        
    % Change the color list depending on the number of lines to plot and
    % the colormap.
    colorList = lines(seq.nSequences);
    
    fig = figure('Visible','off','PaperUnits','centimeters','PaperPosition',[0 0 12.5 10.5]);
    hold on; 
    title(['AUC vs #pixels (P)'], 'FontWeight', 'Bold');
    xlabel('#pixels(P)'); ylabel('AUC');
    legendAux = {};
    for sequence = 1:seq.nSequences
        legendAux{end+1} = getTitle(sequence);
        plot(pixels, AUC(sequence,:), 'Color', colorList(sequence,:));
    end
    savefig(fig, [folderFigures 'Task' taskId '_AUCvsPixels.fig']);
    print(fig,[folderFigures 'Task' taskId '_' '_AUCvsPixels'],'-dpng')
end