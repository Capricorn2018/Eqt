function plot_DD(Date,Price,X,DD)

    z = zeros(length(DD),4);
    u1  =  min(DD)*1.1;
    u2   = max(Price) - min(Price);
    for i  = 1 : height(X)
        z(X.I1(i):X.I2(i),1) = u1;
        z(X.I2(i):X.I3(i),2) = u1;
        z(X.I1(i):X.I2(i),3) = max(Price)+0.1*u2;
        z(X.I2(i):X.I3(i),4) = max(Price)+0.1*u2;
    end

    zz = figure;
    subplot(2,1,1)
    h = area(Date,z(:,1),'LineStyle','none'); hold on
    datetick('x','yy','keeplimits')
    h(1).FaceColor = [0.1,0.1,0.1];
    h(1).EdgeColor = 'none';
    h(1).EdgeAlpha = 0;
    h(1).FaceAlpha = 0.2;

    h = area(Date,z(:,2),'LineStyle','none'); hold on
    h(1).FaceColor = [1,0.1,0.1];
    h(1).EdgeColor = 'none';
    h(1).EdgeAlpha = 0;
    h(1).FaceAlpha = 0.2;

    plot(Date,DD)
    ylim([u1, 0])
    xlim([Date(1,1),Date(end,1)])
    title('最大回撤')
    subplot(2,1,2)
    h = area(Date,z(:,3),'LineStyle','none'); hold on
    datetick('x','yy','keeplimits')
    h(1).FaceColor = [0.1,0.1,0.1];
    h(1).EdgeColor = 'none';
    h(1).EdgeAlpha = 0;
    h(1).FaceAlpha = 0.2;

    h = area(Date,z(:,4),'LineStyle','none'); hold on
    h(1).FaceColor = [1,0.1,0.1];
    h(1).EdgeColor = 'none';
    h(1).EdgeAlpha = 0;
    h(1).FaceAlpha = 0.2;

    plot(Date,Price)
    ylim([0, max(Price)+0.1*u2])
    xlim([Date(1,1),Date(end,1)])
    title('指数走势')
    
end