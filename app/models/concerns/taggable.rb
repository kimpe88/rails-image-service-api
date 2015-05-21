module Taggable
  extend ActiveSupport::Concern
  # Sets up correct associations for a post
  # @param {Array} tags - Tags for the post
  # @param {Array} users_tagged - Users to be tagged in the post
  def create_assoc_and_save(tags = [], users_tagged = [])
    tags = [tags] unless tags.respond_to?('each')
    users_tagged = [users_tagged] unless users_tagged.respond_to?('each')
    self.tags = tags
    user_tag_args = {}
    users_tagged.each do |user|
      user_tag_args[self.class.name.downcase.to_sym] = self
      user_tag_args[:user] = user
      UserTag.create!(user_tag_args)
    end
    self.save!
  end
end
