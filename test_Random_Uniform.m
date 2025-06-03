% test_Random_Uniform检测输入的一组残差是否服从U(0,1)概率分布

% 输入：
%   list_residuals - 残差列向量（必须）
%   'detail'       - 可选标志，触发细节描述（任意位置）
% 输出：
%   f              - 检验结果（1=拒绝原假设, 0=接受原假设）
% ———————————————————————————————————————————
function f = test_Random_Uniform(list_residuals, varargin)
    % ---参数解析与验证---
    detail_flag = false;
    % 默认不输出细节
    for i = 1:numel(varargin)
        if ischar(varargin{i}) && strcmpi(varargin{i}, 'detail')
            % 处理细节标识
            detail_flag = true;
        else
            error('无效参数: %s', varargin{i});
        end
    end
    % ---运算部分---
    n = numel(list_residuals);
    % 样本数量
    m = ceil(n/2);
    % 最接近样本数量一半的整数
    list_deviation_index = (-floor(n/10):1:floor(n/10))';
    % 截断时用于左右偏移的角标序列
    n_deviation = numel(list_deviation_index);
    % 截断总次数
    h_p_matrix = zeros(1+2*n_deviation,4);
    % 新建一个空的h_p_matrix矩阵，（1+2*n_deviation）行，4列，每一行的第1列是h的值，第2列是对应的p值，第3，4列分别代表残差数组截断的位置
    [h,p] = runstest(list_residuals);
    h_p_matrix(1,:) = [h,p,0,0];
    % 使用游程检验，不截断
    for i = 1:n_deviation
        [h,p] = ansaribradley(list_residuals(1:m+list_deviation_index(i)),list_residuals(m+list_deviation_index(i)+1:n));
        h_p_matrix(1+i,:) = [h,p,m+list_deviation_index(i),m+list_deviation_index(i)+1];
    end
    % 使用Ansari-Bradley检验，截断，第3，4列分别代表残差数组截断的位置
    for i = 1:n_deviation
        [h,p] = kstest2(list_residuals(1:m+list_deviation_index(i)),list_residuals(m+list_deviation_index(i)+1:n));
        h_p_matrix(1+n_deviation+i,:) = [h,p,m+list_deviation_index(i),m+list_deviation_index(i)+1];
    end
    % 使用双样本Kolmogorov-Smirnov检验，截断，第3，4列分别代表残差数组截断的位置
    f = (sum(h_p_matrix(:,1))>0);
    % 判断是否有不通过的假设检验，输出f
    
    % ---如果参数指定'detail'，则给出详细结果---
    if detail_flag
        if h_p_matrix(1,1) == 1
            fprintf('残差不通过Run test for randomness检验，无截断，p值为%.4f.\n',h_p_matrix(1,2));
        end
        for i = 1:n_deviation
            if h_p_matrix(1+i,1) == 1
                fprintf('残差不通过Ansari-Bradley检验，p值为%.4f，截断分别为从1到%.0f，从%.0f到%.0f.\n',h_p_matrix(1+i,2),h_p_matrix(1+i,3),h_p_matrix(1+i,4),n);
            end
        end
        for i = 1:n_deviation
            if h_p_matrix(1+n_deviation+i,1) == 1
                fprintf('残差不通过Two-sample Kolmogorov-Smirnov检验，p值为%.4f，截断分别为从1到%.0f，从%.0f到%.0f.\n',h_p_matrix(1+n_deviation+i,2),h_p_matrix(1+n_deviation+i,3),h_p_matrix(1+n_deviation+i,4),n);
            end
        end
    end
end