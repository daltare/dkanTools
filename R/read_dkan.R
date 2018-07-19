#' DKAN Datastore API Function
#'
#' This function provides an interface with the datastore API of any DKAN-based data portal (such as the California Open Data Portal, at: data.ca.gov), to
#' perform queries and download data programattically and in real-time.
#'
#' @param base_URL The base URL for the data portal (defaults to: \code{https://data.ca.gov})
#' @param resource_id An alphanumeric code representing a particular data resource (e.g., \code{a731c980-9477-4ec7-bcfc-6d0cce00306c}). It can be found on
#' the \code{Data API} page for the resource (e.g., \code{https://data.ca.gov/node/1801/api}).
#' @param filter_fields A list of the fields that will be used as a filter. If filtering on multiple fields, enter the field names using the \code{c()}
#' function (e.g., \code{c(field1, field2)}).
#' @param filter_values This argument must be entered as a list, where each element of the list corresponds to a given \code{filter_field}, and each element
#' can have multiple items (e.g., \code{list(c('Element1_Item1', 'Element1_Item2'), c('Element2_Item1','Element2_Item2'))} specifies a 2 element list with 2
#' items in each element, and each element corresponds to the respective field(s) entered to the \code{filter_fields} argument). Note that if a given filter value
#' contains a comma, the filter may not work, and the \code{query} field may need to be used instead.
#' @param fields This specifies the fields (i.e., columns) of the dataset to return. If left blank, all of the dataset's fields will be returned.
#' @param query A fulltext search across all fields (i.e, this returns all records where the query text is found in any field).
#' @param sort_field A field to sort (i.e. order) the records returned by the query, in either ascending or descending order.
#' @param sort_direction The method (i.e., direction) for sorting the given \code{sort_field}, either ascending or descending. Enter \code{asc} (i.e., ascending)
#' or \code{desc} (i.e., descending).
#' @param max_records The maximum number of records to return (if not entered, all records satisfyting the input conditions will be returned).
#'
#' @importFrom dplyr bind_rows as_tibble
#' @importFrom httr GET
#' @importFrom jsonlite fromJSON
#'
#' @return This function returns a data frame with the all records for a given resource on
#' a DKAN portal that match the the given \code{filter_fields}, \code{filter_values}, and/or \code{fields}
#' that are passed as arguments to the function.
#'
#' @keywords DKAN California Open Data Portal
#'
#' @examples
#' # This filters for the PWSID value 'CA3010037' and Stage_Invoked value = 'Stage 1", and returns only 4 fields ('Supplier_Name', 'PWSID', '2013_Production_Reported', and 'Stage_Invoked').
#' # It returns the restuls to a data frame called dkan_data.
#' dkan_data <- read_dkan(resource_id = 'a731c980-9477-4ec7-bcfc-6d0cce00306c', filter_fields = c('PWSID', 'Stage_Invoked'), filter_values = list(c('CA3010037'), c('Stage 1')), fields = c('Supplier_Name', 'PWSID', '2013_Production_Reported', 'Stage_Invoked'))
#'
#' # This returns records from the dataset specificed by resource ID *a731c980-9477-4ec7-bcfc-6d0cce00306c* where the text *American Canyon, City of* is found within any field,
#' # and the records that are returned are sorted on the Reporting_Month field in ascending order.
#' dkan_data <- read_dkan(resource_id = 'a731c980-9477-4ec7-bcfc-6d0cce00306c', query = 'American Canyon, City of', sort_field = 'Reporting_Month', sort_direction = 'asc')
#'
#' # This is an example of accessing a data portal other than the California Open Data Portal (in this case, the Oakland Data Catalog, from OpenOakland)
#' dkan_data <- read_dkan(base_URL = 'http://data.openoakland.org', resource_id = 'aca3da67-a4e2-46a0-8727-1657fcdc0e1d', filter_fields = 'street', filter_values = list(c('HENRY', 'FILBERT', 'MYRTLE')))
#'
#' @export
read_dkan <- function(base_URL = 'https://data.ca.gov', resource_id, filter_fields = NA, filter_values = list(NA), fields = NA, query = NA, sort_field = NA, sort_direction = NA, max_records = NA) {

    # Handle the limit argument
        if(is.na(max_records) | max_records > 100) {limit_temp <- 100} else {limit_temp <- max_records}

    # Construct the initial api call
        api_call <- paste0(base_URL, '/api/action/datastore/search.json?resource_id=', resource_id, '&limit=', limit_temp)

    # Construct the 'filters' part of the query
        if (!is.na(filter_fields[1]) | !is.na(filter_values[[1]][1])) {   # If: one or more of the filters arguments is present
            if (!is.na(filter_fields[1]) & !is.na(filter_values)[[1]][1]) { # If: all of the filters arguments are present
                filter_text <- ''
                for (i in 1:length(filter_values[[1]])) {
                    filter_text <- paste0(filter_text, filter_values[[1]][i], ',') # convert the vector of filter values into a text string separated by commas
                }
                filter_text <- substr(filter_text,1,nchar(filter_text)-1) # remove the last comma
                api_call <- paste0(api_call, '&filters[', filter_fields[1], ']=', filter_text) # Create the first filter call
                # If there is more that one filter field
                if (length(filter_fields) > 1) { # If: there is more than one filter field being used
                    for (j in 2:length(filter_fields)) { # loop through all of the filter fields
                        filter_text <- ''
                        for (k in 1:length(filter_values[[j]])) { # within a filter field, loop through all of the filter values
                            filter_text <- paste0(filter_text, filter_values[[j]][k], ',') # convert the vector of filter values for this filter field into a text string
                        }
                        filter_text <- substr(filter_text,1,nchar(filter_text)-1) # remove the last comma
                        api_call <- paste0(api_call, '&filters[', filter_fields[j], ']=', filter_text) # append with the filter filter field and associated filter values
                    }
                }
            }
            else {
                stop('ERROR - ONE OF THE FILTERS ARGUMENTS IS MISSING')
            }
        }

    # Construct the 'fields' part of the query
        if (!is.na(fields[1])) {
            fields_text <- ''
            for (i in 1:length(fields)) {
                fields_text <- paste0(fields_text, fields[i], ',') # convert the vector of field values into a text string separated by commas
            }
            fields_text <- substr(fields_text,1,nchar(fields_text)-1) # remove the last comma
            api_call <- paste0(api_call, '&fields[t]=', fields_text)
        }

    # Construct the 'query' (i.e., search) part of the query
        if (!is.na(query[1])) {
            query_text <- ''
            for (i in 1:length(query)) {
                query_text <- paste0(query_text, '"', query[i], '"', ',') # convert the vector of field values into a text string separated by commas
            }
            query_text <- substr(query_text,1,nchar(query_text)-1) # remove the last comma
            api_call <- paste0(api_call, '&query=', query_text)
        }


    # Construct the 'sort' part of the query
        if (!is.na(sort_field[1])) {
            api_call <- paste0(api_call, '&sort[', sort_field, ']=', sort_direction)
        }

    # Replace Spaces in the API call with '%20'
        api_call <- gsub(' ', '%20', api_call)

    # get the first records (the smaller of the max_records entered or 100), and find the total number of records available
        raw.result <- httr::GET(api_call)
        raw.content <- rawToChar(raw.result$content)
        formatted.content <- jsonlite::fromJSON(raw.content)
        data.content <- formatted.content[[3]]
        dataset <- dplyr::as_tibble(data.content$records)
        total.records <- as.numeric(data.content$total)
        limit.returned <- as.numeric(data.content$limit)

    # loop through the remaining records, download them, and append them to the 'dataset' variable
        # if no max_records is entered, download all records
            if (is.na(max_records)) {
                for (i in 1:(total.records/limit.returned)) {
                    api_call_new <- paste0(api_call, '&offset=', i * limit.returned)
                    raw.result <- httr::GET(api_call_new)
                    raw.content <- rawToChar(raw.result$content)
                    formatted.content <- jsonlite::fromJSON(raw.content)
                    data.content <- formatted.content[[3]]
                    dataset.new <- dplyr::as_tibble(data.content$records)
                    dataset <- dplyr::bind_rows(dataset, dataset.new)
                }
            } else if (max_records > 100) {
                for (i in 1:(min(max_records, total.records)/limit.returned)) {
                    if (i <= min(max_records, total.records)/limit.returned - 1) {
                        api_call_new <- paste0(api_call, '&offset=', i * limit.returned)
                        raw.result <- httr::GET(api_call_new)
                        raw.content <- rawToChar(raw.result$content)
                        formatted.content <- jsonlite::fromJSON(raw.content)
                        data.content <- formatted.content[[3]]
                        dataset.new <- dplyr::as_tibble(data.content$records)
                        dataset <- dplyr::bind_rows(dataset, dataset.new)
                    } else {
                        api_call_new <- paste0(api_call, '&offset=', i * limit.returned)
                        raw.result <- httr::GET(api_call_new)
                        raw.content <- rawToChar(raw.result$content)
                        formatted.content <- jsonlite::fromJSON(raw.content)
                        data.content <- formatted.content[[3]]
                        dataset.new <- dplyr::as_tibble(data.content$records)
                        remaining.records <- min(max_records, total.records) %% limit.returned
                        if (remaining.records > 0) {
                            dataset.new <- dataset.new[1:remaining.records, ]
                            dataset <- dplyr::bind_rows(dataset, dataset.new)
                        }
                    }
                }
            }

    # return the full dataset to whatever variable the function is passed to
        return(dataset)
}

