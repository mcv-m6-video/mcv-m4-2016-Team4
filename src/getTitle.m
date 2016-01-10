function str = getTitle(id)
    % Get the name of the sequence given an id
    switch id
        case 1
            str = 'Highway';
        case 2
            str = 'Fall';
        case 3
            str = 'Traffic';
        otherwise
            error('Unknown id.');
    end
end
