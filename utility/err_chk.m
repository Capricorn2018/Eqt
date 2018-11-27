function  err_chk(f,T,N)
    % 检查h5文件f中的股票和交易日数是否足量
    x = length(datenum_h5(h5read(f,'/date')))==T&&length(stk_code_h5(h5read(f,'/stk_code')))==N;
    if ~x
       error(['please check: ',f]);
    end
end


