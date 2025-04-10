# -*- encoding: utf-8 -*-
# stub: cocoapods-plugins-install 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "cocoapods-plugins-install".freeze
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eloy Dur\u{e1}n".freeze]
  s.date = "2018-05-09"
  s.email = ["eloy.de.enige@gmail.com".freeze]
  s.homepage = "https://github.com/CocoaPods/CocoaPods.app/blob/master/cocoapods-plugins-install".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.8".freeze
  s.summary = "Adds installation powers to cocoapods-plugins, specifically for CocoaPods.app".freeze

  s.installed_by_version = "2.6.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cocoapods-plugins>.freeze, [">= 0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.4"])
    else
      s.add_dependency(%q<cocoapods-plugins>.freeze, [">= 0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
    end
  else
    s.add_dependency(%q<cocoapods-plugins>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.10"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
  end
end
