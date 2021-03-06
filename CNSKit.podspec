Pod::Spec.new do |s|
  s.name     = 'CNSKit'
  s.version  = '1.0.11'
  s.license = 'Own'
  s.summary  = 'CNSKit is a collection of utility-classes that make the life easier.'
  s.homepage = 'https://github.com/codenauts/CNSKit'
  s.authors   = { 'Thomas Dohmke' => 'thomas.dohmke@codenauts.de' , 'Stefan Haubold' => 'stefan.haubold@codenauts.de', 'Benjamin Reimold' => 'benjamin.reimold@codenauts.de'}
  s.platform     = :ios
  s.ios.frameworks     =  'Security'
  s.source   = { :git => 'https://github.com/codenauts/CNSKit.git', :tag => s.version.to_s}
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.resources = 'Resources/*'
  s.requires_arc = false 
end
