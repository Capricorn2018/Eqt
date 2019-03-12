function [] = oper_profit_yoy(a, p)
% oper_profit_yoy 营业利润单季同比增长率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/oper_profit_yoy.h5'];
    tgt_tag = 'oper_profit_yoy'; 
    [S,oper_profit_yoy] =  check_exist(tgt_file,'/oper_profit_yoy',p,T,N);

    if S>0
        
       oper_file = [a.input_data_path,'/YOY_oper_profit.h5'];

       oper = h5read(oper_file,'/oper_profit')';
       
       oper_profit_yoy(S:T,:) = oper(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

