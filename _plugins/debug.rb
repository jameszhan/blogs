#encoding UTF-8
# A simple way to inspect liquid template variables.
# Usage:
#  Can be used anywhere liquid syntax is parsed (templates, includes, posts/pages)
#  {{ site | debug }}
#  {{ site.posts | debug }}
#
require 'pp'
module Jekyll
  # Need to overwrite the inspect method here because the original
  # uses < > to encapsulate the psuedo post/page objects in which case
  # the output is taken for HTML tags and hidden from view.
  #
  class Post
    def inspect
      "#Jekyll:Post @id=#{self.id.inspect}"
    end
  end

  class Page
    def inspect
      "#Jekyll:Page @name=#{self.name.inspect}"
    end
  end

end

module Jekyll
  module DebugFilter
    
    def debug(obj, stdout=false)
      puts obj.pretty_inspect if stdout
      "<pre>#{obj.class}\n#{obj.pretty_inspect}</pre>"
    end

  end
end

Liquid::Template.register_filter(Jekyll::DebugFilter)

[:after_init, :after_reset, :post_read, :pre_render, :post_render, :post_write].each do|event|
  Jekyll::Hooks.register :site, event do |site|
    puts ">>(#{__FILE__}) site fire #{event}"

    if event == :post_write
      site.collections['sitemap'].docs.each do|s|
        if s.data['title']
          puts s.data['title']
        end
      end
    end
  end
end

[:pages, :posts, :documents].each do |container|
  [:post_init, :pre_render, :post_render, :post_write].each do|event|
    Jekyll::Hooks.register container, event do |target|
      title = if target.respond_to?(:path)
        target.path
      else
        target.class
      end
      puts ">>(#{__FILE__}) #{container}[#{title}] fire #{event}"
    end
  end
end

puts ">>>(#{__FILE__}) Loaded!"
