function [] = asset_turnover(a, p)
% asset_turnover �������¼������걨���ھ����ʲ���ת��
    T = length(p.all_trading_dates );
    N = length(p.stk_codes);   
    tgt_file =  [a.output_data_path,'/asset_turnover.h5'];
    tgt_tag = 'asset_turnover'; 
    [S,asset_turnover] =  check_exist(tgt_file,'/asset_turnover',p,T,N);

    if S>0
        
       rev_file = [a.input_data_path,'/LR_oper_rev.h5'];
       asset_file = [a.input_data_path,'/MEAN_tot_assets.h5'];

       rev = h5read(rev_file,'/oper_rev')';
       asset = h5read(asset_file,'/tot_assets')';
       asset_turnover(S:T,:) = rev(S:T,:)./asset(S:T,:); %#ok<NASGU>

       if  exist(tgt_file,'file')==2
          eval(['delete ',tgt_file]);
       end
       eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
    end

end
