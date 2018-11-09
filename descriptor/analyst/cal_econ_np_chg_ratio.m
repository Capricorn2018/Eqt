function  cal_econ_np_chg_ratio(p,a,K0)
       p.K0 = K0;
       T = length(p.all_trading_dates );
       N = length(p.stk_codes);          
       tgt_tag = 'enp_ratio';
       tgt_tag1 = [tgt_tag,'_',num2str(K0)];   % ������Ӫҵ����һ��Ԥ�� - n����ǰӪҵ����һ��Ԥ�ڣ�/abs��n����ǰӪҵ����һ��Ԥ�ڣ�
       tgt_file =  [a.output_data_path,'\',tgt_tag1 ,'.h5'];
       [S,enp_ratio] =  check_exist(tgt_file,['/',tgt_tag],p,T,N);
       
       tagn = 'con_np';
       table_name = 'con_forecast_stk';
       
       if S>0
           enp_ratio = update_ratio_zyyx_tables_inclue_con_year(S,T,enp_ratio,p,a,table_name,tagn);
           if  exist(tgt_file,'file')==2
               eval(['delete ',tgt_file]);
           end

           eval(['hdf5write(tgt_file, ''date'',p.all_trading_dates_, ''stk_code'',p.stk_codes_,' '''',tgt_tag, ''',','' tgt_tag, ');']);  
       end
end