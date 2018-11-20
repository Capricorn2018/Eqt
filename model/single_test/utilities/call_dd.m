clear;clc;
x = readtable('sp500.xlsx');

Date  = datenum(x.Date);
Price = x.Price;


[X,DD] = get_DD_table(Date,Price);

X = X(X.DD<-0.10,:);
 plot_DD(Date,Price,X,DD)
 writetable(X,'DM.xlsx')
 
%%
y = readtable('EEM.xlsx');

Date  = datenum(y.Date);
Price = y.Price;


[X_EM,DD_EM] = get_DD_table(Date,Price);
X_EM = X_EM(X_EM.DD<-0.20,:);
 plot_DD(Date,Price,X_EM,DD_EM)