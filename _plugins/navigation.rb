module Jekyll
  class NamedPage < Page

    def initialize(site, base, dir, name, source_file)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      process(name)

      read_yaml(base, source_file)

      data.default_proc = proc do |hash, key|
        site.frontmatter_defaults.find(File.join(dir, name), :pages, key)
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
        write_page(site, dir, category, File.join('_navigation', '_category.html'))
      end

      dir = site.config['tag_dir'] || 'tags'
      site.tags.keys.each do |tag|
        write_page(site, dir, tag, File.join('_navigation', '_tag.html'))
      end
    end

    def write_page(site, dir, name, source_file)
      page = NamedPage.new(site, site.source, dir, name, source_file)
      page.render(site.layouts, site.site_payload)
      page.write(site.dest)
      site.pages << page
    end

  end
end