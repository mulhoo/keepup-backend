class CreateSafetyReviewSignals < ActiveRecord::Migration[8.0]
  def change
    create_table :safety_review_signals do |t|
      t.references :school,         null: false, foreign_key: true
      # null = signal applies across all sports at this school (rare but valid)
      t.references :sport_template, null: true,  foreign_key: true

      # Gemma's on-device category label — no message content, just the classification
      # e.g. "competitive_aggression", "profanity_mild", "bullying", "self_harm_ideation"
      t.string  :category,         null: false
      t.integer :decision,         null: false   # 0=approved, 1=rejected
      t.string  :sender_role,      null: false   # student / head_coach / assistant_coach / parent
      t.string  :channel_type                    # broadcast / dm / general / athletes_only
      # How confident Gemma was before escalating (0.0–1.0). Lower = more uncertain.
      t.float   :gemma_confidence

      t.timestamps
    end

    # Primary lookup: "for this school + sport + category, what's the approval history?"
    add_index :safety_review_signals, [ :school_id, :sport_template_id, :category ],
              name: "index_srs_on_school_sport_category"
    add_index :safety_review_signals, :created_at
  end
end
