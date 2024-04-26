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

% File name: RL_AUV_More_Viz.m
% -- [unchanged parts of the script] --

% Visualization section - dynamically update figures based on simulation outcomes
% Go from worst to best scenario incrementally for illustration. These should be calculated during your simulation
mission_success_rates = linspace(70, 95, num_episodes);  % Simulated improvement in mission success
SOC_rates = linspace(0, 20, num_episodes);  % Simulated SOC levels between 0 and 20%

% Create Figure or update it if already exists
fig = findobj('Type', 'figure', 'Name', 'Mission Performance');
if isempty(fig)
    fig = figure('Name', 'Mission Performance');  % Name your figure for easy identification
end
clf(fig);  % Clear the figure for fresh plots each run

% Create a subplot for Mission Success
subplot(1, 2, 1);
bar(mission_success_rates);  % Display mission success data
title('Data Collection Completeness Along Survey Trajectory');
ylabel('Data Points Collected (%)');
xlabel('Episode');
ylim([0 100]);
grid on;

% Create a subplot for State of Charge
subplot(1, 2, 2);
bar(SOC_rates);  % Display SOC data
title('State of Charge (SOC) After Missions');
ylabel('SOC Value (%)');
xlabel('Episode');
ylim([0 20]);  % Set a realistic maximum SOC according to your requirements
grid on;

% Enhance display
sgtitle('Mission Data Collection and SOC Performance Over Episodes');

% Here's an example of how you might update SOC calculation logic dynamically based on your system


% Ensure that all your other function outputs are adjusting new_SOC correctly
% Described function adjustments ensure that SOC computations are within expected realistic operational thresholds.


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
    % Assume successful surface communication results in minimal SOC consumption
    success = true;
    SOC_decrease = rand() * 2;  % Random SOC decrease up to 2% for illustration
    new_SOC = max(0, 100 - SOC_decrease);  % never drop below 0%
end


