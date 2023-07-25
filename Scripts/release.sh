VERSION="$1"
PREFIXED_VERSION="v$1"
NOTES="$2"

# Update version number
#

# Update Carthage release json file
jq --indent 3 '. += {'"\"$VERSION\""': "'"https://github.com/mparticle-integrations/mparticle-apple-integration-branchmetrics/releases/download/$PREFIXED_VERSION/mParticle_BranchMetrics.framework.zip?alt=https://github.com/mparticle-integrations/mparticle-apple-integration-branchmetrics/releases/download/$PREFIXED_VERSION/mParticle_BranchMetrics.xcframework.zip"'"}'
mParticle_BranchMetrics.json > tmp.json
mv tmp.json mParticle_BranchMetrics.json

# Update CocoaPods podspec file
sed -i '' 's/\(^    s.version[^=]*= \).*/\1"'"$VERSION"'"/' mParticle-BranchMetrics.podspec

# Make the release commit in git
#

git add mParticle-BranchMetrics.podspec
git add mParticle_BranchMetrics.json
git add CHANGELOG.md
git commit -m "chore(release): $VERSION [skip ci]

$NOTES"
