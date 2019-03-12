function [] = oper_rev_yoy(a, p)
% operrev_yoy Ӫҵ���뵥��ͬ��������
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/oper_rev_yoy.h5'];
    tgt_tag = 'oper_rev_yoy'; 
    [S,oper_rev_yoy] =  check_exist(tgt_file,'/oper_rev_yoy',p,T,N);

    if S>0
        
       rev_file = [a.input_data_path,'/YOY_oper_rev.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       
       oper_rev_yoy(S:T,:) = rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

