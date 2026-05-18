class AddReportNotesToMessagesAndDirectMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages,        :report_notes, :text
    add_column :direct_messages, :report_notes, :text
  end
end
