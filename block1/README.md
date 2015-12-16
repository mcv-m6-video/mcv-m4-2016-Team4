# Week 1. Assessment of Foreground Extraction and Optical Flow
		
## Structure

* *_docs_* -> Contains the information regarding this week.
* *_src_* -> Contains the code used to solve the proposed problem.
* *_figures_* -> Contains all the plots generated this week.

## Documentation

* *_Week 1_Pre-slides_* -> Problem proposed for the current week.
* *_SlidesB1_* -> Progres slides for the mandatory and optional tasks proposed during this week.

## Source

* *_main.m_*:

Script that generates all the asked results for this week. This file is divided in sections corresponding to the different tasks. For instance, as far as variable _VERBOSE_ is set automatically to _True_, the desired results and plots will be shown for each execution.

* *_getMetrics.m_*

Computes the metrics evaluation, Precision (P), Recall (R), F1-score (F1) given True Positives (TP), False Positives (FP), True Negatives (FN) and False Negatives (TN). TN is optional. This function is prepared to accept vectors as an input.

* *_segmentationEvaluation.m_*

Evaluates the segmentation obtained in the folder _pathResults_ with _testId_ identifier, _pathGroundtruth_ contains the path to the ground truth, _forward_ id the number of frames to shift in order to create a desynchronization for experimentation / debug purposes (forward = 0 means no desynch at all, forward = N creates a shift of N frames between the results and the groundtruth) and _VERBOSE_ that plots further information.

* *_opticalFlowEvaluation.m_*

Evaluates the optical flow obtained in the folder _pathResults_ with _testId_ identifier, _pathGroundtruth_ contains the path to the ground truth, _pepnThresh_ is a threshold for the PEPN computation and _VERBOSE_ that plots further information.

* *_plotF1ScorePerFrame.m_*

Plot the F1-score per frame. Recieve the information _f1Scores_ that is a NxM matrix where N are the F1 Scores of each frame and M_i represents the F1 Score of test sequence i.

* *_plotTP_TF_PerFrame.m_*

Plot true positives and total foreground of the groundtruth. Recieve the information _truePositives_ that is a NxM matrix where N are the TP of each frame and M_i represents the TP of test sequence i.

* *_readFlow.m_*
Given a path of a flow file, extract the components (u,v) and the valid non-ocluded pixels.

* *_plotOpticalFlow.m_*

Show the optical flow. Its parameters are _realImage_ that is the realimage RGB, _annotationImage_ that corresponds to the opticalFlow annotations and _subSample_ that indicates the numbers of subsamples.