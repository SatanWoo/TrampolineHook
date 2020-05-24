Pod::Spec.new do |s|
s.name         = "TrampolineHook"
s.version      = "0.0.5"
s.summary      = "A solution for centralized method redirection"
s.description  = <<-DESC
Intercept any method implementation with a single method.
DESC
s.homepage     = "https://github.com/SatanWoo/TrampolineHook"

s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { "SatanWoo" => "" }
s.source       = { :git => "https://github.com/SatanWoo/TrampolineHook.git", :tag => s.version.to_s }

s.source_files = "TrampolineHook/*.{h,m}", 
				 "TrampolineHook/PageAllocator/*.{h,m}",
				 "TrampolineHook/arm64/*.{h,m}", 
				 "TrampolineHook/arm64/THPage_arm64.s",
				 "TrampolineHook/arm64/THPageVar_arm64.s"

s.public_header_files = "Trampoline/THInterceptor.h"
s.static_framework = true

s.ios.deployment_target = "9.0"
s.requires_arc = true

end

