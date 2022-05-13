# Sleep_Stage_Classification
#Within this repository contains a mlx file for testing results of classifying edf files through random forest classification.

#Functions:
Build_Classification_Tree - Build random forest classification model

Classify_And_Compute_Accuracy_Epochs - Function takes in testing set and classifies the epochs and calculates the performance of the model

Classify_Epoch - Classifies a 30 second epoch using random forest classification

Cut_Signal_Into_Epochs_FLobe - Function for cutting the epoch into signals using the Frontal Lobe

Cut_Signal_Into_Epochs_PLobe - Function for cutting the epoch into signals using the Parietal Lobe

Epoch_Bootstrp - Bootstrapping function to random sample epochs to get random sampling cell array

epochRandomSample - takes in all epochs and splits them between testing and training sets 2/3 for training 1/3 for testing
