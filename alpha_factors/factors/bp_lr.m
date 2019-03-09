function [] = bp_lr(a, p)
% bp_lr 计算最新季报（年报）口径的 BP
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/bp_lr.h5'];
    tgt_tag = 'bp_lr'; 
    [S,bp_lr] =  check_exist(tgt_file,'/bp_lr',p,T,N);

    if S>0
        
       eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5'];
       cap_file = [a.input_data_path,'/tot_cap.h5'];

       eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int')';
       total_capital = h5read(cap_file,'/tot_cap')';
       bp_lr(S:T,:) = eqy(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

