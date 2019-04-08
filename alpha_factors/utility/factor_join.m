function z = factor_join( x , y , tag_x, tag_y)
% ������load������mat�ļ�����date��s_info_windcodeΪ��ֵ��outer join
% ����stk_codes���������մ����, ����R�����е�factor���������level
% tag_x, tag_y��x��y����Ҫ������, ����ΪCell: ���� tag_x = {'tot_shr'};

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

