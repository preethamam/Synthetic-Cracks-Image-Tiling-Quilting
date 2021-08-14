function [Box,plocation] = normalizecracks(Box,plocation)
    [versions_num,cracks_num] = size(plocation);
    for crack_index = 1:cracks_num
        x = Box{versions_num,crack_index}(1)-1;
        y = Box{versions_num,crack_index}(2)-1;
        if(x ~= 0 || y ~= 0)
            for version = 1:versions_num
                if(size(Box{version,crack_index}) > 0)

                    Box{version,crack_index}(1) = round (Box{version,crack_index}(1) - x);
                    Box{version,crack_index}(2) = round (Box{version,crack_index}(2) - y);

                    plocation{version,crack_index}(:,1) = round (plocation{version,crack_index}(:,1) - x );
                    plocation{version,crack_index}(:,2) = round (plocation{version,crack_index}(:,2) - y );

                    if(Box{version,crack_index}(1) <= 0)
                        plocation{version,crack_index}(:,1) = round (plocation{version,crack_index}(:,1) + abs(Box{version,crack_index}(1))+1 );
                        Box{version,crack_index}(1) = 1;
                    end 
                    if(Box{version,crack_index}(2) <= 0)
                        plocation{version,crack_index}(:,2) = round (plocation{version,crack_index}(:,2) + abs(Box{version,crack_index}(2))+1);
                        Box{version,crack_index}(2) = 1;
                    end 
                end
            end
        end
    end
end

