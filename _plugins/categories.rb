module Jekyll
  class CategoryPage < Page
    def initialize(site, base, dir, category, posts_number, posts_per_page, pagination_skip)
      @site = site
      @base = base
      @dir = dir
      @name = "news_#{pagination_skip}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'news.html')
      self.data['category'] = category
      self.data['posts_per_page'] = posts_per_page
      self.data['pagination_skip'] = pagination_skip
      if pagination_skip != 0
        self.data['prev_pagination_skip'] = pagination_skip - posts_per_page
      end
      if pagination_skip + posts_per_page < posts_number
        self.data['next_pagination_skip'] = pagination_skip + posts_per_page
      end
    end
  end

  class CategoryGenerator < Generator
    safe true

    def generate(site)
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

    def write_news_page(site, dir, category, posts_number, posts_per_page, pagination_skip)
      index = NewsPage.new(site, site.source, dir, category, posts_number, posts_per_page, pagination_skip)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end
  end
end