# Pagy Frontend module for Rails views
module PagyFrontend
  def pagy_nav(pagy)
    return '' if pagy.pages <= 1

    html = '<nav class="pagy-nav"><ul class="pagy-nav">'
    
    # Previous link
    if pagy.previous
      html += "<li class=\"prev\"><a href=\"#{pagy_url_for(pagy.previous)}\" rel=\"prev\">&#8592; Previous</a></li>"
    else
      html += '<li class="prev disabled"><span>&#8592; Previous</span></li>'
    end

    # Generate page numbers series
    series = generate_series(pagy)
    series.each do |item|
      if item.is_a?(Integer) || item.is_a?(String)
        page_num = item.to_i
        if page_num == pagy.page
          html += "<li class=\"page active\"><span>#{item}</span></li>"
        else
          html += "<li class=\"page\"><a href=\"#{pagy_url_for(page_num)}\">#{item}</a></li>"
        end
      elsif item == :gap
        html += '<li class="page gap"><span>&hellip;</span></li>'
      end
    end

    # Next link - use instance_variable_get to access @next
    next_page = pagy.instance_variable_get(:@next)
    if next_page
      html += "<li class=\"next\"><a href=\"#{pagy_url_for(next_page)}\" rel=\"next\">Next &#8594;</a></li>"
    else
      html += '<li class="next disabled"><span>Next &#8594;</span></li>'
    end

    html += '</ul></nav>'
    html.html_safe
  end

  def pagy_url_for(page)
    # Use root_path for public index page to ensure pagination links use /?page=X instead of /public?page=X
    if controller.is_a?(PublicController) && controller.action_name == 'index'
      params_with_page = request.params.merge(page: page).except(:controller, :action)
      root_path(params_with_page)
    else
      url_for(request.params.merge(page: page))
    end
  end

  private

  # Generate series of page numbers similar to Pagy's series method
  def generate_series(pagy, slots: 7)
    pages = pagy.pages
    current_page = pagy.page
    
    return (1..pages).to_a if slots >= pages

    half = (slots - 1) / 2
    start = if current_page <= half
              1
            elsif current_page > (pages - slots + half)
              pages - slots + 1
            else
              current_page - half
            end

    series = (start...(start + slots)).to_a
    
    # Add gaps and ensure first/last pages are shown
    unless slots < 7
      series[0] = 1
      series[1] = :gap unless series[1] == 2
      series[-2] = :gap unless series[-2] == pages - 1
      series[-1] = pages
    end

    # Mark current page as string
    current_index = series.index(current_page)
    series[current_index] = current_page.to_s if current_index

    series
  end
end

