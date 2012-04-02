module LinkedIn

  module Search
    # limitation found with search method - multiple facet params are required but hash only allows for unqique keys
    def search(options={}, type='people')
      path = "/#{type.to_s}-search"

      if options.is_a?(Hash)
        fields = options.delete(:fields)
        path += field_selector(fields) if fields
      end

      options = { :keywords => options } if options.is_a?(String)
      options = format_options_for_query(options)

      puts to_uri(path, options) + '&facet=network%2CF'

      # forces serach to use facet for 1st degree connetions
      result_json = get(to_uri(path, options) + '&facet=network%2CF')

      Mash.from_json(result_json)
    end

    private

      def format_options_for_query(opts)
        opts.inject({}) do |list, kv|
          key, value = kv.first.to_s.gsub("_","-"), kv.last
          list[key]  = sanitize_value(value)
          list
        end
      end

      def sanitize_value(value)
        value = value.join("+") if value.is_a?(Array)
        value = value.gsub(" ", "+") if value.is_a?(String)
        value
      end

      def field_selector(fields)
        result = ":("
        fields = fields.to_a.map do |field|
          if field.is_a?(Hash)
            innerFields = []
            field.each do |key, value|
              innerFields << key.to_s.gsub("_","-") + field_selector(value)
            end
            innerFields.join(',')
          else
            field.to_s.gsub("_","-")
          end
        end
        result += fields.join(',')
        result += ")"
        result
      end
  end

end

