Pod::Spec.new do |s|
    s.name             = "mParticle-BranchMetrics"
    s.version          = "8.1.1"
    s.summary          = "BranchMetrics integration for mParticle"

    s.description      = <<-DESC
                       This is the BranchMetrics integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-branchmetrics.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "11.0"
    s.ios.source_files      = 'mParticle-BranchMetrics/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.9'
    s.ios.dependency 'BranchSDK', '~> 2.1.2'
end
