class Rubric
  # Single source of truth for scores that participate in search ranking and
  # overall verdicts. Adding a future rubric dimension should start here, then
  # add the matching database column and CSV header.
  DIMENSIONS = {
    "text_generation" => {
      label: "Text generation",
      short_label: "Text",
      field: :score_text_generation,
      level: :model,
      group: :output,
      intent_words: %w[write writing draft drafting edit editing rewrite rewriting blog blogs article articles essay essays copy copywriting content caption captions post posts story stories newsletter newsletters],
      intent_phrases: ["write for me", "help me write", "draft a", "rewrite a", "improve my writing", "social media post", "blog post"]
    },
    "email_writing" => {
      label: "Email writing",
      short_label: "Email",
      field: :score_email_writing,
      level: :model,
      group: :output,
      intent_words: %w[email emails reply replies outreach inbox newsletter newsletters],
      intent_phrases: ["write email", "write emails", "write an email", "draft email", "draft an email", "reply to email", "reply to emails", "email reply", "cold email", "sales email"]
    },
    "logic" => {
      label: "Logic",
      short_label: "Logic",
      field: :score_logic,
      level: :model,
      group: :output,
      intent_words: %w[reason reasoning logic maths math mathematics analyze analyse analysis solve solving problem problems compare comparing plan planning strategy spreadsheet spreadsheets],
      intent_phrases: ["think through", "work through", "solve a problem", "do math", "data analysis", "make a plan"]
    },
    "coding" => {
      label: "Coding",
      short_label: "Coding",
      field: :score_coding,
      level: :model,
      group: :output,
      intent_words: %w[code coding program programming developer develop debug debugging software script scripts javascript typescript python ruby rails react api bug bugs error errors stacktrace refactor refactoring],
      intent_phrases: ["write code", "review code", "debug code", "fix code", "fix a bug", "build an app", "build a website", "make a website", "web app", "code review"]
    },
    "image_generation" => {
      label: "Image generation",
      short_label: "Image",
      field: :score_image_generation,
      level: :model,
      group: :output,
      intent_words: %w[image images picture pictures photo photos art artwork illustration illustrations logo logos design designs poster posters avatar avatars graphic graphics],
      intent_phrases: ["generate images", "create images", "make images", "make a logo", "design a logo", "ai art", "product mockup"]
    },
    "accuracy" => {
      label: "Accuracy & trustworthiness",
      short_label: "Accuracy",
      field: :score_accuracy,
      level: :model,
      group: :gate,
      intent_words: %w[research cite cites citation citations source sources factual accurate accuracy facts factcheck factchecking trustworthy trust verify verification reference references study studies],
      intent_phrases: ["find sources", "cite sources", "with citations", "fact check", "fact-check", "up to date", "trustworthy answer"]
    },
    "ease_of_use" => {
      label: "Ease of use",
      short_label: "Ease",
      field: :ease_score,
      level: :tool,
      group: :product,
      intent_words: %w[easy simple beginner beginner-friendly nontechnical non-technical quick straightforward intuitive],
      intent_phrases: ["easy to use", "simple to use", "beginner friendly", "no setup", "quick setup", "just works"]
    },
    "privacy" => {
      label: "Privacy & data safety",
      short_label: "Privacy",
      field: :privacy_score,
      level: :tool,
      group: :product,
      intent_words: %w[private privacy confidential sensitive secure local locally offline on-device],
      intent_phrases: ["data safety", "no data retention", "doesn't keep my data", "does not keep my data", "don't keep my data", "do not keep my data", "not store my data", "runs locally", "on my computer"]
    }
  }.freeze

  OUTPUT_DIMENSIONS = DIMENSIONS.select { |_key, config| config[:group] == :output }.freeze
  OUTPUT_FIELDS = OUTPUT_DIMENSIONS.to_h { |_key, config| [config[:label], config[:field]] }.freeze
  PRODUCT_FIELDS = DIMENSIONS.filter_map { |_key, config| config[:field] if config[:group] == :product }.freeze
  GATE_FIELDS = DIMENSIONS.filter_map { |_key, config| config[:field] if config[:group] == :gate }.freeze
  SCORE_FIELDS = DIMENSIONS.values.map { |config| config[:field] }.uniq.freeze
  PRIORITY_DIMENSIONS = DIMENSIONS.to_h { |dimension, config| [dimension, config[:field]] }.freeze
end
