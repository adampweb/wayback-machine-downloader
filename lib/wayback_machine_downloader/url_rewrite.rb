# frozen_string_literal: true

# URLs in HTML attributes
def rewrite_html_attr_urls(content)
  
  content.gsub!(/(\s(?:href|src|action|data-src|data-url)=["'])https?:\/\/web\.archive\.org\/web\/[0-9]+(?:id_)?\/([^"']+)(["'])/i) do
    prefix, url, suffix = $1, $2, $3
    
    if url.start_with?('http')
      begin
        uri = URI.parse(url)
        path = uri.path
        path = path[1..-1] if path.start_with?('/')
        "#{prefix}#{path}#{suffix}"
      rescue
        "#{prefix}#{url}#{suffix}"
      end
    elsif url.start_with?('/')
      "#{prefix}./#{url[1..-1]}#{suffix}"
    else
      "#{prefix}#{url}#{suffix}"
    end
  end
  content
end

# URLs in CSS
def rewrite_css_urls(content)

  content.gsub!(/url\(\s*["']?https?:\/\/web\.archive\.org\/web\/[0-9]+(?:id_)?\/([^"'\)]+)["']?\s*\)/i) do
    url = $1
    
    if url.start_with?('http')
      begin
        uri = URI.parse(url)
        path = uri.path
        path = path[1..-1] if path.start_with?('/')
        "url(\"#{path}\")"
      rescue
        "url(\"#{url}\")"
      end
    elsif url.start_with?('/')
      "url(\"./#{url[1..-1]}\")"
    else
      "url(\"#{url}\")"
    end
  end
  content
end

# URLs in JavaScript
def rewrite_js_urls(content)
  
  content.gsub!(/(["'])https?:\/\/web\.archive\.org\/web\/[0-9]+(?:id_)?\/([^"']+)(["'])/i) do
    quote_start, url, quote_end = $1, $2, $3
    
    if url.start_with?('http')
      begin
        uri = URI.parse(url)
        path = uri.path
        path = path[1..-1] if path.start_with?('/')
        "#{quote_start}#{path}#{quote_end}"
      rescue
        "#{quote_start}#{url}#{quote_end}"
      end
    elsif url.start_with?('/')
      "#{quote_start}./#{url[1..-1]}#{quote_end}"
    else
      "#{quote_start}#{url}#{quote_end}"
    end
  end
  
  content
end