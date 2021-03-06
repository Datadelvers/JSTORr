\name{JSTOR_unpack2grams}
\alias{JSTOR_unpack2grams}
\title{Unpack JSTOR journal articles and bibliographic data to a Document Term Matrix of 2-grams}
\usage{
JSTOR_unpack2grams(parallel = FALSE, path = getwd())
}
\arguments{
  \item{path}{full path to directory containing 'bigrams'
  folder and the citations.CSV file. These are obtained
  after unzipping the file downloaded from DfR (you should
  unzip the file before running this function). Default is
  the working directory.}

  \item{parallel}{if TRUE, apply function in parallel,
  using the parallel library. Default is FALSE as this is
  typically faster for smaller datasets (ie. ~5000
  articles) due to communication overhead.}
}
\value{
Returns a list of two items. First is "bigrams", a Document
Term Matrix of 2-grams, and second is 'bibliodata', a data
frame of bibliographic information for all articles.
}
\description{
Import journal articles and bibliographic data from the
downloaded zipfile and reshape ready for simple text
mining. For use with JSTOR's Data for Research datasets
(http://dfr.jstor.org/).
}
\examples{
## unpack2grams <- JSTOR_unpack2grams(path = "C:/Users/marwick/Downloads/JSTOR") # then follow prompts to navigate to the location of the zipfile
}

