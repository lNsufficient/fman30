start_over = 0;
do_load = 1;
if start_over

    clear all;
    % This files show how to read in the HEp-2 data and perform basic machine learning.

    %% Add functions folder to MATLAB path
    root = fileparts(mfilename('fullpath'));
    addpath([root filesep 'functions']);

    %% Loading data
    % Classes are named
    % 1: 'homogeneous'
    % 2: 'coarse_speckled'
    % 3: 'fine_speckled'
    % 4: 'nucleolar'
    % 5: 'centromere'
    % 6: 'cytoplasmatic'

    % Read all images. 
    % SET is cell array 
    % SET{i} contains all images from measurement i.
    SET = load_all_images();

    %% Features
    for measurement = 1:numel(SET)
        Fv = [];
        for image_id = 1:SET{measurement}.n

            image = SET{measurement}.I{image_id};
            mask = SET{measurement}.M{image_id};

            % It is recommended to have the feature extraction in a seperate function
            % which takes a image and a mask and returns a feature vector.
            Fv(image_id,:) = get_features(image,mask)';
            %

        end

        Fn{measurement} = Fv;
    end

    % Fn is indexed as
    % Fn{measurement}(image_id,feature)


    [~,feature_names] = get_features(image,mask);
    fprintf('Using the features \n')
    for i = 1:numel(feature_names)
            fprintf('%d. %s \n', i, feature_names{i});
    end



%% Creating train and test set

% This division between train and test set contains data from all classes,
% it is possible to change this division.
train_index = [1 11 2 3 6 5 4 15];
test_index = setdiff(1:numel(SET),train_index);

% Merge all measurements into two cells
train_features = [];
test_features = [];
train_classes = [];
test_classes = [];

for i = train_index
	train_features = [train_features; Fn{i}];
	train_classes =  [train_classes; SET{i}.CLASS'];
end

for i = test_index
	 test_features = [test_features; Fn{i}];
	 test_classes =  [test_classes; SET{i}.CLASS'];
end

    %% Save the data so you can continue from here...
    disp('save the data or ctrl-c!')
    pause;
    save('all data');
else 
    if do_load
        disp('load the data or ctrl-c!')
        pause;
        load('all data')
    end
end
%% Create a classifier,
% Built into matlab
% SVM: svmtrain, svmclassify
% Random forest: treebagger
% ADAboost: fitensemble

classify_nbr = 4;
train_classifyer = 1;
if train_classifyer
    if classify_nbr == 1
        nTrees = 500;
        BaggerObj = TreeBagger(nTrees,train_features,train_classes);
    elseif classify_nbr == 2
        N = max(train_classes);
        nbr_classifyers = (N-1)*N/2;
        classifyers = cell(nbr_classifyers);
        k = 1;
        for i = 1:N
            i_index = find(train_classes == i);
            for j = i:N
                j_index = find(train_classes == j);
                indices = [i_index; j_index];
                train_class = [ones(size(i_index)); -ones(size(j_index))];
                classifyers{k} = fitcsvm(train_features(indices,:), train_class); 
                k = k + 1;
            end
        end
    elseif classify_nbr == 3
        N = max(train_classes);
        classifyers = cell(N);
        for i = 1:N
            train_class_temp = (train_classes == i)*2-1;
            classifyers{i} = fitcsvm(train_features, train_class_temp);
        end
    elseif classify_nbr == 4
        KNN = fitcknn(train_features, train_classes)
    end
    save('classifyer');
else
    load('classifyer');
end
%% Classify
if classify_nbr == 1
    Result = BaggerObj.predict(test_features);
elseif classify_nbr == 2
    nbr_test_features = size(test_features, 1);
    class_possibilities = zeros(nbr_test_features, nbr_classifyers);
    scores = class_possibilities;
    for i = 1:nbr_classifyers;
        class_possibilities(:,i) = predict(classifyers{i}, test_features);
    end
    votes_for_classes = zeros(nbr_test_features, N);
    votes_for_classes(:,1) = sum(class_possibilities(:,1:5)>0,2);
    votes_for_classes(:,2) = sum(class_possibilities(:,6:9)>0,2) + sum(class_possibilities(:,1) < 0,2);
    votes_for_classes(:,3) = sum(class_possibilities(:,10:12)>0,2) +sum(class_possibilities(:,[2 6]) < 0,2);
    votes_for_classes(:,4) = sum(class_possibilities(:,13:14)>0,2) +sum(class_possibilities(:,[3 7 10]) < 0,2);
    votes_for_classes(:,5) = sum(class_possibilities(:,15)>0,2) + sum(class_possibilities(:,[4 8 11 13]) < 0,2);
    votes_for_classes(:,6) = sum(class_possibilities(:,[5 9 12 14 15]) <0,2);
    [~, n] = max(votes_for_classes, [], 2);
    %[m, n] = find(class_possibilities == 1);
    class = zeros(nbr_test_features,1);
    no_hit_counter = 0;
    for i = 1:nbr_test_features
        class(i) = n(i);
    end
    Result = class;
elseif classify_nbr == 3
    nbr_test_features = size(test_features, 1);
    class_possibilities = zeros(nbr_test_features, N);
    scores = class_possibilities;
    for i = 1:N
        [class_possibilities(:,i) s] = predict(classifyers{i}, test_features);
        scores(:,i) = s(:,2);
    end
    [~, n] = max(scores, [], 2);
    %[m, n] = find(class_possibilities == 1);
    class = zeros(nbr_test_features,1);
    no_hit_counter = 0;
    for i = 1:nbr_test_features
        class(i) = n(i);
    end
    Result = class;
elseif classify_nbr == 4
    [class, ~, ~] = predict(KNN,test_features)
    Result = class;
end
%% Evaluate 

% Confusion matrix
matrix = zeros(6,6);
for j = 1:length(Result)

	gt = test_classes(j);
	
	% TreeBagger have char/string labels
    if classify_nbr == 1
	classified = str2double(Result{j});
    elseif classify_nbr == 2
        classified = Result(j)
    elseif classify_nbr == 3
        classified = Result(j)
    elseif classify_nbr == 4
        classified = Result(j)
    end
	matrix(gt,classified) = matrix(gt,classified)  + 1;
end

fprintf('Total correct cell rate : %.1f%%\n',sum(diag(matrix))/sum(matrix(:))*100);
