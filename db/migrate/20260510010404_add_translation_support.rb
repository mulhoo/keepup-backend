class AddTranslationSupport < ActiveRecord::Migration[8.0]
  def change
    # User's preferred reading language — nil means English (no translation needed)
    add_column :users, :preferred_language, :string

    # Cache translated message content so Gemma is only called once per language per message
    create_table :message_translations do |t|
      t.references :message, null: false, foreign_key: true
      t.string     :language,        null: false  # BCP-47 code: "es", "zh-CN"
      t.text       :translated_text, null: false
      t.timestamps
    end
    add_index :message_translations, %i[message_id language], unique: true
  end
end
