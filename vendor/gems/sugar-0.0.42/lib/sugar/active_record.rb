module Sugar
  module ActiveRecord
    def slug
      read_attribute(:slug) || to_s && write_attribute(:slug, to_s.parameterize) && read_attribute(:slug)
    end

    def to_param
      slug.present? ? "#{id}-#{slug}" : id.to_s
    end
  end
end
