class Image < ActiveRecord::Base
	# adds an `image` virtual attribute
	include ::PhotoUploader::Attachment.new(:image)
end
