# An individual model offered by a tool (e.g. Claude → Sonnet / Opus / Fable).
# Variants are evidence on the product, not search results in their own right:
# the hard filter and weighted pick operate on tools only, and variants are
# surfaced on result cards, the detail page, and (later) compare.
class ModelVariant < ApplicationRecord
  include Scoreable

  OVERALL_PERFORMANCE_WEIGHT = 0.8
  OVERALL_VALUE_WEIGHT = 0.2
  API_VALUE_FLOOR_PER_DOLLAR = 250.0
  API_VALUE_CEILING_PER_DOLLAR = 20_000.0

  belongs_to :tool, inverse_of: :model_variants
  has_many :evaluation_notes,
    class_name: "ModelEvaluationNote",
    dependent: :destroy,
    inverse_of: :model_variant

  validates :name, presence: true, uniqueness: { scope: :tool_id }

  scope :ordered, -> { order(:position, :id) }

  def scored?
    output_quality.present?
  end

  def performance_verdict
    return nil unless scored?

    verdict_with(extra_scores: tool.rubric_field_values)
  end

  # The headline model score: mostly performance, with token-priced value as a
  # smaller adjustment when usage and API pricing data are available.
  def verdict
    overall_score(raw_score: performance_verdict)
  end

  def overall_score(raw_score:)
    return nil if raw_score.nil?

    value_score = value_overall_score(raw_score:)
    return raw_score.to_f if value_score.nil?

    (
      raw_score.to_f * OVERALL_PERFORMANCE_WEIGHT +
      value_score * OVERALL_VALUE_WEIGHT
    ).clamp(1.0, 10.0)
  end

  def performance_per_1k_tokens(raw_score: performance_verdict)
    tokens = numeric(avg_total_tokens)
    return nil if raw_score.nil? || tokens.nil? || tokens <= 0

    raw_score.to_f / tokens * 1_000.0
  end

  def api_cost_per_run
    tokens = numeric(avg_total_tokens)
    price = api_blended_price_per_million
    return nil if tokens.nil? || tokens <= 0 || price.nil? || price <= 0

    tokens / 1_000_000.0 * price
  end

  def api_performance_per_dollar(raw_score: performance_verdict)
    cost = api_cost_per_run
    return nil if raw_score.nil? || cost.nil? || cost <= 0

    raw_score.to_f / cost
  end

  def api_performance_per_dollar_score(raw_score: performance_verdict)
    metric = api_performance_per_dollar(raw_score:)
    return nil if metric.nil?

    log_value_score(
      metric,
      floor: API_VALUE_FLOOR_PER_DOLLAR,
      ceiling: API_VALUE_CEILING_PER_DOLLAR
    )
  end

  def value_overall_score(raw_score: performance_verdict)
    api_performance_per_dollar_score(raw_score:)
  end

  # "$3 in / $15 out per 1M tokens" — mirrors Tool#price_summary.
  def price_summary
    return nil if input_usd_per_m.blank? && output_usd_per_m.blank?

    parts = []
    parts << "$#{format_price(input_usd_per_m)} in"   if input_usd_per_m.present?
    parts << "$#{format_price(output_usd_per_m)} out" if output_usd_per_m.present?
    [parts.join(" / "), pricing_unit].compact_blank.join(" ")
  end

  # Tooltip text for the compact chip on result cards.
  def chip_title
    [price_summary, best_for].compact_blank.join(" — ")
  end

  private

  def log_value_score(value, floor:, ceiling:)
    return nil if value.nil? || value <= 0 || floor <= 0 || ceiling <= floor

    bounded = value.to_f.clamp(floor, ceiling)
    ratio = (Math.log(bounded) - Math.log(floor)) / (Math.log(ceiling) - Math.log(floor))
    (1.0 + ratio * 9.0).clamp(1.0, 10.0)
  end

  def api_blended_price_per_million
    prices = [input_usd_per_m, output_usd_per_m].filter_map { |price| numeric(price) }
    return nil if prices.empty?

    prices.sum / prices.size
  end

  def numeric(value)
    return nil if value.blank?

    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  # Trim trailing zeros so a decimal(12,4) column reads "$3", not "$3.0000".
  def format_price(value)
    value.to_f % 1 == 0 ? value.to_i.to_s : value.to_f.to_s
  end
end
