function [  ] = change( )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

    folder = 'D:/Projects/pit_data/mat/alpha_factors';

    files = dir(folder);


    for i=1:length(files)

        filename = files(i).name;


        if ~isempty(filename)
            if strcmp(filename(max(length(filename)-3,1):length(filename)),'.mat')

                x = load([folder,'/',filename]);
                n = fieldnames(x);
                f = strcmp(n,'code_map');
                tag = n(~f);
                eval(['data = x.',tag{1},';']);
                code_map = x.code_map; %#ok<NASGU>
                save([folder,'/',filename],'code_map','data');

            end
        end


    end
end

