Pod::Spec.new do |s|
    s.name             = "mParticle-BranchMetrics"
    s.version          = "7.8.4"
    s.summary          = "BranchMetrics integration for mParticle"

    s.description      = <<-DESC
                       This is the BranchMetrics integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-branchmetrics.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-BranchMetrics/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.8.0'
    s.ios.dependency 'Branch', '~> 0.25'
end
