clc;
clear all;

number_of_subject = ['1'];
% Initialization
number_of_sets = 20;
number_of_videos = 11;
total_videos = number_of_sets * number_of_videos;
videoList = ["1.mp4", "0.8.mp4", "0.6.mp4", "0.4.mp4", "0.2.mp4", "0.mp4", "-0.2.mp4", "-0.4.mp4", "-0.6.mp4", "-0.8.mp4", "-1.mp4"];
videolabels = [1, 0.8, 0.6, 0.4, 0.2, 0, -0.2, -0.4, -0.6, -0.8, -1];

% Prepare storage for the participant
forward_answers_participant = cell(1, 2);
ReactionTimes_participant = cell(1, 2);
std_err_participants = cell(1, 2);


% Loop for both participants
for p = 1:2
    % Load data for Participant 1 (rng 40) and Participant 2 (rng 42)
    if p == 1
        rng(40);
        loaddata = matfile(sprintf('%s_biological_results.mat', number_of_subject));
    else
        rng(46);
        loaddata = matfile(sprintf('%s_nonbiological_results.mat', number_of_subject));
    end

    % Variables to store results
    videoFile = [];
    std_dev = zeros(1, number_of_videos);
    std_err = zeros(1, number_of_videos);
    forward_answers = cell(1, number_of_videos);
    ReactionTimes = cell(1, number_of_videos);
    temp_forward = 0;
    temp_RT = 0;
    
    for i = 1:number_of_sets
        videoFile = [videoFile, videoList];
    end
    shuffledVideoFiles{p} = videoFile(randperm(length(videoFile)));
    
    Responses{p} = loaddata.Response;
    ReactionTime{p} = loaddata.ReactionTime;

    % Process data for current participant
    for i = 1:number_of_videos
        temp_reaction_times = [];
        for j = 1:total_videos
            if strcmp(shuffledVideoFiles{p}{j}, videoFile{i})
                temp_RT = temp_RT + ReactionTime{p}{j};
                temp_reaction_times = [temp_reaction_times, ReactionTime{p}{j}];
                if strcmp(Responses{p}{j}, '+')
                    temp_forward = temp_forward + 1;
                end
            end
        end
        ReactionTimes{i} = temp_RT/number_of_sets;
        forward_answers{i} = temp_forward;
        std_dev(i) = std(temp_reaction_times);
        std_err(i) = std_dev(i) / sqrt(number_of_sets);
        temp_RT = 0;
        temp_forward = 0;
    end
    
    forward_answers_participant{p} = cell2mat(forward_answers);
    ReactionTimes_participant{p} = cell2mat(ReactionTimes);
    std_err_participants{p} = std_err;
end


% Define the Boltzmann function as a custom equation
boltzmannEqn = fittype('A1 - (A1-A2) / (1 + exp((x0 - x)/dx)) + A2', ...
                       'independent', 'x', ...
                       'coefficients', {'A1', 'A2', 'x0', 'dx'});


startPoints = [max(forward_answers_participant{1}), min(forward_answers_participant{1}), mean(videolabels), 0.005];
[boltzmannFit1, ~] = fit(videolabels', forward_answers_participant{1}', boltzmannEqn, 'Start', startPoints);

startPoints = [max(forward_answers_participant{2}), min(forward_answers_participant{2}), mean(videolabels), 0.05];
[boltzmannFit2, ~] = fit(videolabels', forward_answers_participant{2}', boltzmannEqn, 'Start', startPoints);

% Create a figure with four subplots for comparison
figure;

% Subplot 1: Number of Forward Answers per Video File
subplot(2, 1, 1);
plot(videolabels, forward_answers_participant{1}, 'ko');
hold on;
plot(boltzmannFit1, 'b-');
plot(videolabels, forward_answers_participant{2}, 'ro');
plot(boltzmannFit2, 'r-');
legend('Biological Data', 'Boltzmann Fit Biological', 'Non-Biological Data', 'Boltzmann Fit Non-Biological');
xlabel('Video Files');
ylabel('Forward Answers');
title('Comparison of Forward Answers (Boltzmann Fit)');
grid on;
hold off;



% Subplot 2: Average of Reaction Times for both participants
subplot(2, 1, 2);
plot(videolabels, ReactionTimes_participant{1}, 'b-o');
hold on;
plot(videolabels, ReactionTimes_participant{2}, 'r-o');
xlabel('Video Files');
ylabel('Time');
title('Average Reaction Time per Video File');
legend('Biological', 'Non-Biological');
hold off;


batch_size = 5;
nbatch = number_of_sets/batch_size;

for p = 1:2
    % Load data for Participant p (rng 40 for p=1, rng 41 for p=2)
    if p == 1
        rng(40)
        loaddata = matfile(sprintf('%s_biological_results.mat', number_of_subject));
    else
        rng(46)
        loaddata = matfile(sprintf('%s_nonbiological_results.mat', number_of_subject));
    end
    
    % Variables to store results
    videoFile = [];
    
    for i = 1:number_of_sets
        videoFile = [videoFile, videoList];
    end
    shuffledVideoFiles{p} = videoFile(randperm(length(videoFile)));
    
    Responses{p} = loaddata.Response;
    ReactionTime{p} = loaddata.ReactionTime;
    
    % Initialize the maps
    label_map = containers.Map;
    response_map = containers.Map;
    
    for k = 1:number_of_videos
        % Get logical indices of current video label in the shuffled files
        indices = find(strcmp(shuffledVideoFiles{p}, videoList{k}));
        
        % Store the indices in the label_map
        label_map(videoList{k}) = indices; 
        
        % Ensure we only get valid responses corresponding to the current indices
        label_responses = Responses{p}(indices);
        
%         % Check if any responses exist for this video before storing
%         if ~isempty(label_responses)
%             response_map(videoList{k}) = label_responses;
%         else
%             response_map(videoList{k}) = {};  % Assign an empty array if no responses
%         end
    end


    % Initialize precision storage
    for k = 1:number_of_videos
        for j = 1:nbatch
            precision{k}{j} = 0; % Initialize to zero
        end
    end

    % Iterate over each video label
    for k = 1:number_of_videos
        label_indices = label_map(videoList{k});  % Get all indices of the current video label
        label_responses = Responses{p}(label_indices);  % Get the corresponding responses
        num_videos = length(label_indices);
        
        % Split into batches
        for j = 1:nbatch
            batch_indices = (j-1)*batch_size + 1 : min(j*batch_size, num_videos);
            batch_responses = label_responses(batch_indices);
            
            % Count correct responses in this batch
            if contains(videoList{k}, '-')
                % Negative video, looking for '-' response
                precision{k}{j} = sum(strcmp(batch_responses, '-'));
            else
                % Positive video, looking for '+' response
                precision{k}{j} = sum(strcmp(batch_responses, '+'));
            end
        end
    end

    % Convert counts to percentage precision for each batch (5 videos per batch)
    precision_numeric = zeros(number_of_videos, nbatch); % Create a numeric array to store precision
    for k = 1:number_of_videos
        for j = 1:nbatch
            precision{k}{j} = (precision{k}{j} / batch_size) * 100;  % Convert to percentage
            precision_numeric(k, j) = precision{k}{j};  % Store as numeric value
        end
    end
    
    % Store precision results for this participant
    precision_participant{p} = precision_numeric;
end

% Plotting precision results in subplots for both participants
figure;

% Prepare x values for plotting
x = 1:nbatch; % x-values (batch number)
colors = lines(number_of_videos); % Color map for different labels

% Create subplots for each video label
for k = 1:number_of_videos
    subplot(ceil(number_of_videos/2), 2, k); % Arrange subplots in a grid
    %y1 = precision_participant{1}(k, :);  % Precision values for Upright
    y2 = precision_participant{2}(k, :);  % Precision values for Inverse
    %plot(x, y1, '-o', 'Color', colors(k, :), 'DisplayName', sprintf('Upright Block - Label %.1f', videolabels(k)));
    hold on;
    plot(x, y2, '--o', 'Color', colors(k, :), 'DisplayName', sprintf('Non-Biological Block - Label %.1f', videolabels(k)));
    
    % Add details for each subplot
    xlabel('Batch Number');
    ylabel('Precision (%)');
    title(sprintf('Label %.1f', videolabels(k)));
    % legend('show');
    grid on;
    ylim([0 100]);
    hold off;
end

sgtitle('Precision of Correct Responses by Batch and Video Label for Both Blocks');  % Global title for all subplots



% Initialize storage for precision results
total_batches = total_videos / 5;
total_precision = zeros(1, total_batches);
correct = 0;
j = 0; % Index for counting batches
ne = 0;

% Iterate through the shuffled video files and responses
for i = 1:total_videos
    if contains(shuffledVideoFiles{1}{i}, '-')  % For negative videos
        ne = ne + 1;
        if strcmp(Responses{1}{i}, '-')  % Correct response is '-'
            correct = correct + 1;
        end
    end
    % Every 5th video (end of a batch)
    if mod(i, batch_size) == 0
        j = j + 1;  % Move to the next batch
        total_precision(j) = (correct / ne) * 100;  % Calculate precision for this batch
        correct = 0;  % Reset correct count for the next batch
        ne = 0;
    end
end

% Handle any remaining videos in the last batch (if the total is not a perfect multiple of batch_size)
if mod(total_videos, batch_size) ~= 0
    j = j + 1;
    total_precision(j) = (correct / (total_videos - (j-1)*batch_size)) * 100;
end

% % Plot total precision by batch
% figure;
% x = 1:total_batches; % x-values (batch number)
% plot(x, total_precision(1:total_batches), '-o');
% xlabel('Batch Number');
% ylabel('Precision (%)');
% title('Precision of `-` Videos by Batch In Upright Videos');
% grid on;
% ylim([0 100]);  % Set y-axis limits from 0 to 100



j = 1;
% tahlil
correct = 0;
totalTime = 0;
for i=1:total_videos
    if  contains(shuffledVideoFiles{1}{i}, '-')
        j = j + 1;
        if strcmp(Responses{1}{i}, '-')
            correct = correct + 1;
        end
    elseif strcmp(Responses{1}{i}, '+')
            correct = correct + 1;
    end
    totalTime = totalTime + ReactionTime{1}{i};
end

