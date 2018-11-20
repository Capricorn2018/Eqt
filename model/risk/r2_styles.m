function  r2_styles(p,a,K1,K2)

     N = length(p.model.stk_codes);
     T = length(p.model.model_trading_dates);
     M = length(p.style.style);  % number of styles
%% 

     
    for j  = 1 : height(p.style.sty)
       file_name  =  p.file.(cell2mat(p.style.sty.descriptors_(j)));
       tag_name   = get_tag(file_name);
       eval([cell2mat(p.style.sty.descriptors_(j)),' = h5read(''',file_name,'', ''',''/',tag_name,''');']);
    end
    clear j;
    
    for  idx_index = K1:K2
      
        idx = find(p.model.model_trading_dates(1)==p.model.all_trading_dates);      
        index_w = zeros(T,1);

        index_membs  =  p.model.indexmemb.(['index',num2str(idx_index)]); %　基准成分    
        index_membs_n   = table2array(index_membs);
        
        [style_cover,style_mean,style_std,style_skew,style_kurt] = deal([datenum(p.model.model_trading_dates), zeros(T,M)]);
        
        for i = 1 :T 
             load ([a.sector,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_today','T_stocks_cap_freecap_sector','T_sectors_cap_freecap','T_sus');
             
             idx_stk = ismember(p.model.stk_codes1',T_sector_today.Properties.RowNames);      % 今天的股票，包括停盘的  
                          
           %  [T_des,T_style]   = deal(cell2table(T_sector_today.Properties.RowNames,'VariableNames',{'stk_codes'}));       %T_des: descriptors, T_style:factors          

             T_des = T_sector_today;
             
             T_sector_style = T_sector_today;
             
             % 把所有股票中不是benchmark 成分的除去，仅仅用benchmark 的成分来计算zscore
             indexw  =  index_membs_n(max(i-1,1),:);      % 昨天的指数权重
             weight_vector = indexw(idx_stk)';  % 如果指数存在停盘，这里可以不是100
             index_w(i,1) = sum(weight_vector);

             for j = 1 : M
                if ~strcmp(p.style.style(j),'soe')
                    descriptors = p.style.sty.descriptors_(strcmp(p.style.sty.factors,p.style.style(j)));
                    wei         = p.style.sty.weight(strcmp(p.style.sty.factors,p.style.style(j)));
                    z = zeros(height(T_des),1);
                    for k = 1 : length(wei)
                        eval(['T_des.(cell2mat(descriptors(k))) =' cell2mat(descriptors(k)),'(idx-1,idx_stk)'';']);% 取数，取的是昨天的exposure
                        z = z + wei(k)*cal_zscore(T_des.(cell2mat(descriptors(k))),weight_vector);  % cal zscore
                    end
                   % T_style.(cell2mat(p.style.style(j))) = cal_zscore(z,weight_vector);
                   T_sector_style.(cell2mat(p.style.style(j))) = cal_zscore(z,weight_vector);
                end
             end

             if any(ismember(p.style.style,'soe'))
                %  p.styles01  可以用到这里自动弄，鉴于现在这样的变量只有SOE一个，先凑合了
                T_des.soe  = soe(idx-1,idx_stk)';
               % T_style.soe  = soe(idx-1,idx_stk)';
               T_sector_style.soe  = soe(idx-1,idx_stk)';
             end
             
%               [~,loc] = ismember(['stk_codes',p.style.style'],T_style.Properties.VariableNames);
%               T_style = T_style(:,loc(loc>0));
%              
%              T_sector_today.stk_codes = T_sector_today.Properties.RowNames;
% 
%              T_sector_style = outerjoin(T_sector_today,T_style,'Type','left','MergeKeys',true);
%              T_sector_style.Properties.RowNames   = T_sector_style.stk_codes;
%              T_sector_style.stk_codes = [];
%          
%              T_sector_style = T_sector_style(T_sector_today.Properties.RowNames,:);
             
               [~,loc] = ismember([p.style.style'],T_sector_style.Properties.VariableNames);
              T_style = T_sector_style(:,loc(loc>0));

             [ non_nans,nans,means,stds,skews,kurts ] = nan_stat( table2array(T_style(:,1:end)));
             style_cover(i,2:end) = non_nans';
             style_mean(i,2:end) = means';
             style_std(i,2:end)   =  stds';
             style_skew(i,2:end)  =  skews';
             style_kurt(i,2:end)  =  kurts';

             save ([a.style,'\','Index',num2str(idx_index),'_',datestr(p.model.model_trading_dates(i),29),'.mat'],'T_sector_style','T_des'); 
            
             if i<T,idx = idx+1;end;
        end
        save ([a.backtest,'\style\style_stats_','Index',num2str(idx_index),'.mat'],'style_mean','style_cover','style_std','style_skew','style_kurt','index_w');
   end  %end for  for  idx_index = K1:K2
%%     
      
    
% %%      plots
%      x = p.model.model_trading_dates;
%      
%      style_cover = array2table(style_cover(:,2:end),'RowNames', cellstr(datestr(style_cover(:,1),29)),'VariableNames',p.style.style');
%      style_std   = array2table(style_std(:,2:end),  'RowNames', cellstr(datestr(style_std(:,1),29)),  'VariableNames',p.style.style');
%      style_skew  = array2table(style_skew(:,2:end), 'RowNames', cellstr(datestr(style_skew(:,1),29)), 'VariableNames',p.style.style');
%      style_kurt  = array2table(style_kurt(:,2:end), 'RowNames', cellstr(datestr(style_kurt(:,1),29)), 'VariableNames',p.style.style');
%       
%     fig = mul_plot( x, table2array(style_cover), p.style.style','coverage');
%     saveas(fig,[a.backtest,'\style\','\style_cover.png']); fig.delete; clear fig;
%     
%     fig = mul_plot( x, table2array(style_std), p.style.style','std');
%     saveas(fig,[a.backtest,'\style\','\style_std.png']); fig.delete; clear fig;
%     
%     fig = mul_plot( x, table2array(style_skew), p.style.style','skew');
%     saveas(fig,[a.backtest,'\style\','\style_skew.png']); fig.delete; clear fig;
%     
%     fig = mul_plot( x, table2array(style_kurt), p.style.style','kurt');
%     saveas(fig,[a.backtest,'\style\','\style_kurt.png']); fig.delete; clear fig;
%     
%     for  i =  1: length(p.style.style')
%          fig = figure;
%         % title(cell2mat(style_factors(i)));
%          subplot(2,2,1)
%             plot(x,table2array(style_cover(:,i)))
%             datetick('x','yyyy','keepticks');xlim manual
%             title('Coverage'); 
%          subplot(2,2,2)
%             plot(x,table2array(style_std(:,i)))
%             datetick('x','yyyy','keepticks');xlim manual
%             title('Std');
%          subplot(2,2,3)
%             plot(x,table2array(style_skew(:,i)))
%             datetick('x','yyyy','keepticks');xlim manual
%             title('Skew');
%          subplot(2,2,4)
%             plot(x,table2array(style_kurt(:,i)))
%             datetick('x','yyyy','keepticks');xlim manual
%             title('Kurt');
%         saveas(fig,[a.backtest,'\style\',cell2mat(p.style.style(i)),'.png']); 
%         fig.delete; clear fig;
%     end
end