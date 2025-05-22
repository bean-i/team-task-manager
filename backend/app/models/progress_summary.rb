class ProgressSummary < ApplicationRecord
  belongs_to :workspace
  belongs_to :user, optional: true
end
