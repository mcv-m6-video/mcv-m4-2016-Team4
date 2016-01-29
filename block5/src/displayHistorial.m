function displayHistorial(historial)
    disp('HISTORIAL');
    disp('-----------------------');
    for i=1:length(historial)
        disp(sprintf(['\tVehicle num: ' num2str(i)]))
        disp(sprintf(['\t\t - Location: (x=' num2str(historial{i}.location(1)) ', y=' num2str(historial{i}.location(2)) ')']))
        disp(sprintf(['\t\t - Velocity: ' num2str(historial{i}.avgVel)]))
    end
    disp('-----------------------');
    disp(['Total:', num2str(length(historial))]);
end