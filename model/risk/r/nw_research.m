%% 股票协方差

tN = 20;
Nstock = 30;
% 虚拟收益率序列
R = randn(tN,Nstock);
% demean
R = R - repmat(mean(R,1),tN,1);
% 比较协方差
cv1 = (R'*R)/(tN-1);
cv2 = cov(R);
disp(cv1)
disp(cv2)
rank(cv1)
rank(cv2)

%% 因子指数加权协方差
tN = 20;
Nfactor = 3;
% 虚拟收益率序列
f = randn(tN,Nfactor);
% demean
f = f - repmat(mean(f,1),tN,1);
% 指数衰减权重
halfLift = 10;
lambda = (1/2)^(1/halfLift);
w = lambda.^((tN-1):-1:0);
plot((tN-1):-1:0,w)
w = w/sum(w);
cov_F = (f'*diag(w)*f)/(tN-1)


%% Newey-West 修正
tN = 40;
Nfactor = 3;
% 虚拟收益率序列
F = randn(tN,Nfactor);
% demean
F = F - mean(F,1);
% 指数衰减参数
halfLift = 10;
lambda = (1/2)^(1/halfLift);
% C0
w = lambda.^((tN-1):-1:0);
w = w/sum(w);
C0 = (F'*diag(w)*F)/(tN-1);
% Newey-West 参数
D = 15;

% 计算修正矩阵
C = 0;
for i = 1:D
    F0 = F(i+1:end,:);
    F1 = F(1:end-i,:);
    dim_F = size(F0,1);
    wt = lambda.^((dim_F-1):-1:0);
    wt = wt/sum(wt);
    w_nw = 1 - i/(1+D);
    C_lag = F0'*diag(wt)*F1/(tN-1);
    C = C + w_nw*(C_lag+C_lag');
end
COV_F = 22*(C0+C);
disp(C0)
disp(C)
