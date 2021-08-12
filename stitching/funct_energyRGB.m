function res = funct_energyRGB(I)
% returns energy of all pixelels
% e = |dI/dx| + |dI/dy|
    res = funct_energyGrey(I(:, :, 1)) + funct_energyGrey(I(:, :, 2)) +...
          funct_energyGrey(I(:, :, 3));
end