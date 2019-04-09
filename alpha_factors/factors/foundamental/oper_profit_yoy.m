function [] = oper_profit_yoy(a, p)
% oper_profit_yoy 营业利润单季同比增长率
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/oper_profit_yoy.h5'];
%     tgt_tag = 'oper_profit_yoy'; 
%     [S,oper_profit_yoy] =  check_exist(tgt_file,'/oper_profit_yoy',p,T,N);
% 
%     if S>0
%         
%        oper_file = [a.input_data_path,'/YOY_oper_profit.h5'];
% 
%        oper = h5read(oper_file,'/oper_profit');
%        oper_stk = xblank(h5read(oper_file,'/stk_code'));
%        oper_dt = datenum_h5(h5read(oper_file,'/date'));
%        
%        [~,p_i,oper_i] = intersect(p.stk_codes,oper_stk);
%        [~,p_t,oper_t] = intersect(p.all_trading_dates(S:T),oper_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        oper_profit_yoy(p_t,p_i) = oper(oper_t,oper_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/oper_profit_yoy.mat'];
    if exist(tgt_file,'file')==2
        oper_profit_yoy = load(tgt_file);
        dt = oper_profit_yoy.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        oper = load([a.input_data_path,'/YOY_oper_profit.mat']);
        
        oper.data = oper.data(oper.data.DATEN>dt_max,:);
                
        append.data.oper_profit_yoy = oper.data.oper_profit;
                            
        append.data = append.data(:,{'DATEN','stk_num','oper_profit_yoy'});
        
        if bool
            oper_profit_yoy = factor_append(oper_profit_yoy,append);
        else
            oper_profit_yoy = append;
        end
            
        data = oper_profit_yoy.data; %#ok<NASGU>
        code_map = oper_profit_yoy.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end


end

