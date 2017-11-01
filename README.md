## Overview
This package defines an R function called `read_dkan()` which provides an interface for datastore API of any DKAN-based data portal, such as California's Open Data Portal at [data.ca.gov](https://data.ca.gov/). The `read_dkan()` function retrieves data specified by the query parameters (described below), and returns the data formatted in an R data frame (which can be used for analysis within R, or written to an external file, such as a .csv file).

## Instructions
This section describes how to install the package, and how to use it to construct a query of a DKAN-based data portal via the datastore API.

### Installation
To install the package, run the following lines of code:
``` 
install.packages('devtools')
devtools::install_github('daltare/dkanTools')
library(dkanTools)
```

Alternatively, you can save the *read_dkan.R* file (in the *R* folder) to your computer, then run the following code (NOTE: this assumes the file is saved in your home directory; to save the file in a different location, replace ~ with the path to the location where you saved the file):
```
source('~/read_dkan.R')
```

### Function Parameters
The arguments to the function correspond to certain parameters of the DKAN datastore API. A description of the DKAN datastore API and its parameters is available [here](http://dkan.readthedocs.io/en/latest/apis/datastore-api.html).

The possible arguments to the `read_dkan()` function include:
* `base_URL` (optional): The base URL for the data portal (defaults to: https://data.ca.gov)
* `resource_id` (required): An alphanumeric code representing a particular data resource (e.g., a731c980-9477-4ec7-bcfc-6d0cce00306c). It can be found on the data.ca.gov portal, by clicking on the *Data API* link within a data resource's *Preview* page (here's an [example](https://data.ca.gov/node/1801/api)).
* `filter_fields` (optional): A list of the fields that will be used as a filter. If filtering on multiple fields, enter the field names using the `c()` function (e.g., `c(field1, field2)`)
* `filter_values` (optional):  This argument must be entered as a list, where each element of the list corresponds to a given `filter_field`, and each element can have multiple items (e.g., `list(c('Element1_Item1', 'Element1_Item2'), c('Element2_Item1','Element2_Item2')` specifies a 2 element list with 2 items in each element, and each element corresponds to the respective field(s) entered to the `filter_fields` argument. Note that if a given filter value contains a comma (`,`), the filter may not work, and the `query` field may need to be used instead.
* `fields` (optional): This specifies the fields (i.e., columns) of the dataset to return. If left blank, all of the dataset's fields will be returned.
* `query` (optional): A fulltext search across all fields (i.e, this returns all records where the query text is found in any field).
* `sort_field` (optional): A field to sort (i.e. order) the records returned by the query, in either ascending or descending order.
* `sort_direction` (optional): The method (i.e., direction) for sorting the given `sort_field`, either ascending or descending. Enter 'asc' (i.e., ascending) or 'desc' (i.e., descending).

## Example Function Call
The following examples illustrate how to use the `read_dkan()` to download data from the California Open Data Portal via the datastore API (in each example, the results are stored in an object called `dkan_data`):

```
dkan_data <- read_dkan(resource_id = 'a731c980-9477-4ec7-bcfc-6d0cce00306c', filter_fields = c('PWSID', 'Stage_Invoked'), filter_values = list(c('CA3010037'), c('Stage 1')), fields = c('Supplier_Name', 'PWSID', '2013_Production_Reported', 'Stage_Invoked'))
```

The above example returns records from the dataset specificed by resource ID *a731c980-9477-4ec7-bcfc-6d0cce00306c* where the PWSID value is *CA3010037* AND the Stage_Invoked value is *Stage 1*, then it returns only 4 colums of data ('Supplier_Name', 'PWSID', '2013_Production_Reported', and 'Stage_Invoked').

```
dkan_data <- read_dkan('a731c980-9477-4ec7-bcfc-6d0cce00306c', query = 'American Canyon, City of', sort_field = 'Reporting_Month', sort_direction = 'asc')
```

The above example returns records from the dataset specificed by resource ID *a731c980-9477-4ec7-bcfc-6d0cce00306c* where the text *American Canyon, City of* is found within any field, and the records that are returned are sorted on the Reporting_Month field in ascending order.

The results from these examples would be returned to an R data frame stored in the variable called `dkan_data`. To write this data to a text document called *Output.csv* in your home directory, use the R code below (you can change the location of the file by replacing the `~` with a new path, and you can change the filename by changing *Output.csv* to a different name):

`write.csv(dkan_data, file = '~/Output.csv', row.names = FALSE)`

## Example Application
An example application built with this function to access data via the datastore API is avaiable [here](https://daltare.shinyapps.io/dkan_datastore_api_example/).