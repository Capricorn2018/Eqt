function [m,n] = get_full_sectors(f)
    x = readtable(f);
    lv1 = unique(x.lv1num);
    m = cell(length(lv1),1);
    n =  cell(length(lv1),1);
    for i = 1:length(lv1)
        m{i,1} = num2cell(lv1(i));  % ����Ϊ���һ����ҵ�Ĳ���
        k = x.lv2num(x.lv1num==lv1(i));
        y = [];
        for j = 1:length(k)
            y = [y,num2cell(k(j))]; % ���������ҵ�Ĳ���
        end
        n{i,1} = y;
    end

end