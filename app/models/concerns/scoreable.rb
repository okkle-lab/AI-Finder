# Shared score math for Tool (its "one model") and ModelVariant (a specific
# model). Rubric metadata lives in Rubric; this concern only applies it.
module Scoreable
  extend ActiveSupport::Concern

  # Average of whichever output sub-scores are filled (nil if none yet).
  def output_quality
    vals = Rubric::OUTPUT_FIELDS.values.filter_map { |field| public_send(field) }
    vals.any? ? vals.sum.to_f / vals.size : nil
  end

  # Gated verdict (1-10): average of output quality + the given ease & privacy,
  # capped by accuracy (a low accuracy score caps everything). Requires this
  # record's own output quality or accuracy — ease/privacy alone don't make a
  # verdict. nil = not yet rated.
  def verdict_with(product_scores: nil, ease: nil, privacy: nil)
    gate_scores = Rubric::GATE_FIELDS.filter_map { |field| public_send(field) if respond_to?(field) }
    return nil if output_quality.nil? && gate_scores.empty?

    product_scores ||= [ease, privacy]
    parts = [output_quality, *product_scores].compact
    base = parts.empty? ? nil : parts.sum.to_f / parts.size

    if gate_scores.any?
      gate = gate_scores.min.to_f
      base ? [base, gate].min : gate
    else
      base
    end
  end
end
