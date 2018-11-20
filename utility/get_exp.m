function f  = get_exp(T_sector,T_style, mdl,id,u)
     


     b = mdl.Coefficients(:,1);
     mkt = array2table(nan(1,1),'RowNames',{'Exp'},'VariableNames',{'mkt'}); 
     sec = array2table(nan(1,size(T_sector,2)),'RowNames',{'Exp'},'VariableNames',T_sector.Properties.VariableNames);
     sty = array2table(nan(1,size(T_style,2)), 'RowNames',{'Exp'},'VariableNames',T_style.Properties.VariableNames);
    
     mkt(:,ismember(mkt.Properties.VariableNames,b.Properties.RowNames))  = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,mkt.Properties.VariableNames))');
     
     sec(:,ismember(T_sector.Properties.VariableNames,b.Properties.RowNames)) = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,T_sector.Properties.VariableNames))');
   
     sec(:,id) = array2table( nansum(table2array(sec).*u')/u(id));
     
     sty(:,ismember(T_style.Properties.VariableNames,b.Properties.RowNames)) = ...
         array2table(b.Estimate(ismember(b.Properties.RowNames,T_style.Properties.VariableNames))');  
 
     f = [mkt,sec,sty];
end