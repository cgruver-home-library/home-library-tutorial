#!/bin/bash

CATALOG_ROUTE=$(oc get route catalog -n home-library --template='{{ .spec.host }}')
BOOKSHELF_ROUTE=$(oc get route bookshelf -n home-library --template='{{ .spec.host }}')
LIBRARIAN_ROUTE=$(oc get route librarian -n home-library --template='{{ .spec.host }}')

for i in $(cat isbn.list)
do
    BOOK_INFO=$(curl http://${CATALOG_ROUTE}/bookCatalog/getBookInfo/${i})
    CATALOG_ID=$(echo ${BOOK_INFO} | jq .catalogId)
    curl -X DELETE -H "Content-Type: application/json" -d ${BOOK_INFO} http://${CATALOG_ROUTE}/bookCatalog/deleteBookInfo/${CATALOG_ID}
    
done