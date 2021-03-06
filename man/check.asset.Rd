% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/asset-base.R
\name{check.asset}
\alias{check.asset}
\title{Checking Consistency of an Asset with Direct
Market Price with a MarketRisk}
\usage{
\method{check}{asset}(object, market.risk, ...)
}
\arguments{
\item{object}{S3 object of class asset.}

\item{market.risk}{S3 object of class marketRisk created using
the constructor \code{\link{marketRisk}}.}

\item{...}{additional arguments.}
}
\value{
a logical value, is the asset consistent with the marketRisk?
}
\description{
\code{check} is a generic S3 method for S3 classes inheriting
  from item. It is a logical method checking if the item is well-defined
  with respect to a risk (i.e. that all information necessary for valuating
  the item is available).
}
\seealso{
\code{\link{check}}, \code{\link{asset}},
  \code{\link{marketRisk}}.
}
