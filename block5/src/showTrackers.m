function showTrackers(im, mask, positions)        
    subplot(1,2,1), imshow(im), hold on;
    codes = {};
    for i=1:length(positions)
        pos = positions{i};
        loc = pos.location;
        code = pos.code;

        if strcmp(code, 'inactive')
            n = 'Inactive';
            c = 'r*';
        elseif strcmp(code, 'notVehicleYet')
            n = 'Not Vehicle Yet';
            c = 'b*';
        elseif strcmp(code, 'active')
            n = 'Active';
            c = 'g*';
        end
        plot(loc(1), loc(2), c);
        codes{end+1} = n;
    end
    legend(codes, 'Location', 'NorthOutside')
    hold off;
    
    
    subplot(1,2,2), imshow(mask), hold on;
    for i=1:length(positions)
        pos = positions{i};
        loc = pos.location;
        code = pos.code;

        if strcmp(code, 'inactive')
            c = 'r*';
        elseif strcmp(code, 'notVehicleYet')
            c = 'b*';
        elseif strcmp(code, 'active')
            c = 'g*';
        end
        plot(loc(1), loc(2), c);
    end
    hold off;
    
    pause(0.001);
end