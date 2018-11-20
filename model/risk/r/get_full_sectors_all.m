function [m,n] = get_full_sectors_all(f)
    x = readtable(f);
    lv1 = 8888;
    m =  cell(length(lv1),1);
    n =  cell(length(lv1),1);
 
        y = [];
        for j = 1:height(x)
            y = [y,num2cell(x.lv2num(j))]; % 多个二级行业的并集
        end
        n{1,1} = y;
    

end