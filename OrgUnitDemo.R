# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# ORIGINAL CODE: dhis api access
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# https://www.dhis2.org/doc/snapshot/en/developer/html/apas07.html
# https://github.com/jason-p-pickering/datim-validation
# http://www.r-fiddle.org/#/fiddle?id=wHglXleC&version=1
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# modified and adapted by Chris van hasselt
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


# setup =======================================================================
  require(RCurl)
  require(XML)
  require(httr)
  require(rjson)
  require(plyr)
  pass <- "access-here"
  username <- "username-here"
  password <- "passwor-here"
  
  source("accountinfo.R")
  url1 <- "https://dhis2-hqtest.fhi360.org/api/"
  url3 <- ".xml?paging=false&links=false&fields=id,displayName,code,ancestors"
  

# specify targets =============================================================

  targets <- c("organisationUnits")
  
# get metadata ================================================================

    url2 <- targets[1]
    url <- paste0(url1, url2, url3)

    response <- getURL(url,
                       userpwd=pass,
                       httpauth=1L, 
                       header=FALSE,
                       ssl.verifypeer=FALSE)
    
  # parse the result
    bri <- xmlParse(response)
    
  # get the root
    r <- xmlRoot(bri)
    
  # parse out names and IDs
    rows <- xmlApply(r[[targets[1]]], function(xNode) {
      print(xmlValue(xNode,"ancestors"))
              c("name" = xmlValue(xNode,"displayName"),
                "id"=xmlGetAttr(xNode, "id"),
                "code"=xmlGetAttr(xNode,"code"))
            })
    df <- as.data.frame(do.call(rbind,rows),row.names=1)
    ancestors <- xmlLApply(r[[targets[1]]], xmlValue, "ancestors")
  # bind
    temp <- cbind("name"=name,"id" = id, ancestors)
  # recast as a data frame
    df <- as.data.frame(temp,
                        stringsAsFactors=FALSE,
                        row.names=1:nrow(temp))
    assign(targets[1], df)
    
   # remove(df)



