class User < ActiveRecord::Base
  validates :username, :email, presence: true, uniqueness: true
  validates :birthdate, :description, :gender, presence: true
  validates :password, length: { minimum: 6 }
  validate  :validate_birthdate

  def validate_birthdate
    if birthdate > 0.days.ago
      errors.add(:birthdate, 'Cannot be born in the future')
    end
  end

end
