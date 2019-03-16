function [] = ep_fwd12m(a,p)
% ep_fwd12m 未来12个月预期eps

    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/ep_fwd12m.h5'];
    tgt_tag = 'ep_fwd12m'; 
    [S,ep_fwd12m] =  check_exist(tgt_file,'/ep_fwd12m',p,T,N);
    
    if S>0
        
        stk_code = p.stk_codes;        
        
        for i=S:T
            
            dt = p.all_trading_dates(i);
            sdt = int2str(dt);
            sdt = [sdt(1:4),'-',sdt(5:6),'-',sdt(7:8)];
            
            load('D:\Capricorn\DB\zyyx\daily\con_forecast_roll_stk\con_forecast_roll_stk_',sdt,'.mat');
            
            eps_stk = cell_s2l(t.STOCK_CODE); % 把朝阳永续里的股票代码补齐
            eps = t.CON_EPS_ROLL;
            
            [all_stk,eps_i,stk_i] = union(eps_stk,stk_code);
            
            if length(all_stk) > length(code)
                tmp = nan(size(ep_fwd12m,1),length(all_stk));
                tmp(:,stk_i) = ep_fwd12m;
                ep_fwd12m = tmp;
                stk_code = all_stk;                
            end
            
            ep_fwd12m(i,stk_i) = eps(eps_i);
                    
        end        
        
        if exist(tgt_file,'file')==2
            eval(['delete ',tgt_file]);
        end
        
        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',stk_code,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end
    

end

function cell_lcode=cell_s2l(cell_scode)

    cell_lcode = cell(size(cell_scode,1),1);
    for i=1:length(cell_scode)
        cell_lcode{i} = scode2lcode(cell_scode{i});
    end

end

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

