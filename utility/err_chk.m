function  err_chk(f,T,N)
    % ���h5�ļ�f�еĹ�Ʊ�ͽ��������Ƿ�����
    x = length(datenum_h5(h5read(f,'/date')))==T&&length(stk_code_h5(h5read(f,'/stk_code')))==N;
    if ~x
       error(['please check: ',f]);
    end
end


