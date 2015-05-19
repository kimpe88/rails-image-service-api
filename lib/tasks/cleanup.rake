namespace :cleanup do
  desc "Removes all CarrierWave uploades"
  task uploads: :environment do
    FileUtils.rm_rf(CarrierWave::Uploader::Base.root.call + "/uploads/post/")
    FileUtils.rm_rf(CarrierWave::Uploader::Base.root.call + "/uploads/tmp/")
  end
end
