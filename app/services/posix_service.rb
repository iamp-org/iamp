class PosixService
  # Generate unique identifier in the defined range for Posix account.
  def self.generate_unique_uid_number
    range_start = 10_001
    range_end = 50_000
    loop do
      random_number = rand(range_start..range_end).to_s
      break random_number unless User.exists?(uid_number: random_number)
    end
  end
end