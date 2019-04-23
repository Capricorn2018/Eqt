function y = fillnan(x)
% ”√«∞÷µÃÓ≥‰NaN

    idx = 1:length(x);
    
    idx(isnan(x)) = NaN;
    
    y = nan(length(x),1);
    
    for i=1:length(x)
        
        if isnan(x(i))
            
            prev = nanmax(idx(1:i));
            
            if ~isnan(prev)
                y(i) = price(prev);
            end
            
        else
            y(i) = x(i);            
        end            
        
    end

end

