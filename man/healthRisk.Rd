% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/healthRisk-base.R
\name{healthRisk}
\alias{healthRisk}
\title{Constructing a HealthRisk}
\usage{
healthRisk(corr.mat)
}
\arguments{
\item{corr.mat}{matrix of numeric values. It must be a valid
correlation matrix. This matrix must have names, i.e. attributes
\code{colnames} and \code{rownames} indicating the names of the
corresponding health insurance risk factors.}
}
\value{
an S3 object, instance of the class healthRisk.
}
\description{
\code{healthRisk} is the constructor for the
  S3 class healthRisk. It allows to build for health
  insurance risks parameters.
}
\examples{
# Creating new healthRisks.

corr.mat <- diag(rep(1, 2))
colnames(corr.mat) <- c("invalidity", "longetivity")
rownames(corr.mat) <- colnames(corr.mat)

healthRisk1 <- healthRisk(corr.mat  = corr.mat)

}
\seealso{
\code{\link{summary.healthRisk}}, \code{\link{print.healthRisk}},
  \code{\link{compute.healthRisk}}.
}
