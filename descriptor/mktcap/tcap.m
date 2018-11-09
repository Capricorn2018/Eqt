function  tcap(p,a)

    total_capital = h5read([a.input_data_path,'\fdata\base_data\capital.h5'],'/total_capital')';
    tcap = log(total_capital);
    hdf5write([a.output_data_path,'\tcap.h5'], 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'tcap',tcap);  
    
    
    tgt_file = [a.output_data_path,'\tmidcap.h5'];
    [idx_stk, loc_stk,idx_dt, loc_dt,exist_flag] = check_exist_h5(tgt_file,p);
    
     if all(idx_stk)&&all(idx_dt)  %不需要更新
        return;
     end
    
     tmidcap = nan(size(tcap));
     
      if exist_flag==0      
          S = find(p.all_trading_dates>=datenum(2005,1,1),1,'first');
      elseif exist_flag==1
          S = find(loc_dt==0,1,'first');
          tmidcap(idx_dt,idx_stk) = h5read(tgt_file,'/tmidcap');
      end
     
    
     T = length(p.all_trading_dates_);
     for i = S : T
      %  tic
        idx_nan  = isnan(tcap(i,:));
        if sum(~idx_nan)>2
           x = tcap(i,~idx_nan)';
           mdl = fitlm(array2table([x.*x.*x,x],  'VariableNames',{'y','x'}), 'ResponseVar','y','Intercept',true);
           tmidcap(i,~idx_nan) = mdl.Residuals.Raw';
        end
      %  toc
     end
    
     if  exist(tgt_file,'file')==2
           delete tgt_file
     end
    

    hdf5write(tgt_file, 'date',p.all_trading_dates_, 'stk_code',p.stk_codes_, 'tmidcap',tmidcap);  
end