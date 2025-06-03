% get_resi_ulr根据输入的参数，响应变量和解释变量，输出参数估计的目标函数值

% 输入：
%   list_para      - 参数列向量（必须）
%   list_y_i       - 响应变量列向量（必须）
%   matrix_x_ij    - 解释变量列向量（可选）
% 输出：
%   f              - 以list_para = (beta_0, beta_1, ..., beta_p)'为参数，
%                  - 以list_y_i = (y_1,y_2,...,y_n)'为响应变量，
%                  - 以matrix_x_ij = [x_{11},x_{12},...,x_{1k};
%                                     x_{21},x_{22},...,x_{2k};
%                                     ...
%                                     x_{n1},x_{n2},...,x_{nk}]为解释变量，（注意，matrix_x_ij）是一个n*p矩阵，n行代表n组观测数据，p列代表p个解释变量
%                  - 此时的不确定线性回归模型 y = beta_0 + beta_1 * x_1 + beta_2 * x_2
%                  + ... + beta_p * x_p + epsilon的残差列向量
% ———————————————————————————————————————————
function f = get_resi_ULR(list_para,list_y_i,matrix_x_ij)
    % ---参数解析与验证---
    if nargin < 2 || nargin > 3
        error('输入参数数量错误：应为2或3个');
    % 如果只提供了两个参数，则设置matrix_x_ij的默认值
    elseif (nargin == 2)
        matrix_x_ij = (1:numel(list_y_i))'; % 默认列向量
    % 如果提供了所有的三个参数，检验参数的合理性
    else
        % 验证x_t_matrix的维度
        if size(matrix_x_ij, 1) ~= numel(list_y_i)
            error('x_t_matrix的行数必须等于numel(y_t)');
        elseif size(matrix_x_ij, 2) ~= numel(list_para)-1
            error('x_t_matrix的列数必须等于numel(para)-1');
        end
    end
    
    % ---运算部分---
    n = numel(list_y_i);
    % 得到总样本数
    beta_0 = list_para(1);
    % 得到常系数
    list_beta = list_para(2:end);
    % 得到beta_1到beta_p的列向量
    list_residuals = list_y_i-beta_0-matrix_x_ij*list_beta;
    % 得到残差列向量
    f = list_residuals;
end