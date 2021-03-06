\name{NEWS}
\title{News for Package "recosystem"}

\section{Changes in recosystem version 0.3}{
  \itemize{
    \item Update LIBMF to version 1.2.
    \item Due to API change in LIBMF 1.2, \code{$convert_train()} and
          \code{$convert_test()} have been removed, and \code{$train()}
          and \code{$predict()} have changed API accordingly.
    \item New member function \code{$tune()} for tuning model parameters.
  }
}

\section{Changes in recosystem version 0.2.5}{
  \itemize{
    \item New member function \code{$output()} to output factorization matrices.
  }
}

\section{Changes in recosystem version 0.2.4}{
  \itemize{
    \item (Internal) Avoid using C RNG.
    \item Fix UBSAN runtime errors with thanks to Prof. Brian Ripley.
  }
}

\section{Changes in recosystem version 0.2.3}{
  \itemize{
    \item (Internal) Use pthreads on Windows to support multithreading.
  }
}

\section{Changes in recosystem version 0.2.2}{
  \itemize{
    \item (Internal) Use portable code to allocate aligned memory.
  }
}

\section{Changes in recosystem version 0.2.1}{
  \itemize{
    \item Roll back to \pkg{Rcpp} due to a NOTE in \code{R CMD check}.
    \item Change package name from \pkg{Recosystem} to \pkg{recosystem}.
    \item Now using R to generate random numbers in the algorithm, so
    the result is reproducible by setting seeds inside R.
  }
}

\section{Changes in recosystem version 0.2}{
  \itemize{
    \item Now linking to \pkg{Rcpp11}.
    \item A new parameter \code{verbose} to control output information.
  }
}

\section{Changes in recosystem version 0.1}{
  \itemize{
    \item Initial version.
  }
}
 
  
