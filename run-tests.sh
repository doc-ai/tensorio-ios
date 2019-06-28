#/bin/sh

set -Eeuo pipefail

xcodebuild clean build test -enableCodeCoverage YES -workspace Example/TensorIO.xcworkspace -scheme TensorIO-Example -destination 'platform=iOS Simulator,name=iPhone X,OS=12.2' | xcpretty
xcodebuild clean build test -enableCodeCoverage YES -workspace TensorFlowExample/TensorFlowExample.xcworkspace -scheme TensorFlowExample -destination 'platform=iOS Simulator,name=iPhone X,OS=12.2' | xcpretty
xcodebuild clean build test -enableCodeCoverage YES -workspace SwiftExample/SwiftExample.xcworkspace -scheme SwiftExample -destination 'platform=iOS Simulator,name=iPhone X,OS=12.2' | xcpretty
xcodebuild clean build test -enableCodeCoverage YES -workspace DeployExample/DeployExample.xcworkspace -scheme DeployExample -destination 'platform=iOS Simulator,name=iPhone X,OS=12.2' | xcpretty
xcodebuild clean build test -enableCodeCoverage YES -workspace FederatedExample/FederatedExample.xcworkspace -scheme FederatedExample -destination 'platform=iOS Simulator,name=iPhone X,OS=12.2' | xcpretty

# pod lib lint --skip-import-validation --allow-warnings
