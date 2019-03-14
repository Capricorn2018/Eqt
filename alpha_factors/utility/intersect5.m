function [G,ia,ib,ic,id,ie] = intersect5(a,b,c,d,e)
% a,b,c,d,e之间的重合项
    
     if(iscell(a))
        if(ischar(a{1}))
            for i=1:length(a)
                a{i} = deblank(a{i});
            end

            for i=1:length(c)
                c{i} = deblank(c{i});
            end

            for i=1:length(b)
                b{i} = deblank(b{i});
            end
            
            for i=1:length(d)
                d{i} = deblank(d{i});
            end
            
            for i=1:length(e)
                e{i} = deblank(e{i});
            end
            
        end
    end


    [H,ia1,ib1,ic1] = intersect3(a,b,c);
    
    [G,ih,id,ie] = intersect3(H,d,e);
    
    ia = ia1(ih);
    ib = ib1(ih);
    ic = ic1(ih);

end

