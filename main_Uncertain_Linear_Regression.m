clear;clc;
% 清空数据
tic
% 开始计时

% ---如有必要，关闭所有警告以使输出结果干净---
warning('off');

% ---导入数据---
data = importdata('example_DATA.mat');
% 导入数据矩阵，实践中将example_DATA.mat替换为观测数据，响应变量y的n组数据在第1列，第i个解释变量的n组数据在第i+1列 
options = optimset('MaxIter', 1e4, 'MaxFunEvals', 1e4);
% 方便fminsearch运算的设置

% ---选取需要的数据---
list_y = data(:,1);
% 获得响应变量list_y，注意是列向量
matrix_x_ij = data(:,2:end);
% 获得解释变量，注意这里是一个矩阵，共n行，p列，n是样本数，p是响应变量的个数

% ---不确定线性回归模型---
disp('---不确定线性回归模型---');
n_starts_ULR = 100;
% 参数估计的初始点数量，建议在50以上
bound_ULR = 100;
% 参数估计的初始点分布大小，可调
best_para_0_ULR = [];
% 空数组，记录估计出最佳参数的初始参数
best_para_esti_ULR = [];
% 空数组，记录最佳估计参数
best_residuals_ULR = [];
% 空数组，记录最佳估计参数得到的残差
best_value_ULR = Inf;
% 初始目标函数值设置为无穷大
for i = 1:n_starts_ULR
    para_0 = randn(1+size(matrix_x_ij,2),1).*bound_ULR;  
    % 根据参数范围生成随机初始点
    [para_esti, fval] = fminsearch(@(para) get_obj_func_ULR(para,list_y,matrix_x_ij),para_0,options);
    % 估计参数并记录参数估计的目标函数值
    residual_temp_ULR = get_resi_ULR(para_esti,list_y,matrix_x_ij);
    % 根据估计参数计算残差
    if test_Random_Normal(residual_temp_ULR) == 1 && test_Uncertain_Normal(residual_temp_ULR) == 0
    % 如果残差既通过不确定假设检验，又不通过随机的假设检验，则可以成为潜在的记录对象
        if fval < best_value_ULR
            best_para_0_ULR = para_0;
            % 记录此次生成的随机初始点
            best_para_esti_ULR = para_esti;
            % 记录此次得到的估计参数
            best_residuals_ULR = residual_temp_ULR;
            % 记录此次得到的估计参数相应的残差
            best_value_ULR = fval;
            % 记录此次参数估计的目标函数值
        end
        % 在循环中更新更好的参数估计结果
    end
end

% ---输出部分---
if isempty(best_para_esti_ULR) == 1
    disp('---没有得到符合预期的参数估计，可能需要增大n_starts_ULR或bound_ULR的值，或者数据不符合线性回归模型---');
else
    e_ULR = mean(best_residuals_ULR);
    % 计算残差的均值
    sigma_ULR = std(best_residuals_ULR, 1); 
    % 计算残差的标准差
    percent_ULR = sigma_ULR/(max(list_y)-min(list_y));
    % 计算标准差与观测数据上下极差的比例
    fprintf('最佳估计参数向量是: ');
    for i = 1:numel(best_para_esti_ULR)
        if i < numel(best_para_esti_ULR)
            fprintf('%.4f, ', best_para_esti_ULR(i)); % 输出元素加逗号
        else
            fprintf('%.4f', best_para_esti_ULR(i));   % 最后一个元素不加逗号
        end
    end
    fprintf('\n'); % 在最后统一换行
    fprintf('参数估计的目标函数值是: %.4f\n', best_value_ULR);
    fprintf('残差的均值是: %.4f\n', e_ULR);
    fprintf('残差的标准差是: %.4f\n', sigma_ULR);
    fprintf('残差标准差与观测数据上下极差的比例是: %.2f%%\n', percent_ULR * 100);
    
    % ---可选项，输出残差检验的细节---
    % disp('---空间自回归模型残差不通过概率的假设检验，细节如下---')
    % test_Random_Normal(best_residuals_ULR,'detail');
end
toc
% 结束计时