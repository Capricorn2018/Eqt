function  [x1,x2] = get_dates_from_holdigs(x)

    z = year(x);
    switch month(x)
        case 6 
             x1 = datenum(z,09,01); x2 = datenum(z+1,04,30);
        case 12
             x1 = datenum(z+1,05,01); x2 = datenum(z+1,08,31);
        otherwise
            x1 =[]; x2 = [];
    end
    
end