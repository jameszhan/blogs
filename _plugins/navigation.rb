module Jekyll
  class NavPage < Page

    def initialize(site, base, dir, name, type)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      process(name)
      read_yaml(base, "#{type}#{output_ext}")
      data.default_proc = proc do |_, key|
        site.frontmatter_defaults.find(File.join(dir, name), type, key)
      end
    end

    # if you want to expose more keys to liquid, you can override the render method.
    def output_ext
      '.html'
    end

  end

  class NavGenerator < Generator
    safe true

    def generate(site)
      dir = site.config['category_dir'] || 'categories'
      site.categories.keys.each do |category|
        write_page(site, dir, category, '_category', 'navigation')
      end

      dir = site.config['tag_dir'] || 'tags'
      site.tags.keys.each do |tag|
        write_page(site, dir, tag, '_tag', 'navigation')
      end
    end

    def write_page(site, dir, name, type, subdir)
      page = NavPage.new(site, File.join(site.source, subdir), dir, name, type)
      page.render(site.layouts, site.site_payload)
      page.write(site.dest)
      site.pages << page
    end
  end
end