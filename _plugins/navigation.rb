module Jekyll
  class NamedDocument < Document

    attr_reader :name, :group

    def initialize(path, relations)
      @name = relations[:name]
      @group = relations[:group]
      @site = relations[:site]
      @path = path
      @collection = relations[:collection]
      @has_yaml_header = nil
    end

    def to_liquid
      if data.is_a?(Hash)
        Utils.deep_merge_hashes data, {
            'output'        => output,
            'content'       => content,
            'path'          => path,
            'relative_path' => relative_path,
            'url'           => url,
            'collection'    => collection.label,
            'name'          => name
        }
      else
        data
      end
    end

    def url_placeholders
      {
          collection: collection.label,
          path:       cleaned_relative_path,
          output_ext: Jekyll::Renderer.new(site, self).output_ext,
          name: name,
          group: group
      }
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
      col = site.collections['sitemap']
      doc = NamedDocument.new(File.join(site.source, "_#{collection_name}", source_file), { site: site, collection: col, name: name, group: group })
      doc.read
      site.collections['sitemap'].docs << doc
    end

  end
end