function [] = sales2ev(a, p)
% sales2ev 计算滚动12个月口径的 营业收入/(总市值+非流动负债-货币资金)
%     T = length(p.all_trading_dates );
%     N = length(p.stk_codes);   
%     tgt_file =  [a.output_data_path,'/sales2ev.h5'];
%     tgt_tag = 'sales2ev'; 
%     [S,sales2ev] =  check_exist(tgt_file,'/sales2ev',p,T,N);
%     
%     if S>0
%        rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
%        cap_file = [a.input_data_path,'/tot_cap.h5'];
%        liab_file = [a.input_data_path,'/LR_tot_non_cur_liab.h5'];
%        money_file = [a.input_data_path,'/LR_monetary_cap.h5'];
% 
%        rev = h5read(rev_file,'/oper_rev');
%        rev_stk = h5read(rev_file,'/stk_code');
%        rev_dt = datenum_h5(h5read(rev_file,'/date'));
%        total_capital = h5read(cap_file,'/tot_cap');
%        cap_stk = h5read(cap_file,'/stk_code');
%        cap_dt = datenum_h5(h5read(cap_file,'/date'));
%        liab = h5read(liab_file,'/tot_non_cur_liab');
%        liab_stk = h5read(liab_file,'/stk_code');
%        liab_dt = datenum_h5(h5read(liab_file,'/date'));
%        money = h5read(money_file,'/monetary_cap');
%        money_stk = h5read(money_file,'/stk_code');
%        money_dt = datenum_h5(h5read(money_file,'/date'));
%        
%        [~,p_i,rev_i,cap_i,liab_i,money_i] = intersect5(p.stk_codes,rev_stk,cap_stk,liab_stk,money_stk);
%        [~,p_t,rev_t,cap_t,liab_t,money_t] = intersect5(p.all_trading_dates(S:T),rev_dt,cap_dt,liab_dt,money_dt);
%        idx = S:T;
%        p_t = idx(p_t);
%        
%        sales2ev(p_t,p_i) = rev(rev_t,rev_i)./(total_capital(cap_t,cap_i)+liab(liab_t,liab_i)+money(money_t,money_i)); %#ok<NASGU>
% 
%        if  exist(tgt_file,'file')==2
%           eval(['delete ',tgt_file]);
%        end
%        eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
%     end

    tgt_file = [a.output_data_path,'/sales2ev.mat'];
    if exist(tgt_file,'file')==2
        sales2ev = load(tgt_file);
        dt = sales2ev.data.DATEN;
        dt_max = max(dt);
        bool = true;
    else
        dt_max = 0;
        bool = false;
    end    
    
    if dt_max<p.all_trading_dates(end)
        
        rev = load([a.input_data_path,'/TTM_oper_rev.mat']);
        cap = load([a.input_data_path,'/LR_tot_cap.mat']);
        liab = load([a.input_data_path,'/LR_tot_non_cur_liab.mat']);
        money = load([a.input_data_path,'/LR_monetary_cap.mat']);
        
        rev.data = rev.data(rev.data.DATEN>dt_max,:);
        cap.data = cap.data(cap.data.DATEN>dt_max,:);
        liab.data = liab.data(liab.data.DATEN>dt_max,:);
        money.data = money.data(money.data.DATEN>dt_max,:);
        
        x = factor_join(rev,cap,{'oper_rev'},{'tot_cap'});
        y = factor_join(liab,x,{'tot_non_cur_liab'},{'oper_rev','tot_cap'});
        append = factor_join(money,y,{'monetary_cap'},{'tot_non_cur_liab','oper_rev','tot_cap'});
        
        append.data.sales2ev = append.data.oper_rev ...
                                      ./ (append.data.tot_cap + append.data.tot_non_cur_liab + append.data.monetary_cap);
                            
        append.data = append.data(:,{'DATEN','stk_num','sales2ev'});

        
        if bool
            sales2ev = factor_append(sales2ev,append);
        else
            sales2ev = append;
        end
            
        data = sales2ev.data; %#ok<NASGU>
        code_map = sales2ev.code_map; %#ok<NASGU>
        eval(['save(''',tgt_file,''',''data'',''code_map'');']);
        
    end


end

