function  b = yyyy2datenum(a)

    % 从yyyymmdd格式的日期转换成datenum

     if  ~isempty(a)
         b = zeros(length(a),1);
         for i = 1: length(a)
             x = cell2mat(a(i));
             b(i,1) = datenum(str2double(x(1:4)),str2double(x(5:6)),str2double(x(7:8)));
         end       
     else
          b = [];
     end
  
end