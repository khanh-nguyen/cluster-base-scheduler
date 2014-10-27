function plotDots(points, xlab, ylab) 
%% Plot a column vectors as dots on a horizontal line
    validateattributes(points,{'numeric'},{'column'});
    n = length(points);
    plot(points, zeros(n,1), '-bo',...
        'MarkerSize',7,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0,0,0]);
        
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    xlabel(xlab);
    ylabel(ylab);
end