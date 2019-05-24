function []=factor2table( data, code_map, tag, output_path)
% 把存在类似数据库的mat文件中的alpha因子数据转换成为以日期为行股票为列的表数据, 方便做test

    DATEN = data.DATEN;    
    DATEN = unique(DATEN);
    DATEN = sort(DATEN,'ascend');
    
    dt = cell(0);
    
    stk_num = data.stk_num;
    stk_num = unique(stk_num);
    stk_num = sort(stk_num,'ascend');
    
    stk_code = code_map.stk_codes(ismember(stk_num,code_map.stk_num));
    
    tbl_style = nan(length(DATEN),length(stk_num));
    
    for i=1:length(DATEN)
        
        tmp = data(data.DATEN==DATEN(i),:);
        
        Lia = ismember(tmp.stk_num,stk_num);
        
        row = tmp(Lia,tag);
        
        row = row';
        
        tbl_style(i,:) = table2array(row);
        
        dt{i} = datestr(DATEN(i),'yyyymmdd');
        
    end
        
    filename = [output_path,'/',tag,'.h5'];
    h5write(filename,['/',tag],tbl_style,'/stk_code',stk_code,'/date',dt);

end

