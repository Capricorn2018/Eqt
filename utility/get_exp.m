function f  = get_exp(T_sector,T_style, mdl,id,u)
     
    % 从回归的结果计算真正的factor return, 尤其是行业因子
    % u是每个行业的权重, id是在做行业因子调整时作为分母的那个行业的下标

     b = mdl.Coefficients(:,1);
     mkt = array2table(nan(1,1),'RowNames',{'Exp'},'VariableNames',{'mkt'}); 
     sec = array2table(nan(1,size(T_sector,2)),'RowNames',{'Exp'},'VariableNames',T_sector.Properties.VariableNames);
     sty = array2table(nan(1,size(T_style,2)), 'RowNames',{'Exp'},'VariableNames',T_style.Properties.VariableNames);
    
     mkt(:,ismember(mkt.Properties.VariableNames,b.Properties.RowNames))  = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,mkt.Properties.VariableNames))');
     
     sec(:,ismember(T_sector.Properties.VariableNames,b.Properties.RowNames)) = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,T_sector.Properties.VariableNames))');
   
     % 作为分母的那个行业的factor return
     sec(:,id) = array2table(- nansum(table2array(sec).*u')/u(id));
      
     disp(['sum of weighted factor rtns: ',num2str(sum(table2array(sec).*u'))])
     
     sty(:,ismember(T_style.Properties.VariableNames,b.Properties.RowNames)) = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,T_style.Properties.VariableNames))');  
 
     f = [mkt,sec,sty];
end