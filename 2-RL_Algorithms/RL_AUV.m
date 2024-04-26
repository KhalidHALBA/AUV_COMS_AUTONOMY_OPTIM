% File name: RL_AUV.m
% Define constants for action indices
COM_CORRECTION = 1;
AUTO_CORRECTION = 2;

% Environment settings
num_states = 10; % Example states representing different distances from the objective and current position
num_actions = 2; % Two actions: com_correction, autonomy_correction

% Learning parameters
alpha = 0.1; % Learning rate
gamma = 0.9; % Discount factor
epsilon = 0.1; % Exploration probability
num_episodes = 500;

% Initialize Q-table
Q = zeros(num_states, num_actions);

% Main RL Loop
for episode = 1:num_episodes
    state = randi(num_states); % Initialize a random state
    
    is_terminal = false; % Initialize terminal condition
    while ~is_terminal
        % Choose an action using epsilon-greedy strategy
        if rand() < epsilon
            action = randi(num_actions); % Exploration: choose a random action
        else
            [~, action] = max(Q(state, :)); % Exploitation: choose the best known action
        end
        
        % Perform the action and observe the new state and reward
        [new_state, reward, is_terminal] = take_action(state, action, COM_CORRECTION, AUTO_CORRECTION, num_states);
        
        % Learn: update Q-table using the Q-learning algorithm
        future_rewards = max(Q(new_state, :));
        Q(state, action) = Q(state, action) + alpha * (reward + gamma * future_rewards - Q(state, action));
        
        % Update the state
        state = new_state;
    end
end

% Display the learned Q-values
disp('Learned Q-values:');
disp(Q);
function [new_state, reward, is_terminal] = take_action(state, action, COM_CORRECTION, AUTO_CORRECTION, num_states)
    switch action
        case COM_CORRECTION
            [flag, new_SOC] = coms_correction();
        case AUTO_CORRECTION
            [flag, new_SOC] = autonomy_correction();
    end

    % Handle new state change
    if flag
        new_state = max(1, min(num_states, state - 1));  % Ensure new_state stays between 1 and num_states
    else
        new_state = max(1, min(num_states, state + 1));  % Ensure new_state stays between 1 and num_states
    end

    % Check terminal state
    is_terminal = new_state == 1 || new_state >= num_states || new_SOC <= 0;

    % Calculate reward
    reward = flag * 20 - (1 - flag) * 10 - (10 * (1 - new_SOC/100));
end

function [success, new_SOC] = coms_correction()
    % Simulate a communication-based correction
    if rand() > 0.5 % Example: 50% chance of successful communication
        success = true;
        SOC_decrease = 5; % Communication consumes less battery
    else
        success = false;
        SOC_decrease = 2;
    end
    
    new_SOC = 100 - SOC_decrease; % Example initial SOC of 100%
end

function [success, new_SOC] = autonomy_correction()
    % Simulate an autonomy-based correction
    if rand() > 0.3 % Example: 70% chance of successful autonomy correction
        success = true;
        SOC_decrease = 8; % Autonomy consumes more battery
    else
        success = false;
        SOC_decrease = 3;
    end
    
    new_SOC = 100 - SOC_decrease; % Example initial SOC of 100%
end