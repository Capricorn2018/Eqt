function [] = current_ratio(a, p)
% currentratio 计算最新季报（年报）口径的 流动比率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/current_ratio.h5'];
    tgt_tag = 'current_ratio'; 
    [S,current_ratio] =  check_exist(tgt_file,'/current_ratio',p,T,N);

    if S>0
        
       asset_file = [a.input_data_path,'/LR_tot_cur_assets.h5'];
       debt_file = [a.input_data_path,'/LR_tot_cur_liab.h5'];

       asset = h5read(asset_file,'/tot_cur_assets');
       asset_stk = h5read(asset_file,'/stk_code');
       asset_dt = datenum_h5 (h5read(asset_file,'/date'));
       debt = h5read(debt_file,'/tot_cur_liab');
       debt_stk = h5read(debt_file,'/stk_code');
       debt_dt = h5read(debt_file,'/date');
       
       [~,p_i,asset_i,debt_i] = intersect3(p.stk_codes,asset_stk,debt_stk);
       [~,p_t,asset_t,debt_t] = intersect3(p.all_trading_dates(S:T),asset_dt,debt_dt);
       idx = S:T;
       p_t = idx(p_t);
       
       current_ratio(p_t,p_i) = asset(asset_t,asset_i)./debt(debt_t,debt_i); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

