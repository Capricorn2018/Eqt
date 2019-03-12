function [] = oper_rev_ltg(a, p)
% operrev_ltg 营业收入长期增长趋势（三年单季数据回归）
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/oper_rev_ltg.h5'];
    tgt_tag = 'oper_rev_ltg'; 
    [S,oper_rev_ltg] =  check_exist(tgt_file,'/oper_rev_ltg',p,T,N);

    if S>0
        
       rev_file = [a.input_data_path,'/LTG_oper_rev.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       
       oper_rev_ltg(S:T,:) = rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

