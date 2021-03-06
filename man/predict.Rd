% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/RecoSys.R
\name{predict}
\alias{predict}
\title{Recommender Model Predictions}
\arguments{
\item{r}{Object returned by \code{\link{Reco}()}.}

\item{out_pred}{Path to the output file for prediction. If set to \code{NULL},
                this function will return the predicted values in memory.
                The format of testing data file is the same as training
                data (see the \strong{Data Format} section in
                \code{$\link{train}()}), except that the third value in
                each line can be omitted.}
}
\description{
This method is a member function of class "\code{RecoSys}"
that predicts unknown entries in the rating matrix.
Prior to calling this method, model needs to be trained by calling
\code{$\link{train}()}.
Prediction results will be written into the specified file, one value
per line, corresponding to the testing data.

The common usage of this method is
\preformatted{r = Reco()
r$predict(test_path, out_pred = file.path(tempdir(), "predict.txt")}
}
\examples{
\dontrun{trainset = system.file("dat", "smalltrain.txt", package = "recosystem")
testset = system.file("dat", "smalltest.txt", package = "recosystem")
r = Reco()
set.seed(123) # This is a randomized algorithm
opts_tune = r$tune(trainset)$min
r$train(trainset, opts = opts_tune)

## Write predicted values to file
out_pred = tempfile()
r$predict(trainset, out_pred)

## Return predicted values in memory
pred = r$predict(trainset, NULL)

## Compare results
print(scan(out_pred, n = 10))
head(pred, 10)
}
}
\author{
Yixuan Qiu <\url{http://statr.me}>
}
\references{
W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
ACM TIST, 2015.

W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
A learning-rate schedule for stochastic gradient methods to matrix factorization.
PAKDD, 2015.
}
\seealso{
\code{$\link{train}()}
}

