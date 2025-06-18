require 'singleton'
require 'nokogiri'
require 'digest'
require 'uri'

class HTML_Parser
    include Singleton

    def initialize params
        @base_url = params[:base_url]
        @file_path = params[:file_path]
        @allowed_meta_names = ['charset', 'viewport', 'theme-color', 'description']
        
        @doc = Nokogiri::HTML(URI.open(@file_path))
        cleanup_doc
    end

    def validate_params(params)
        raise ArgumentError, "Base URL is required" unless params[:base_url]
        raise ArgumentError, "File path is required" unless params[:file_path]
    end

    def collect_files_from_html
        
    end

    def cleanup_doc
        
        # Collect all meta tags from HTML document
        @doc.css('head > meta').each do |meta_tag|
            # Check the tag is allowed or not
            if meta_tag['charset'] || @allowed_meta_names.include?(meta_tag['name']) || @allowed_meta_names.include?(meta_tag['property'])
                # If allowed then we keep it...
                next
            else
                # ... or remove it.
                meta_tag.remove
            end
        end
    end

end