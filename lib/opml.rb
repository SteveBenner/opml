require 'rexml/document'
require 'active_support/core_ext/string'

module Opml
  class Opml
    class Outline
      attr_accessor :attributes, :outlines

      def initialize(element)
        @attributes = map_attributes_to_hash(element.attributes)
        @outlines   = element.elements.collect { |e| Outline.new(e) }
      end

      def flatten
        @flatten ||= @outlines.map(&:flatten).unshift(self)
      end

      def to_s
        @to_s ||= attributes['text'] || super
      end

      # todo: TEST THIS!!!
      def to_hash
				attr = self.attributes.clone
        h = { self.attributes['text'] => attr.delete('text') }
        unless self.outlines.empty?
          self.outlines.map {|o| h.update o.to_hash }
        end
				h
      end

      def respond_to?(method)
        return true if attributes[method.to_s]
        super
      end

      def method_missing(method, *args)
        attributes[method.to_s] || super
      end

      private

      def map_attributes_to_hash(attributes)
        h = Hash.new
        attributes.each { |key, value|
          h[key.underscore] = value
        }
        h
      end
    end

    attr_reader :outlines

    def initialize(xml)
      @doc = REXML::Document.new(xml)

      parse_head_elements :title, :owner_name, :owner_email
      parse_head_elements :date_created, :date_modified, :with => Proc.new { |e| Time.parse(e) }

      @outlines = document_body ? initialize_outlines_from_document_body : []
    end

    def flatten
      @flatten ||= @outlines.map(&:flatten).flatten
    end

    private

    def parse_head_elements(*elements)
      options = elements.last.is_a?(Hash) ? elements.pop : {}
      elements.each do |attribute|
        define_head_attr_reader(attribute)
        set_head_value(attribute, options)
      end
    end

    def define_head_attr_reader(attribute)
      self.class.send(:attr_reader, attribute)
    end

    def get_head_value(attribute)
      if element = @doc.elements["opml/head/#{attribute.to_s.camelize(:lower)}"]
        element.text
      end
    end

    def parse_value(value, options)
      options[:with] ? options[:with].call(value) : value
    end

    def set_head_value(attribute, options)
      if value = get_head_value(attribute)
        instance_variable_set("@#{attribute}", parse_value(value, options))
      end
    end

    def document_body
      @document_body ||= @doc.elements['opml/body']
    end

    def initialize_outlines_from_document_body
      document_body.elements.map { |element| Outline.new(element) }
    end
  end
end
