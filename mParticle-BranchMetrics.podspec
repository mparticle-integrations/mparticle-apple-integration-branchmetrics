Pod::Spec.new do |s|
    s.name             = "mParticle-BranchMetrics"
    s.version          = "8.5.1"
    s.summary          = "BranchMetrics integration for mParticle"

    s.description      = <<-DESC
                       This is the BranchMetrics integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-branchmetrics.git", :tag => "v" +s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "12.0"
    s.ios.source_files      = 'mParticle-BranchMetrics/*.{h,m,mm}'
    s.ios.resource_bundles  = { 'mParticle-BranchMetrics-Privacy' => ['mParticle-BranchMetrics/PrivacyInfo.xcprivacy'] }
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.19'
    s.ios.dependency 'BranchSDK', '~> 3.4'
end
