BRANCH=`git rev-parse --abbrev-ref HEAD`
SLUG_PATH=$PWD/tmp/slug.tar
echo "building slug $SLUG_PATH ..."
rm -f -- $SLUG_PATH
git archive --output=$SLUG_PATH $BRANCH ./www
