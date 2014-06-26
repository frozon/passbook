module Passbook
  module Compressor
    extend self

    def all_compressors
      [:rubyzip]
    end

    def get name
      @compressors = {} unless defined?(@compressors)
      @compressors[name] = spawn(name) unless @compressors.include?(name)
      @compressors[name]
    end

    private

    ##
    # Spawn a Lookup of the given name.
    #
    def spawn name
      Passbook::Compressor.const_get(classify_name(name)).new
    end

    ##
    # Convert an "underscore" version of a name into a "class" version.
    #
    def classify_name filename
      filename.to_s.split("_").map{ |i| i[0...1].upcase + i[1..-1] }.join
    end
  end
end

Passbook::Compressor.all_compressors.each do |name|
  require "passbook/compressors/#{name}"
end