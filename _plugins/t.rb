require 'active_support/core_ext/string'

module Jekyll
  module TFilter

    attr_reader :context, :vocabulary

    def t(obj)
      "HELLO#{vocabulary[obj] || obj.classify}"
    end

    def vocabulary
      @vocabulary ||= (context.environments.first['site']['data']['vocabulary'] || {})
    end

  end
end

Liquid::Template.register_filter(Jekyll::TFilter)