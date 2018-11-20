function [ stk_code_cell ] = stk_code_h5( h5_string )
     stk_code_cell  = cell(size(h5_string,1),1);
     for  i = 1: size(h5_string,1)
         stk_code_cell(i,1) = h5_string(i);
     end  
end

