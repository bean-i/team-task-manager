module CustomErrors
  class AuthenticationError < StandardError; end  # 401
  class AuthorizationError < StandardError; end   # 403
  class ResourceNotFound < StandardError; end     # 404
  class ValidationError < StandardError; end      # 422
end 