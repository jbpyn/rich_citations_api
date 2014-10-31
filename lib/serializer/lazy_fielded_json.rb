module Serializer
  class LazyFieldedJson
    def initialize(fields)
      @h = HashWithIndifferentAccess.new
      @fields = fields
    end

    def add(field)
      @h[field] = yield if @fields.member? field
    end

    def build
      @h.compact
    end
  end
end
