#!/bin/sh

git add .
git commit -am 'hugo files update'
git push

cd public
git add .
git commit -am 'update html pages'
git push
