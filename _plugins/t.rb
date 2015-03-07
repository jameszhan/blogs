require 'active_support/core_ext/string'

module Jekyll
  module TFilter

    attr_reader :context, :vocabulary

    def t(obj)
      vocabulary[obj] || obj.camelcase
    end

    def vocabulary
      @vocabulary ||= (context.environments.first['site']['data']['vocabulary'] || {})
    end

  end
end

Liquid::Template.register_filter(Jekyll::TFilter)