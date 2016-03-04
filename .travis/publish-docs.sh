#!/bin/bash

doc_dir="./docs"
src_branch="develop"

if [ "$TRAVIS_PULL_REQUEST" == "false" ] \
    && [ "$TRAVIS_BRANCH" == $src_branch ]; then

  if [ ! -d "$doc_dir" ]; then
    echo "Documentation directory is not available. Publish to GitHub Pages skipped."
    exit 0
  fi

  cd "$doc_dir/html"
  git init
  git config user.email "travis-ci@post-quantum.com"
  git config user.name "Travis CI"
  git add .
  git commit -m "Published documentation from Travis CI build $TRAVIS_BUILD_NUMBER"
  git push --force --quiet \
      "https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}" \
      master:gh-pages >/dev/null 2>&1
fi
