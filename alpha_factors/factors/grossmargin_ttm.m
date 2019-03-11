function [] = grossmargin_ttm(a, p)
% grossmargin_ttm 计算滚动12个月口径的 毛利率
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/grossmargin_ttm.h5'];
    tgt_tag = 'grossmargin_ttm'; 
    [S,grossmargin_ttm] =  check_exist(tgt_file,'/grossmargin_ttm',p,T,N);


    if S>0
       rev_file = [a.input_data_path,'/TTM_oper_rev.h5'];
       cost_file = [a.input_data_path,'/TTM_less_oper_cost.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       cost = h5read(cost_file,'/less_oper_cost')';
       grossmargin_ttm(S:T,:) = 1 - cost(S:T,:)./rev(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end

