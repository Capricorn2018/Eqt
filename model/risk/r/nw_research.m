%% ��ƱЭ����

tN = 20;
Nstock = 30;
% ��������������
R = randn(tN,Nstock);
% demean
R = R - repmat(mean(R,1),tN,1);
% �Ƚ�Э����
cv1 = (R'*R)/(tN-1);
cv2 = cov(R);
disp(cv1)
disp(cv2)
rank(cv1)
rank(cv2)

%% ����ָ����ȨЭ����
tN = 20;
Nfactor = 3;
% ��������������
f = randn(tN,Nfactor);
% demean
f = f - repmat(mean(f,1),tN,1);
% ָ��˥��Ȩ��
halfLift = 10;
lambda = (1/2)^(1/halfLift);
w = lambda.^((tN-1):-1:0);
plot((tN-1):-1:0,w)
w = w/sum(w);
cov_F = (f'*diag(w)*f)/(tN-1)


%% Newey-West ����
tN = 40;
Nfactor = 3;
% ��������������
F = randn(tN,Nfactor);
% demean
F = F - mean(F,1);
% ָ��˥������
halfLift = 10;
lambda = (1/2)^(1/halfLift);
% C0
w = lambda.^((tN-1):-1:0);
w = w/sum(w);
C0 = (F'*diag(w)*F)/(tN-1);
% Newey-West ����
D = 15;

% ������������
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
