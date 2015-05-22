module Pagingable
  extend ActiveSupport::Concern
  private
  def pagination_values
    offset = (params[:offset] || 0).to_i
    # Set limit to supplied value if any otherwise default to 10
    # max limit 100 per request
    limit =  (params[:limit] || 10).to_i
    limit = 100 if limit > 100
    return offset, limit
  end
end
