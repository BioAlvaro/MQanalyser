#' geneList for enrichemnt.
#'
#' @param data_results
#' @param comparison_samples
#' @param organism
#'
#' @return
#' @export
#'
#' @examples
create_geneList <- function(data_results = data_results,
                            comparison_samples = NULL,
                            organism = "org.Hs.eg.db"){

    # First Selected The comparison_samples a

    df <- data_results %>% select(contains(c(comparison_samples, 'name'))) %>%
          select(-contains(c('_p.val','_p.adj')))

    df <- df[df[, paste0(comparison_samples,'_significant')] == TRUE,]

    # Remove the column significant (since all of them are at this step.)
    df[,paste0(comparison_samples,'_significant')] <- NULL

    # make a newcolumn with the entrezid

    ENTREZID <-  clusterProfiler::bitr(geneID = df$name,
                                          fromType = 'SYMBOL',
                                          toType = 'ENTREZID',
                                          OrgDb = organism, drop = T)




    colnames(df)[colnames(df)=='name'] = 'SYMBOL'
    colnames(df)[colnames(df)==paste0(comparison_samples,'_ratio')] = 'ratio'


    # Failed_to_map

    failedToMap <-format(
        (1 - (nrow(ENTREZID)/nrow(df))) * 100,
        digits = 3
    )


    df <- merge(x=df,y=ENTREZID,by="SYMBOL")

    # reorder in descending order

    df <- df[order(df$ratio,decreasing = TRUE),]

    # It'll be good to return also the gene name so I can create a tabular
    # form of the enrichemnt.


    to_return <- list(geneList = df,
                      failedToMap = failedToMap
                      )

    #create a named vector (the geneList)

    # geneList <- df$ratio
    #
    # names(geneList) <- df$ENTREZID
    #
    # return(geneList)

    return(to_return)
}
