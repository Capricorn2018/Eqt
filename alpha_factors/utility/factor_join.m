function z = factor_join( x , y , tag_x, tag_y)
% 把两个load进来的mat文件进行date和s_info_windcode为键值的outer join
% 其中stk_codes是做过对照处理的, 类似R语言中的factor类型里面的level
% tag_x, tag_y是x和y中需要的列名, 必须为Cell: 例如 tag_x = {'tot_shr'};

    code_map1 = x.code_map;
    code_map2 = y.code_map;

    C = innerjoin(code_map1,code_map2,'Keys',{'stk_codes'});
    
    data1 = x.data(:,['DATEN','stk_num',tag_x]);
    data2 = y.data(:,['DATEN','stk_num',tag_y]);
    
    [Lia,Locb] = ismember(data1.stk_num,C.stk_num_code_map1);
    data1.stk_num2 = nan(height(data1),1);
    data1.stk_num2(Lia) = C.stk_num_code_map2(Locb(Locb>0));
    
    data = innerjoin(data1,data2,'LeftKeys',{'stk_num2','DATEN'},'RightKeys',{'stk_num','DATEN'});
    data = data(:,['DATEN','stk_num',tag_x, tag_y]);
    code_map = C(:,{'stk_codes','stk_num_code_map1'});
    code_map.Properties.VariableNames = {'stk_codes','stk_num'};
    
    z.data = data;
    z.code_map = code_map;


end

