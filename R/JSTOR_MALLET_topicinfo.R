#' Get information about a topic generated by MALLET
#' 
#' @description Gets keywords, DOIs, alpha values and exemplary articles for a topic. Originally written by Andrew Goldstone. For use with JSTOR's Data for Research datasets (http://dfr.jstor.org/).
#' @param x the object returned by the function JSTOR_unpack.
#' @param n the topic number to get information about (starts at 1)
#' @param threshold proportion of topic required for a document to be considered exemplary of that topic
#' @return Returns a list that includes top words, alpha value, and top articles for the selected topic
#' @examples 
#' ## info <- JSTOR_MALLET_topicinfo(x = unpack, n = 1)



JSTOR_MALLET_topicinfo <- function(x, n, threshold=0.3){
  ## = Ben Marwick's comments
  # = Andrew Goldstone's comments, directly from https://github.com/agoldst/dfr-analysis
  
  
  # Andrew Goldstone's method: get the user to choose the file
  
  message("Select the topic keys file")
  ignore <- readline("(press return to open file dialog - it might pop up behind here) ")
  outputtopickeys <- file.choose()
  print(outputtopickeys)
  
  message("Select the topic docs file")
  ignore <- readline("(press return to open file dialog - it might pop up behind here) ")
  outputdoctopics <- file.choose()
  print(outputdoctopics)
  
  outputtopickeysresult <- read.table(outputtopickeys, header=F, sep="\t", col.names=c("topic","alpha","keywords"))
  outputdoctopicsresult <- read.table(outputdoctopics, header=F, sep="\t")
  
  ## Andrew Goldstone's function to make a matrix where
  ## cols = topics
  ## rows = docs
  sort.topics <- function(df) {
    # width of data frame: 2n + 2
    w <- dim(df)[2]
    n.topics <- (w - 2) / 2
    # number of docs
    n.docs <- dim(df)[1]
    
    # construct matrix of indices by extracting topic numbers from each row
    topic.nums <- df[,seq(from=3,to=w-1,by=2)]
    # thus topic.nums[i,j] is the jth most frequent topic in doc i
    # and df[i,2(j + 2)] is the proportion of topic topic.nums[i,j] in doc i
    # with topics numbered from 0 
    # since this is just permuting the even-numbered rows of
    # t.m <- as.matrix(df[,3:w])
    # it must be expressible as some outer product or something
    # but screw it, time for a for loop
    
    result <- matrix(0,nrow=n.docs,ncol=n.topics)
    for(i in 1:n.docs) {
      for(j in 1:n.topics) {
        result[i,topic.nums[i,j]+1] <- df[i,2 * j + 2] 
      }
    }
    result
  }
  
  
  ## Andrew Goldstone's function: get topic and metadata together
  # create a dataframe with row n, column m giving proportion of topic m in doc m
  # add rows named by doc id
  # Pass in a function for converting filenames stored
  # in mallet's output to id's. The default is the as.id function from metadata.
  # R, but you can pass a different one
  
  read.doc.topics <- function() {
    
    df <- read.table(outputdoctopics,header=FALSE,skip=1,stringsAsFactors=FALSE)
    
    ids <- gsub("\\.txt", "", basename(df$V2))
    
    topics.frame <- as.data.frame(sort.topics(df))
    names(topics.frame) <- paste("topic",sep="",1:length(topics.frame))
    cbind(topics.frame,id=ids,stringsAsFactors=FALSE)
    
    # add the ids again, but on the right 
    cbind(topics.frame,id=ids,stringsAsFactors=FALSE)
    
  }
  
  ## make it so, using the function above
  doc.topics <- read.doc.topics()
  
  ## Andrew Goldstone's function
  read.keys <- function() {
    
    keys.filename <- outputtopickeys
    
    df <- read.csv(keys.filename,sep="\t",header=FALSE,as.is=TRUE,
                   col.names=c("topic","alpha","keywords"))
    df$topic <- df$topic + 1
    df
  }
  ## make it so, using above function
  keys.frame <- read.keys()
  
  ## Andrew Goldstone's function (I have un-functioned it)
  # top-level input function: make a combined 
  # dataframe of topic proportions and document metadata
  # replace pubdate string with numeric year
  # NB id formats must match in the two frames, since the merge is by id
  
  ## first, get meta.frame
  meta.frame <- x$bibliodata ## read in citations.CSV
  meta.frame$id <- meta.frame$x 
  meta.frame$pubdate <- as.numeric(substr(meta.frame$issue, 1,4))
  
  # merge and
  # clumsily reorder to ensure that subsetting result to nth column
  # will give topic n
  merged <- merge(doc.topics,meta.frame,by="id")
  ids <- merged$id
  topic.model.df <- cbind(subset(merged,select=-id),id=ids)  
  
  ## make a compact fragment of title without punctuation
  topic.model.df$titlefrag <- unlist(lapply(1:nrow(topic.model.df), function(i) paste(unlist(strsplit(as.character(gsub('[[:punct:]]','', topic.model.df$doi)[i]), " "))[1:6], collapse = ".")))
  
  
  ## Andrew Goldstone's function (slightly modified)
  # return some descriptive information about the topic
  # n: topic number, from 1
  # df: frame returned by topic.model.df
  # keys.frame: frame returned by read.keys
  # threshold: proportion of topic required for a document to be considered
  #   exemplary of that topic
  # result: a list
  #   $top.words: key words in descending order
  #   $alpha: alpha_n for the topic
  #   $top.articles: exemplary articles, in descending order
    keys.frame <- outputtopickeysresult
    result <- list()
    result$top.words <- as.character(keys.frame$keywords[n])
    result$alpha <- keys.frame$alpha[n]
    docs <- topic.model.df[topic.model.df[paste0("topic",n)] > threshold,]
    docs <- docs[c("id","titlefrag","pubdate",paste0("topic",n))]
    result$top.articles <- docs[order(docs[paste0("topic",n)],decreasing=TRUE),]
    result
}

