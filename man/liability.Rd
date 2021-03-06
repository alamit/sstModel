% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/liability-base.R
\name{liability}
\alias{liability}
\title{Constructing an Insurance Liability}
\usage{
liability(time, currency, value)
}
\arguments{
\item{time}{stricly positive integer value of length one representing the
time-to-maturity. This parameter relates to the \emph{"Restlaufzeit"} liability variable
\code{tau} in the FINMA document \emph{"SST-Marktrisiko und -Aggregation Technische Beschreibung"}.}

\item{currency}{character value of length one representing the currency in
which the fixed-income-asset is labeled. This parameter relates
 to the \emph{"Fremdwährungsrisikofaktor"} index \code{j} in the FINMA
 document \emph{"SST-Marktrisiko und -Aggregation Technische Beschreibung"}.}

\item{value}{non-zero numeric value of length one representing the
\emph{"Certainty-Equivalent-Versicherungsverpflichtung-Cashflows"} as referred in
the FINMA document \emph{"SST-Marktrisiko und -Aggregation Technische Beschreibung"}.
at time \code{time}. This must be expressed in the same currency as \code{currency}.
If \code{value} is negative, then the liability is interpreted as a positive cashflow.}
}
\value{
an S3 object, instance of the class liability.
}
\description{
Constructor for the S3 class liability.
  It allows to build for an insurance liability referred under the
  name \emph{"Versicherungsverpflichtungen"} in the FINMA technical document
  \emph{"SST-Marktrisiko und -Aggregation Technische Beschreibung"}.
}
\examples{
# Creating new liabilities.
liability1 <- liability(1, "USD", 1000)
liability2 <- liability(2, "EUR", 2000)

}
\seealso{
\code{\link{summary.liability}}, \code{\link{print.liability}}.
}
