RecoSys = setRefClass("RecoSys",
                      fields = list(model = "RecoModel"))

#' Constructing a Recommender System Object
#' 
#' This function simply returns an object of class "\code{RecoSys}"
#' that can be used to construct recommender model and conduct prediction.
#' 
#' @return \code{Reco()} returns an object of class "\code{RecoSys}"
#' equipped with methods
#' \code{$\link{tune}()}, \code{$\link{train}()}, \code{$\link{output}()}
#' and \code{$\link{predict}()}, which describe the typical process of
#' building and tuning model, outputing coefficients, and
#' predicting results. See their help documents for details.
#' @author Yixuan Qiu <\url{http://statr.me}>
#' @seealso \code{$\link{tune}()}, \code{$\link{train}()}, \code{$\link{output}()},
#' \code{$\link{predict}()}
#' @references W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
#' ACM TIST, 2015.
#' 
#' W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A learning-rate schedule for stochastic gradient methods to matrix factorization.
#' PAKDD, 2015. 
#' 
#' @export
#' @keywords models
Reco = function()
{
    return(RecoSys$new())
}



## Notice on API change
RecoSys$methods(
    convert_train = function(...)
    {
        message("The API of recosystem has changed since version 0.3
- $convert_train() and $convert_test() have been removed
- $train() and $predict() have different argument lists
- Added $tune() member function for parameter tuning

Please see the help pages or the vignette for details")
    }
)
RecoSys$methods(
    convert_test = function(...)
    {
        .self$convert_train(...)
    }
)



#' Tuning Model Parameters
#' 
#' @description This method is a member function of class "\code{RecoSys}"
#' that uses cross validation to tune the model parameters.
#' 
#' The common usage of this method is
#' \preformatted{r = Reco()
#' r$tune(train_path, opts = list(dim = c(10, 15, 20),
#'                                cost = c(0.01, 0.1),
#'                                lrate = c(0.01, 0.1))
#' )}
#' 
#' @name tune
#' 
#' @param r Object returned by \code{\link{Reco}}().
#' @param train_path Path to the traning data file, same as the one in
#'                   \code{$\link{train}()}. See the help page there for the
#'                   details about the data format.
#' @param opts A number of candidate tuning parameter values and extra options in the
#'             model tuning procedure. See section \strong{Parameters and Options}
#'             for details.
#' 
#' @return A list with two components:
#' 
#' \describe{
#'   \item{\code{min}}{Parameter values with minimum cross validation RMSE. This
#'                     is a list that can be passed to the \code{opts} argument
#'                     in \code{$\link{train}()}.}
#'   \item{\code{res}}{A data frame giving the supplied candidate
#'                     values of tuning parameters, and one column showing the
#'                     RMSE associated with each combination.}
#' }
#'             
#' @section Parameters and Options:
#' The \code{opts} argument should be a list that provides the candidate values
#' of tuning parameters and some other options. For tuning parameter (\code{dim},
#' \code{cost} or \code{lrate}), users can provide a numeric vector, so that
#' the model will be evaluated on each combination of the candidate values.
#' For other non-tuning options, users should give a single value. If a parameter
#' or option is not set by the user, the program will use a default one.
#' 
#' See below for the list of available parameters and options:
#'
#' \describe{
#' \item{\code{dim}}{Tuning parameter, the number of latent factors.
#'                   Can be specified as an integer vector, with default value
#'                   \code{c(10, 15, 20)}.}
#' \item{\code{cost}}{Tuning parameter, the regularization cost for latent factors.
#'                    Can be specified as a numeric vector, with default value
#'                    \code{c(0.01, 0.1)}.}
#' \item{\code{lrate}}{Tuning parameter, the learning rate, which can be thought
#'                     of as the step size in gradient descent.
#'                     Can be specified as a numeric vector, with default value
#'                     \code{c(0.01, 0.1)}.}
#' \item{\code{nfold}}{Integer, the number of folds in cross validation. Default is 5.}
#' \item{\code{niter}}{Integer, the number of iterations. Default is 20.}
#' \item{\code{nthread}}{Integer, the number of threads for parallel
#'                       computing. Default is 1.}
#' \item{\code{nmf}}{Logical, whether to perform non-negative matrix factorization.
#'                   Default is \code{FALSE}.}
#' \item{\code{verbose}}{Logical, whether to show detailed information. Default is
#'                       \code{FALSE}.}
#' }
#' 
#' @examples \dontrun{trainset = system.file("dat", "smalltrain.txt", package = "recosystem")
#' r = Reco()
#' set.seed(123) # This is a randomized algorithm
#' res = r$tune(
#'     trainset,
#'     opts = list(dim = c(10, 20, 30), lrate = c(0.05, 0.1, 0.2), nthread = 2)
#' )
#' r$train(trainset, opts = res$min)
#' }
#' 
#' @author Yixuan Qiu <\url{http://statr.me}>
#' @seealso \code{$\link{train}()}
#' @references W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
#' ACM TIST, 2015.
#' 
#' W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A learning-rate schedule for stochastic gradient methods to matrix factorization.
#' PAKDD, 2015. 
#' 
NULL

RecoSys$methods(
    tune = function(train_path, opts = list(dim = c(10L, 15L, 20L),
                                            cost = c(0.01, 0.1),
                                            lrate = c(0.01, 0.1)))
    {
        ## Check whether training set file exists
        train_path = path.expand(train_path)
        if(!file.exists(train_path))
        {
            stop(sprintf("%s does not exist", train_path))
        }
        
        ## Tuning parameters: dim, cost, lrate
        ## First set up default values
        opts_tune = list(dim   = c(10L, 15L, 20L),
                         cost  = c(0.01, 0.1),
                         lrate = c(0.01, 0.1))
        ## Update opts_tune from opts
        if("dim" %in% names(opts))
        {
            opts_tune$dim = as.integer(opts$dim)
        }
        if("cost" %in% names(opts))
        {
            opts_tune$cost = as.numeric(opts$cost)
        }
        if("lrate" %in% names(opts))
        {
            opts_tune$lrate = as.numeric(opts$lrate)
        }
        ## Expand combinations
        opts_tune = expand.grid(opts_tune)
        
        ## Other options
        opts_train = list(nfold = 5L, niter = 20L, nthread = 1L,
                          nmf = FALSE, verbose = FALSE)
        opts = as.list(opts)
        opts_common = intersect(names(opts), names(opts_train))
        opts_train[opts_common] = opts[opts_common]
        
        rmse = .Call("reco_tune", train_path, opts_tune, opts_train,
                            package = "recosystem")
        
        opts_tune$rmse = rmse
        opts_tune = na.omit(opts_tune)
        if(!nrow(opts_tune))
            stop("results are all NA/NaN")

        tune_min = opts_tune[which.min(rmse), ]
        opts_min = list(dim = tune_min$dim, cost = tune_min$cost, lrate = tune_min$lrate)
        
        return(list(min = opts_min, res = opts_tune))
    }
)



#' Training a Recommender Model
#' 
#' @description This method is a member function of class "\code{RecoSys}"
#' that trains a recommender model. It will read a training data file and
#' create a model file at the specified locations. The model file contains
#' necessary information for prediction.
#' 
#' The common usage of this method is
#' \preformatted{r = Reco()
#' r$train(train_path, out_model = file.path(tempdir(), "model.txt"),
#'         opts = list())}
#' 
#' @name train
#' 
#' @param r Object returned by \code{\link{Reco}}().
#' @param train_path Path to the traning data file. See section \strong{Data Format}
#'                   for the details about the data format.
#' @param out_model Path to the model file that will be created.
#' @param opts A number of parameters and options for the model training.
#'             See section \strong{Parameters and Options} for details.
#'             
#' @section Parameters and Options:
#' The \code{opts} argument is a list that can supply any of the following parameters:
#'
#' \describe{
#' \item{\code{dim}}{Integer, the number of latent factors. Default is 10.}
#' \item{\code{cost}}{Numeric, the regularization cost for latent factors. Default is 0.1.}
#' \item{\code{lrate}}{Numeric, the learning rate, which can be thought
#'                     of as the step size in gradient descent. Default is 0.1.}
#' \item{\code{niter}}{Integer, the number of iterations. Default is 20.}
#' \item{\code{nthread}}{Integer, the number of threads for parallel
#'                       computing. Default is 1.}
#' \item{\code{nmf}}{Logical, whether to perform non-negative matrix factorization.
#'                   Default is \code{FALSE}.}
#' \item{\code{verbose}}{Logical, whether to show detailed information. Default is
#'                       \code{TRUE}.}
#' }
#' 
#' @section Data Format:
#' The training data file takes the format of sparse matrix
#' in triplet form, i.e., each line in the file contains three numbers
#' \preformatted{row col value}
#' representing a number in the rating matrix
#' with its location. In real applications, it typically looks like
#' \preformatted{user_id item_id rating}
#' 
#' \bold{NOTE}: \code{row} and \code{col} start from 0. So if the first user
#' rates 3 on the first item, the line will be
#' \preformatted{0 0 3}
#' 
#' Example data files are contained in the \code{recosystem/dat} directory.
#' 
#' @examples trainset = system.file("dat", "smalltrain.txt", package = "recosystem")
#' r = Reco()
#' set.seed(123) # This is a randomized algorithm
#' r$train(trainset, opts = list(dim = 20, cost = 0.01, nthread = 2))
#' 
#' @author Yixuan Qiu <\url{http://statr.me}>
#' @seealso \code{$\link{tune}()}, \code{$\link{output}()}, \code{$\link{predict}()}
#' @references W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
#' ACM TIST, 2015.
#' 
#' W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A learning-rate schedule for stochastic gradient methods to matrix factorization.
#' PAKDD, 2015. 
NULL

RecoSys$methods(
    train = function(train_path, out_model = file.path(tempdir(), "model.txt"),
                     opts = list())
    {
        ## Check whether training set file exists
        train_path = path.expand(train_path)
        if(!file.exists(train_path))
        {
            stop(sprintf("%s does not exist", train_path))
        }
        
        model_path = path.expand(out_model)
        
        ## Parse options
        opts_train = list(dim = 10L, cost = 0.1, lrate = 0.1,
                          niter = 20L, nthread = 1L,
                          nmf = FALSE, implicit = FALSE, verbose = TRUE)
        opts = as.list(opts)
        opts_common = intersect(names(opts), names(opts_train))
        opts_train[opts_common] = opts[opts_common]
        
        ## Additional parameters to be passed to libmf but not set by users here
        opts_train$nfold = 1L;
        opts_train$va_path = ""
        
        model_param = .Call("reco_train", train_path, model_path, opts_train,
                            package = "recosystem")
        
        .self$model$path = model_path
        .self$model$nuser = model_param$nuser
        .self$model$nitem = model_param$nitem
        .self$model$nfac = model_param$nfac
        
        invisible(.self)
    }
)



#' Outputing Factorization Matrices
#' 
#' @description This method is a member function of class "\code{RecoSys}"
#' that could write the user score matrix \eqn{P} and item score matrix \eqn{Q}
#' to text files.
#' 
#' Prior to calling this method, model needs to be trained by calling
#' \code{$\link{train}()}.
#' 
#' The common usage of this method is
#' \preformatted{r = Reco()
#' r$output(out_P = file.path(tempdir(), "mat_P.txt"),
#'          out_Q = file.path(tempdir(), "mat_Q.txt"))}
#' 
#' @name output
#' 
#' @param r Object returned by \code{\link{Reco}()}.
#' @param out_P Filename of the output user score matrix. Note that this contains
#'              the \strong{transpose} of the \eqn{P} matrix, hence each row in
#'              the file stands for a user, and each column stands for a latent
#'              factor. Values are space seperated. If \code{out_P} is an empty
#'              string (\code{""}), the \eqn{P} matrix will not be output.
#' @param out_Q Filename of the output item score matrix. Note that this contains
#'              the \strong{transpose} of the \eqn{Q} matrix, hence each row in
#'              the file stands for an item, and each column stands for a latent
#'              factor. Values are space seperated. If \code{out_Q} is an empty
#'              string (\code{""}), the \eqn{Q} matrix will not be output. If both
#'              \code{out_P} and \code{out_Q} are \code{NULL}, this function will
#'              return a list containing the \eqn{P} and \eqn{Q} matrices in memory,
#'              and no files will be created.
#' 
#' @examples trainset = system.file("dat", "smalltrain.txt", package = "recosystem")
#' r = Reco()
#' set.seed(123) # This is a randomized algorithm
#' r$train(trainset, opts = list(dim = 10, nmf = TRUE))
#' P_path = tempfile()
#' Q_path = tempfile()
#' 
#' ## Write P and Q matrices to files
#' r$output(P_path, Q_path)
#' head(read.table(P_path, header = FALSE, sep = " "))
#' head(read.table(Q_path, header = FALSE, sep = " "))
#' 
#' ## Skip P and only output Q
#' r$output("", Q_path)
#' 
#' ## Return P and Q in memory
#' res = r$output(NULL, NULL)
#' head(res$P)
#' head(res$Q)
#'
#' @author Yixuan Qiu <\url{http://statr.me}>
#' @seealso \code{$\link{train}()}, \code{$\link{predict}()}
#' @references W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
#' ACM TIST, 2015.
#' 
#' W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A learning-rate schedule for stochastic gradient methods to matrix factorization.
#' PAKDD, 2015. 
NULL

RecoSys$methods(
    output = function(out_P = file.path(tempdir(), "mat_P.txt"),
                      out_Q = file.path(tempdir(), "mat_Q.txt"))
    {
        ## Check whether model has been trained
        model_path = .self$model$path
        if(!file.exists(model_path))
        {
            stop("model not trained yet
[Call $train() method to train model]")
        }
        
        ## If both are NULL, return P and Q matrices in memory
        if(is.null(out_P) & is.null(out_Q))
        {
            res = .Call("reco_output_memory", model_path)
            return(list(P = matrix(res$Pdata, .self$model$nuser, byrow = TRUE),
                        Q = matrix(res$Qdata, .self$model$nitem, byrow = TRUE)))
        }
        
        out_P = path.expand(out_P)
        out_Q = path.expand(out_Q)
        
        .Call("reco_output", model_path, out_P, out_Q, PACKAGE = "recosystem")
        
        if(nchar(out_P))
            cat(sprintf("P matrix generated at %s\n", out_P))
        
        if(nchar(out_Q))
            cat(sprintf("Q matrix generated at %s\n", out_Q))
        
        invisible(.self)
    }
)



#' Recommender Model Predictions
#' 
#' @description This method is a member function of class "\code{RecoSys}"
#' that predicts unknown entries in the rating matrix.
#' Prior to calling this method, model needs to be trained by calling
#' \code{$\link{train}()}.
#' Prediction results will be written into the specified file, one value
#' per line, corresponding to the testing data.
#' 
#' The common usage of this method is
#' \preformatted{r = Reco()
#' r$predict(test_path, out_pred = file.path(tempdir(), "predict.txt")}
#' 
#' @name predict
#' 
#' @param r Object returned by \code{\link{Reco}()}.
#' @param out_pred Path to the output file for prediction. If set to \code{NULL},
#'                 this function will return the predicted values in memory.
#'                 The format of testing data file is the same as training
#'                 data (see the \strong{Data Format} section in
#'                 \code{$\link{train}()}), except that the third value in
#'                 each line can be omitted.
#'
#' @examples \dontrun{trainset = system.file("dat", "smalltrain.txt", package = "recosystem")
#' testset = system.file("dat", "smalltest.txt", package = "recosystem")
#' r = Reco()
#' set.seed(123) # This is a randomized algorithm
#' opts_tune = r$tune(trainset)$min
#' r$train(trainset, opts = opts_tune)
#' 
#' ## Write predicted values to file
#' out_pred = tempfile()
#' r$predict(trainset, out_pred)
#' 
#' ## Return predicted values in memory
#' pred = r$predict(trainset, NULL)
#'
#' ## Compare results
#' print(scan(out_pred, n = 10))
#' head(pred, 10)
#' }
#' 
#' @author Yixuan Qiu <\url{http://statr.me}>
#' @seealso \code{$\link{train}()}
#' @references W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A Fast Parallel Stochastic Gradient Method for Matrix Factorization in Shared Memory Systems.
#' ACM TIST, 2015.
#' 
#' W.-S. Chin, Y. Zhuang, Y.-C. Juan, and C.-J. Lin.
#' A learning-rate schedule for stochastic gradient methods to matrix factorization.
#' PAKDD, 2015. 
NULL

RecoSys$methods(
    predict = function(test_path, out_pred = file.path(tempdir(), "predict.txt"))
    {
        ## Check whether testing set file exists
        test_path = path.expand(test_path)
        if(!file.exists(test_path))
        {
            stop(sprintf("%s does not exist", test_path))
        }
        
        ## Check whether model has been trained
        model_path = .self$model$path
        if(!file.exists(model_path))
        {
            stop("model not trained yet
[Call $train() method to train model]")
        }
        
        ## If out_pred is NULL, return prediction in memory
        if(is.null(out_pred))
        {
            res = .Call("reco_predict_memory", test_path, model_path)
            return(res)
        }
        
        out_path = path.expand(out_pred)
        
        .Call("reco_predict", test_path, model_path, out_path, PACKAGE = "recosystem")
        
        cat(sprintf("prediction output generated at %s\n", out_path))
        
        invisible(.self)
    }
)

RecoSys$methods(
    show = function()
    {
        cat("[=== Fitted Model ===]\n\n")
        .self$model$show()
        
        invisible(.self)
    }
)
