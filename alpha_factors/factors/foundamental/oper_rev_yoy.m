function [] = oper_rev_yoy(a, p)
% operrev_yoy 营业收入单季同比增长率
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/oper_rev_yoy.h5'];
%     tgt_tag = 'oper_rev_yoy'; 
%     [S,oper_rev_yoy] =  check_exist(tgt_file,'/oper_rev_yoy',p,T,N);
% 
%     if S>0
%         
%        rev_file = [a.input_data_path,'/YOY_oper_rev.h5'];
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = xblank(h5read(rev_file,'/stk_code'));
%        rev_dt = datenum_h5(h5read(rev_file,'/date'));
%        
%        [~,p_i,rev_i] = intersect(p.stk_codes,rev_stk);
%        [~,p_t,rev_t] = intersect(p.all_trading_dates(S:T),rev_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        oper_rev_yoy(p_t,p_i) = rev(rev_t,rev_i); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

   tgt_file = [a.output_data_path,'/oper_rev_yoy.mat'];
    if exist(tgt_file,'file')==2
        oper_rev_yoy = load(tgt_file);
        dt = oper_rev_yoy.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/YOY_oper_rev.mat']);
        
        rev.data = rev.data(rev.data.DATEN>dt_max,:);
            
        append = rev;
        append.data.oper_rev_yoy = append.data.oper_rev;
                            
        append.data = append.data(:,{'DATEN','stk_num','oper_rev_yoy'});
        
        if bool
            oper_rev_yoy = factor_append(oper_rev_yoy,append);
        else
            oper_rev_yoy = append;
        end
            
        data = oper_rev_yoy.data; %#ok<NASGU>
        code_map = oper_rev_yoy.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end


end

