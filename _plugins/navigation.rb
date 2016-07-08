module Jekyll
  class NamedDocument < Document

    attr_reader :name, :group

    def initialize(path, relations)
      super(path, relations)
      @group = relations[:group]
      @name = relations[:name]
    end

    def url_placeholders
      @url_placeholders ||= { group: group, name: name, output_ext: Jekyll::Renderer.new(site, self).output_ext }
    end
  end

  class NavGenerator < Generator
    safe true

    def generate(site)
      site.categories.keys.each do |category|
        write_page(site, category, 'categories', 'sitemap', '_category.html')
      end

      site.tags.keys.each do |tag|
        write_page(site, tag, 'tags', 'sitemap', '_tag.html')
      end
    end

    def write_page(site, name, group, collection_name, source_file)
      col = site.collections[collection_name]
      doc = NamedDocument.new(File.join(site.source, "_#{collection_name}", source_file), { site: site, collection: col, name: name, group: group })
      doc.read
      col.docs << doc
    end

  end
end