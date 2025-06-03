% test_Uncertain_Linear检测输入的一组残差是否服从线性不确定分布L(0,1)

% 输入：
%   list_residuals - 残差列向量（必须）
%   alpha          - 显著性水平（可选，默认0.05）
%   'plot'         - 可选标志，触发绘图（任意位置）
% 输出：
%   f              - 检验结果（1=拒绝原假设, 0=接受原假设）
% ———————————————————————————————————————————
function f = test_Uncertain_Linear(list_residuals, varargin)
    % ---参数解析与验证---
    alpha = 0.05;
    % 默认显著性水平
    plot_flag = false;
    % 默认不绘图
    alpha_specified = false;
    % alpha标记，避免多个alpha值
    for i = 1:numel(varargin)
        if isnumeric(varargin{i}) && isscalar(varargin{i})
            % 处理alpha参数
            if alpha_specified
                error('只能指定一个alpha值');
            end
            alpha = varargin{i};
            alpha_specified = true;
        elseif ischar(varargin{i}) && strcmpi(varargin{i}, 'plot')
            % 处理绘图标志
            plot_flag = true;
        else
            error('无效参数: %s', varargin{i});
        end
    end

    % ---验证alpha有效性---
    if alpha <= 0 || alpha >= 1
        error('alpha必须在(0,1)范围内');
    end

    % ---运算部分---
    n = numel(list_residuals);
    % 样本数量
    m = max(ceil(alpha*n) + (ceil(alpha*n) == alpha*n), 1);
    % 异常值数量阈值
    left_bound = alpha/2;
    right_bound = 1-alpha/2;
    
    % ---异常值检测---
    list_is_outlier = (list_residuals < left_bound) | (list_residuals > right_bound);
    % 元素为0或1的向量，如果残差是异常值，对应位置赋值为1
    outlier_count = nnz(list_is_outlier);
    % 统计异常值的个数
    
    % ---检验结果---
    if outlier_count >= m
        f = 1;
    else
        f = 0;
    end
    
    % ---如果参数指定'plot'，则输出绘图---
    if plot_flag
        plot(list_residuals,'color','k','linewidth',1)
        hold on
        plot([1,n],[left_bound,left_bound],'--','color','r')
        hold on
        plot([1,n],[right_bound,right_bound],'--','color','r')
    end
end