module Jekyll
  class DynamicPage < Page

    def initialize(site, base, dir, name)
      super
    end

  end

  class DynamicUrlGenerator < Generator
    safe true

    def generate(site)
      puts "#" * 100
      p site.layouts.map{|k, n| k }
      puts "*" * 100
      if site.layouts.key? 'news'
        dir = site.config['category_dir'] || 'categories'
        site.categories.keys.each do |category|
          posts_number = site.categories[category].length
          pagination_skip = 0;
          posts_per_page = 5;
          begin
            write_news_page(site, File.join(dir, category), category, posts_number, posts_per_page, pagination_skip)
            pagination_skip += posts_per_page;
          end while pagination_skip < posts_number
        end
      end
    end

    def write(site, base, dir, name)
      page = DynamicPage.new(site, base, dir, name)
      page.render(site.layouts, site.site_payload)
      page.write(site.dest)
      site.pages << page
    end
  end
end