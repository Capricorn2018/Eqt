function [] = operrev_yoy(a, p)
% operrev_yoy 营业收入单季同比增长率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/operrev_yoy.h5'];
    tgt_tag = 'operrev_yoy'; 
    [S,operrev_yoy] =  check_exist(tgt_file,'/operrev_yoy',p,T,N);

    if S>0
        
       rev_file = [a.input_data_path,'/YOY_oper_rev.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       
       operrev_yoy(S:T,:) = rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

