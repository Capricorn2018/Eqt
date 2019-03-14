function [D,ia,ib,ic] = intersect3(a,b,c)
% 找a,b,c的重合项
    
    if(iscell(a))
        if(ischar(a{1}))
            for i=1:length(a)
                a{i} = deblank(a{i});
            end

            for(i=1:length(c))
                c{i} = deblank(c{i});
            end

            for i=1:length(b)
                b{i} = deblank(b{i});
            end
        end
    end


    [E,ia1,ib1] = intersect(a,b);
    
    [D,ie,ic] = intersect(E,c);
    
    ia = ia1(ie);
    ib = ib1(ie);

end

