function z = factor_append(x , append)
%FACTOR_APPEND 此处显示有关此函数的摘要
%   此处显示详细说明

    code_map1 = x.code_map;
    code_map2 = append.code_map;

    C = outerjoin(code_map1,code_map2,'Keys',{'stk_codes'},'Type','full');
    C.stk_codes = C.stk_codes_code_map1;
    C.stk_codes(isnan(C.stk_num_code_map1)) = C.stk_codes_code_map2(isnan(C.stk_num_code_map1));
    C = sortrows(C,{'stk_codes'},{'ascend'});
    
    stk_num1 = C.stk_num_code_map1;
    
    count = length(stk_num1(isnan(stk_num1)));
    stk_num1(isnan(stk_num1)) = ((max([stk_num1;0])+1):(max([stk_num1;0])+count))';
    C.stk_num_code_map1 = stk_num1;
    
    append_data = outerjoin(append.data,C,'LeftKeys',{'stk_num'},'RightKeys',{'stk_num_code_map2'},'RightVariables',{'stk_num_code_map1'},'Type','left');
    append_data.stk_num = append_data.stk_num_code_map1;
    append_data = append_data(:,x.data.Properties.VariableNames);
    
    data = [x.data;append_data];
    C.stk_num = C.stk_num_code_map1;
    code_map = C(:,{'stk_codes','stk_num'});
    
    z = struct();
    z.data = data;
    z.code_map = code_map;

end

