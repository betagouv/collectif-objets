die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 2 ] || die "2 arguments required, $# provided"
[[ $1 = "www" || $1 = "admin" ]] || die "first argument should be www or admin"
[[ $2 = "staging" || $2 = "prod" || $2 = "admin-prod" || $2 = "admin-staging" ]] || die "second argument should be scalingo app suffix"
[[ $1 != "admin" || ($2 = "admin-prod" || $2 = "admin-staging") ]] || die "admin should be deployed to admin app"

WWW_OR_ADMIN=$1
SCALINGO_APP=$2
BRANCH=`git rev-parse --abbrev-ref HEAD`
ROOT_PATH=$PWD
SLUG_DIR=$PWD/tmp/slug
SLUG_PATH=$SLUG_DIR/archive.tar
SLUG_PATH_GZ=$SLUG_DIR/archive.tar.gz
echo "building git archive $SLUG_PATH ..."
rm -rf -- $SLUG_DIR
mkdir -p $SLUG_DIR
rm -f -- $SLUG_PATH
git archive --output=$SLUG_PATH $BRANCH ./$WWW_OR_ADMIN
echo "adding shared directory to archive $SLUG_PATH ..."
cd $SLUG_DIR
tar -xvf archive.tar
rm archive.tar
rm $WWW_OR_ADMIN/shared
cp -r $ROOT_PATH/shared ./$WWW_OR_ADMIN/
rm -f -- ./$WWW_OR_ADMIN/shared/.DS_Store
rm -rf -- ./$WWW_OR_ADMIN/shared/**/.DS_Store
tar -cvf archive.tar $WWW_OR_ADMIN
rm -rf $WWW_OR_ADMIN
gzip archive.tar
cd $ROOT_PATH
echo "deploying archive $SLUG_PATH_GZ"
# scalingo --app collectif-objets-${SCALINGO_APP} deploy $SLUG_PATH_GZ
