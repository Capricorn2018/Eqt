function [ datenum_matlab ] = datenum_h5( h5_string )
     
    datenum_matlab = zeros(size(h5_string,1),1);
    for  i = 1: size(h5_string,1)
         x = cell2mat(h5_string(i));
         datenum_matlab(i,1) = datenum(str2double(x(1:4)),str2double(x(5:6)),str2double(x(7:8)));
    end
     
end

