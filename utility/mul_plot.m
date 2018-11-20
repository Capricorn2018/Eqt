function [ figure1,plot1 ] = mul_plot( x, input_matrix, leg,tit)
     
   figure1 = figure;
   axes1 = axes('Parent',figure1);
   hold(axes1,'on');
   
   plot1 = plot(x,input_matrix,'Parent',axes1);
   datetick('x','yyyy','keepticks')
   legend(leg,'Location','southeast');
   title(tit);
end


