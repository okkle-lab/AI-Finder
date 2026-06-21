class SetWhisperLogoDomain < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL.squish
      UPDATE tools
      SET logo_domain = 'openai.com'
      WHERE name = 'Whisper'
        AND (logo_domain IS NULL OR logo_domain = '')
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE tools
      SET logo_domain = NULL
      WHERE name = 'Whisper'
        AND logo_domain = 'openai.com'
    SQL
  end
end
