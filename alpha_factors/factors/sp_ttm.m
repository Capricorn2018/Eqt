function [] = sp_ttm(a, p)
% sp_ttm 计算滚动12个月口径的 营业收入/总市值
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/sp_ttm.h5'];
    tgt_tag = 'sp_ttm'; 
    [S,sp_ttm] =  check_exist(tgt_file,'/sp_ttm',p,T,N);
    
    if S>0
       rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
       cap_file = [a.input_data_path,'/tot_cap.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       total_capital = h5read(cap_file,'/tot_cap')';
       sp_ttm(S:T,:) = rev(S:T,:)./total_capital(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



