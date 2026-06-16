module ApplicationHelper
  # Format a 1-10 score/verdict: "8.4", "9", or nil.
  def score_number(value)
    return nil if value.nil?

    n = value.to_f.round(1)
    (n % 1).zero? ? n.to_i.to_s : n.to_s
  end

  # A score cell that falls back to an em dash when unrated.
  def score_or_dash(value)
    score_number(value) || content_tag(:span, "—", class: "score-none", title: "Not yet rated")
  end

  # A visible 1-10 score coloured by the same red→green scale.
  def colored_score(value, css_class: nil)
    return score_or_dash(value) if value.nil?

    content_tag(:span, score_number(value), class: css_class, style: "color: #{score_color(value)}")
  end

  # Colour a 1-10 score on a red→green scale: 1 is red, 10 is green.
  def score_color(value)
    return nil if value.nil?

    n = value.to_f.clamp(1.0, 10.0)
    hue = ((n - 1) / 9.0 * 120).round # 0 = red, 120 = green
    "hsl(#{hue}, 72%, 42%)"
  end
end
