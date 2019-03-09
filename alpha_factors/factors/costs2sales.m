function [] = costs2sales(a, p)
% costs2sales 计算滚动12个月口径的 三费/营业收入
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/costs2sales.h5'];
    tgt_tag = 'costs2sales'; 
    [S,costs2sales] =  check_exist(tgt_file,'/costs2sales',p,T,N);
    
    if S>0
       scost_file = [a.input_data_path,'/TTM_less_selling_dist_exp.h5']; % 销售费用
       mcost_file = [a.input_data_path,'/TTM_less_gerl_admin_exp.h5']; % 管理费用
       fcost_file = [a.input_data_path,'/TTM_less_fin_exp.h5']; % 财务费用
       profit_file = [a.input_data_path,'/TTM_oper_profit.h5'];

       scost = h5read(cash_file,'/less_selling_dist_exp')';
       mcost = h5read(cash_file,'/less_gerl_admin_exp')';
       fcost = h5read(cash_file,'/less_fin_exp')';
       profit = h5read(profit_file,'/oper_profit')';
       costs2sales(S:T,:) = (scost(S:T,:)+mcost(S:T,:)+fcost(S:T,:))./profit(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end



