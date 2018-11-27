function  [x1,x2] = get_dates_from_rpt(x)

    z = year(x);
    switch month(x)
        case 3
            x1 = datenum(z,05,01); x2 = datenum(z,08,31);
        case 6 
            x1 = datenum(z,09,01); x2 = datenum(z,10,31);
        case 9
            x1 = datenum(z,11,01); x2 = datenum(z+1,04,30);
        otherwise
            x1 =[]; x2 = [];
    end
    
end