# frozen_string_literal: true

# essentially, this is for converting a string with a potentially
# broken or unknown encoding into a valid UTF-8 string
module TidyBytes
  def tidy_bytes
    # return if the string is already valid UTF-8
    return self if self.valid_encoding? && self.encoding == Encoding::UTF_8

    # create a mutable copy so we don't modify the original string
    str = self.dup

    # attempt to encode to UTF-8
    begin
      return str.encode(Encoding::UTF-8)
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError
    end

    # if it failed, force the encoding to ISO-8859-1, transcode the
    # string to UTF-8, and use replacement options for any characters
    # that might still be problematic
    str.force_encoding(Encoding::ISO_8859_1).encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '�')
  end

  def tidy_bytes!
    replace(self.tidy_bytes)
  end

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def tidy_bytes
      TidyBytes.instance_method(:tidy_bytes).bind(self).call
    end

    def tidy_bytes!
      TidyBytes.instance_method(:tidy_bytes!).bind(self).call
    end
  end
end

class String
  include TidyBytes
end
