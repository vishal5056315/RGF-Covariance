function xcovar=covarf(x,cov_wsize)

%%% covarf: computes covariance of a signal.
%%% covarf(X), if X is a vector, returns the variance.
%%% For matrices, where each row is an observation, and each column a variable,
%%% covarf(X) is the covariance matrix.
%%% diag(covarf(X)) is a vector of variances for each column.
%%% sqrt(diag(covarf(X))) is a vector of standard deviations.
%%% wsize should be odd.


tr=x-repmat(mean(x),cov_wsize,1);
xcovar=tr'*tr/(cov_wsize-1);