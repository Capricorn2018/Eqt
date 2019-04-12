function [] = ep_fwd12m(a,p)
% ep_fwd12m 未来12个月预期ep

%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/ep_fwd12m.h5'];
%     tgt_tag = 'ep_fwd12m'; 
%     [S,ep_fwd12m] =  check_exist(tgt_file,'/ep_fwd12m',p,T,N);
%     
%     if S>0
%         
%         stk_code = p.stk_codes;        
%         
%         for i=S:T
%             
%             sdt = p.all_trading_dates_{i};
%             %sdt = int2str(dt);
%             sdt = [sdt(1:4),'-',sdt(5:6),'-',sdt(7:8)];
%             
%             file = ['D:\Capricorn\DB\zyyx\daily\con_forecast_roll_stk\con_forecast_roll_stk_',sdt,'.mat'];
%             
%             if exist(file,'file')==2
%                 load(file);
%             else
%                 continue;
%             end
%             
%             eps_stk = cell_s2l(t.STOCK_CODE); % 把朝阳永续里的股票代码补齐
%             
%             % 一致预期净利润增长率
%             eps = t.CON_EPS_ROLL; % 要替换的是这里
%             
%             [all_stk,~,~] = union(eps_stk,stk_code);
%             [~,eps_i] = ismember(eps_stk,all_stk);
%             [~,stk_i] = ismember(stk_code,all_stk);
%             
%             if length(all_stk) > length(stk_code)
%                 tmp = nan(size(ep_fwd12m,1),length(all_stk));
%                 tmp(:,stk_i) = ep_fwd12m;
%                 ep_fwd12m = tmp;
%                 stk_code = all_stk;                
%             end
%             
%             ep_fwd12m(i,eps_i) = eps;
%                     
%         end        
%         
%         if exist(tgt_file,'file')==2
%             eval(['delete ',tgt_file]);
%         end
%         
%         eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',stk_code,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/ep_fwd12m.mat'];
    if exist(tgt_file,'file')==2
        ep_fwd12m = load(tgt_file);
        dt = ep_fwd12m.data.DATEN;
        dt_max = max(dt);
    else
        dt_max = 0;
    end    
    
    
    if dt_max<=p.all_trading_dates(end)
        
        S = find(p.all_trading_dates>dt_max,1);
        
        for i = S:length(p.all_trading_dates)
        
            sdt = p.all_trading_dates_{i};
            sdt = [sdt(1:4),'-',sdt(5:6),'-',sdt(7:8)];
            
            DATEN = datenum(p.all_trading_dates_{i},'yyyymmdd');
            
            file = [a.zyyx_path,'/con_forecast_roll_stk/con_forecast_roll_stk_',sdt,'.mat'];
            
            if exist(file,'file')==2
                load(file);
            else
                continue;
            end
            
            append = struct();
            append.data = table();
            append.code_map = table();
            
            append.data.stk_codes = cell_s2l(t.STOCK_CODE); % 把朝阳永续里的股票代码补齐
            append.data.DATEN = ones(height(t),1) * DATEN;
            append.data.ep_fwd12m = t.CON_EPS_ROLL;
            
            append.code_map.stk_codes = unique(append.data.stk_codes);
            append.code_map.stk_num = (1:height(append.code_map))';
            
            [~,Locb] = ismember(append.data.stk_codes,append.code_map.stk_codes);
            append.data.stk_num = append.code_map.stk_num(Locb);
            
            append.data = append.data(:,{'DATEN','stk_num','ep_fwd12m'});
            
            if exist('ep_fwd12m','var')==1
                ep_fwd12m = factor_append(ep_fwd12m,append);
            else
                ep_fwd12m = append;
            end
                        
        end
        
        data = ep_fwd12m.data; %#ok<NASGU>
        code_map = ep_fwd12m.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);        
        
    end


end

function cell_lcode=cell_s2l(cell_scode)

    cell_lcode = cell(size(cell_scode,1),1);
    for i=1:length(cell_scode)
        cell_lcode{i} = s2l(cell_scode{i});
    end

end

% 短代码转换为长代码
% 从'000001'变化为'000001.SZ'
function lcode = s2l(scode)

    switch scode(1)
        case '6'
            lcode = [scode,'.SH'];
        case {'0' ,'3'}
            lcode = [scode,'.SZ'];
        otherwise
            disp([scode,': not start with 0,3,or 6']);
            return;
    end

end

