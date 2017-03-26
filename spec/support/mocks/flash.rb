# spec/support/mocks/flash.rb

module Spec
  class Flash
    def initialize
      @data = {}
    end # method initialize

    def [] key
      @data[key]
    end # method []

    def []= key, value
      @data[key] = value
    end # method []=

    def empty?
      @data.empty? && (!@now || @now.empty?)
    end # method empty?

    def now
      @now ||= self.class.new
    end # method now
  end # class
end # module
