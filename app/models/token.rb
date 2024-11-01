class Token < ApplicationRecord
  belongs_to :user

  # Generate a JWT token for a user and store its hashed version
  def self.generate_token(user)
    expiration = 1.year.from_now
    payload = {
      user_id: user.id,
      exp: expiration.to_i
    }

    token = JWT.encode(payload, Rails.application.secrets.secret_key_base)
    hashed_token = Digest::SHA256.hexdigest(token) # Hash the token

    # Store the hashed token instead of plaintext
    Token.create(user: user, token: hashed_token, expires_at: expiration)

    token # Return the original token (not hashed) to the user
  end

  # Verify the token by comparing its hash with the stored hash
  def self.verify_token(token)
    hashed_token = Digest::SHA256.hexdigest(token)
    Token.find_by(token: hashed_token)
  end

  # Decode and validate the JWT token
  def self.decode_token(token)
    begin
      decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base).first
      HashWithIndifferentAccess.new(decoded_token)
    rescue JWT::DecodeError
      nil
    end
  end
end
