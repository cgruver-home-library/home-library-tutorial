#!/bin/bash

for i in bookshelf catalog librarian library
do
  cd ${LAB_MONKEYS}/${i}
  git add .
  git commit -m wip
  git push
done
