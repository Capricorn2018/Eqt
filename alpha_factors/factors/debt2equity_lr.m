function [] = debt2equity_lr(a, p)
% debt2equity_lr 计算最新季报（年报）口径的 debt/equity
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/debt2equity_lr.h5'];
    tgt_tag = 'debt2equity_lr'; 
    [S,debt2equity_lr] =  check_exist(tgt_file,'/debt2equity_lr',p,T,N);

    if S>0
        
       eqy_file = [a.input_data_path,'/LR_tot_shrhldr_eqy_excl_min_int.h5'];
       debt_file = [a.input_data_path,'/LR_tot_liab.h5'];

       eqy = h5read(eqy_file,'/tot_shrhldr_eqy_excl_min_int')';
       debt = h5read(debt_file,'/tot_liab')';
       debt2equity_lr(S:T,:) = debt(S:T,:)./eqy(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

