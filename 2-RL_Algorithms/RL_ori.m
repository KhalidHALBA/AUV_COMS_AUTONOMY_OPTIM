function SimpleRL_GridWorld
    % Define the grid
    grid = [0 0 0 1; 
            0 -1 0 -1; 
            0 0 0 0];
        
    % Hyperparameters
    alpha = 0.1; % Learning rate
    gamma = 0.9; % Discount factor
    epsilon = 0.1; % Exploration rate
    
    % Initialize Q-table
    [num_rows, num_cols] = size(grid);
    Q = zeros(num_rows, num_cols, 4); % 4 possible actions (up, down, left, right)

    % Training parameters
    num_episodes = 500;
    
    for episode = 1:num_episodes
        % Random initial state
        state = [randi(num_rows), randi(num_cols)];
        while grid(state(1), state(2)) == -1 || grid(state(1), state(2)) == 1
            state = [randi(num_rows), randi(num_cols)];
        end

        is_terminal = false;
        while ~is_terminal
            % Choose action
            if rand() < epsilon
                action = randi(4); % Explore
            else
                [~, action] = max(Q(state(1), state(2), :)); % Exploit
            end
            
            % Take action
            [new_state, reward, is_terminal] = step(state, action, grid, num_rows, num_cols);

            % Q-learning update
            best_future_q = max(Q(new_state(1), new_state(2), :));
            Q(state(1), state(2), action) = Q(state(1), state(2), action) + ...
                alpha * (reward + gamma * best_future_q - Q(state(1), state(2), action));
            
            % Update state
            state = new_state;
        end
    end

    % Display learned Q-values
    disp('Learned Q-values:');
    disp(Q);
end

function [new_state, reward, is_terminal] = step(state, action, grid, num_rows, num_cols)
    % Map actions to movement (1: up, 2: down, 3: left, 4: right)
    move = [ -1, 0; 1, 0; 0, -1; 0, 1 ];
    
    % Calculate new state
    new_state = state + move(action, :);
    
    % Check if out of bounds
    if new_state(1) < 1 || new_state(1) > num_rows || new_state(2) < 1 || new_state(2) > num_cols
        new_state = state;
    end
    
    % Get reward and check for termination
    if grid(new_state(1), new_state(2)) == 1
        reward = 10; % Reward for reaching goal
        is_terminal = true;
    elseif grid(new_state(1), new_state(2)) == -1
        reward = -10; % Penalty for hitting an obstacle
        is_terminal = true;
    else
        reward = -1; % Small penalty each step
        is_terminal = false;
    end
end