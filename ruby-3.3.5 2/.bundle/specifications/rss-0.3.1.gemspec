# -*- encoding: utf-8 -*-
# stub: rss 0.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rss".freeze
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Kouhei Sutou".freeze]
  s.date = "2024-08-02"
  s.description = "Family of libraries that support various formats of XML \"feeds\".".freeze
  s.email = ["kou@cozmixng.org".freeze]
  s.files = ["LICENSE.txt".freeze, "NEWS.md".freeze, "README.md".freeze, "lib/rss.rb".freeze, "lib/rss/0.9.rb".freeze, "lib/rss/1.0.rb".freeze, "lib/rss/2.0.rb".freeze, "lib/rss/atom.rb".freeze, "lib/rss/content.rb".freeze, "lib/rss/content/1.0.rb".freeze, "lib/rss/content/2.0.rb".freeze, "lib/rss/converter.rb".freeze, "lib/rss/dublincore.rb".freeze, "lib/rss/dublincore/1.0.rb".freeze, "lib/rss/dublincore/2.0.rb".freeze, "lib/rss/dublincore/atom.rb".freeze, "lib/rss/image.rb".freeze, "lib/rss/itunes.rb".freeze, "lib/rss/maker.rb".freeze, "lib/rss/maker/0.9.rb".freeze, "lib/rss/maker/1.0.rb".freeze, "lib/rss/maker/2.0.rb".freeze, "lib/rss/maker/atom.rb".freeze, "lib/rss/maker/base.rb".freeze, "lib/rss/maker/content.rb".freeze, "lib/rss/maker/dublincore.rb".freeze, "lib/rss/maker/entry.rb".freeze, "lib/rss/maker/feed.rb".freeze, "lib/rss/maker/image.rb".freeze, "lib/rss/maker/itunes.rb".freeze, "lib/rss/maker/slash.rb".freeze, "lib/rss/maker/syndication.rb".freeze, "lib/rss/maker/taxonomy.rb".freeze, "lib/rss/maker/trackback.rb".freeze, "lib/rss/parser.rb".freeze, "lib/rss/rexmlparser.rb".freeze, "lib/rss/rss.rb".freeze, "lib/rss/slash.rb".freeze, "lib/rss/syndication.rb".freeze, "lib/rss/taxonomy.rb".freeze, "lib/rss/trackback.rb".freeze, "lib/rss/utils.rb".freeze, "lib/rss/version.rb".freeze, "lib/rss/xml-stylesheet.rb".freeze, "lib/rss/xml.rb".freeze, "lib/rss/xmlparser.rb".freeze, "lib/rss/xmlscanner.rb".freeze]
  s.homepage = "https://github.com/ruby/rss".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "Family of libraries that support various formats of XML \"feeds\".".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rexml>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rexml>.freeze, [">= 0"])
  end
end
