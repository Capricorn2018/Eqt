function [] = ln_floatcap(a,p)
% ln_floatcap 净利润（不含少数股东损益）单季同比增长率

    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/ln_floatcap.h5'];
    tgt_tag = 'ln_floatcap'; 
    [S,ln_floatcap] =  check_exist(tgt_file,'/ln_floatcap',p,T,N);

    if S>0
        
       cap_file = [a.input_data_path,'/float_cap.h5'];
        
       cap = h5read(cap_file,'/float_cap');
       cap_stk = h5read(cap_file,'/stk_code');
       cap_dt = datenum_h5(h5read(cap_file,'/date'));
       
       [~,p_i,cap_i] = intersect(p.stk_codes,cap_stk);
       [~,p_t,cap_t] = intersect(p.all_trading_dates(S:T),cap_dt);
       idx = S:T;
       p_t = idx(p_t);
       
       ln_floatcap(p_t,p_i) = cap(cap_t,cap_i);
       
       ln_floatcap(ln_floatcap==0) = NaN;
       ln_floatcap = log(ln_floatcap); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end
end

