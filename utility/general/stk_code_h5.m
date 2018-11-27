function [ stk_code_cell ] = stk_code_h5( h5_string )

    % 把h5读出来的股票代码存在cell里面

     stk_code_cell  = cell(size(h5_string,1),1);
     for  i = 1: size(h5_string,1)
         stk_code_cell(i,1) = h5_string(i);
     end  
end

