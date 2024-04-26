% File name: RL_AUV_More_Viz.m

% Define constants for action indices including new actions
COM_CORRECTION = 1;
AUTO_CORRECTION = 2;
SURFACE_COMMS = 3;  % Surfacing for satellite communication
AUV_TO_AUV_COMMS = 4;  % Communication between AUVs

% Environment settings
environments = [1, 2, 3];  % 1 - Shallow waters, 2 - Deep waters, 3 - Arctic under ice
num_states = 10; % Example states representing different distances from the objective and current position
num_actions = 4; % Expanded actions

% Learning parameters
alpha = 0.1; % Learning rate
gamma = 0.9; % Discount factor
epsilon = 0.1; % Exploration probability
num_episodes = 500;

% Initialize Q-table to incorporate states for each environment
Q = zeros(num_states, num_actions, length(environments));

% Main RL Loop
for episode = 1:num_episodes
    state = randi(num_states); % Initialize a random state
    env_state = randi(length(environments)); % Initialize random environment

    is_terminal = false; % Initialize terminal condition
    while ~is_terminal
        % Choose an action using epsilon-greedy strategy
        if rand() < epsilon
            action = randi(num_actions); % Exploration: choose a random action
        else
            [~, action] = max(Q(state, :, env_state)); % Exploitation: choose the best known action
        end
        
        % Perform the action and observe the new state and reward
        % Assuming 'take_action' is called inside the main simulation loop
        [new_state, reward, is_terminal] = take_action(state, action, env_state, num_states, COM_CORRECTION, AUTO_CORRECTION, SURFACE_COMMS, AUV_TO_AUV_COMMS);
        
        % Learn: update Q-table using the Q-learning algorithm
        future_rewards = max(Q(new_state, :, env_state));
        Q(state, action, env_state) = Q(state, action, env_state) + alpha * (reward + gamma * future_rewards - Q(state, action, env_state));
        
        % Update the state
        state = new_state;
    end
end

% Display the learned Q-values
disp('Learned Q-values:');
disp(Q);


% Visualization section 
% Assuming mission_success_rates and SOC_rates are collected from your simulation results.
mission_success_rates = linspace(0.7, 0.95, 4);  % Example mission success rates
SOC_rates = linspace(70, 90, 4);  % Example SOC values demonstrating no depletion

% Create Figure
figure;

% Create a subplot for Mission Success
subplot(1, 2, 1); % 1 row, 2 columns, 1st subplot
bar(mission_success_rates * 100); % Convert fraction to percentage
title('Data Collection Completeness Along Survey Trajectory');
ylabel('Data Points Collected (%)');
xlabel('Episode');
ylim([0 100]);
grid on;

% Create a subplot for State of Charge
subplot(1, 2, 2); % 1 row, 2 columns, 2nd subplot
bar(SOC_rates);
title('State of Charge (SOC) After Missions');
ylabel('SOC Value');
xlabel('Episode');
ylim([0 100]);
grid on;

% Enhance display
sgtitle('Mission Data Collection and SOC Performance Over Episodes');


function [new_state, reward, is_terminal] = take_action(state, action, env_state, num_states, COM_CORRECTION, AUTO_CORRECTION, SURFACE_COMMS, AUV_TO_AUV_COMMS)
    switch action
        case COM_CORRECTION
            [flag, new_SOC] = coms_correction();
        case AUTO_CORRECTION
            [flag, new_SOC] = autonomy_correction();
        case SURFACE_COMMS
            if env_state == 3  % Arctic condition with potential ice
                [flag, new_SOC] = handle_ice_block();
            else
                [flag, new_SOC] = surface_and_communicate();
            end
        case AUV_TO_AUV_COMMS
            [flag, new_SOC] = communicate_with_nearby_auv();
    end

    % Handle new state change
    if flag
        new_state = max(1, min(num_states, state - 1));  % Ensure new_state stays within valid range
    else
        new_state = max(1, min(num_states, state + 1));  % Ensure new_state stays within valid range
    end

    % Check terminal state condition
    is_terminal = new_state == 1 || new_state >= num_states || new_SOC <= 0;

    % Calculate reward
    reward = flag * 20 - (1 - flag) * 10 - (10 * (1 - new_SOC/100));
end

function [success, new_SOC] = coms_correction()
    % Simulate a communication-based correction with a 50% success rate
    success = rand() > 0.5;
    if success
        SOC_decrease = 2;  % Less SOC decrease if successful
    else
        SOC_decrease = 5;  % More SOC decrease if unsuccessful
    end
    new_SOC = 100 - SOC_decrease;
end

function [success, new_SOC] = autonomy_correction()
    % Simulate an autonomy-based correction with a 70% success rate
    success = rand() > 0.3;
    if success
        SOC_decrease = 3;  % Less SOC decrease if successful
    else
        SOC_decrease = 8;  % More SOC decrease if unsuccessful
    end
    new_SOC = 100 - SOC_decrease;
end

function [success, new_SOC] = handle_ice_block()
    % Handle potential ice blockage with a low success rate if ice is thick
    success = rand() > 0.8;  % 20% chance of success
    if success
        SOC_decrease = 5;  % Less SOC consumed if successful
    else
        SOC_decrease = 10;  % More SOC consumed on unsuccessful attempts
    end
    new_SOC = 100 - SOC_decrease;
end

function [success, new_SOC] = communicate_with_nearby_auv()
    % Simulate communicating with a nearby AUV with moderate success rate
    success = rand() > 0.5;  % 50% chance of success
    if success
        SOC_decrease = 4;  % Less SOC consumed if successful
    else
        SOC_decrease = 6;  % More SOC consumed if unsuccessful
    end
    new_SOC = 100 - SOC_decrease;
end

function [success, new_SOC] = surface_and_communicate()
    % Simulate successful surfacing and communication, assuming no ice
    success = true;  % Assume always successful except in ice conditions
    SOC_decrease = 7;  % SOC consumed during surfacing and transmitting
    new_SOC = 100 - SOC_decrease;
end

