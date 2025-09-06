# frozen_string_literal: true

# URLs in HTML attributes
def rewrite_html_attr_urls(content)
  content.gsub!(/(\s(?:href|src|action|data-src|data-url|content)=["'])(https?:)?\/\/web\.archive\.org\/web\/[0-9]+(?:[a-z_]+)?\/(https?:\/\/[^"']+)(["'])/i) do
    prefix, original_proto, inner_url, suffix = $1, $2, $3, $4

    puts "Inner URL: #{inner_url}\r\n"

    # Ha nincs megadva protokoll, adj hozzá
    "#{prefix}#{inner_url.start_with?('http') ? inner_url : 'https://' + inner_url.sub(%r{^//}, '')}#{suffix}"
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
  
  content.gsub!(/(["'])\/\/web\.archive\.org\/web\/\d+(?:[a-z_]+)?\/(https?:\/\/[^"']+)(["'])/i) do
    quote_start, inner_url, quote_end = $1, $2, $3
    "#{quote_start}#{inner_url}#{quote_end}"
  end
  
  content
end